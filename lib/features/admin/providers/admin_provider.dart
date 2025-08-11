import 'package:flutter/material.dart';
import '../models/admin_dashboard_model.dart';

/// Provider for managing admin dashboard data
class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  AdminDashboardModel _dashboardData = AdminDashboardModel.empty();

  bool get isLoading => _isLoading;
  String? get error => _error;
  AdminDashboardModel get dashboardData => _dashboardData;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Fetch dashboard data for admin
  Future<void> fetchDashboardData() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock dashboard data
      _dashboardData = AdminDashboardModel(
        totalUsers: 1250,
        totalElections: 5,
        activeElections: 2,
        completedElections: 3,
        totalVotes: 3750,
        recentActivity: [
          ActivityItem(
            type: 'election_created',
            title: 'City Council Election created',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ActivityItem(
            type: 'election_started',
            title: 'Presidential Election 2025 started',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ActivityItem(
            type: 'election_ended',
            title: 'School Board Election ended',
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ActivityItem(
            type: 'user_registered',
            title: 'New candidate registered',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        userRegistrations: [
          {'date': '2025-01-01', 'count': 25},
          {'date': '2025-02-01', 'count': 42},
          {'date': '2025-03-01', 'count': 58},
          {'date': '2025-04-01', 'count': 75},
          {'date': '2025-05-01', 'count': 90},
          {'date': '2025-06-01', 'count': 110},
        ],
      );

      notifyListeners();
    } catch (e) {
      setError('Failed to fetch dashboard data: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Fetch users data for admin
  Future<void> fetchUsersData() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock implementation - would be replaced with actual API call
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch users data: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Fetch elections data for admin
  Future<void> fetchElectionsData() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock implementation - would be replaced with actual API call
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch elections data: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Fetch reports data for admin
  Future<void> fetchReportsData() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock implementation - would be replaced with actual API call
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch reports data: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}