import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Authentication provider for managing user authentication state
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;
  final ApiClient _apiClient;

  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepository, this._prefs, this._apiClient) {
    _loadStoredAuth();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get accessToken => _accessToken;

  /// Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      _accessToken = _prefs.getString(AppConstants.authTokenKey);
      _refreshToken = _prefs.getString(AppConstants.refreshTokenKey);
      final userDataJson = _prefs.getString(AppConstants.userDataKey);
      final expiresAtString = _prefs.getString('${AppConstants.authTokenKey}_expires_at');

      if (_accessToken != null && userDataJson != null) {
        _currentUser = User.fromJson(_parseJsonString(userDataJson));
        
        if (expiresAtString != null) {
          _tokenExpiresAt = DateTime.parse(expiresAtString);
        }

        // Set token in API client
        _apiClient.setAuthToken(_accessToken!);

        // Check if token needs refresh
        if (_tokenExpiresAt != null && _shouldRefreshToken()) {
          await _refreshTokenIfNeeded();
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
      await _clearStoredAuth();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authRepository.login(email, password);
      await _handleAuthResponse(authResponse);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user
  Future<bool> register(UserRegistrationRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authRepository.register(request);
      await _handleAuthResponse(authResponse);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);

    try {
      // Call logout endpoint (don't wait for it to complete)
      _authRepository.logout().catchError((e) {
        debugPrint('Logout API call failed: $e');
      });
    } finally {
      await _clearAuth();
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserProfileUpdateRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authRepository.updateProfile(request);
      _currentUser = updatedUser;
      await _storeUserData(updatedUser);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Request password reset
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.forgotPassword(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.resetPassword(token, newPassword);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (!isLoggedIn) return;

    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser = user;
      await _storeUserData(user);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      // Don't show error to user for background refresh
    }
  }

  /// Handle authentication response
  Future<void> _handleAuthResponse(AuthResponse authResponse) async {
    _currentUser = authResponse.user;
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;
    _tokenExpiresAt = authResponse.expiresAt;

    // Store in secure storage
    await _storeAuthData(authResponse);

    // Set token in API client
    _apiClient.setAuthToken(_accessToken!);

    notifyListeners();
  }

  /// Store authentication data
  Future<void> _storeAuthData(AuthResponse authResponse) async {
    await Future.wait([
      _prefs.setString(AppConstants.authTokenKey, authResponse.accessToken),
      _prefs.setString(AppConstants.refreshTokenKey, authResponse.refreshToken),
      _prefs.setString(AppConstants.userDataKey, _encodeJsonString(authResponse.user.toJson())),
      _prefs.setString('${AppConstants.authTokenKey}_expires_at', authResponse.expiresAt.toIso8601String()),
    ]);
  }

  /// Store user data only
  Future<void> _storeUserData(User user) async {
    await _prefs.setString(AppConstants.userDataKey, _encodeJsonString(user.toJson()));
  }

  /// Clear authentication data
  Future<void> _clearAuth() async {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiresAt = null;

    await _clearStoredAuth();
    _apiClient.clearAuthToken();
    notifyListeners();
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    await Future.wait([
      _prefs.remove(AppConstants.authTokenKey),
      _prefs.remove(AppConstants.refreshTokenKey),
      _prefs.remove(AppConstants.userDataKey),
      _prefs.remove('${AppConstants.authTokenKey}_expires_at'),
    ]);
  }

  /// Check if token should be refreshed
  bool _shouldRefreshToken() {
    if (_tokenExpiresAt == null) return false;
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(_tokenExpiresAt!);
  }

  /// Refresh token if needed
  Future<void> _refreshTokenIfNeeded() async {
    if (_refreshToken == null || !_shouldRefreshToken()) return;

    try {
      final authResponse = await _authRepository.refreshToken(_refreshToken!);
      await _handleAuthResponse(authResponse);
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      await _clearAuth();
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  /// Parse JSON string safely
  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
      return {};
    }
  }

  /// Encode JSON to string safely
  String _encodeJsonString(Map<String, dynamic> json) {
    try {
      return jsonEncode(json);
    } catch (e) {
      debugPrint('Error encoding JSON: $e');
      return '{}';
    }
  }
}
