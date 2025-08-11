/// Candidate model representing a candidate in an election
class CandidateModel {
  final String id;
  final String name;
  final String party;
  final String position;
  final String? photoUrl;
  final String? biography;
  final Map<String, dynamic>? additionalInfo;
  final int voteCount;

  CandidateModel({
    required this.id,
    required this.name,
    required this.party,
    required this.position,
    this.photoUrl,
    this.biography,
    this.additionalInfo,
    this.voteCount = 0,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'],
      name: json['name'],
      party: json['party'],
      position: json['position'],
      photoUrl: json['photoUrl'],
      biography: json['biography'],
      additionalInfo: json['additionalInfo'],
      voteCount: json['voteCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'position': position,
      'photoUrl': photoUrl,
      'biography': biography,
      'additionalInfo': additionalInfo,
      'voteCount': voteCount,
    };
  }

  CandidateModel copyWith({
    String? id,
    String? name,
    String? party,
    String? position,
    String? photoUrl,
    String? biography,
    Map<String, dynamic>? additionalInfo,
    int? voteCount,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      party: party ?? this.party,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl,
      biography: biography ?? this.biography,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}