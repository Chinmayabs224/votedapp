import '../../core/network/api_service.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/vote_model.dart';

/// Voting repository for handling vote-related API calls
class VotingRepository {
  final ApiService _apiService;

  VotingRepository(this._apiService);

  /// Submit a vote
  Future<VoteReceipt> submitVote(VoteSubmissionRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.vote,
        data: request.toJson(),
      );

      return VoteReceipt.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to submit vote: ${e.toString()}');
    }
  }

  /// Get vote history for current user
  Future<List<VoteReceipt>> getVoteHistory({
    int? page,
    int? limit,
    String? electionId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (electionId != null) queryParams['electionId'] = electionId;

      final response = await _apiService.get(
        ApiEndpoints.voteHistory,
        queryParameters: queryParams,
      );

      final List<dynamic> votesJson = response.data['votes'] ?? response.data;
      return votesJson
          .map((json) => VoteReceipt.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch vote history: ${e.toString()}');
    }
  }

  /// Verify a vote using receipt code
  Future<VoteReceipt> verifyVote(VoteVerificationRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.voteVerification,
        data: request.toJson(),
      );

      return VoteReceipt.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to verify vote: ${e.toString()}');
    }
  }

  /// Get vote receipt by ID
  Future<VoteReceipt> getVoteReceipt(String receiptId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.voteReceipt,
        {'id': receiptId},
      );

      final response = await _apiService.get(endpoint);
      return VoteReceipt.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch vote receipt: ${e.toString()}');
    }
  }

  /// Check if user has voted in an election
  Future<bool> hasVotedInElection(String electionId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.vote}/check/$electionId',
      );

      return response.data['hasVoted'] as bool? ?? false;
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to check vote status: ${e.toString()}');
    }
  }

  /// Get election results
  Future<ElectionResults> getElectionResults(String electionId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.resultsByElection,
        {'id': electionId},
      );

      final response = await _apiService.get(endpoint);
      return ElectionResults.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch election results: ${e.toString()}');
    }
  }

  /// Get live election results
  Future<ElectionResults> getLiveElectionResults(String electionId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.liveResults,
        {'id': electionId},
      );

      final response = await _apiService.get(endpoint);
      return ElectionResults.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch live results: ${e.toString()}');
    }
  }

  /// Get all results
  Future<List<ElectionResults>> getAllResults({
    int? page,
    int? limit,
    bool? finalOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (finalOnly != null) queryParams['finalOnly'] = finalOnly;

      final response = await _apiService.get(
        ApiEndpoints.results,
        queryParameters: queryParams,
      );

      final List<dynamic> resultsJson = response.data['results'] ?? response.data;
      return resultsJson
          .map((json) => ElectionResults.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch results: ${e.toString()}');
    }
  }

  /// Get voting statistics for an election
  Future<VotingStatistics> getVotingStatistics(String electionId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.elections}/$electionId/statistics',
      );

      return VotingStatistics.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch voting statistics: ${e.toString()}');
    }
  }

  /// Get user's vote for a specific election (if allowed)
  Future<VoteReceipt?> getUserVoteForElection(String electionId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.vote}/election/$electionId',
      );

      if (response.data == null) return null;
      return VoteReceipt.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions && e.statusCode == 404) {
        return null; // User hasn't voted
      }
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch user vote: ${e.toString()}');
    }
  }
}

/// Voting statistics model
class VotingStatistics {
  final String electionId;
  final int totalEligibleVoters;
  final int totalVotesCast;
  final double turnoutPercentage;
  final Map<String, int> votesByHour;
  final DateTime lastUpdated;

  const VotingStatistics({
    required this.electionId,
    required this.totalEligibleVoters,
    required this.totalVotesCast,
    required this.turnoutPercentage,
    required this.votesByHour,
    required this.lastUpdated,
  });

  factory VotingStatistics.fromJson(Map<String, dynamic> json) {
    return VotingStatistics(
      electionId: json['electionId'] as String,
      totalEligibleVoters: json['totalEligibleVoters'] as int,
      totalVotesCast: json['totalVotesCast'] as int,
      turnoutPercentage: (json['turnoutPercentage'] as num).toDouble(),
      votesByHour: Map<String, int>.from(json['votesByHour'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'electionId': electionId,
      'totalEligibleVoters': totalEligibleVoters,
      'totalVotesCast': totalVotesCast,
      'turnoutPercentage': turnoutPercentage,
      'votesByHour': votesByHour,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
