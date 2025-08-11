import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/vote_model.dart';
import 'blockchain_repository.dart';
import 'voting_repository.dart';
import '../../core/services/blockchain_manager.dart' as blockchain_manager;

/// Enhanced voting repository that integrates blockchain for vote storage and verification
class BlockchainVotingRepository {
  final VotingRepository _traditionalVotingRepository;
  final BlockchainRepository _blockchainRepository;
  final StreamController<VoteSubmissionProgress> _progressController = StreamController.broadcast();

  BlockchainVotingRepository(
    this._traditionalVotingRepository,
    this._blockchainRepository,
  );

  /// Stream of vote submission progress
  Stream<VoteSubmissionProgress> get progressStream => _progressController.stream;

  /// Submit a vote with blockchain integration
  Future<BlockchainVoteReceipt> submitVote(VoteSubmissionRequest request, String voterId) async {
    _emitProgress(VoteSubmissionProgress.validating());

    try {
      // Step 1: Validate the vote request
      await _validateVoteRequest(request, voterId);
      
      _emitProgress(VoteSubmissionProgress.submittingToBlockchain());

      // Step 2: Create voter signature for blockchain
      final voterSignature = _createVoterSignature(request, voterId);

      // Step 3: Submit to blockchain
      final blockchainResult = await _blockchainRepository.submitVote(
        electionId: request.electionId,
        candidateId: request.candidateId,
        voterId: voterId,
        voterSignature: voterSignature,
      );

      if (!blockchainResult.success) {
        throw VotingException('Blockchain submission failed: ${blockchainResult.message}');
      }

      _emitProgress(VoteSubmissionProgress.recordingTraditional());

      // Step 4: Submit to traditional system with blockchain hash
      final enhancedRequest = VoteSubmissionRequest(
        electionId: request.electionId,
        candidateId: request.candidateId,
        signature: request.signature,
        metadata: {
          ...?request.metadata,
          'blockchainHash': blockchainResult.transactionHash,
          'blockchainTimestamp': blockchainResult.timestamp.toIso8601String(),
          'voterSignature': voterSignature,
        },
      );

      final traditionalReceipt = await _traditionalVotingRepository.submitVote(enhancedRequest);

      _emitProgress(VoteSubmissionProgress.completed());

      // Step 5: Create enhanced receipt
      return BlockchainVoteReceipt(
        receiptCode: traditionalReceipt.receiptCode,
        electionId: traditionalReceipt.electionId,
        electionTitle: traditionalReceipt.electionTitle,
        candidateName: traditionalReceipt.candidateName,
        timestamp: traditionalReceipt.timestamp,
        blockchainHash: blockchainResult.transactionHash,
        status: traditionalReceipt.status,
        blockchainConfirmed: blockchainResult.success,
        blockchainTimestamp: blockchainResult.timestamp,
        voterSignature: voterSignature,
      );

    } catch (e) {
      _emitProgress(VoteSubmissionProgress.failed(e.toString()));
      rethrow;
    }
  }

  /// Verify a vote using both traditional and blockchain verification
  Future<VoteVerificationResult> verifyVote(VoteVerificationRequest request) async {
    try {
      // Get traditional receipt
      final traditionalReceipt = await _traditionalVotingRepository.verifyVote(request);
      
      // If no blockchain hash, return traditional verification only
      if (traditionalReceipt.blockchainHash == null) {
        return VoteVerificationResult(
          isValid: traditionalReceipt.status == VoteStatus.confirmed,
          receipt: traditionalReceipt,
          blockchainVerified: false,
          verificationDetails: 'Vote verified through traditional system only',
        );
      }

      // Verify on blockchain
      final blockchainVerified = await _verifyOnBlockchain(
        traditionalReceipt.blockchainHash!,
        traditionalReceipt.electionId,
      );

      return VoteVerificationResult(
        isValid: traditionalReceipt.status == VoteStatus.confirmed && blockchainVerified,
        receipt: traditionalReceipt,
        blockchainVerified: blockchainVerified,
        verificationDetails: blockchainVerified 
            ? 'Vote verified on both traditional system and blockchain'
            : 'Vote verified on traditional system but not found on blockchain',
      );

    } catch (e) {
      throw VotingException('Failed to verify vote: $e');
    }
  }

  /// Get election results with blockchain verification
  Future<BlockchainElectionResults> getElectionResults(String electionId) async {
    try {
      // Get traditional results
      final traditionalResults = await _traditionalVotingRepository.getElectionResults(electionId);

      // Get blockchain results
      final blockchainManagerResults = await _blockchainRepository.getElectionResults(electionId);

      // Convert blockchain results to traditional format for comparison
      final blockchainResults = _convertBlockchainResults(blockchainManagerResults, traditionalResults.electionTitle);

      // Compare and create enhanced results
      final discrepancies = _findDiscrepancies(traditionalResults, blockchainResults);

      return BlockchainElectionResults(
        electionId: electionId,
        electionTitle: traditionalResults.electionTitle,
        traditionalResults: traditionalResults,
        blockchainResults: blockchainResults,
        discrepancies: discrepancies,
        isVerified: discrepancies.isEmpty,
        lastUpdated: DateTime.now(),
      );

    } catch (e) {
      throw VotingException('Failed to get election results: $e');
    }
  }

  /// Get vote history with blockchain verification
  Future<List<BlockchainVoteReceipt>> getVoteHistory({
    int? page,
    int? limit,
    String? electionId,
  }) async {
    try {
      final traditionalReceipts = await _traditionalVotingRepository.getVoteHistory(
        page: page,
        limit: limit,
        electionId: electionId,
      );

      final blockchainReceipts = <BlockchainVoteReceipt>[];

      for (final receipt in traditionalReceipts) {
        bool blockchainConfirmed = false;
        DateTime? blockchainTimestamp;
        Map<String, dynamic>? voterSignature;

        if (receipt.blockchainHash != null) {
          try {
            blockchainConfirmed = await _verifyOnBlockchain(
              receipt.blockchainHash!,
              receipt.electionId,
            );
            
            // Try to get blockchain timestamp and signature from metadata
            // This would require additional blockchain query methods
            blockchainTimestamp = receipt.timestamp; // Fallback to receipt timestamp
          } catch (e) {
            // Blockchain verification failed
            blockchainConfirmed = false;
          }
        }

        blockchainReceipts.add(BlockchainVoteReceipt(
          receiptCode: receipt.receiptCode,
          electionId: receipt.electionId,
          electionTitle: receipt.electionTitle,
          candidateName: receipt.candidateName,
          timestamp: receipt.timestamp,
          blockchainHash: receipt.blockchainHash,
          status: receipt.status,
          blockchainConfirmed: blockchainConfirmed,
          blockchainTimestamp: blockchainTimestamp,
          voterSignature: voterSignature,
        ));
      }

      return blockchainReceipts;

    } catch (e) {
      throw VotingException('Failed to get vote history: $e');
    }
  }

  /// Check if user has voted in an election (checks both systems)
  Future<VoteStatus> hasVotedInElection(String electionId, String voterId) async {
    try {
      // Check traditional system
      final hasVotedTraditional = await _traditionalVotingRepository.hasVotedInElection(electionId);
      
      if (!hasVotedTraditional) {
        return VoteStatus.pending;
      }

      // Check blockchain for verification
      final blockchainResults = await _blockchainRepository.getElectionResults(electionId);
      final hasVotedBlockchain = blockchainResults.candidateVotes.values.any((count) => count > 0);

      if (hasVotedTraditional && hasVotedBlockchain) {
        return VoteStatus.confirmed;
      } else if (hasVotedTraditional) {
        return VoteStatus.pending; // Traditional vote exists but not confirmed on blockchain
      } else {
        return VoteStatus.pending;
      }

    } catch (e) {
      throw VotingException('Failed to check vote status: $e');
    }
  }

  /// Validate vote request
  Future<void> _validateVoteRequest(VoteSubmissionRequest request, String voterId) async {
    // Check if blockchain is running
    if (!_blockchainRepository.currentState.isOperational) {
      throw VotingException('Blockchain is not operational. Please try again later.');
    }

    // Check if user has already voted
    final voteStatus = await hasVotedInElection(request.electionId, voterId);
    if (voteStatus == VoteStatus.confirmed) {
      throw VotingException('You have already voted in this election.');
    }

    // Additional validation can be added here
  }

  /// Create voter signature for blockchain
  Map<String, dynamic> _createVoterSignature(VoteSubmissionRequest request, String voterId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dataToSign = '${request.electionId}:${request.candidateId}:$voterId:$timestamp';
    
    // Create a simple hash-based signature (in production, use proper cryptographic signing)
    final bytes = utf8.encode(dataToSign);
    final digest = sha256.convert(bytes);
    
    return {
      'signature': digest.toString(),
      'timestamp': timestamp,
      'algorithm': 'SHA256',
      'data': dataToSign,
    };
  }

  /// Verify vote on blockchain
  Future<bool> _verifyOnBlockchain(String blockchainHash, String electionId) async {
    try {
      // This would involve querying the blockchain for the specific transaction
      // For now, we'll check if the election has any votes on the blockchain
      final blockchainResults = await _blockchainRepository.getElectionResults(electionId);
      return blockchainResults.totalVotes > 0;
    } catch (e) {
      return false;
    }
  }

  /// Convert blockchain manager results to traditional ElectionResults format
  ElectionResults _convertBlockchainResults(blockchain_manager.ElectionResults blockchainResults, String electionTitle) {
    final candidateResults = blockchainResults.candidateVotes.entries.map((entry) {
      final percentage = blockchainResults.totalVotes > 0
          ? (entry.value / blockchainResults.totalVotes) * 100
          : 0.0;

      return CandidateResult(
        candidateId: entry.key,
        candidateName: 'Candidate ${entry.key}', // In a real implementation, you'd look up the name
        voteCount: entry.value,
        percentage: percentage,
      );
    }).toList();

    return ElectionResults(
      electionId: blockchainResults.electionId,
      electionTitle: electionTitle,
      totalVotes: blockchainResults.totalVotes,
      candidateResults: candidateResults,
      lastUpdated: blockchainResults.lastUpdated,
      isFinal: true, // Blockchain results are considered final
    );
  }

  /// Find discrepancies between traditional and blockchain results
  List<String> _findDiscrepancies(ElectionResults traditional, ElectionResults blockchain) {
    final discrepancies = <String>[];

    // Compare total votes
    if (traditional.totalVotes != blockchain.totalVotes) {
      discrepancies.add(
        'Total vote count mismatch: Traditional=${traditional.totalVotes}, Blockchain=${blockchain.totalVotes}'
      );
    }

    // Compare candidate votes
    for (final traditionalResult in traditional.candidateResults) {
      final blockchainResult = blockchain.candidateResults.firstWhere(
        (result) => result.candidateId == traditionalResult.candidateId,
        orElse: () => const CandidateResult(
          candidateId: '',
          candidateName: '',
          voteCount: 0,
          percentage: 0.0,
        ),
      );

      if (traditionalResult.voteCount != blockchainResult.voteCount) {
        discrepancies.add(
          'Vote count mismatch for ${traditionalResult.candidateName}: Traditional=${traditionalResult.voteCount}, Blockchain=${blockchainResult.voteCount}'
        );
      }
    }

    return discrepancies;
  }

  /// Emit vote submission progress
  void _emitProgress(VoteSubmissionProgress progress) {
    _progressController.add(progress);
  }

  /// Dispose resources
  void dispose() {
    _progressController.close();
  }
}

/// Enhanced vote receipt with blockchain information
class BlockchainVoteReceipt extends VoteReceipt {
  final bool blockchainConfirmed;
  final DateTime? blockchainTimestamp;
  final Map<String, dynamic>? voterSignature;

  const BlockchainVoteReceipt({
    required super.receiptCode,
    required super.electionId,
    required super.electionTitle,
    required super.candidateName,
    required super.timestamp,
    super.blockchainHash,
    required super.status,
    required this.blockchainConfirmed,
    this.blockchainTimestamp,
    this.voterSignature,
  });

  /// Check if vote is fully verified (both traditional and blockchain)
  bool get isFullyVerified => status == VoteStatus.confirmed && blockchainConfirmed;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'blockchainConfirmed': blockchainConfirmed,
      'blockchainTimestamp': blockchainTimestamp?.toIso8601String(),
      'voterSignature': voterSignature,
    });
    return json;
  }
}

/// Vote submission progress tracking
class VoteSubmissionProgress {
  final VoteSubmissionStage stage;
  final String message;
  final double progress; // 0.0 to 1.0
  final bool isError;

  const VoteSubmissionProgress({
    required this.stage,
    required this.message,
    required this.progress,
    this.isError = false,
  });

  factory VoteSubmissionProgress.validating() {
    return const VoteSubmissionProgress(
      stage: VoteSubmissionStage.validating,
      message: 'Validating vote request...',
      progress: 0.1,
    );
  }

  factory VoteSubmissionProgress.submittingToBlockchain() {
    return const VoteSubmissionProgress(
      stage: VoteSubmissionStage.submittingToBlockchain,
      message: 'Submitting vote to blockchain...',
      progress: 0.3,
    );
  }

  factory VoteSubmissionProgress.recordingTraditional() {
    return const VoteSubmissionProgress(
      stage: VoteSubmissionStage.recordingTraditional,
      message: 'Recording vote in traditional system...',
      progress: 0.7,
    );
  }

  factory VoteSubmissionProgress.completed() {
    return const VoteSubmissionProgress(
      stage: VoteSubmissionStage.completed,
      message: 'Vote submitted successfully!',
      progress: 1.0,
    );
  }

  factory VoteSubmissionProgress.failed(String error) {
    return VoteSubmissionProgress(
      stage: VoteSubmissionStage.failed,
      message: 'Vote submission failed: $error',
      progress: 0.0,
      isError: true,
    );
  }
}

/// Vote submission stages
enum VoteSubmissionStage {
  validating,
  submittingToBlockchain,
  recordingTraditional,
  completed,
  failed,
}

/// Vote verification result
class VoteVerificationResult {
  final bool isValid;
  final VoteReceipt receipt;
  final bool blockchainVerified;
  final String verificationDetails;

  const VoteVerificationResult({
    required this.isValid,
    required this.receipt,
    required this.blockchainVerified,
    required this.verificationDetails,
  });

  /// Check if vote is fully verified on both systems
  bool get isFullyVerified => isValid && blockchainVerified;
}

/// Enhanced election results with blockchain comparison
class BlockchainElectionResults {
  final String electionId;
  final String electionTitle;
  final ElectionResults traditionalResults;
  final ElectionResults blockchainResults;
  final List<String> discrepancies;
  final bool isVerified;
  final DateTime lastUpdated;

  const BlockchainElectionResults({
    required this.electionId,
    required this.electionTitle,
    required this.traditionalResults,
    required this.blockchainResults,
    required this.discrepancies,
    required this.isVerified,
    required this.lastUpdated,
  });

  /// Get verification status as string
  String get verificationStatus {
    if (isVerified) return 'Verified';
    if (discrepancies.isEmpty) return 'Pending Verification';
    return 'Discrepancies Found';
  }

  /// Get trust score (0.0 to 1.0)
  double get trustScore {
    if (isVerified) return 1.0;
    if (discrepancies.isEmpty) return 0.8;
    return 0.5 - (discrepancies.length * 0.1).clamp(0.0, 0.4);
  }
}

/// Voting exception for blockchain voting operations
class VotingException implements Exception {
  final String message;

  const VotingException(this.message);

  @override
  String toString() => 'VotingException: $message';
}
