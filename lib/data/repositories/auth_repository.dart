import 'package:dio/dio.dart';
import '../models/admin.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<Admin?> login(String username, String password) async {
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

        await _storageService.saveToken(data['access_token']);

        await _storageService.saveAdminInfo(data['admin']);

        return Admin.fromJson(data['admin']);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Incorrect username or password');
      }
      throw Exception('Error connecting to server');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  Future<Admin?> getCurrentAdmin() async {
    try {
      final response = await _apiService.get(ApiConstants.me);

      if (response.statusCode == 200) {
        final admin = Admin.fromJson(response.data);
        await _storageService.saveAdminInfo(response.data);
        return admin;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (e) {

    } finally {
      await _storageService.clearAll();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null;
  }

  Future<Admin?> getStoredAdmin() async {
    final adminData = await _storageService.getAdminInfo();
    if (adminData != null) {
      return Admin.fromJson(adminData);
    }
    return null;
  }
}