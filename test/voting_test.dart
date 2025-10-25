import 'package:flutter_test/flutter_test.dart';
import 'package:bockvote/data/repositories/voting_repository.dart';
import 'package:bockvote/core/network/api_service.dart';

void main() {
  group('Voting Tests', () {
    late VotingRepository votingRepository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      votingRepository = VotingRepository(mockApiService);
    });

    test('Get elections should return list of elections', () async {
      // Act
      final elections = await votingRepository.getElections();

      // Assert
      expect(elections, isNotNull);
      expect(elections, isList);
    });

    test('Cast vote should succeed for valid election', () async {
      // Arrange
      const electionId = 'election-1';
      const candidateId = 'candidate-1';

      // Act
      final result = await votingRepository.castVote(electionId, candidateId);

      // Assert
      expect(result, isNotNull);
      expect(result['txHash'], isNotNull);
    });

    test('Cast vote twice in same election should fail', () async {
      // Arrange
      const electionId = 'election-1';
      const candidateId = 'candidate-1';

      // Act - First vote
      await votingRepository.castVote(electionId, candidateId);

      // Act & Assert - Second vote should fail
      expect(
        () => votingRepository.castVote(electionId, candidateId),
        throwsException,
      );
    });

    test('Get election results should return vote counts', () async {
      // Arrange
      const electionId = 'election-1';

      // Act
      final results = await votingRepository.getResults(electionId);

      // Assert
      expect(results, isNotNull);
      expect(results['totalVotes'], isNotNull);
      expect(results['candidates'], isList);
    });

    test('Verify vote should confirm blockchain transaction', () async {
      // Arrange
      const voteId = 'vote-1';

      // Act
      final verification = await votingRepository.verifyVote(voteId);

      // Assert
      expect(verification, isNotNull);
      expect(verification['verified'], isTrue);
      expect(verification['txHash'], isNotNull);
    });
  });
}
