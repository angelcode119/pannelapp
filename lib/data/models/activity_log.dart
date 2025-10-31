/// Admin Activity Log Model
class ActivityLog {
  final String adminUsername;
  final String activityType;
  final String description;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceId;
  final Map<String, dynamic> metadata;
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;

  ActivityLog({
    required this.adminUsername,
    required this.activityType,
    required this.description,
    this.ipAddress,
    this.userAgent,
    this.deviceId,
    Map<String, dynamic>? metadata,
    this.success = true,
    this.errorMessage,
    required this.timestamp,
  }) : metadata = metadata ?? {};

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      adminUsername: json['admin_username'] ?? '',
      activityType: json['activity_type'] ?? '',
      description: json['description'] ?? '',
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      deviceId: json['device_id'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : {},
      success: json['success'] ?? true,
      errorMessage: json['error_message'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_username': adminUsername,
      'activity_type': activityType,
      'description': description,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (userAgent != null) 'user_agent': userAgent,
      if (deviceId != null) 'device_id': deviceId,
      'metadata': metadata,
      'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get activityIcon {
    switch (activityType.toLowerCase()) {
      case 'login':
        return '??';
      case 'logout':
        return '??';
      case 'view_device':
        return '???';
      case 'view_sms':
        return '??';
      case 'send_command':
        return '?';
      case 'create_admin':
        return '?';
      case 'delete_admin':
        return '???';
      case 'update_admin':
        return '??';
      default:
        return '??';
    }
  }
}
