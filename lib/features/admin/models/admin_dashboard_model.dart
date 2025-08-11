/// Model for admin dashboard data
class AdminDashboardModel {
  final int totalUsers;
  final int totalElections;
  final int activeElections;
  final int completedElections;
  final int totalVotes;
  final List<ActivityItem> recentActivity;
  final List<Map<String, dynamic>> userRegistrations;

  const AdminDashboardModel({
    required this.totalUsers,
    required this.totalElections,
    required this.activeElections,
    required this.completedElections,
    required this.totalVotes,
    required this.recentActivity,
    required this.userRegistrations,
  });

  /// Create an empty dashboard model
  factory AdminDashboardModel.empty() {
    return const AdminDashboardModel(
      totalUsers: 0,
      totalElections: 0,
      activeElections: 0,
      completedElections: 0,
      totalVotes: 0,
      recentActivity: [],
      userRegistrations: [],
    );
  }

  /// Create a copy with updated fields
  AdminDashboardModel copyWith({
    int? totalUsers,
    int? totalElections,
    int? activeElections,
    int? completedElections,
    int? totalVotes,
    List<ActivityItem>? recentActivity,
    List<Map<String, dynamic>>? userRegistrations,
  }) {
    return AdminDashboardModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalElections: totalElections ?? this.totalElections,
      activeElections: activeElections ?? this.activeElections,
      completedElections: completedElections ?? this.completedElections,
      totalVotes: totalVotes ?? this.totalVotes,
      recentActivity: recentActivity ?? this.recentActivity,
      userRegistrations: userRegistrations ?? this.userRegistrations,
    );
  }
}

/// Model for activity item in the dashboard
class ActivityItem {
  final String type;
  final String title;
  final DateTime timestamp;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.timestamp,
  });
}