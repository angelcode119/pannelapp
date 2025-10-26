import 'package:flutter/foundation.dart';
import '../../data/models/admin.dart';
import '../../data/models/activity_log.dart';
import '../../data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepository();

  List<Admin> _admins = [];
  List<ActivityLog> _activities = [];
  Map<String, dynamic>? _activityStats;

  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalActivities = 0;
  int _pageSize = 100;

  List<Admin> get admins => _admins;
  List<ActivityLog> get activities => _activities;
  Map<String, dynamic>? get activityStats => _activityStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalActivities => _totalActivities;
  int get pageSize => _pageSize;

  Future<void> fetchAdmins() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _admins = await _adminRepository.getAdmins();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching admins list';
      notifyListeners();
    }
  }

  Future<bool> createAdmin({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminRepository.createAdmin(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      _isLoading = false;

      if (success) {
        await fetchAdmins();
      }

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error creating admin';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAdmin(
    String username, {
    String? role,
    bool? isActive,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminRepository.updateAdmin(
        username,
        role: role,
        isActive: isActive,
      );

      _isLoading = false;

      if (success) {
        await fetchAdmins();
      }

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error updating admin';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAdmin(String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminRepository.deleteAdmin(username);

      _isLoading = false;

      if (success) {
        await fetchAdmins();
      }

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error deleting admin';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchActivities({
    String? adminUsername,
    String? activityType,
    int? page,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final skip = ((page ?? 1) - 1) * _pageSize;

      final result = await _adminRepository.getActivities(
        adminUsername: adminUsername,
        activityType: activityType,
        skip: skip,
        limit: _pageSize,
      );

      _activities = result['activities'] as List<ActivityLog>;
      _totalActivities = result['total'] as int;
      _currentPage = result['page'] as int;
      _pageSize = result['page_size'] as int;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching activity logs';
      notifyListeners();
    }
  }

  Future<void> fetchActivityStats({String? adminUsername}) async {
    try {
      _activityStats = await _adminRepository.getActivityStats(
        adminUsername: adminUsername,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching activity stats';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetActivities() {
    _activities = [];
    _currentPage = 1;
    _totalActivities = 0;
    notifyListeners();
  }
}