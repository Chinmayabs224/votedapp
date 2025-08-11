import '../../core/network/api_service.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

/// Authentication repository for handling auth-related API calls
class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Login failed: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthResponse> register(UserRegistrationRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Registration failed: ${e.toString()}');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // Logout should not fail silently, but we don't want to throw
      // if the server is unreachable
      if (e is NetworkExceptions && !e.isNetworkError) {
        rethrow;
      }
    }
  }

  /// Refresh authentication token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Token refresh failed: ${e.toString()}');
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      return User.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<User> updateProfile(UserProfileUpdateRequest request) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        data: request.toJson(),
      );

      return User.fromJson(response.data);
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Profile update failed: ${e.toString()}');
    }
  }

  /// Change user password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Password change failed: ${e.toString()}');
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Password reset failed: ${e.toString()}');
    }
  }

  /// Verify email address
  Future<void> verifyEmail(String token) async {
    try {
      await _apiService.post(
        '/auth/verify-email',
        data: {
          'token': token,
        },
      );
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Email verification failed: ${e.toString()}');
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _apiService.post('/auth/resend-verification');
    } catch (e) {
      if (e is NetworkExceptions) {
        rethrow;
      }
      throw NetworkExceptions(message: 'Failed to resend verification email: ${e.toString()}');
    }
  }
}

/// Authentication response model
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token will expire soon (within 5 minutes)
  bool get willExpireSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }
}
