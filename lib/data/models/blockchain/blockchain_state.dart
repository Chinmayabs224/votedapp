import 'package:equatable/equatable.dart';
import 'blockchain_block.dart';
import 'blockchain_transaction.dart';

/// Blockchain state model that represents the current state of the blockchain
class BlockchainState extends Equatable {
  final int currentHeight;
  final String latestBlockHash;
  final int totalTransactions;
  final bool isHealthy;
  final bool isRunning;
  final DateTime lastUpdated;
  final List<BlockchainBlock> recentBlocks;
  final Map<String, ElectionVoteCount> electionVotes;

  const BlockchainState({
    required this.currentHeight,
    required this.latestBlockHash,
    required this.totalTransactions,
    required this.isHealthy,
    required this.isRunning,
    required this.lastUpdated,
    this.recentBlocks = const [],
    this.electionVotes = const {},
  });

  /// Create initial/empty blockchain state
  factory BlockchainState.initial() {
    return BlockchainState(
      currentHeight: 0,
      latestBlockHash: '',
      totalTransactions: 0,
      isHealthy: false,
      isRunning: false,
      lastUpdated: DateTime.now(),
      recentBlocks: [],
      electionVotes: {},
    );
  }

  /// Create BlockchainState from JSON
  factory BlockchainState.fromJson(Map<String, dynamic> json) {
    final recentBlocksList = json['recentBlocks'] as List<dynamic>? ?? [];
    final electionVotesMap = json['electionVotes'] as Map<String, dynamic>? ?? {};

    return BlockchainState(
      currentHeight: json['currentHeight'] as int? ?? 0,
      latestBlockHash: json['latestBlockHash'] as String? ?? '',
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      isHealthy: json['isHealthy'] as bool? ?? false,
      isRunning: json['isRunning'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
      recentBlocks: recentBlocksList
          .map((block) => BlockchainBlock.fromJson(block as Map<String, dynamic>))
          .toList(),
      electionVotes: electionVotesMap.map(
        (key, value) => MapEntry(
          key,
          ElectionVoteCount.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// Convert BlockchainState to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentHeight': currentHeight,
      'latestBlockHash': latestBlockHash,
      'totalTransactions': totalTransactions,
      'isHealthy': isHealthy,
      'isRunning': isRunning,
      'lastUpdated': lastUpdated.toIso8601String(),
      'recentBlocks': recentBlocks.map((block) => block.toJson()).toList(),
      'electionVotes': electionVotes.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  /// Get vote count for a specific election
  ElectionVoteCount? getElectionVotes(String electionId) {
    return electionVotes[electionId];
  }

  /// Get total votes for a specific election
  int getTotalVotesForElection(String electionId) {
    final electionVoteCount = electionVotes[electionId];
    return electionVoteCount?.totalVotes ?? 0;
  }

  /// Get votes for a specific candidate in an election
  int getVotesForCandidate(String electionId, String candidateId) {
    final electionVoteCount = electionVotes[electionId];
    return electionVoteCount?.candidateVotes[candidateId] ?? 0;
  }

  /// Check if blockchain is operational
  bool get isOperational => isRunning && isHealthy;

  /// Get blockchain status as string
  String get statusString {
    if (!isRunning) return 'Stopped';
    if (!isHealthy) return 'Unhealthy';
    return 'Running';
  }

  /// Create a copy with updated fields
  BlockchainState copyWith({
    int? currentHeight,
    String? latestBlockHash,
    int? totalTransactions,
    bool? isHealthy,
    bool? isRunning,
    DateTime? lastUpdated,
    List<BlockchainBlock>? recentBlocks,
    Map<String, ElectionVoteCount>? electionVotes,
  }) {
    return BlockchainState(
      currentHeight: currentHeight ?? this.currentHeight,
      latestBlockHash: latestBlockHash ?? this.latestBlockHash,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      isHealthy: isHealthy ?? this.isHealthy,
      isRunning: isRunning ?? this.isRunning,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      recentBlocks: recentBlocks ?? this.recentBlocks,
      electionVotes: electionVotes ?? this.electionVotes,
    );
  }

  /// Update with new block
  BlockchainState withNewBlock(BlockchainBlock block) {
    final updatedRecentBlocks = [block, ...recentBlocks].take(10).toList();
    
    return copyWith(
      currentHeight: block.height,
      latestBlockHash: block.hash,
      totalTransactions: totalTransactions + block.transactionCount,
      lastUpdated: DateTime.now(),
      recentBlocks: updatedRecentBlocks,
    );
  }

  /// Update election votes
  BlockchainState withUpdatedElectionVotes(Map<String, ElectionVoteCount> newElectionVotes) {
    return copyWith(
      electionVotes: newElectionVotes,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        currentHeight,
        latestBlockHash,
        totalTransactions,
        isHealthy,
        isRunning,
        lastUpdated,
        recentBlocks,
        electionVotes,
      ];

  @override
  String toString() {
    return 'BlockchainState(height: $currentHeight, txs: $totalTransactions, status: $statusString)';
  }
}

/// Election vote count model
class ElectionVoteCount extends Equatable {
  final String electionId;
  final int totalVotes;
  final Map<String, int> candidateVotes;
  final DateTime lastUpdated;

  const ElectionVoteCount({
    required this.electionId,
    required this.totalVotes,
    required this.candidateVotes,
    required this.lastUpdated,
  });

  /// Create ElectionVoteCount from JSON
  factory ElectionVoteCount.fromJson(Map<String, dynamic> json) {
    final candidateVotesMap = json['candidateVotes'] as Map<String, dynamic>? ?? {};
    
    return ElectionVoteCount(
      electionId: json['electionId'] as String? ?? '',
      totalVotes: json['totalVotes'] as int? ?? 0,
      candidateVotes: candidateVotesMap.map(
        (key, value) => MapEntry(key, value as int),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert ElectionVoteCount to JSON
  Map<String, dynamic> toJson() {
    return {
      'electionId': electionId,
      'totalVotes': totalVotes,
      'candidateVotes': candidateVotes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Get vote percentage for a candidate
  double getVotePercentage(String candidateId) {
    if (totalVotes == 0) return 0.0;
    final votes = candidateVotes[candidateId] ?? 0;
    return (votes / totalVotes) * 100;
  }

  /// Get leading candidate
  String? get leadingCandidate {
    if (candidateVotes.isEmpty) return null;
    
    String? leader;
    int maxVotes = 0;
    
    for (final entry in candidateVotes.entries) {
      if (entry.value > maxVotes) {
        maxVotes = entry.value;
        leader = entry.key;
      }
    }
    
    return leader;
  }

  /// Add vote for a candidate
  ElectionVoteCount addVote(String candidateId) {
    final updatedVotes = Map<String, int>.from(candidateVotes);
    updatedVotes[candidateId] = (updatedVotes[candidateId] ?? 0) + 1;
    
    return ElectionVoteCount(
      electionId: electionId,
      totalVotes: totalVotes + 1,
      candidateVotes: updatedVotes,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [electionId, totalVotes, candidateVotes, lastUpdated];

  @override
  String toString() {
    return 'ElectionVoteCount(electionId: $electionId, totalVotes: $totalVotes)';
  }
}

/// Blockchain network status
class BlockchainNetworkStatus extends Equatable {
  final bool isConnected;
  final int connectedPeers;
  final String networkId;
  final DateTime lastSyncTime;
  final bool isSyncing;

  const BlockchainNetworkStatus({
    required this.isConnected,
    required this.connectedPeers,
    required this.networkId,
    required this.lastSyncTime,
    required this.isSyncing,
  });

  /// Create initial network status
  factory BlockchainNetworkStatus.initial() {
    return BlockchainNetworkStatus(
      isConnected: false,
      connectedPeers: 0,
      networkId: '',
      lastSyncTime: DateTime.now(),
      isSyncing: false,
    );
  }

  /// Check if network is healthy
  bool get isHealthy => isConnected && connectedPeers > 0 && !isSyncing;

  @override
  List<Object?> get props => [isConnected, connectedPeers, networkId, lastSyncTime, isSyncing];

  @override
  String toString() {
    return 'BlockchainNetworkStatus(connected: $isConnected, peers: $connectedPeers)';
  }
}
