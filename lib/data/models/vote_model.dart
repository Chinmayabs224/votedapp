import 'package:equatable/equatable.dart';

/// Vote model for the Bockvote application
class Vote extends Equatable {
  final String id;
  final String electionId;
  final String candidateId;
  final String voterId;
  final DateTime timestamp;
  final String? receiptCode;
  final String? blockchainHash;
  final VoteStatus status;
  final Map<String, dynamic>? metadata;

  const Vote({
    required this.id,
    required this.electionId,
    required this.candidateId,
    required this.voterId,
    required this.timestamp,
    this.receiptCode,
    this.blockchainHash,
    required this.status,
    this.metadata,
  });

  /// Create Vote from JSON
  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as String,
      electionId: json['electionId'] as String,
      candidateId: json['candidateId'] as String,
      voterId: json['voterId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      receiptCode: json['receiptCode'] as String?,
      blockchainHash: json['blockchainHash'] as String?,
      status: VoteStatus.fromString(json['status'] as String? ?? 'pending'),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Vote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'electionId': electionId,
      'candidateId': candidateId,
      'voterId': voterId,
      'timestamp': timestamp.toIso8601String(),
      'receiptCode': receiptCode,
      'blockchainHash': blockchainHash,
      'status': status.value,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Vote copyWith({
    String? id,
    String? electionId,
    String? candidateId,
    String? voterId,
    DateTime? timestamp,
    String? receiptCode,
    String? blockchainHash,
    VoteStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return Vote(
      id: id ?? this.id,
      electionId: electionId ?? this.electionId,
      candidateId: candidateId ?? this.candidateId,
      voterId: voterId ?? this.voterId,
      timestamp: timestamp ?? this.timestamp,
      receiptCode: receiptCode ?? this.receiptCode,
      blockchainHash: blockchainHash ?? this.blockchainHash,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if vote is confirmed
  bool get isConfirmed => status == VoteStatus.confirmed;

  /// Check if vote is pending
  bool get isPending => status == VoteStatus.pending;

  /// Check if vote is verified on blockchain
  bool get isVerified => blockchainHash != null && blockchainHash!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        electionId,
        candidateId,
        voterId,
        timestamp,
        receiptCode,
        blockchainHash,
        status,
        metadata,
      ];
}

/// Vote status enumeration
enum VoteStatus {
  pending('pending'),
  confirmed('confirmed'),
  rejected('rejected'),
  invalid('invalid');

  const VoteStatus(this.value);

  final String value;

  static VoteStatus fromString(String value) {
    return VoteStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VoteStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case VoteStatus.pending:
        return 'Pending';
      case VoteStatus.confirmed:
        return 'Confirmed';
      case VoteStatus.rejected:
        return 'Rejected';
      case VoteStatus.invalid:
        return 'Invalid';
    }
  }
}

/// Vote submission request
class VoteSubmissionRequest {
  final String electionId;
  final String candidateId;
  final String? signature;
  final Map<String, dynamic>? metadata;

  const VoteSubmissionRequest({
    required this.electionId,
    required this.candidateId,
    this.signature,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'electionId': electionId,
      'candidateId': candidateId,
      'signature': signature,
      'metadata': metadata,
    };
  }
}

/// Vote verification request
class VoteVerificationRequest {
  final String receiptCode;
  final String? electionId;

  const VoteVerificationRequest({
    required this.receiptCode,
    this.electionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiptCode': receiptCode,
      'electionId': electionId,
    };
  }
}

/// Vote receipt model
class VoteReceipt extends Equatable {
  final String receiptCode;
  final String electionId;
  final String electionTitle;
  final String candidateName;
  final DateTime timestamp;
  final String? blockchainHash;
  final VoteStatus status;

  const VoteReceipt({
    required this.receiptCode,
    required this.electionId,
    required this.electionTitle,
    required this.candidateName,
    required this.timestamp,
    this.blockchainHash,
    required this.status,
  });

  /// Create VoteReceipt from JSON
  factory VoteReceipt.fromJson(Map<String, dynamic> json) {
    return VoteReceipt(
      receiptCode: json['receiptCode'] as String,
      electionId: json['electionId'] as String,
      electionTitle: json['electionTitle'] as String,
      candidateName: json['candidateName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      blockchainHash: json['blockchainHash'] as String?,
      status: VoteStatus.fromString(json['status'] as String? ?? 'pending'),
    );
  }

  /// Convert VoteReceipt to JSON
  Map<String, dynamic> toJson() {
    return {
      'receiptCode': receiptCode,
      'electionId': electionId,
      'electionTitle': electionTitle,
      'candidateName': candidateName,
      'timestamp': timestamp.toIso8601String(),
      'blockchainHash': blockchainHash,
      'status': status.value,
    };
  }

  @override
  List<Object?> get props => [
        receiptCode,
        electionId,
        electionTitle,
        candidateName,
        timestamp,
        blockchainHash,
        status,
      ];
}

/// Election results model
class ElectionResults extends Equatable {
  final String electionId;
  final String electionTitle;
  final int totalVotes;
  final List<CandidateResult> candidateResults;
  final DateTime lastUpdated;
  final bool isFinal;

  const ElectionResults({
    required this.electionId,
    required this.electionTitle,
    required this.totalVotes,
    required this.candidateResults,
    required this.lastUpdated,
    required this.isFinal,
  });

  /// Create ElectionResults from JSON
  factory ElectionResults.fromJson(Map<String, dynamic> json) {
    return ElectionResults(
      electionId: json['electionId'] as String,
      electionTitle: json['electionTitle'] as String,
      totalVotes: json['totalVotes'] as int,
      candidateResults: (json['candidateResults'] as List)
          .map((item) => CandidateResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isFinal: json['isFinal'] as bool? ?? false,
    );
  }

  /// Convert ElectionResults to JSON
  Map<String, dynamic> toJson() {
    return {
      'electionId': electionId,
      'electionTitle': electionTitle,
      'totalVotes': totalVotes,
      'candidateResults': candidateResults.map((result) => result.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isFinal': isFinal,
    };
  }

  /// Get winning candidate
  CandidateResult? get winner {
    if (candidateResults.isEmpty) return null;
    return candidateResults.reduce((a, b) => a.voteCount > b.voteCount ? a : b);
  }

  @override
  List<Object?> get props => [
        electionId,
        electionTitle,
        totalVotes,
        candidateResults,
        lastUpdated,
        isFinal,
      ];
}

/// Candidate result model
class CandidateResult extends Equatable {
  final String candidateId;
  final String candidateName;
  final String? party;
  final int voteCount;
  final double percentage;

  const CandidateResult({
    required this.candidateId,
    required this.candidateName,
    this.party,
    required this.voteCount,
    required this.percentage,
  });

  /// Create CandidateResult from JSON
  factory CandidateResult.fromJson(Map<String, dynamic> json) {
    return CandidateResult(
      candidateId: json['candidateId'] as String,
      candidateName: json['candidateName'] as String,
      party: json['party'] as String?,
      voteCount: json['voteCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  /// Convert CandidateResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'candidateId': candidateId,
      'candidateName': candidateName,
      'party': party,
      'voteCount': voteCount,
      'percentage': percentage,
    };
  }

  @override
  List<Object?> get props => [
        candidateId,
        candidateName,
        party,
        voteCount,
        percentage,
      ];
}
