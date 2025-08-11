import 'package:flutter/foundation.dart';
import '../../core/network/network_exceptions.dart';
import '../repositories/election_repository.dart';
import '../models/election_model.dart';
import '../models/candidate_model.dart';

/// Election provider for managing election state
class ElectionProvider extends ChangeNotifier {
  final ElectionRepository _electionRepository;

  List<Election> _elections = [];
  Election? _selectedElection;
  List<Candidate> _selectedElectionCandidates = [];
  bool _isLoading = false;
  bool _isLoadingCandidates = false;
  String? _error;

  ElectionProvider(this._electionRepository);

  // Getters
  List<Election> get elections => _elections;
  Election? get selectedElection => _selectedElection;
  List<Candidate> get selectedElectionCandidates => _selectedElectionCandidates;
  bool get isLoading => _isLoading;
  bool get isLoadingCandidates => _isLoadingCandidates;
  String? get error => _error;

  // Filtered elections
  List<Election> get activeElections => 
      _elections.where((election) => election.isActive).toList();
  
  List<Election> get upcomingElections => 
      _elections.where((election) => election.isUpcoming).toList();
  
  List<Election> get completedElections => 
      _elections.where((election) => election.isCompleted).toList();

  /// Load all elections
  Future<void> loadElections({
    ElectionStatus? status,
    ElectionType? type,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      final elections = await _electionRepository.getElections(
        status: status,
        type: type,
      );
      
      _elections = elections;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load election by ID
  Future<void> loadElectionById(String electionId) async {
    _setLoading(true);
    _clearError();

    try {
      final election = await _electionRepository.getElectionById(electionId);
      _selectedElection = election;
      
      // Update in elections list if it exists
      final index = _elections.indexWhere((e) => e.id == electionId);
      if (index != -1) {
        _elections[index] = election;
      } else {
        _elections.add(election);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load candidates for selected election
  Future<void> loadElectionCandidates(String electionId) async {
    _setLoadingCandidates(true);
    _clearError();

    try {
      final candidates = await _electionRepository.getElectionCandidates(electionId);
      _selectedElectionCandidates = candidates;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoadingCandidates(false);
    }
  }

  /// Create new election
  Future<bool> createElection(ElectionCreateRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final election = await _electionRepository.createElection(request);
      _elections.insert(0, election);
      _selectedElection = election;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update election
  Future<bool> updateElection(String electionId, ElectionUpdateRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedElection = await _electionRepository.updateElection(electionId, request);
      
      // Update in elections list
      final index = _elections.indexWhere((e) => e.id == electionId);
      if (index != -1) {
        _elections[index] = updatedElection;
      }
      
      // Update selected election if it's the same
      if (_selectedElection?.id == electionId) {
        _selectedElection = updatedElection;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete election
  Future<bool> deleteElection(String electionId) async {
    _setLoading(true);
    _clearError();

    try {
      await _electionRepository.deleteElection(electionId);
      
      // Remove from elections list
      _elections.removeWhere((e) => e.id == electionId);
      
      // Clear selected election if it's the same
      if (_selectedElection?.id == electionId) {
        _selectedElection = null;
        _selectedElectionCandidates.clear();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Start election
  Future<bool> startElection(String electionId) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedElection = await _electionRepository.startElection(electionId);
      _updateElectionInList(updatedElection);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// End election
  Future<bool> endElection(String electionId) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedElection = await _electionRepository.endElection(electionId);
      _updateElectionInList(updatedElection);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel election
  Future<bool> cancelElection(String electionId) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedElection = await _electionRepository.cancelElection(electionId);
      _updateElectionInList(updatedElection);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search elections
  Future<void> searchElections(String query) async {
    if (query.isEmpty) {
      await loadElections();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final elections = await _electionRepository.searchElections(query);
      _elections = elections;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Select election
  void selectElection(Election election) {
    _selectedElection = election;
    _selectedElectionCandidates.clear();
    notifyListeners();
    
    // Load candidates for the selected election
    loadElectionCandidates(election.id);
  }

  /// Clear selected election
  void clearSelectedElection() {
    _selectedElection = null;
    _selectedElectionCandidates.clear();
    notifyListeners();
  }

  /// Get election by ID from current list
  Election? getElectionById(String electionId) {
    try {
      return _elections.firstWhere((election) => election.id == electionId);
    } catch (e) {
      return null;
    }
  }

  /// Get candidate by ID from current list
  Candidate? getCandidateById(String candidateId) {
    try {
      return _selectedElectionCandidates.firstWhere((candidate) => candidate.id == candidateId);
    } catch (e) {
      return null;
    }
  }

  /// Update election in list
  void _updateElectionInList(Election updatedElection) {
    final index = _elections.indexWhere((e) => e.id == updatedElection.id);
    if (index != -1) {
      _elections[index] = updatedElection;
    }
    
    if (_selectedElection?.id == updatedElection.id) {
      _selectedElection = updatedElection;
    }
    
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set candidates loading state
  void _setLoadingCandidates(bool loading) {
    _isLoadingCandidates = loading;
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

  /// Refresh elections
  Future<void> refresh() async {
    await loadElections(forceRefresh: true);
  }
}
