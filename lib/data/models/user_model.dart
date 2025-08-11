import 'package:equatable/equatable.dart';

/// User model for the Bockvote application
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'voter'),
      status: UserStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'profileImageUrl': profileImageUrl,
      'role': role.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? profileImageUrl,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is voter
  bool get isVoter => role == UserRole.voter;

  /// Check if user is candidate
  bool get isCandidate => role == UserRole.candidate;

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Get display name
  String get displayName => name.isNotEmpty ? name : email;

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        address,
        dateOfBirth,
        profileImageUrl,
        role,
        status,
        createdAt,
        updatedAt,
        metadata,
      ];
}

/// User role enumeration
enum UserRole {
  voter('voter'),
  candidate('candidate'),
  admin('admin'),
  moderator('moderator');

  const UserRole(this.value);

  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.voter,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.voter:
        return 'Voter';
      case UserRole.candidate:
        return 'Candidate';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.moderator:
        return 'Moderator';
    }
  }
}

/// User status enumeration
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  pending('pending');

  const UserStatus(this.value);

  final String value;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.pending:
        return 'Pending';
    }
  }
}

/// User profile update request
class UserProfileUpdateRequest {
  final String? name;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? profileImageUrl;

  const UserProfileUpdateRequest({
    this.name,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
    return data;
  }
}

/// User registration request
class UserRegistrationRequest {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final UserRole role;

  const UserRegistrationRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.role = UserRole.voter,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'role': role.value,
    };
  }
}
