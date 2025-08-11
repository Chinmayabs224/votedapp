import '../../core/network/api_service.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/election_model.dart';
import '../models/candidate_model.dart';

/// Election repository for handling election-related API calls
class ElectionRepository {
  final ApiService _apiService;

  ElectionRepository(this._apiService);

  /// Get all elections
  Future<List<Election>> getElections({
    int? page,
    int? limit,
    ElectionStatus? status,
    ElectionType? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status.value;
      if (type != null) queryParams['type'] = type.value;

      final response = await _apiService.get(
        ApiEndpoints.elections,
        queryParameters: queryParams,
      );

      final List<dynamic> electionsJson = response.data['elections'] ?? response.data;
      return electionsJson
          .map((json) => Election.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch elections: ${e.toString()}');
    }
  }

  /// Get election by ID
  Future<Election> getElectionById(String electionId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.electionById,
        {'id': electionId},
      );

      final response = await _apiService.get(endpoint);
      return Election.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch election: ${e.toString()}');
    }
  }

  /// Create new election
  Future<Election> createElection(ElectionCreateRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.createElection,
        data: request.toJson(),
      );

      return Election.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to create election: ${e.toString()}');
    }
  }

  /// Update election
  Future<Election> updateElection(String electionId, ElectionUpdateRequest request) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.updateElection,
        {'id': electionId},
      );

      final response = await _apiService.put(
        endpoint,
        data: request.toJson(),
      );

      return Election.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to update election: ${e.toString()}');
    }
  }

  /// Delete election
  Future<void> deleteElection(String electionId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.deleteElection,
        {'id': electionId},
      );

      await _apiService.delete(endpoint);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to delete election: ${e.toString()}');
    }
  }

  /// Get candidates for an election
  Future<List<Candidate>> getElectionCandidates(String electionId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.electionCandidates,
        {'id': electionId},
      );

      final response = await _apiService.get(endpoint);
      final List<dynamic> candidatesJson = response.data['candidates'] ?? response.data;
      
      return candidatesJson
          .map((json) => Candidate.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to fetch election candidates: ${e.toString()}');
    }
  }

  /// Add candidate to election
  Future<void> addCandidateToElection(String electionId, String candidateId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.electionCandidates,
        {'id': electionId},
      );

      await _apiService.post(
        endpoint,
        data: {
          'candidateId': candidateId,
        },
      );
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to add candidate to election: ${e.toString()}');
    }
  }

  /// Remove candidate from election
  Future<void> removeCandidateFromElection(String electionId, String candidateId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.electionCandidates,
        {'id': electionId},
      );

      await _apiService.delete(
        '$endpoint/$candidateId',
      );
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to remove candidate from election: ${e.toString()}');
    }
  }

  /// Get active elections
  Future<List<Election>> getActiveElections() async {
    return getElections(status: ElectionStatus.active);
  }

  /// Get upcoming elections
  Future<List<Election>> getUpcomingElections() async {
    return getElections(status: ElectionStatus.scheduled);
  }

  /// Get completed elections
  Future<List<Election>> getCompletedElections() async {
    return getElections(status: ElectionStatus.completed);
  }

  /// Search elections
  Future<List<Election>> searchElections(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.elections}/search',
        queryParameters: {
          'q': query,
        },
      );

      final List<dynamic> electionsJson = response.data['elections'] ?? response.data;
      return electionsJson
          .map((json) => Election.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to search elections: ${e.toString()}');
    }
  }

  /// Start election
  Future<Election> startElection(String electionId) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.elections}/$electionId/start',
      );

      return Election.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to start election: ${e.toString()}');
    }
  }

  /// End election
  Future<Election> endElection(String electionId) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.elections}/$electionId/end',
      );

      return Election.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to end election: ${e.toString()}');
    }
  }

  /// Cancel election
  Future<Election> cancelElection(String electionId) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.elections}/$electionId/cancel',
      );

      return Election.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to cancel election: ${e.toString()}');
    }
  }
}
