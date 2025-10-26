import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../data/models/device.dart';
import '../../data/models/stats.dart';
import '../../data/repositories/device_repository.dart';

enum DeviceFilter {
  all,
  active,
  pending,
  online,
  offline,
}

class DeviceProvider extends ChangeNotifier {
  final DeviceRepository _deviceRepository = DeviceRepository();

  List<Device> _devices = [];
  Stats? _stats;
  bool _isLoading = false;
  String? _errorMessage;
  DeviceFilter _currentFilter = DeviceFilter.all;
  String _searchQuery = '';

  // 🔥 Page-based Pagination
  int _currentPage = 1; // صفحه فعلی (از 1 شروع میشه)
  int _pageSize = 50; // تعداد آیتم در هر صفحه
  int _totalDevicesCount = 0;

  // 🔥 Real-time Auto-Refresh
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = false;
  int _autoRefreshInterval = 30; // ثانیه

  List<Device> get devices => _filteredDevices;
  Stats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DeviceFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  int get totalDevicesCount => _totalDevicesCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => (_totalDevicesCount / _pageSize).ceil();
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  int get autoRefreshInterval => _autoRefreshInterval;

  List<Device> get _filteredDevices {
    var filtered = _devices;

    switch (_currentFilter) {
      case DeviceFilter.active:
        filtered = filtered.where((d) => d.isActive).toList();
        break;
      case DeviceFilter.pending:
        filtered = filtered.where((d) => d.isPending).toList();
        break;
      case DeviceFilter.online:
        filtered = filtered.where((d) => d.isOnline).toList();
        break;
      case DeviceFilter.offline:
        filtered = filtered.where((d) => d.isOffline).toList();
        break;
      case DeviceFilter.all:
      default:
        break;
    }

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

  int get totalDevices => _devices.length;
  int get activeDevices => _devices.where((d) => d.isActive).length;
  int get pendingDevices => _devices.where((d) => d.isPending).length;
  int get onlineDevices => _devices.where((d) => d.isOnline).length;
  int get offlineDevices => _devices.where((d) => d.isOffline).length;

  // لود اولیه (صفحه اول)
  Future<void> fetchDevices() async {
    _currentPage = 1;
    await _loadCurrentPage();
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
      );

      _devices = result['devices'];
      _totalDevicesCount = result['total'];

      // لود آمار
      _stats = await _deviceRepository.getStats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching devices list';
      notifyListeners();
    }
  }

  // 🔥 تغییر Page Size
  Future<void> setPageSize(int size) async {
    if (size == _pageSize) return;

    _pageSize = size;
    _currentPage = 1; // برگرد به صفحه اول
    await _loadCurrentPage();
  }

  // صفحه بعدی
  Future<void> goToNextPage() async {
    if (!hasNextPage) return;
    _currentPage++;
    await _loadCurrentPage();
  }

  // صفحه قبلی
  Future<void> goToPreviousPage() async {
    if (!hasPreviousPage) return;
    _currentPage--;
    await _loadCurrentPage();
  }

  // رفتن به صفحه خاص
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    await _loadCurrentPage();
  }

  void setFilter(DeviceFilter filter) {
    _currentFilter = filter;
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

  Future<void> refreshDevices() async {
    await _loadCurrentPage();
  }

  // 🔥 REAL-TIME AUTO-REFRESH
  // فقط صفحه فعلی رو هر X ثانیه refresh می‌کنه
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

  // Silent Refresh - بدون نشون دادن Loading
  Future<void> _silentRefresh() async {
    try {
      final skip = (_currentPage - 1) * _pageSize;

      debugPrint('🔄 Auto-refresh: Page $_currentPage (items: $skip-${skip + _pageSize})');

      final result = await _deviceRepository.getDevices(
        skip: skip,
        limit: _pageSize,
      );

      _devices = result['devices'];
      _totalDevicesCount = result['total'];

      _stats = await _deviceRepository.getStats();

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