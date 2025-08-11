import 'dart:async';
import '../../core/services/blockchain_manager.dart';
import '../../core/services/blockchain_service.dart';
import '../models/blockchain/blockchain_block.dart';
import '../models/blockchain/blockchain_transaction.dart';
import '../models/blockchain/blockchain_state.dart';

/// Repository for blockchain operations following the repository pattern
class BlockchainRepository {
  final BlockchainManager _blockchainManager;
  final StreamController<BlockchainState> _stateController = StreamController.broadcast();
  
  BlockchainState _currentState = BlockchainState.initial();
  Timer? _stateUpdateTimer;

  BlockchainRepository(this._blockchainManager) {
    _initializeStateManagement();
  }

  /// Stream of blockchain state changes
  Stream<BlockchainState> get stateStream => _stateController.stream;

  /// Current blockchain state
  BlockchainState get currentState => _currentState;

  /// Stream of blockchain events
  Stream<BlockchainEvent> get eventStream => _blockchainManager.eventStream;

  /// Stream of blockchain status changes
  Stream<BlockchainStatus> get statusStream => _blockchainManager.statusStream;

  /// Stream of blockchain logs
  Stream<String> get logStream => _blockchainManager.logStream;

  /// Initialize the blockchain repository
  Future<void> initialize({bool autoStart = true}) async {
    try {
      await _blockchainManager.initialize(autoStart: autoStart);
      _startStateUpdates();
    } catch (e) {
      throw BlockchainRepositoryException('Failed to initialize blockchain: $e');
    }
  }

  /// Start the blockchain
  Future<void> startBlockchain() async {
    try {
      await _blockchainManager.startBlockchain();
    } catch (e) {
      throw BlockchainRepositoryException('Failed to start blockchain: $e');
    }
  }

  /// Stop the blockchain
  Future<void> stopBlockchain() async {
    try {
      await _blockchainManager.stopBlockchain();
      _stopStateUpdates();
    } catch (e) {
      throw BlockchainRepositoryException('Failed to stop blockchain: $e');
    }
  }

  /// Submit a vote to the blockchain
  Future<VoteTransactionResult> submitVote({
    required String electionId,
    required String candidateId,
    required String voterId,
    Map<String, dynamic>? voterSignature,
  }) async {
    try {
      final result = await _blockchainManager.submitVote(
        electionId: electionId,
        candidateId: candidateId,
        voterId: voterId,
        voterSignature: voterSignature ?? {},
      );

      // Update local state if vote was successful
      if (result.success) {
        await _updateElectionVotes(electionId);
      }

      return result;
    } catch (e) {
      throw BlockchainRepositoryException('Failed to submit vote: $e');
    }
  }

  /// Get election results from the blockchain
  Future<ElectionResults> getElectionResults(String electionId) async {
    try {
      return await _blockchainManager.getElectionResults(electionId);
    } catch (e) {
      throw BlockchainRepositoryException('Failed to get election results: $e');
    }
  }

  /// Get blockchain statistics
  Future<BlockchainStats> getBlockchainStats() async {
    try {
      return await _blockchainManager.getBlockchainStats();
    } catch (e) {
      throw BlockchainRepositoryException('Failed to get blockchain stats: $e');
    }
  }

  /// Get block by height or hash
  Future<BlockchainBlock> getBlock(String hashOrHeight) async {
    try {
      if (!_blockchainManager.isRunning) {
        throw BlockchainRepositoryException('Blockchain is not running');
      }

      // For now, create a mock block - this will be improved when we add the proper method
      return BlockchainBlock(
        hash: hashOrHeight,
        version: 1,
        dataHash: '',
        prevBlockHash: '',
        height: int.tryParse(hashOrHeight) ?? 0,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        validator: '',
        signature: '',
        txResponse: const BlockTransactionResponse(txCount: 0, hashes: []),
      );
    } catch (e) {
      throw BlockchainRepositoryException('Failed to get block: $e');
    }
  }

  /// Get transaction by hash
  Future<BlockchainTransaction> getTransaction(String hash) async {
    try {
      if (!_blockchainManager.isRunning) {
        throw BlockchainRepositoryException('Blockchain is not running');
      }

      // For now, create a mock transaction - this will be improved when we add the proper method
      return BlockchainTransaction(
        hash: hash,
        value: 0,
        nonce: 0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw BlockchainRepositoryException('Failed to get transaction: $e');
    }
  }

  /// Get recent blocks
  Future<List<BlockchainBlock>> getRecentBlocks({int limit = 10}) async {
    try {
      final stats = await getBlockchainStats();
      final blocks = <BlockchainBlock>[];
      
      final startHeight = stats.blockHeight;
      final endHeight = (startHeight - limit + 1).clamp(0, startHeight);
      
      for (int height = startHeight; height >= endHeight; height--) {
        try {
          final block = await getBlock(height.toString());
          blocks.add(block);
        } catch (e) {
          // Skip blocks that can't be retrieved
          continue;
        }
      }
      
      return blocks;
    } catch (e) {
      throw BlockchainRepositoryException('Failed to get recent blocks: $e');
    }
  }

  /// Get vote transactions for an election
  Future<List<VoteTransaction>> getVoteTransactions(String electionId) async {
    try {
      final stats = await getBlockchainStats();
      final voteTransactions = <VoteTransaction>[];
      
      for (int height = 0; height <= stats.blockHeight; height++) {
        try {
          final block = await getBlock(height.toString());
          
          for (final txHash in block.transactionHashes) {
            try {
              final tx = await getTransaction(txHash);
              
              if (tx.isVoteTransaction && 
                  tx.txInner?.electionId == electionId) {
                voteTransactions.add(VoteTransaction.fromBlockchainTransaction(tx));
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
      
      return voteTransactions;
    } catch (e) {
      throw BlockchainRepositoryException('Failed to get vote transactions: $e');
    }
  }

  /// Check if blockchain is healthy
  Future<bool> isHealthy() async {
    try {
      if (!_blockchainManager.isRunning) return false;

      // For now, just return the running status
      // This will be improved when we add proper health check methods
      return _blockchainManager.isRunning;
    } catch (e) {
      return false;
    }
  }

  /// Initialize state management
  void _initializeStateManagement() {
    // Listen to blockchain events and update state accordingly
    _blockchainManager.eventStream.listen((event) {
      _handleBlockchainEvent(event);
    });

    // Listen to status changes
    _blockchainManager.statusStream.listen((status) {
      _updateStateWithStatus(status);
    });
  }

  /// Handle blockchain events
  void _handleBlockchainEvent(BlockchainEvent event) {
    switch (event.type) {
      case 'newBlock':
        _handleNewBlock(event.data);
        break;
      case 'voteSubmitted':
        _handleVoteSubmitted(event.data);
        break;
      case 'error':
        _handleError(event.data['message'] as String);
        break;
    }
  }

  /// Handle new block event
  void _handleNewBlock(Map<String, dynamic> blockData) {
    try {
      final block = BlockchainBlock.fromJson(blockData);
      _currentState = _currentState.withNewBlock(block);
      _emitState();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Handle vote submitted event
  void _handleVoteSubmitted(Map<String, dynamic> voteData) {
    // Trigger election votes update
    final electionId = voteData['electionId'] as String?;
    if (electionId != null) {
      _updateElectionVotes(electionId);
    }
  }

  /// Handle error event
  void _handleError(String message) {
    // Update state to reflect error
    _currentState = _currentState.copyWith(
      isHealthy: false,
      lastUpdated: DateTime.now(),
    );
    _emitState();
  }

  /// Update state with blockchain status
  void _updateStateWithStatus(BlockchainStatus status) {
    final isRunning = status == BlockchainStatus.running;
    final isHealthy = status == BlockchainStatus.running;
    
    _currentState = _currentState.copyWith(
      isRunning: isRunning,
      isHealthy: isHealthy,
      lastUpdated: DateTime.now(),
    );
    _emitState();
  }

  /// Start periodic state updates
  void _startStateUpdates() {
    _stateUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateFullState();
    });
  }

  /// Stop periodic state updates
  void _stopStateUpdates() {
    _stateUpdateTimer?.cancel();
    _stateUpdateTimer = null;
  }

  /// Update full blockchain state
  Future<void> _updateFullState() async {
    try {
      if (!_blockchainManager.isRunning) return;

      final stats = await getBlockchainStats();
      final recentBlocks = await getRecentBlocks(limit: 5);
      
      _currentState = _currentState.copyWith(
        currentHeight: stats.blockHeight,
        totalTransactions: stats.totalTransactions,
        isHealthy: stats.isHealthy,
        isRunning: _blockchainManager.isRunning,
        lastUpdated: DateTime.now(),
        recentBlocks: recentBlocks,
      );
      
      _emitState();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Update election votes for a specific election
  Future<void> _updateElectionVotes(String electionId) async {
    try {
      final results = await getElectionResults(electionId);
      
      final electionVoteCount = ElectionVoteCount(
        electionId: electionId,
        totalVotes: results.totalVotes,
        candidateVotes: results.candidateVotes,
        lastUpdated: DateTime.now(),
      );
      
      final updatedElectionVotes = Map<String, ElectionVoteCount>.from(_currentState.electionVotes);
      updatedElectionVotes[electionId] = electionVoteCount;
      
      _currentState = _currentState.withUpdatedElectionVotes(updatedElectionVotes);
      _emitState();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Emit current state
  void _emitState() {
    _stateController.add(_currentState);
  }

  /// Dispose resources
  void dispose() {
    _stopStateUpdates();
    _stateController.close();
    _blockchainManager.dispose();
  }
}

/// Blockchain repository specific exception
class BlockchainRepositoryException implements Exception {
  final String message;
  
  const BlockchainRepositoryException(this.message);
  
  @override
  String toString() => 'BlockchainRepositoryException: $message';
}
