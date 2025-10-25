import 'package:equatable/equatable.dart';

/// Represents a blockchain transaction
class BlockchainTransaction extends Equatable {
  final String hash;
  final String fromAddress;
  final String toAddress;
  final double amount;
  final double fee;
  final String signature;
  final int timestamp;
  final TransactionStatus status;
  final String? data;
  final int? blockHeight;
  final int nonce;

  const BlockchainTransaction({
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.fee,
    required this.signature,
    required this.timestamp,
    required this.status,
    this.data,
    this.blockHeight,
    required this.nonce,
  });

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      hash: json['hash'] ?? '',
      fromAddress: json['from'] ?? '',
      toAddress: json['to'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      fee: (json['fee'] ?? 0.0).toDouble(),
      signature: json['signature'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      status: TransactionStatus.fromString(json['status'] ?? 'pending'),
      data: json['data'],
      blockHeight: json['blockHeight'],
      nonce: json['nonce'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'from': fromAddress,
      'to': toAddress,
      'amount': amount,
      'fee': fee,
      'signature': signature,
      'timestamp': timestamp,
      'status': status.toString(),
      'data': data,
      'blockHeight': blockHeight,
      'nonce': nonce,
    };
  }

  BlockchainTransaction copyWith({
    String? hash,
    String? fromAddress,
    String? toAddress,
    double? amount,
    double? fee,
    String? signature,
    int? timestamp,
    TransactionStatus? status,
    String? data,
    int? blockHeight,
    int? nonce,
  }) {
    return BlockchainTransaction(
      hash: hash ?? this.hash,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      signature: signature ?? this.signature,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      data: data ?? this.data,
      blockHeight: blockHeight ?? this.blockHeight,
      nonce: nonce ?? this.nonce,
    );
  }

  @override
  List<Object?> get props => [
        hash,
        fromAddress,
        toAddress,
        amount,
        fee,
        signature,
        timestamp,
        status,
        data,
        blockHeight,
        nonce,
      ];
}

/// Transaction status enumeration
enum TransactionStatus {
  pending,
  validating,
  confirmed,
  failed,
  cancelled;

  static TransactionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'validating':
        return TransactionStatus.validating;
      case 'confirmed':
        return TransactionStatus.confirmed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.validating:
        return 'validating';
      case TransactionStatus.confirmed:
        return 'confirmed';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }
}
