import 'package:flutter_test/flutter_test.dart';
import 'package:bockvote/data/repositories/auth_repository.dart';
import 'package:bockvote/core/network/api_service.dart';

void main() {
  group('Authentication Tests', () {
    late AuthRepository authRepository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authRepository = AuthRepository(mockApiService);
    });

    test('Login with valid credentials should succeed', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final result = await authRepository.login(email, password);

      // Assert
      expect(result, isNotNull);
      expect(result['token'], isNotNull);
    });

    test('Login with invalid credentials should fail', () async {
      // Arrange
      const email = 'invalid@example.com';
      const password = 'wrongpassword';

      // Act & Assert
      expect(
        () => authRepository.login(email, password),
        throwsException,
      );
    });

    test('Register new user should succeed', () async {
      // Arrange
      const email = 'newuser@example.com';
      const password = 'password123';
      const firstName = 'John';
      const lastName = 'Doe';

      // Act
      final result = await authRepository.register(
        email,
        password,
        firstName,
        lastName,
      );

      // Assert
      expect(result, isNotNull);
      expect(result['user'], isNotNull);
    });

    test('Logout should clear user session', () async {
      // Act
      await authRepository.logout();

      // Assert
      final currentUser = await authRepository.getCurrentUser();
      expect(currentUser, isNull);
    });
  });
}
