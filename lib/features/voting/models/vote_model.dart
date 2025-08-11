/// Vote model representing a vote cast by a user
class VoteModel {
  final String id;
  final String userId;
  final String electionId;
  final String candidateId;
  final DateTime timestamp;
  final String? receiptCode;
  final bool isVerified;

  VoteModel({
    required this.id,
    required this.userId,
    required this.electionId,
    required this.candidateId,
    required this.timestamp,
    this.receiptCode,
    this.isVerified = false,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'],
      userId: json['userId'],
      electionId: json['electionId'],
      candidateId: json['candidateId'],
      timestamp: DateTime.parse(json['timestamp']),
      receiptCode: json['receiptCode'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'electionId': electionId,
      'candidateId': candidateId,
      'timestamp': timestamp.toIso8601String(),
      'receiptCode': receiptCode,
      'isVerified': isVerified,
    };
  }

  VoteModel copyWith({
    String? id,
    String? userId,
    String? electionId,
    String? candidateId,
    DateTime? timestamp,
    String? receiptCode,
    bool? isVerified,
  }) {
    return VoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      electionId: electionId ?? this.electionId,
      candidateId: candidateId ?? this.candidateId,
      timestamp: timestamp ?? this.timestamp,
      receiptCode: receiptCode ?? this.receiptCode,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}