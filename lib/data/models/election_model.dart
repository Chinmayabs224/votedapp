import 'package:equatable/equatable.dart';

/// Election model for the Bockvote application
class Election extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ElectionStatus status;
  final ElectionType type;
  final String? imageUrl;
  final List<String> candidateIds;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Election({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.type,
    this.imageUrl,
    required this.candidateIds,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  /// Create Election from JSON
  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: ElectionStatus.fromString(json['status'] as String? ?? 'draft'),
      type: ElectionType.fromString(json['type'] as String? ?? 'general'),
      imageUrl: json['imageUrl'] as String?,
      candidateIds: List<String>.from(json['candidateIds'] as List? ?? []),
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  /// Convert Election to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.value,
      'type': type.value,
      'imageUrl': imageUrl,
      'candidateIds': candidateIds,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  /// Create a copy with updated fields
  Election copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ElectionStatus? status,
    ElectionType? type,
    String? imageUrl,
    List<String>? candidateIds,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Election(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      candidateIds: candidateIds ?? this.candidateIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Check if election is active (ongoing)
  bool get isActive {
    final now = DateTime.now();
    return status == ElectionStatus.active && 
           now.isAfter(startDate) && 
           now.isBefore(endDate);
  }

  /// Check if election is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return status == ElectionStatus.scheduled && now.isBefore(startDate);
  }

  /// Check if election is completed
  bool get isCompleted {
    return status == ElectionStatus.completed || 
           (status == ElectionStatus.active && DateTime.now().isAfter(endDate));
  }

  /// Check if election is draft
  bool get isDraft => status == ElectionStatus.draft;

  /// Get election duration
  Duration get duration => endDate.difference(startDate);

  /// Get time remaining (if active)
  Duration? get timeRemaining {
    if (!isActive) return null;
    final now = DateTime.now();
    return endDate.difference(now);
  }

  /// Get time until start (if upcoming)
  Duration? get timeUntilStart {
    if (!isUpcoming) return null;
    final now = DateTime.now();
    return startDate.difference(now);
  }

  /// Check if user can vote
  bool canVote() {
    return isActive;
  }

  /// Check if results can be viewed
  bool canViewResults() {
    return isCompleted || (settings?['showLiveResults'] == true && isActive);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        status,
        type,
        imageUrl,
        candidateIds,
        settings,
        createdAt,
        updatedAt,
        createdBy,
      ];
}

/// Election status enumeration
enum ElectionStatus {
  draft('draft'),
  scheduled('scheduled'),
  active('active'),
  completed('completed'),
  cancelled('cancelled'),
  suspended('suspended');

  const ElectionStatus(this.value);

  final String value;

  static ElectionStatus fromString(String value) {
    return ElectionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ElectionStatus.draft,
    );
  }

  String get displayName {
    switch (this) {
      case ElectionStatus.draft:
        return 'Draft';
      case ElectionStatus.scheduled:
        return 'Scheduled';
      case ElectionStatus.active:
        return 'Active';
      case ElectionStatus.completed:
        return 'Completed';
      case ElectionStatus.cancelled:
        return 'Cancelled';
      case ElectionStatus.suspended:
        return 'Suspended';
    }
  }
}

/// Election type enumeration
enum ElectionType {
  general('general'),
  primary('primary'),
  local('local'),
  referendum('referendum'),
  poll('poll');

  const ElectionType(this.value);

  final String value;

  static ElectionType fromString(String value) {
    return ElectionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ElectionType.general,
    );
  }

  String get displayName {
    switch (this) {
      case ElectionType.general:
        return 'General Election';
      case ElectionType.primary:
        return 'Primary Election';
      case ElectionType.local:
        return 'Local Election';
      case ElectionType.referendum:
        return 'Referendum';
      case ElectionType.poll:
        return 'Poll';
    }
  }
}

/// Election creation request
class ElectionCreateRequest {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ElectionType type;
  final String? imageUrl;
  final Map<String, dynamic>? settings;

  const ElectionCreateRequest({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.imageUrl,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.value,
      'imageUrl': imageUrl,
      'settings': settings,
    };
  }
}

/// Election update request
class ElectionUpdateRequest {
  final String? title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ElectionStatus? status;
  final ElectionType? type;
  final String? imageUrl;
  final Map<String, dynamic>? settings;

  const ElectionUpdateRequest({
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.type,
    this.imageUrl,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (startDate != null) data['startDate'] = startDate!.toIso8601String();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (status != null) data['status'] = status!.value;
    if (type != null) data['type'] = type!.value;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (settings != null) data['settings'] = settings;
    return data;
  }
}
