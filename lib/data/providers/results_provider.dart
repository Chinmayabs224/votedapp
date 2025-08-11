import 'package:flutter/foundation.dart';
import '../../core/network/network_exceptions.dart';
import '../repositories/voting_repository.dart';
import '../models/vote_model.dart';

/// Results provider for managing election results state
class ResultsProvider extends ChangeNotifier {
  final VotingRepository _votingRepository;

  List<ElectionResults> _allResults = [];
  ElectionResults? _selectedElectionResults;
  VotingStatistics? _selectedElectionStatistics;
  bool _isLoading = false;
  bool _isLoadingStatistics = false;
  String? _error;

  ResultsProvider(this._votingRepository);

  // Getters
  List<ElectionResults> get allResults => _allResults;
  ElectionResults? get selectedElectionResults => _selectedElectionResults;
  VotingStatistics? get selectedElectionStatistics => _selectedElectionStatistics;
  bool get isLoading => _isLoading;
  bool get isLoadingStatistics => _isLoadingStatistics;
  String? get error => _error;

  // Filtered results
  List<ElectionResults> get finalResults => 
      _allResults.where((result) => result.isFinal).toList();
  
  List<ElectionResults> get liveResults => 
      _allResults.where((result) => !result.isFinal).toList();

  /// Load all election results
  Future<void> loadAllResults({
    bool finalOnly = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      final results = await _votingRepository.getAllResults(
        finalOnly: finalOnly,
      );
      
      _allResults = results;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load results for specific election
  Future<void> loadElectionResults(String electionId, {bool isLive = false}) async {
    _setLoading(true);
    _clearError();

    try {
      final results = isLive 
          ? await _votingRepository.getLiveElectionResults(electionId)
          : await _votingRepository.getElectionResults(electionId);
      
      _selectedElectionResults = results;
      
      // Update in all results list if it exists
      final index = _allResults.indexWhere((r) => r.electionId == electionId);
      if (index != -1) {
        _allResults[index] = results;
      } else {
        _allResults.add(results);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load voting statistics for election
  Future<void> loadVotingStatistics(String electionId) async {
    _setLoadingStatistics(true);
    _clearError();

    try {
      final statistics = await _votingRepository.getVotingStatistics(electionId);
      _selectedElectionStatistics = statistics;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoadingStatistics(false);
    }
  }

  /// Get results by election ID from current list
  ElectionResults? getResultsByElectionId(String electionId) {
    try {
      return _allResults.firstWhere((result) => result.electionId == electionId);
    } catch (e) {
      return null;
    }
  }

  /// Get candidate result by ID from selected election
  CandidateResult? getCandidateResult(String candidateId) {
    if (_selectedElectionResults == null) return null;
    
    try {
      return _selectedElectionResults!.candidateResults
          .firstWhere((result) => result.candidateId == candidateId);
    } catch (e) {
      return null;
    }
  }

  /// Get winning candidate from selected election
  CandidateResult? getWinner() {
    return _selectedElectionResults?.winner;
  }

  /// Get top N candidates from selected election
  List<CandidateResult> getTopCandidates(int count) {
    if (_selectedElectionResults == null) return [];
    
    final sortedResults = List<CandidateResult>.from(_selectedElectionResults!.candidateResults)
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    
    return sortedResults.take(count).toList();
  }

  /// Check if election has results
  bool hasResults(String electionId) {
    return _allResults.any((result) => result.electionId == electionId);
  }

  /// Check if selected election has live results
  bool get hasLiveResults {
    return _selectedElectionResults != null && !_selectedElectionResults!.isFinal;
  }

  /// Get total votes for selected election
  int get totalVotes {
    return _selectedElectionResults?.totalVotes ?? 0;
  }

  /// Get turnout percentage for selected election
  double get turnoutPercentage {
    if (_selectedElectionStatistics == null) return 0.0;
    return _selectedElectionStatistics!.turnoutPercentage;
  }

  /// Select election results
  void selectElectionResults(String electionId) {
    final results = getResultsByElectionId(electionId);
    if (results != null) {
      _selectedElectionResults = results;
      notifyListeners();
    }
    
    // Load statistics for the selected election
    loadVotingStatistics(electionId);
  }

  /// Clear selected election results
  void clearSelectedResults() {
    _selectedElectionResults = null;
    _selectedElectionStatistics = null;
    notifyListeners();
  }

  /// Refresh results for selected election
  Future<void> refreshSelectedElectionResults({bool isLive = false}) async {
    if (_selectedElectionResults == null) return;
    
    await loadElectionResults(_selectedElectionResults!.electionId, isLive: isLive);
  }

  /// Refresh all results
  Future<void> refreshAllResults() async {
    await loadAllResults(forceRefresh: true);
  }

  /// Auto-refresh live results (call this periodically for live elections)
  Future<void> autoRefreshLiveResults() async {
    if (_selectedElectionResults == null || _selectedElectionResults!.isFinal) {
      return;
    }
    
    try {
      final results = await _votingRepository.getLiveElectionResults(
        _selectedElectionResults!.electionId,
      );
      
      _selectedElectionResults = results;
      
      // Update in all results list
      final index = _allResults.indexWhere((r) => r.electionId == results.electionId);
      if (index != -1) {
        _allResults[index] = results;
      }
      
      notifyListeners();
    } catch (e) {
      // Don't show error for auto-refresh failures
      debugPrint('Auto-refresh failed: $e');
    }
  }

  /// Get results summary for dashboard
  ResultsSummary getResultsSummary() {
    final totalElections = _allResults.length;
    final completedElections = finalResults.length;
    final liveElections = liveResults.length;
    
    int totalVotesCast = 0;
    for (final result in _allResults) {
      totalVotesCast += result.totalVotes;
    }
    
    return ResultsSummary(
      totalElections: totalElections,
      completedElections: completedElections,
      liveElections: liveElections,
      totalVotesCast: totalVotesCast,
    );
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set statistics loading state
  void _setLoadingStatistics(bool loading) {
    _isLoadingStatistics = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is NetworkExceptions) {
      return error.userFriendlyMessage;
    }
    return error.toString();
  }
}

/// Results summary model for dashboard
class ResultsSummary {
  final int totalElections;
  final int completedElections;
  final int liveElections;
  final int totalVotesCast;

  const ResultsSummary({
    required this.totalElections,
    required this.completedElections,
    required this.liveElections,
    required this.totalVotesCast,
  });

  double get completionRate {
    if (totalElections == 0) return 0.0;
    return (completedElections / totalElections) * 100;
  }
}
