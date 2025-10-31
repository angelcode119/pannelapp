import 'package:flutter/material.dart';
import '../../data/models/admin.dart';
import '../../data/models/activity_log.dart';
import '../../data/repositories/admin_repository.dart';

class AdminProvider with ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  List<Admin> _admins = [];
  List<ActivityLog> _activities = [];
  Map<String, dynamic> _activityStats = {};
  
  bool _isLoading = false;
  bool _isLoadingActivities = false;
  String? _error;
  int _totalAdmins = 0;
  int _totalActivities = 0;

  List<Admin> get admins => _admins;
  List<ActivityLog> get activities => _activities;
  Map<String, dynamic> get activityStats => _activityStats;
  bool get isLoading => _isLoading;
  bool get isLoadingActivities => _isLoadingActivities;
  String? get error => _error;
  int get totalAdmins => _totalAdmins;
  int get totalActivities => _totalActivities;

  /// Fetch all admins
  Future<void> fetchAdmins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _admins = await _repository.getAllAdmins();
      _totalAdmins = _admins.length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new admin
  Future<bool> createAdmin(AdminCreate adminCreate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAdmin = await _repository.createAdmin(adminCreate);
      if (newAdmin != null) {
        _admins.add(newAdmin);
        _totalAdmins = _admins.length;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Failed to create admin';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update admin
  Future<bool> updateAdmin(String username, AdminUpdate adminUpdate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateAdmin(username, adminUpdate);
      if (success) {
        // Refresh admins list
        await fetchAdmins();
      } else {
        _error = 'Failed to update admin';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete admin
  Future<bool> deleteAdmin(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteAdmin(username);
      if (success) {
        _admins.removeWhere((admin) => admin.username == username);
        _totalAdmins = _admins.length;
      } else {
        _error = 'Failed to delete admin';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch admin activities
  Future<void> fetchActivities({
    String? adminUsername,
    String? activityType,
    int skip = 0,
    int limit = 100,
  }) async {
    _isLoadingActivities = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getActivities(
        adminUsername: adminUsername,
        activityType: activityType,
        skip: skip,
        limit: limit,
      );

      final activitiesJson = result['activities'] as List;
      _activities = activitiesJson
          .map((json) => ActivityLog.fromJson(json))
          .toList();
      _totalActivities = result['total'] ?? 0;
      
      _isLoadingActivities = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoadingActivities = false;
      notifyListeners();
    }
  }

  /// Fetch activity stats
  Future<void> fetchActivityStats({String? adminUsername}) async {
    try {
      _activityStats = await _repository.getActivityStats(
        adminUsername: adminUsername,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Get admin by username
  Admin? getAdminByUsername(String username) {
    try {
      return _admins.firstWhere((admin) => admin.username == username);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _admins = [];
    _activities = [];
    _activityStats = {};
    _totalAdmins = 0;
    _totalActivities = 0;
    _error = null;
    notifyListeners();
  }
}
