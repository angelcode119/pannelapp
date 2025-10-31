import 'package:dio/dio.dart';
import '../models/admin.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  /// Login with username and password
  /// Returns Admin data with token if successful
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // ? Save token
        final token = data['access_token'];
        await _storage.saveToken(token);
        
        // ? Save admin data
        final admin = Admin.fromJson(data['admin']);
        await _storage.saveUsername(admin.username);
        
        return {
          'token': token,
          'admin': admin,
          'expires_in': data['expires_in'] ?? 86400,
        };
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Login failed: $e');
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
      await _storage.clearAll();
      return true;
    } catch (e) {
      // ??? ??? logout endpoint fail ???? local storage ?? ??? ??
      await _storage.clearAll();
      return true;
    }
  }

  /// Get current admin info
  Future<Admin?> getCurrentAdmin() async {
    try {
      final response = await _apiService.get(ApiConstants.me);
      
      if (response.statusCode == 200) {
        return Admin.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get admin info: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  /// Get stored username
  Future<String?> getUsername() async {
    return await _storage.getUsername();
  }
}
