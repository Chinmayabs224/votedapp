import 'package:equatable/equatable.dart';
import 'blockchain_transaction.dart';

/// Represents a blockchain block
class BlockchainBlock extends Equatable {
  final String hash;
  final String previousHash;
  final int height;
  final int timestamp;
  final String validator;
  final List<BlockchainTransaction> transactions;
  final String merkleRoot;
  final int nonce;
  final double difficulty;
  final int gasUsed;
  final int gasLimit;
  final BlockStatus status;

  const BlockchainBlock({
    required this.hash,
    required this.previousHash,
    required this.height,
    required this.timestamp,
    required this.validator,
    required this.transactions,
    required this.merkleRoot,
    required this.nonce,
    required this.difficulty,
    required this.gasUsed,
    required this.gasLimit,
    required this.status,
  });

  factory BlockchainBlock.fromJson(Map<String, dynamic> json) {
    final transactionsList = json['transactions'] as List<dynamic>? ?? [];
    final transactions = transactionsList
        .map((tx) => BlockchainTransaction.fromJson(tx as Map<String, dynamic>))
        .toList();

    return BlockchainBlock(
      hash: json['hash'] ?? '',
      previousHash: json['previousHash'] ?? '',
      height: json['height'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
      validator: json['validator'] ?? '',
      transactions: transactions,
      merkleRoot: json['merkleRoot'] ?? '',
      nonce: json['nonce'] ?? 0,
      difficulty: (json['difficulty'] ?? 0.0).toDouble(),
      gasUsed: json['gasUsed'] ?? 0,
      gasLimit: json['gasLimit'] ?? 0,
      status: BlockStatus.fromString(json['status'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'previousHash': previousHash,
      'height': height,
      'timestamp': timestamp,
      'validator': validator,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
      'merkleRoot': merkleRoot,
      'nonce': nonce,
      'difficulty': difficulty,
      'gasUsed': gasUsed,
      'gasLimit': gasLimit,
      'status': status.toString(),
    };
  }

  BlockchainBlock copyWith({
    String? hash,
    String? previousHash,
    int? height,
    int? timestamp,
    String? validator,
    List<BlockchainTransaction>? transactions,
    String? merkleRoot,
    int? nonce,
    double? difficulty,
    int? gasUsed,
    int? gasLimit,
    BlockStatus? status,
  }) {
    return BlockchainBlock(
      hash: hash ?? this.hash,
      previousHash: previousHash ?? this.previousHash,
      height: height ?? this.height,
      timestamp: timestamp ?? this.timestamp,
      validator: validator ?? this.validator,
      transactions: transactions ?? this.transactions,
      merkleRoot: merkleRoot ?? this.merkleRoot,
      nonce: nonce ?? this.nonce,
      difficulty: difficulty ?? this.difficulty,
      gasUsed: gasUsed ?? this.gasUsed,
      gasLimit: gasLimit ?? this.gasLimit,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        hash,
        previousHash,
        height,
        timestamp,
        validator,
        transactions,
        merkleRoot,
        nonce,
        difficulty,
        gasUsed,
        gasLimit,
        status,
      ];
}

/// Block status enumeration
enum BlockStatus {
  pending,
  validating,
  confirmed,
  finalized,
  orphaned;

  static BlockStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BlockStatus.pending;
      case 'validating':
        return BlockStatus.validating;
      case 'confirmed':
        return BlockStatus.confirmed;
      case 'finalized':
        return BlockStatus.finalized;
      case 'orphaned':
        return BlockStatus.orphaned;
      default:
        return BlockStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case BlockStatus.pending:
        return 'pending';
      case BlockStatus.validating:
        return 'validating';
      case BlockStatus.confirmed:
        return 'confirmed';
      case BlockStatus.finalized:
        return 'finalized';
      case BlockStatus.orphaned:
        return 'orphaned';
    }
  }
}
