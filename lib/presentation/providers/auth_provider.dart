import 'package:flutter/foundation.dart';
import '../../data/models/admin.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  Admin? _currentAdmin;
  String? _errorMessage;

  AuthStatus get status => _status;
  Admin? get currentAdmin => _currentAdmin;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> checkAuthStatus() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final admin = await _authRepository.getCurrentAdmin();

        if (admin != null) {
          _currentAdmin = admin;
          _status = AuthStatus.authenticated;
        } else {
          final storedAdmin = await _authRepository.getStoredAdmin();
          if (storedAdmin != null) {
            _currentAdmin = storedAdmin;
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.unauthenticated;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Error checking authentication status';
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final admin = await _authRepository.login(username, password);

      if (admin != null) {
        _currentAdmin = admin;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Incorrect username or password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _currentAdmin = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error logging out';
      notifyListeners();
    }
  }

  Future<void> refreshAdminInfo() async {
    try {
      final admin = await _authRepository.getCurrentAdmin();
      if (admin != null) {
        _currentAdmin = admin;
        notifyListeners();
      }
    } catch (e) {

    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}