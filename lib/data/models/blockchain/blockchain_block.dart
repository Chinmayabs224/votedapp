import 'package:equatable/equatable.dart';
import 'blockchain_transaction.dart';

/// Blockchain block model that mirrors the Go blockchain Block structure
class BlockchainBlock extends Equatable {
  final String hash;
  final int version;
  final String dataHash;
  final String prevBlockHash;
  final int height;
  final int timestamp;
  final String validator;
  final String signature;
  final BlockTransactionResponse txResponse;

  const BlockchainBlock({
    required this.hash,
    required this.version,
    required this.dataHash,
    required this.prevBlockHash,
    required this.height,
    required this.timestamp,
    required this.validator,
    required this.signature,
    required this.txResponse,
  });

  /// Create BlockchainBlock from JSON
  factory BlockchainBlock.fromJson(Map<String, dynamic> json) {
    return BlockchainBlock(
      hash: json['Hash'] as String? ?? '',
      version: json['Version'] as int? ?? 0,
      dataHash: json['DataHash'] as String? ?? '',
      prevBlockHash: json['PrevBlockHash'] as String? ?? '',
      height: json['Height'] as int? ?? 0,
      timestamp: json['Timestamp'] as int? ?? 0,
      validator: json['Validator'] as String? ?? '',
      signature: json['Signature'] as String? ?? '',
      txResponse: BlockTransactionResponse.fromJson(
        json['TxResponse'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Convert BlockchainBlock to JSON
  Map<String, dynamic> toJson() {
    return {
      'Hash': hash,
      'Version': version,
      'DataHash': dataHash,
      'PrevBlockHash': prevBlockHash,
      'Height': height,
      'Timestamp': timestamp,
      'Validator': validator,
      'Signature': signature,
      'TxResponse': txResponse.toJson(),
    };
  }

  /// Get block creation date
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  /// Check if this is the genesis block
  bool get isGenesisBlock => height == 0;

  /// Get transaction count
  int get transactionCount => txResponse.txCount;

  /// Get transaction hashes
  List<String> get transactionHashes => txResponse.hashes;

  /// Create a copy with updated fields
  BlockchainBlock copyWith({
    String? hash,
    int? version,
    String? dataHash,
    String? prevBlockHash,
    int? height,
    int? timestamp,
    String? validator,
    String? signature,
    BlockTransactionResponse? txResponse,
  }) {
    return BlockchainBlock(
      hash: hash ?? this.hash,
      version: version ?? this.version,
      dataHash: dataHash ?? this.dataHash,
      prevBlockHash: prevBlockHash ?? this.prevBlockHash,
      height: height ?? this.height,
      timestamp: timestamp ?? this.timestamp,
      validator: validator ?? this.validator,
      signature: signature ?? this.signature,
      txResponse: txResponse ?? this.txResponse,
    );
  }

  @override
  List<Object?> get props => [
        hash,
        version,
        dataHash,
        prevBlockHash,
        height,
        timestamp,
        validator,
        signature,
        txResponse,
      ];

  @override
  String toString() {
    return 'BlockchainBlock(hash: $hash, height: $height, txCount: ${txResponse.txCount})';
  }
}

/// Transaction response within a block
class BlockTransactionResponse extends Equatable {
  final int txCount;
  final List<String> hashes;

  const BlockTransactionResponse({
    required this.txCount,
    required this.hashes,
  });

  /// Create BlockTransactionResponse from JSON
  factory BlockTransactionResponse.fromJson(Map<String, dynamic> json) {
    final hashList = json['Hashes'] as List<dynamic>? ?? [];
    return BlockTransactionResponse(
      txCount: json['TxCount'] as int? ?? 0,
      hashes: hashList.map((hash) => hash.toString()).toList(),
    );
  }

  /// Convert BlockTransactionResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'TxCount': txCount,
      'Hashes': hashes,
    };
  }

  /// Check if block has transactions
  bool get hasTransactions => txCount > 0;

  /// Create a copy with updated fields
  BlockTransactionResponse copyWith({
    int? txCount,
    List<String>? hashes,
  }) {
    return BlockTransactionResponse(
      txCount: txCount ?? this.txCount,
      hashes: hashes ?? this.hashes,
    );
  }

  @override
  List<Object?> get props => [txCount, hashes];

  @override
  String toString() {
    return 'BlockTransactionResponse(txCount: $txCount, hashes: ${hashes.length})';
  }
}

/// Block header information
class BlockHeader extends Equatable {
  final int version;
  final String dataHash;
  final String prevBlockHash;
  final int height;
  final int timestamp;

  const BlockHeader({
    required this.version,
    required this.dataHash,
    required this.prevBlockHash,
    required this.height,
    required this.timestamp,
  });

  /// Create BlockHeader from JSON
  factory BlockHeader.fromJson(Map<String, dynamic> json) {
    return BlockHeader(
      version: json['Version'] as int? ?? 0,
      dataHash: json['DataHash'] as String? ?? '',
      prevBlockHash: json['PrevBlockHash'] as String? ?? '',
      height: json['Height'] as int? ?? 0,
      timestamp: json['Timestamp'] as int? ?? 0,
    );
  }

  /// Convert BlockHeader to JSON
  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'DataHash': dataHash,
      'PrevBlockHash': prevBlockHash,
      'Height': height,
      'Timestamp': timestamp,
    };
  }

  /// Get header creation date
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  @override
  List<Object?> get props => [version, dataHash, prevBlockHash, height, timestamp];

  @override
  String toString() {
    return 'BlockHeader(height: $height, timestamp: $timestamp)';
  }
}
