import 'package:equatable/equatable.dart';

/// Represents the current state of the blockchain network
class BlockchainNetworkState extends Equatable {
  final int currentBlockHeight;
  final String latestBlockHash;
  final int totalTransactions;
  final double networkHashRate;
  final int connectedPeers;
  final NetworkStatus status;
  final double avgBlockTime;
  final int pendingTransactions;
  final double totalSupply;
  final double circulatingSupply;
  final int timestamp;

  const BlockchainNetworkState({
    required this.currentBlockHeight,
    required this.latestBlockHash,
    required this.totalTransactions,
    required this.networkHashRate,
    required this.connectedPeers,
    required this.status,
    required this.avgBlockTime,
    required this.pendingTransactions,
    required this.totalSupply,
    required this.circulatingSupply,
    required this.timestamp,
  });

  factory BlockchainNetworkState.fromJson(Map<String, dynamic> json) {
    return BlockchainNetworkState(
      currentBlockHeight: json['currentBlockHeight'] ?? 0,
      latestBlockHash: json['latestBlockHash'] ?? '',
      totalTransactions: json['totalTransactions'] ?? 0,
      networkHashRate: (json['networkHashRate'] ?? 0.0).toDouble(),
      connectedPeers: json['connectedPeers'] ?? 0,
      status: NetworkStatus.fromString(json['status'] ?? 'offline'),
      avgBlockTime: (json['avgBlockTime'] ?? 0.0).toDouble(),
      pendingTransactions: json['pendingTransactions'] ?? 0,
      totalSupply: (json['totalSupply'] ?? 0.0).toDouble(),
      circulatingSupply: (json['circulatingSupply'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentBlockHeight': currentBlockHeight,
      'latestBlockHash': latestBlockHash,
      'totalTransactions': totalTransactions,
      'networkHashRate': networkHashRate,
      'connectedPeers': connectedPeers,
      'status': status.toString(),
      'avgBlockTime': avgBlockTime,
      'pendingTransactions': pendingTransactions,
      'totalSupply': totalSupply,
      'circulatingSupply': circulatingSupply,
      'timestamp': timestamp,
    };
  }

  BlockchainNetworkState copyWith({
    int? currentBlockHeight,
    String? latestBlockHash,
    int? totalTransactions,
    double? networkHashRate,
    int? connectedPeers,
    NetworkStatus? status,
    double? avgBlockTime,
    int? pendingTransactions,
    double? totalSupply,
    double? circulatingSupply,
    int? timestamp,
  }) {
    return BlockchainNetworkState(
      currentBlockHeight: currentBlockHeight ?? this.currentBlockHeight,
      latestBlockHash: latestBlockHash ?? this.latestBlockHash,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      networkHashRate: networkHashRate ?? this.networkHashRate,
      connectedPeers: connectedPeers ?? this.connectedPeers,
      status: status ?? this.status,
      avgBlockTime: avgBlockTime ?? this.avgBlockTime,
      pendingTransactions: pendingTransactions ?? this.pendingTransactions,
      totalSupply: totalSupply ?? this.totalSupply,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        currentBlockHeight,
        latestBlockHash,
        totalTransactions,
        networkHashRate,
        connectedPeers,
        status,
        avgBlockTime,
        pendingTransactions,
        totalSupply,
        circulatingSupply,
        timestamp,
      ];
}

/// Network status enumeration
enum NetworkStatus {
  offline,
  connecting,
  online,
  syncing,
  error;

  static NetworkStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'offline':
        return NetworkStatus.offline;
      case 'connecting':
        return NetworkStatus.connecting;
      case 'online':
        return NetworkStatus.online;
      case 'syncing':
        return NetworkStatus.syncing;
      case 'error':
        return NetworkStatus.error;
      default:
        return NetworkStatus.offline;
    }
  }

  @override
  String toString() {
    switch (this) {
      case NetworkStatus.offline:
        return 'offline';
      case NetworkStatus.connecting:
        return 'connecting';
      case NetworkStatus.online:
        return 'online';
      case NetworkStatus.syncing:
        return 'syncing';
      case NetworkStatus.error:
        return 'error';
    }
  }
}
