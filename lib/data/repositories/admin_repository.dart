import 'package:dio/dio.dart';
import '../models/admin.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class AdminRepository {
  final ApiService _apiService = ApiService();

  /// Get list of all admins (Super Admin only)
  Future<List<Admin>> getAllAdmins() async {
    try {
      final response = await _apiService.get(ApiConstants.adminList);

      if (response.statusCode == 200) {
        final List adminsJson = response.data['admins'] ?? response.data;
        return adminsJson.map((json) => Admin.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch admins: $e');
    }
  }

  /// Create new admin
  Future<Admin?> createAdmin(AdminCreate adminCreate) async {
    try {
      final response = await _apiService.post(
        ApiConstants.adminCreate,
        data: adminCreate.toJson(),
      );

      if (response.statusCode == 200) {
        return Admin.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to create admin');
      }
      throw Exception('Failed to create admin: $e');
    }
  }

  /// Update admin
  Future<bool> updateAdmin(String username, AdminUpdate adminUpdate) async {
    try {
      final response = await _apiService.put(
        ApiConstants.adminUpdate(username),
        data: adminUpdate.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
  }

  /// Delete admin
  Future<bool> deleteAdmin(String username) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.adminDelete(username),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete admin: $e');
    }
  }

  /// Get admin activities
  Future<Map<String, dynamic>> getActivities({
    String? adminUsername,
    String? activityType,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };

      if (adminUsername != null) queryParams['admin_username'] = adminUsername;
      if (activityType != null) queryParams['activity_type'] = activityType;

      final response = await _apiService.get(
        ApiConstants.adminActivities,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'activities': response.data['activities'] ?? [],
          'total': response.data['total'] ?? 0,
          'page': response.data['page'] ?? 1,
          'page_size': response.data['page_size'] ?? limit,
        };
      }
      return {'activities': [], 'total': 0};
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }

  /// Get admin activity stats
  Future<Map<String, dynamic>> getActivityStats({String? adminUsername}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (adminUsername != null) queryParams['admin_username'] = adminUsername;

      final response = await _apiService.get(
        ApiConstants.adminActivitiesStats,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to fetch activity stats: $e');
    }
  }
}
