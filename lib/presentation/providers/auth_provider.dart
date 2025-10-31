import 'package:flutter/material.dart';
import '../../data/models/admin.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  Admin? _admin;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  Admin? get admin => _admin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize - check if already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        _admin = await _repository.getCurrentAdmin();
        _isAuthenticated = _admin != null;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(username, password);
      
      if (result != null) {
        _admin = result['admin'] as Admin;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _admin = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh current admin data
  Future<void> refreshAdmin() async {
    try {
      _admin = await _repository.getCurrentAdmin();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check permissions
  bool hasPermission(String permission) {
    if (_admin == null) return false;
    return _admin!.permissions.contains(permission);
  }

  /// Check if super admin
  bool get isSuperAdmin => _admin?.isSuperAdmin ?? false;

  /// Check if admin
  bool get isAdmin => _admin?.isAdmin ?? false;

  /// Check if viewer
  bool get isViewer => _admin?.isViewer ?? false;
}
