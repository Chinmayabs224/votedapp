import 'package:flutter/material.dart';

/// Provider for managing dashboard data
class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardData = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Fetch dashboard data for a user
  Future<void> fetchDashboardData(String userId, String role) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock dashboard data based on user role
      if (role == 'admin') {
        _dashboardData = {
          'totalUsers': 1250,
          'totalElections': 5,
          'activeElections': 2,
          'completedElections': 3,
          'totalVotes': 3750,
          'recentActivity': [
            {
              'type': 'election_created',
              'title': 'City Council Election created',
              'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            },
            {
              'type': 'election_started',
              'title': 'Presidential Election 2025 started',
              'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            },
            {
              'type': 'election_ended',
              'title': 'School Board Election ended',
              'timestamp': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            },
          ],
          'userRegistrations': [
            {'date': '2025-01-01', 'count': 25},
            {'date': '2025-02-01', 'count': 42},
            {'date': '2025-03-01', 'count': 58},
            {'date': '2025-04-01', 'count': 75},
            {'date': '2025-05-01', 'count': 90},
            {'date': '2025-06-01', 'count': 110},
          ],
        };
      } else if (role == 'voter') {
        _dashboardData = {
          'upcomingElections': 1,
          'activeElections': 1,
          'completedElections': 1,
          'votesSubmitted': 1,
          'recentActivity': [
            {
              'type': 'vote_cast',
              'title': 'You voted in Presidential Election 2025',
              'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            },
            {
              'type': 'election_started',
              'title': 'Presidential Election 2025 started',
              'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            },
            {
              'type': 'election_ended',
              'title': 'School Board Election ended',
              'timestamp': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            },
          ],
        };
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to fetch dashboard data: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}