import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Authentication provider for managing user authentication state
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock user data for demonstration
      if (email == 'user@example.com' && password == 'password') {
        final user = UserModel(
          id: '1',
          name: 'John Doe',
          email: email,
          role: 'voter',
          isVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        setUser(user);
        return true;
      } else {
        setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Register a new user
  Future<bool> register(String name, String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock registration
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: 'voter',
        isVerified: false,
        createdAt: DateTime.now(),
      );

      setUser(user);
      setLoading(false);
      return true;
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    setLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      setUser(null);
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}