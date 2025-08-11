/// Election model representing an election in the system
class ElectionModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'upcoming', 'active', 'completed', 'cancelled'
  final List<String> candidateIds;
  final Map<String, dynamic>? rules;
  final Map<String, dynamic>? results;

  ElectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.candidateIds,
    this.rules,
    this.results,
  });

  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    return ElectionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      candidateIds: List<String>.from(json['candidateIds']),
      rules: json['rules'],
      results: json['results'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'candidateIds': candidateIds,
      'rules': rules,
      'results': results,
    };
  }

  ElectionModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    List<String>? candidateIds,
    Map<String, dynamic>? rules,
    Map<String, dynamic>? results,
  }) {
    return ElectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      candidateIds: candidateIds ?? this.candidateIds,
      rules: rules ?? this.rules,
      results: results ?? this.results,
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && status == 'active';
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startDate) && status == 'upcoming';
  }

  bool get isCompleted {
    final now = DateTime.now();
    return now.isAfter(endDate) || status == 'completed';
  }
}