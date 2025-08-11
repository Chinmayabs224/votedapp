import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/blockchain_repository.dart';
import '../repositories/blockchain_voting_repository.dart';
import '../models/blockchain/blockchain_state.dart';
import '../models/vote_model.dart';
import '../../core/services/blockchain_realtime_service.dart';
import '../../core/services/blockchain_manager.dart';

/// Provider for managing blockchain state and real-time updates in the UI
class BlockchainProvider extends ChangeNotifier {
  final BlockchainRepository _blockchainRepository;
  final BlockchainVotingRepository _votingRepository;
  final BlockchainRealtimeService _realtimeService;

  BlockchainState _state = BlockchainState.initial();
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  List<BlockchainRealtimeEvent> _recentEvents = [];
  Map<String, ElectionVoteCount> _liveElectionResults = {};
  bool _isInitialized = false;
  String? _lastError;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _eventSubscription;
  StreamSubscription? _connectionSubscription;

  BlockchainProvider(
    this._blockchainRepository,
    this._votingRepository,
    this._realtimeService,
  );

  /// Current blockchain state
  BlockchainState get state => _state;

  /// Current connection status
  ConnectionStatus get connectionStatus => _connectionStatus;

  /// Recent blockchain events
  List<BlockchainRealtimeEvent> get recentEvents => List.unmodifiable(_recentEvents);

  /// Live election results
  Map<String, ElectionVoteCount> get liveElectionResults => Map.unmodifiable(_liveElectionResults);

  /// Whether the provider is initialized
  bool get isInitialized => _isInitialized;

  /// Last error message
  String? get lastError => _lastError;

  /// Whether blockchain is operational
  bool get isOperational => _state.isOperational;

  /// Whether blockchain is connected
  bool get isConnected => _connectionStatus.isConnected;

  /// Initialize the blockchain provider
  Future<void> initialize({bool autoStart = true}) async {
    try {
      _lastError = null;
      
      // Initialize blockchain repository
      await _blockchainRepository.initialize(autoStart: autoStart);
      
      // Initialize real-time service
      await _realtimeService.initialize();
      
      // Set up subscriptions
      _setupSubscriptions();
      
      // Start real-time service
      await _realtimeService.start();
      
      _isInitialized = true;
      notifyListeners();
      
    } catch (e) {
      _lastError = 'Failed to initialize blockchain: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Start the blockchain
  Future<void> startBlockchain() async {
    try {
      _lastError = null;
      await _blockchainRepository.startBlockchain();
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to start blockchain: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Stop the blockchain
  Future<void> stopBlockchain() async {
    try {
      _lastError = null;
      await _blockchainRepository.stopBlockchain();
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to stop blockchain: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Submit a vote through blockchain
  Future<BlockchainVoteReceipt> submitVote({
    required String electionId,
    required String candidateId,
    required String voterId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _lastError = null;
      
      final request = VoteSubmissionRequest(
        electionId: electionId,
        candidateId: candidateId,
        metadata: metadata,
      );
      
      final receipt = await _votingRepository.submitVote(request, voterId);
      
      // Update live results
      await _updateLiveElectionResults(electionId);
      
      notifyListeners();
      return receipt;
      
    } catch (e) {
      _lastError = 'Failed to submit vote: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get election results with blockchain verification
  Future<BlockchainElectionResults> getElectionResults(String electionId) async {
    try {
      _lastError = null;
      final results = await _votingRepository.getElectionResults(electionId);
      notifyListeners();
      return results;
    } catch (e) {
      _lastError = 'Failed to get election results: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get vote history with blockchain verification
  Future<List<BlockchainVoteReceipt>> getVoteHistory({
    int? page,
    int? limit,
    String? electionId,
  }) async {
    try {
      _lastError = null;
      final history = await _votingRepository.getVoteHistory(
        page: page,
        limit: limit,
        electionId: electionId,
      );
      notifyListeners();
      return history;
    } catch (e) {
      _lastError = 'Failed to get vote history: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Verify a vote
  Future<VoteVerificationResult> verifyVote(String receiptCode, {String? electionId}) async {
    try {
      _lastError = null;
      final request = VoteVerificationRequest(
        receiptCode: receiptCode,
        electionId: electionId,
      );
      final result = await _votingRepository.verifyVote(request);
      notifyListeners();
      return result;
    } catch (e) {
      _lastError = 'Failed to verify vote: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get blockchain statistics
  Future<BlockchainStats> getBlockchainStats() async {
    try {
      _lastError = null;
      final stats = await _blockchainRepository.getBlockchainStats();
      notifyListeners();
      return stats;
    } catch (e) {
      _lastError = 'Failed to get blockchain stats: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh blockchain state
  Future<void> refreshState() async {
    try {
      _lastError = null;
      // The state will be updated through subscriptions
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to refresh state: $e';
      notifyListeners();
    }
  }

  /// Clear last error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Set up subscriptions to blockchain events
  void _setupSubscriptions() {
    // Subscribe to blockchain state changes
    _stateSubscription = _blockchainRepository.stateStream.listen(
      (state) {
        _state = state;
        _liveElectionResults = state.electionVotes;
        notifyListeners();
      },
      onError: (error) {
        _lastError = 'Blockchain state error: $error';
        notifyListeners();
      },
    );

    // Subscribe to real-time events
    _eventSubscription = _realtimeService.eventStream.listen(
      (event) {
        _handleRealtimeEvent(event);
      },
      onError: (error) {
        _lastError = 'Real-time event error: $error';
        notifyListeners();
      },
    );

    // Subscribe to connection status changes
    _connectionSubscription = _realtimeService.connectionStream.listen(
      (status) {
        _connectionStatus = status;
        notifyListeners();
      },
      onError: (error) {
        _lastError = 'Connection status error: $error';
        notifyListeners();
      },
    );
  }

  /// Handle real-time events
  void _handleRealtimeEvent(BlockchainRealtimeEvent event) {
    // Add to recent events (keep last 50)
    _recentEvents.insert(0, event);
    if (_recentEvents.length > 50) {
      _recentEvents = _recentEvents.take(50).toList();
    }

    // Handle specific event types
    switch (event.type) {
      case 'newBlock':
        _handleNewBlockEvent(event);
        break;
      case 'voteSubmitted':
        _handleVoteSubmittedEvent(event);
        break;
      case 'statsUpdate':
        _handleStatsUpdateEvent(event);
        break;
      case 'error':
      case 'connectionError':
        _lastError = event.data['message'] as String?;
        break;
    }

    notifyListeners();
  }

  /// Handle new block event
  void _handleNewBlockEvent(BlockchainRealtimeEvent event) {
    // Update state with new block information
    final blockHeight = event.data['Height'] as int?;
    if (blockHeight != null && blockHeight > _state.currentHeight) {
      _state = _state.copyWith(
        currentHeight: blockHeight,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Handle vote submitted event
  void _handleVoteSubmittedEvent(BlockchainRealtimeEvent event) {
    // Update live election results if this is for a tracked election
    final electionId = event.data['electionId'] as String?;
    if (electionId != null) {
      _updateLiveElectionResults(electionId);
    }
  }

  /// Handle stats update event
  void _handleStatsUpdateEvent(BlockchainRealtimeEvent event) {
    final blockHeight = event.data['blockHeight'] as int?;
    final totalTransactions = event.data['totalTransactions'] as int?;
    final isHealthy = event.data['isHealthy'] as bool?;

    if (blockHeight != null || totalTransactions != null || isHealthy != null) {
      _state = _state.copyWith(
        currentHeight: blockHeight ?? _state.currentHeight,
        totalTransactions: totalTransactions ?? _state.totalTransactions,
        isHealthy: isHealthy ?? _state.isHealthy,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Update live election results
  Future<void> _updateLiveElectionResults(String electionId) async {
    try {
      final results = await _blockchainRepository.getElectionResults(electionId);
      final electionVoteCount = ElectionVoteCount(
        electionId: electionId,
        totalVotes: results.totalVotes,
        candidateVotes: results.candidateVotes,
        lastUpdated: DateTime.now(),
      );
      
      _liveElectionResults = {
        ..._liveElectionResults,
        electionId: electionVoteCount,
      };
    } catch (e) {
      // Handle error silently for live updates
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _realtimeService.dispose();
    super.dispose();
  }
}
