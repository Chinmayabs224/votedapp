import 'dart:async';
import 'dart:convert';
import 'blockchain_service.dart';

/// High-level blockchain manager that provides a clean interface for blockchain operations
class BlockchainManager {
  final BlockchainService _blockchainService;
  final StreamController<BlockchainEvent> _eventController = StreamController.broadcast();
  
  Timer? _blockPollingTimer;
  int _lastKnownBlockHeight = -1;
  bool _autoStart = true;
  
  BlockchainManager(this._blockchainService) {
    _initializeEventListeners();
  }

  /// Stream of blockchain events
  Stream<BlockchainEvent> get eventStream => _eventController.stream;

  /// Current blockchain status
  bool get isRunning => _blockchainService.isRunning;

  /// Stream of blockchain status changes
  Stream<BlockchainStatus> get statusStream => _blockchainService.statusStream;

  /// Stream of blockchain logs
  Stream<String> get logStream => _blockchainService.logStream;

  /// Initialize the blockchain manager
  Future<void> initialize({bool autoStart = true}) async {
    _autoStart = autoStart;
    
    if (_autoStart) {
      await startBlockchain();
    }
  }

  /// Start the blockchain
  Future<void> startBlockchain() async {
    try {
      await _blockchainService.start();
      _startBlockPolling();
      _emitEvent(BlockchainEvent.started());
    } catch (e) {
      _emitEvent(BlockchainEvent.error('Failed to start blockchain: $e'));
      rethrow;
    }
  }

  /// Stop the blockchain
  Future<void> stopBlockchain() async {
    try {
      _stopBlockPolling();
      await _blockchainService.stop();
      _emitEvent(BlockchainEvent.stopped());
    } catch (e) {
      _emitEvent(BlockchainEvent.error('Failed to stop blockchain: $e'));
      rethrow;
    }
  }

  /// Submit a vote transaction to the blockchain
  Future<VoteTransactionResult> submitVote({
    required String electionId,
    required String candidateId,
    required String voterId,
    required Map<String, dynamic> voterSignature,
  }) async {
    try {
      if (!_blockchainService.isRunning) {
        throw BlockchainException('Blockchain is not running');
      }

      // Create vote transaction
      final voteTransaction = {
        'type': 'vote',
        'electionId': electionId,
        'candidateId': candidateId,
        'voterId': voterId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'signature': voterSignature,
      };

      // Submit to blockchain
      final result = await _blockchainService.submitTransaction(voteTransaction);
      
      final transactionResult = VoteTransactionResult(
        success: true,
        transactionHash: _generateTransactionHash(voteTransaction),
        message: result,
        timestamp: DateTime.now(),
      );

      _emitEvent(BlockchainEvent.voteSubmitted(transactionResult));
      return transactionResult;
      
    } catch (e) {
      final errorResult = VoteTransactionResult(
        success: false,
        transactionHash: null,
        message: 'Failed to submit vote: $e',
        timestamp: DateTime.now(),
      );
      
      _emitEvent(BlockchainEvent.error(errorResult.message));
      return errorResult;
    }
  }

  /// Get election results from the blockchain
  Future<ElectionResults> getElectionResults(String electionId) async {
    try {
      if (!_blockchainService.isRunning) {
        throw BlockchainException('Blockchain is not running');
      }

      // Get the latest block to determine blockchain height
      final latestBlock = await _blockchainService.getLatestBlock();
      final blockHeight = latestBlock['Height'] as int? ?? 0;

      // Collect votes from all blocks
      final Map<String, int> voteCounts = {};
      int totalVotes = 0;

      for (int height = 0; height <= blockHeight; height++) {
        try {
          final block = await _blockchainService.getBlock(height.toString());
          final transactions = block['TxResponse']['Hashes'] as List<dynamic>? ?? [];

          for (final txHash in transactions) {
            try {
              final tx = await _blockchainService.getTransaction(txHash.toString());
              
              // Check if this is a vote transaction for our election
              if (_isVoteTransaction(tx, electionId)) {
                final candidateId = tx['candidateId'] as String;
                voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
                totalVotes++;
              }
            } catch (e) {
              // Skip invalid transactions
              continue;
            }
          }
        } catch (e) {
          // Skip invalid blocks
          continue;
        }
      }

      return ElectionResults(
        electionId: electionId,
        totalVotes: totalVotes,
        candidateVotes: voteCounts,
        lastUpdated: DateTime.now(),
        blockHeight: blockHeight,
      );

    } catch (e) {
      _emitEvent(BlockchainEvent.error('Failed to get election results: $e'));
      rethrow;
    }
  }

  /// Get blockchain statistics
  Future<BlockchainStats> getBlockchainStats() async {
    try {
      if (!_blockchainService.isRunning) {
        throw BlockchainException('Blockchain is not running');
      }

      final latestBlock = await _blockchainService.getLatestBlock();
      final blockHeight = latestBlock['Height'] as int? ?? 0;
      
      int totalTransactions = 0;
      for (int height = 0; height <= blockHeight; height++) {
        try {
          final block = await _blockchainService.getBlock(height.toString());
          final txCount = block['TxResponse']['TxCount'] as int? ?? 0;
          totalTransactions += txCount;
        } catch (e) {
          // Skip invalid blocks
          continue;
        }
      }

      return BlockchainStats(
        blockHeight: blockHeight,
        totalTransactions: totalTransactions,
        isHealthy: await _blockchainService.isHealthy(),
        lastUpdated: DateTime.now(),
      );

    } catch (e) {
      _emitEvent(BlockchainEvent.error('Failed to get blockchain stats: $e'));
      rethrow;
    }
  }

  /// Initialize event listeners
  void _initializeEventListeners() {
    _blockchainService.statusStream.listen((status) {
      switch (status) {
        case BlockchainStatus.running:
          _startBlockPolling();
          break;
        case BlockchainStatus.stopped:
        case BlockchainStatus.error:
          _stopBlockPolling();
          break;
        default:
          break;
      }
    });
  }

  /// Start polling for new blocks
  void _startBlockPolling() {
    _stopBlockPolling();
    
    _blockPollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        if (!_blockchainService.isRunning) {
          timer.cancel();
          return;
        }

        final latestBlock = await _blockchainService.getLatestBlock();
        final currentHeight = latestBlock['Height'] as int? ?? 0;

        if (currentHeight > _lastKnownBlockHeight) {
          _lastKnownBlockHeight = currentHeight;
          _emitEvent(BlockchainEvent.newBlock(latestBlock));
        }
      } catch (e) {
        // Continue polling even if there's an error
      }
    });
  }

  /// Stop polling for new blocks
  void _stopBlockPolling() {
    _blockPollingTimer?.cancel();
    _blockPollingTimer = null;
  }

  /// Check if a transaction is a vote transaction for the given election
  bool _isVoteTransaction(Map<String, dynamic> tx, String electionId) {
    return tx['type'] == 'vote' && tx['electionId'] == electionId;
  }

  /// Generate a simple transaction hash (in a real implementation, this would be more sophisticated)
  String _generateTransactionHash(Map<String, dynamic> transaction) {
    final jsonString = jsonEncode(transaction);
    return jsonString.hashCode.toRadixString(16);
  }

  /// Emit a blockchain event
  void _emitEvent(BlockchainEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    _stopBlockPolling();
    _eventController.close();
    _blockchainService.dispose();
  }
}

/// Blockchain event types
class BlockchainEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BlockchainEvent._(this.type, this.data) : timestamp = DateTime.now();

  factory BlockchainEvent.started() => BlockchainEvent._('started', {});
  factory BlockchainEvent.stopped() => BlockchainEvent._('stopped', {});
  factory BlockchainEvent.error(String message) => BlockchainEvent._('error', {'message': message});
  factory BlockchainEvent.newBlock(Map<String, dynamic> block) => BlockchainEvent._('newBlock', block);
  factory BlockchainEvent.voteSubmitted(VoteTransactionResult result) => 
    BlockchainEvent._('voteSubmitted', result.toMap());
}

/// Vote transaction result
class VoteTransactionResult {
  final bool success;
  final String? transactionHash;
  final String message;
  final DateTime timestamp;

  VoteTransactionResult({
    required this.success,
    required this.transactionHash,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'transactionHash': transactionHash,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Election results from blockchain
class ElectionResults {
  final String electionId;
  final int totalVotes;
  final Map<String, int> candidateVotes;
  final DateTime lastUpdated;
  final int blockHeight;

  ElectionResults({
    required this.electionId,
    required this.totalVotes,
    required this.candidateVotes,
    required this.lastUpdated,
    required this.blockHeight,
  });
}

/// Blockchain statistics
class BlockchainStats {
  final int blockHeight;
  final int totalTransactions;
  final bool isHealthy;
  final DateTime lastUpdated;

  BlockchainStats({
    required this.blockHeight,
    required this.totalTransactions,
    required this.isHealthy,
    required this.lastUpdated,
  });
}
