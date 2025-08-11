import 'package:equatable/equatable.dart';

/// Candidate model for the Bockvote application
class Candidate extends Equatable {
  final String id;
  final String name;
  final String? party;
  final String? description;
  final String? photoUrl;
  final String? experience;
  final String? education;
  final String? platform;
  final String? website;
  final String? email;
  final String? phone;
  final List<String> electionIds;
  final CandidateStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final Map<String, dynamic>? metadata;

  const Candidate({
    required this.id,
    required this.name,
    this.party,
    this.description,
    this.photoUrl,
    this.experience,
    this.education,
    this.platform,
    this.website,
    this.email,
    this.phone,
    required this.electionIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.metadata,
  });

  /// Create Candidate from JSON
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] as String,
      name: json['name'] as String,
      party: json['party'] as String?,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      experience: json['experience'] as String?,
      education: json['education'] as String?,
      platform: json['platform'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      electionIds: List<String>.from(json['electionIds'] as List? ?? []),
      status: CandidateStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Candidate to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'description': description,
      'photoUrl': photoUrl,
      'experience': experience,
      'education': education,
      'platform': platform,
      'website': website,
      'email': email,
      'phone': phone,
      'electionIds': electionIds,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Candidate copyWith({
    String? id,
    String? name,
    String? party,
    String? description,
    String? photoUrl,
    String? experience,
    String? education,
    String? platform,
    String? website,
    String? email,
    String? phone,
    List<String>? electionIds,
    CandidateStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return Candidate(
      id: id ?? this.id,
      name: name ?? this.name,
      party: party ?? this.party,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      platform: platform ?? this.platform,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      electionIds: electionIds ?? this.electionIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if candidate is active
  bool get isActive => status == CandidateStatus.active;

  /// Check if candidate is approved
  bool get isApproved => status == CandidateStatus.approved;

  /// Check if candidate is pending approval
  bool get isPending => status == CandidateStatus.pending;

  /// Get display name with party
  String get displayNameWithParty {
    if (party != null && party!.isNotEmpty) {
      return '$name ($party)';
    }
    return name;
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'C';
  }

  /// Check if candidate is running in specific election
  bool isRunningInElection(String electionId) {
    return electionIds.contains(electionId);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        party,
        description,
        photoUrl,
        experience,
        education,
        platform,
        website,
        email,
        phone,
        electionIds,
        status,
        createdAt,
        updatedAt,
        userId,
        metadata,
      ];
}

/// Candidate status enumeration
enum CandidateStatus {
  pending('pending'),
  approved('approved'),
  active('active'),
  inactive('inactive'),
  rejected('rejected'),
  withdrawn('withdrawn');

  const CandidateStatus(this.value);

  final String value;

  static CandidateStatus fromString(String value) {
    return CandidateStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CandidateStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case CandidateStatus.pending:
        return 'Pending Approval';
      case CandidateStatus.approved:
        return 'Approved';
      case CandidateStatus.active:
        return 'Active';
      case CandidateStatus.inactive:
        return 'Inactive';
      case CandidateStatus.rejected:
        return 'Rejected';
      case CandidateStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

/// Candidate registration request
class CandidateRegistrationRequest {
  final String name;
  final String? party;
  final String? description;
  final String? photoUrl;
  final String? experience;
  final String? education;
  final String? platform;
  final String? website;
  final String? email;
  final String? phone;
  final List<String> electionIds;

  const CandidateRegistrationRequest({
    required this.name,
    this.party,
    this.description,
    this.photoUrl,
    this.experience,
    this.education,
    this.platform,
    this.website,
    this.email,
    this.phone,
    required this.electionIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'party': party,
      'description': description,
      'photoUrl': photoUrl,
      'experience': experience,
      'education': education,
      'platform': platform,
      'website': website,
      'email': email,
      'phone': phone,
      'electionIds': electionIds,
    };
  }
}

/// Candidate update request
class CandidateUpdateRequest {
  final String? name;
  final String? party;
  final String? description;
  final String? photoUrl;
  final String? experience;
  final String? education;
  final String? platform;
  final String? website;
  final String? email;
  final String? phone;
  final List<String>? electionIds;
  final CandidateStatus? status;

  const CandidateUpdateRequest({
    this.name,
    this.party,
    this.description,
    this.photoUrl,
    this.experience,
    this.education,
    this.platform,
    this.website,
    this.email,
    this.phone,
    this.electionIds,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (party != null) data['party'] = party;
    if (description != null) data['description'] = description;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (experience != null) data['experience'] = experience;
    if (education != null) data['education'] = education;
    if (platform != null) data['platform'] = platform;
    if (website != null) data['website'] = website;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (electionIds != null) data['electionIds'] = electionIds;
    if (status != null) data['status'] = status!.value;
    return data;
  }
}
