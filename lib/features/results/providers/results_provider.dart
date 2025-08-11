import 'package:flutter/material.dart';

/// Provider for managing election results data
class ResultsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _resultsData = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get resultsData => _resultsData;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Fetch results for a specific election
  Future<void> fetchElectionResults(String electionId) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock results data
      if (electionId == '1') {
        // Presidential Election (active)
        _resultsData = {
          'electionId': '1',
          'title': 'Presidential Election 2025',
          'status': 'active',
          'totalVotes': 2950,
          'lastUpdated': DateTime.now().toIso8601String(),
          'candidates': [
            {
              'id': '1',
              'name': 'Jane Smith',
              'party': 'Progressive Party',
              'votes': 1250,
              'percentage': 42.37,
            },
            {
              'id': '2',
              'name': 'John Johnson',
              'party': 'Conservative Party',
              'votes': 980,
              'percentage': 33.22,
            },
            {
              'id': '3',
              'name': 'Maria Rodriguez',
              'party': 'Liberty Party',
              'votes': 720,
              'percentage': 24.41,
            },
          ],
          'votingTrends': [
            {'date': '2025-07-20', 'votes': 1200},
            {'date': '2025-07-21', 'votes': 950},
            {'date': '2025-07-22', 'votes': 800},
          ],
          'demographicData': {
            'ageGroups': [
              {'group': '18-24', 'percentage': 15},
              {'group': '25-34', 'percentage': 22},
              {'group': '35-44', 'percentage': 25},
              {'group': '45-54', 'percentage': 18},
              {'group': '55-64', 'percentage': 12},
              {'group': '65+', 'percentage': 8},
            ],
            'regions': [
              {'name': 'North', 'votes': 850},
              {'name': 'South', 'votes': 720},
              {'name': 'East', 'votes': 680},
              {'name': 'West', 'votes': 700},
            ],
          },
        };
      } else if (electionId == '3') {
        // School Board Election (completed)
        _resultsData = {
          'electionId': '3',
          'title': 'School Board Election',
          'status': 'completed',
          'totalVotes': 1250,
          'lastUpdated': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'candidates': [
            {
              'id': '7',
              'name': 'David Lee',
              'party': 'Education First',
              'votes': 750,
              'percentage': 60.0,
              'winner': true,
            },
            {
              'id': '8',
              'name': 'Lisa Garcia',
              'party': 'Parents Coalition',
              'votes': 500,
              'percentage': 40.0,
            },
          ],
          'votingTrends': [
            {'date': '2025-07-05', 'votes': 450},
            {'date': '2025-07-06', 'votes': 350},
            {'date': '2025-07-07', 'votes': 450},
          ],
          'demographicData': {
            'ageGroups': [
              {'group': '18-24', 'percentage': 5},
              {'group': '25-34', 'percentage': 25},
              {'group': '35-44', 'percentage': 35},
              {'group': '45-54', 'percentage': 20},
              {'group': '55-64', 'percentage': 10},
              {'group': '65+', 'percentage': 5},
            ],
            'regions': [
              {'name': 'District 1', 'votes': 350},
              {'name': 'District 2', 'votes': 300},
              {'name': 'District 3', 'votes': 250},
              {'name': 'District 4', 'votes': 350},
            ],
          },
        };
      } else {
        throw Exception('No results available for this election');
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to fetch election results: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Verify a vote using receipt code
  Future<bool> verifyVote(String receiptCode) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock verification (always succeeds for demo)
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to verify vote: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  /// Export results data to a file (mock implementation)
  Future<String?> exportResults(String electionId, String format) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock export (always succeeds for demo)
      final fileName = 'election_${electionId}_results.$format';
      setLoading(false);
      return fileName;
    } catch (e) {
      setError('Failed to export results: ${e.toString()}');
      setLoading(false);
      return null;
    }
  }
}