import 'package:flutter/material.dart';
import 'package:lost_and_found_hub/models/user.dart';
import 'package:lost_and_found_hub/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isAdmin => _authService.isAdmin;
  User? get currentUser => _authService.currentUser;
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.init();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      if (username == 'admin' && password == 'password') {

        await _authService.login(username, password);
        return true;
      } else {
        _error = 'Invalid username or password';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<User?> register({
    required String username,
    required String password,
    required bool isAdmin,
    String? name,
    String? email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        username: username,
        password: password,
        isAdmin: isAdmin,
        name: name,
        email: email,
      );

      return user;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.changePassword(currentPassword, newPassword);

      if (!success) {
        _error = 'Current password is incorrect';
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
}
