import 'package:equatable/equatable.dart';

/// Blockchain transaction model that mirrors the Go blockchain Transaction structure
class BlockchainTransaction extends Equatable {
  final String? data;
  final String? to;
  final int value;
  final int nonce;
  final String? signature;
  final String? from;
  final String hash;
  final TransactionInner? txInner;
  final DateTime timestamp;

  const BlockchainTransaction({
    this.data,
    this.to,
    required this.value,
    required this.nonce,
    this.signature,
    this.from,
    required this.hash,
    this.txInner,
    required this.timestamp,
  });

  /// Create BlockchainTransaction from JSON
  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      data: json['Data'] as String?,
      to: json['To'] as String?,
      value: json['Value'] as int? ?? 0,
      nonce: json['Nonce'] as int? ?? 0,
      signature: json['Signature'] as String?,
      from: json['From'] as String?,
      hash: json['Hash'] as String? ?? '',
      txInner: json['TxInner'] != null 
          ? TransactionInner.fromJson(json['TxInner'] as Map<String, dynamic>)
          : null,
      timestamp: json['Timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['Timestamp'] as int)
          : DateTime.now(),
    );
  }

  /// Convert BlockchainTransaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'Data': data,
      'To': to,
      'Value': value,
      'Nonce': nonce,
      'Signature': signature,
      'From': from,
      'Hash': hash,
      'TxInner': txInner?.toJson(),
      'Timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Check if this is a vote transaction
  bool get isVoteTransaction => txInner?.type == TransactionType.vote;

  /// Check if this is a collection transaction
  bool get isCollectionTransaction => txInner?.type == TransactionType.collection;

  /// Check if this is a mint transaction
  bool get isMintTransaction => txInner?.type == TransactionType.mint;

  /// Check if this is a transfer transaction
  bool get isTransferTransaction => to != null && value > 0 && txInner == null;

  /// Get transaction type as string
  String get transactionType {
    if (txInner != null) {
      return txInner!.type.name;
    } else if (isTransferTransaction) {
      return 'transfer';
    }
    return 'unknown';
  }

  /// Create a copy with updated fields
  BlockchainTransaction copyWith({
    String? data,
    String? to,
    int? value,
    int? nonce,
    String? signature,
    String? from,
    String? hash,
    TransactionInner? txInner,
    DateTime? timestamp,
  }) {
    return BlockchainTransaction(
      data: data ?? this.data,
      to: to ?? this.to,
      value: value ?? this.value,
      nonce: nonce ?? this.nonce,
      signature: signature ?? this.signature,
      from: from ?? this.from,
      hash: hash ?? this.hash,
      txInner: txInner ?? this.txInner,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        data,
        to,
        value,
        nonce,
        signature,
        from,
        hash,
        txInner,
        timestamp,
      ];

  @override
  String toString() {
    return 'BlockchainTransaction(hash: $hash, type: $transactionType, value: $value)';
  }
}

/// Transaction inner data for special transaction types
class TransactionInner extends Equatable {
  final TransactionType type;
  final Map<String, dynamic> data;

  const TransactionInner({
    required this.type,
    required this.data,
  });

  /// Create TransactionInner from JSON
  factory TransactionInner.fromJson(Map<String, dynamic> json) {
    // Determine transaction type based on the fields present
    TransactionType type;
    if (json.containsKey('electionId') && json.containsKey('candidateId')) {
      type = TransactionType.vote;
    } else if (json.containsKey('Fee') && json.containsKey('MetaData') && !json.containsKey('NFT')) {
      type = TransactionType.collection;
    } else if (json.containsKey('NFT') && json.containsKey('Collection')) {
      type = TransactionType.mint;
    } else {
      type = TransactionType.unknown;
    }

    return TransactionInner(
      type: type,
      data: Map<String, dynamic>.from(json),
    );
  }

  /// Convert TransactionInner to JSON
  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }

  /// Create a vote transaction inner
  factory TransactionInner.vote({
    required String electionId,
    required String candidateId,
    required String voterId,
    Map<String, dynamic>? additionalData,
  }) {
    final data = {
      'electionId': electionId,
      'candidateId': candidateId,
      'voterId': voterId,
      'type': 'vote',
      ...?additionalData,
    };

    return TransactionInner(
      type: TransactionType.vote,
      data: data,
    );
  }

  /// Create a collection transaction inner
  factory TransactionInner.collection({
    required int fee,
    required List<int> metaData,
  }) {
    return TransactionInner(
      type: TransactionType.collection,
      data: {
        'Fee': fee,
        'MetaData': metaData,
      },
    );
  }

  /// Create a mint transaction inner
  factory TransactionInner.mint({
    required int fee,
    required String nft,
    required List<int> metaData,
    required String collection,
    required String collectionOwner,
  }) {
    return TransactionInner(
      type: TransactionType.mint,
      data: {
        'Fee': fee,
        'NFT': nft,
        'MetaData': metaData,
        'Collection': collection,
        'CollectionOwner': collectionOwner,
      },
    );
  }

  /// Get specific field from data
  T? getField<T>(String key) {
    return data[key] as T?;
  }

  /// Get election ID for vote transactions
  String? get electionId => getField<String>('electionId');

  /// Get candidate ID for vote transactions
  String? get candidateId => getField<String>('candidateId');

  /// Get voter ID for vote transactions
  String? get voterId => getField<String>('voterId');

  /// Get fee for collection/mint transactions
  int? get fee => getField<int>('Fee');

  /// Get metadata for collection/mint transactions
  List<int>? get metaData => getField<List<int>>('MetaData');

  @override
  List<Object?> get props => [type, data];

  @override
  String toString() {
    return 'TransactionInner(type: $type, data: $data)';
  }
}

/// Transaction types
enum TransactionType {
  vote,
  collection,
  mint,
  transfer,
  unknown,
}

/// Vote transaction model for easier handling
class VoteTransaction extends Equatable {
  final String electionId;
  final String candidateId;
  final String voterId;
  final String transactionHash;
  final DateTime timestamp;
  final Map<String, dynamic>? signature;

  const VoteTransaction({
    required this.electionId,
    required this.candidateId,
    required this.voterId,
    required this.transactionHash,
    required this.timestamp,
    this.signature,
  });

  /// Create VoteTransaction from BlockchainTransaction
  factory VoteTransaction.fromBlockchainTransaction(BlockchainTransaction tx) {
    if (!tx.isVoteTransaction || tx.txInner == null) {
      throw ArgumentError('Transaction is not a vote transaction');
    }

    return VoteTransaction(
      electionId: tx.txInner!.electionId ?? '',
      candidateId: tx.txInner!.candidateId ?? '',
      voterId: tx.txInner!.voterId ?? '',
      transactionHash: tx.hash,
      timestamp: tx.timestamp,
      signature: tx.signature != null ? {'signature': tx.signature} : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'electionId': electionId,
      'candidateId': candidateId,
      'voterId': voterId,
      'transactionHash': transactionHash,
      'timestamp': timestamp.toIso8601String(),
      'signature': signature,
    };
  }

  @override
  List<Object?> get props => [
        electionId,
        candidateId,
        voterId,
        transactionHash,
        timestamp,
        signature,
      ];

  @override
  String toString() {
    return 'VoteTransaction(electionId: $electionId, candidateId: $candidateId, hash: $transactionHash)';
  }
}
