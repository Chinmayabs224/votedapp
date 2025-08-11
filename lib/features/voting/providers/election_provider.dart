import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../models/election_model.dart';
import '../models/vote_model.dart';

/// Provider for managing elections and voting
class ElectionProvider extends ChangeNotifier {
  List<ElectionModel> _elections = [];
  List<CandidateModel> _candidates = [];
  final List<VoteModel> _votes = [];
  bool _isLoading = false;
  String? _error;

  List<ElectionModel> get elections => _elections;
  List<CandidateModel> get candidates => _candidates;
  List<VoteModel> get votes => _votes;
  bool get isLoading => _isLoading;
  bool get isCandidatesLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Fetch all elections
  Future<void> fetchElections() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock election data
      _elections = [
        ElectionModel(
          id: '1',
          title: 'Presidential Election 2025',
          description: 'National presidential election for the term 2025-2029',
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 5)),
          status: 'active',
          candidateIds: ['1', '2', '3'],
        ),
        ElectionModel(
          id: '2',
          title: 'City Council Election',
          description: 'Local city council election for the term 2025-2027',
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          status: 'upcoming',
          candidateIds: ['4', '5', '6'],
        ),
        ElectionModel(
          id: '3',
          title: 'School Board Election',
          description: 'School board election for the term 2025-2028',
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().subtract(const Duration(days: 5)),
          status: 'completed',
          candidateIds: ['7', '8'],
          results: {
            'totalVotes': 1250,
            'candidates': [
              {'id': '7', 'votes': 750},
              {'id': '8', 'votes': 500},
            ],
          },
        ),
      ];

      // Load all candidates at once
      await _loadAllCandidates();

      notifyListeners();
    } catch (e) {
      setError('Failed to fetch elections: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Load all candidates for all elections
  Future<void> _loadAllCandidates() async {
    _candidates = [
      // Presidential Election candidates
      CandidateModel(
        id: '1',
        name: 'Jane Smith',
        party: 'Progressive Party',
        position: 'President',
        photoUrl: 'https://example.com/jane-smith.jpg',
        biography: 'Former Governor with 8 years of executive experience.',
        voteCount: 1250,
      ),
      CandidateModel(
        id: '2',
        name: 'John Johnson',
        party: 'Conservative Party',
        position: 'President',
        photoUrl: 'https://example.com/john-johnson.jpg',
        biography: 'Senator with 12 years of legislative experience.',
        voteCount: 980,
      ),
      CandidateModel(
        id: '3',
        name: 'Maria Rodriguez',
        party: 'Liberty Party',
        position: 'President',
        photoUrl: 'https://example.com/maria-rodriguez.jpg',
        biography: 'Business leader and philanthropist.',
        voteCount: 720,
      ),
      // City Council candidates
      CandidateModel(
        id: '4',
        name: 'Robert Chen',
        party: 'Community First',
        position: 'City Council',
        photoUrl: 'https://example.com/robert-chen.jpg',
        biography: 'Local business owner and community advocate.',
      ),
      CandidateModel(
        id: '5',
        name: 'Sarah Johnson',
        party: 'Progressive Party',
        position: 'City Council',
        photoUrl: 'https://example.com/sarah-johnson.jpg',
        biography: 'Former city planner with urban development expertise.',
      ),
      CandidateModel(
        id: '6',
        name: 'Michael Williams',
        party: 'Conservative Party',
        position: 'City Council',
        photoUrl: 'https://example.com/michael-williams.jpg',
        biography: 'Retired police officer and neighborhood watch organizer.',
      ),
      // School Board candidates
      CandidateModel(
        id: '7',
        name: 'David Lee',
        party: 'Education First',
        position: 'School Board',
        photoUrl: 'https://example.com/david-lee.jpg',
        biography: 'Former principal with 15 years in education.',
        voteCount: 750,
      ),
      CandidateModel(
        id: '8',
        name: 'Lisa Garcia',
        party: 'Parents Coalition',
        position: 'School Board',
        photoUrl: 'https://example.com/lisa-garcia.jpg',
        biography: 'PTA president and education advocate.',
        voteCount: 500,
      ),
    ];
  }

  /// Fetch candidates for a specific election
  Future<void> fetchCandidates(String electionId) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Find the election
      final election = _elections.firstWhere(
        (e) => e.id == electionId,
        orElse: () => throw Exception('Election not found'),
      );

      // Mock candidate data based on election
      if (electionId == '1') {
        _candidates = [
          CandidateModel(
            id: '1',
            name: 'Jane Smith',
            party: 'Progressive Party',
            position: 'President',
            photoUrl: 'https://example.com/jane-smith.jpg',
            biography: 'Former Governor with 8 years of executive experience.',
            voteCount: 1250,
          ),
          CandidateModel(
            id: '2',
            name: 'John Johnson',
            party: 'Conservative Party',
            position: 'President',
            photoUrl: 'https://example.com/john-johnson.jpg',
            biography: 'Senator with 12 years of legislative experience.',
            voteCount: 980,
          ),
          CandidateModel(
            id: '3',
            name: 'Maria Rodriguez',
            party: 'Liberty Party',
            position: 'President',
            photoUrl: 'https://example.com/maria-rodriguez.jpg',
            biography: 'Business leader and philanthropist.',
            voteCount: 720,
          ),
        ];
      } else if (electionId == '2') {
        _candidates = [
          CandidateModel(
            id: '4',
            name: 'Robert Chen',
            party: 'Community First',
            position: 'City Council',
            photoUrl: 'https://example.com/robert-chen.jpg',
            biography: 'Local business owner and community advocate.',
          ),
          CandidateModel(
            id: '5',
            name: 'Sarah Johnson',
            party: 'Progressive Party',
            position: 'City Council',
            photoUrl: 'https://example.com/sarah-johnson.jpg',
            biography: 'Former city planner with urban development expertise.',
          ),
          CandidateModel(
            id: '6',
            name: 'Michael Williams',
            party: 'Conservative Party',
            position: 'City Council',
            photoUrl: 'https://example.com/michael-williams.jpg',
            biography: 'Retired police officer and neighborhood watch organizer.',
          ),
        ];
      } else if (electionId == '3') {
        _candidates = [
          CandidateModel(
            id: '7',
            name: 'David Lee',
            party: 'Education First',
            position: 'School Board',
            photoUrl: 'https://example.com/david-lee.jpg',
            biography: 'Former principal with 15 years in education.',
            voteCount: 750,
          ),
          CandidateModel(
            id: '8',
            name: 'Lisa Garcia',
            party: 'Parents Coalition',
            position: 'School Board',
            photoUrl: 'https://example.com/lisa-garcia.jpg',
            biography: 'PTA president and education advocate.',
            voteCount: 500,
          ),
        ];
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to fetch candidates: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Cast a vote in an election
  Future<bool> castVote(String userId, String electionId, String candidateId) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Check if user has already voted in this election
      final hasVoted = _votes.any(
        (vote) => vote.userId == userId && vote.electionId == electionId,
      );

      if (hasVoted) {
        setError('You have already voted in this election');
        return false;
      }

      // Create a new vote
      final vote = VoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        electionId: electionId,
        candidateId: candidateId,
        timestamp: DateTime.now(),
        receiptCode: _generateReceiptCode(),
        isVerified: true,
      );

      _votes.add(vote);

      // Update candidate vote count
      final candidateIndex = _candidates.indexWhere((c) => c.id == candidateId);
      if (candidateIndex != -1) {
        final candidate = _candidates[candidateIndex];
        _candidates[candidateIndex] = candidate.copyWith(
          voteCount: candidate.voteCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to cast vote: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get user's votes
  List<VoteModel> getUserVotes(String userId) {
    return _votes.where((vote) => vote.userId == userId).toList();
  }

  /// Get election by ID
  ElectionModel? getElectionById(String id) {
    try {
      return _elections.firstWhere((election) => election.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get candidate by ID
  CandidateModel? getCandidateById(String id) {
    try {
      return _candidates.firstWhere((candidate) => candidate.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get candidates for a specific election
  List<CandidateModel> getCandidatesForElection(String electionId) {
    final election = getElectionById(electionId);
    if (election == null) return [];

    return _candidates.where((candidate) =>
      election.candidateIds.contains(candidate.id)
    ).toList();
  }

  /// Get user's vote for a specific election
  VoteModel? getUserVoteForElection(String userId, String electionId) {
    try {
      return _votes.firstWhere(
        (vote) => vote.userId == userId && vote.electionId == electionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch candidates for a specific election (async version)
  Future<void> fetchCandidatesForElection(String electionId) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Candidates are already loaded with fetchElections
      // This method exists for compatibility
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch candidates: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Generate a random receipt code for vote verification
  String _generateReceiptCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final code = List.generate(10, (index) {
      final randomIndex = (random.codeUnitAt(index % random.length) + index) % chars.length;
      return chars[randomIndex];
    }).join();
    return code;
  }
}