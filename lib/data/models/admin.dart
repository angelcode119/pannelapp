/// Telegram Bot Configuration
class TelegramBot {
  final int botId; // 1-5
  final String botName;
  final String token;
  final String chatId;

  TelegramBot({
    required this.botId,
    required this.botName,
    required this.token,
    required this.chatId,
  });

  factory TelegramBot.fromJson(Map<String, dynamic> json) {
    return TelegramBot(
      botId: json['bot_id'] ?? 0,
      botName: json['bot_name'] ?? '',
      token: json['token'] ?? '',
      chatId: json['chat_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bot_id': botId,
      'bot_name': botName,
      'token': token,
      'chat_id': chatId,
    };
  }

  TelegramBot copyWith({
    int? botId,
    String? botName,
    String? token,
    String? chatId,
  }) {
    return TelegramBot(
      botId: botId ?? this.botId,
      botName: botName ?? this.botName,
      token: token ?? this.token,
      chatId: chatId ?? this.chatId,
    );
  }
}

/// Admin Model with Multi-Admin Support
class Admin {
  final String username;
  final String email;
  final String fullName;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final DateTime? lastLogin;
  final int loginCount;
  final DateTime createdAt;
  
  // ?? Device Token for linking devices
  final String? deviceToken;
  
  // ?? Telegram 2FA Chat ID (personal numeric ID for 2FA)
  final String? telegram2faChatId;
  
  // ?? Telegram Bots (5 bots with token + chat_id each)
  final List<TelegramBot> telegramBots;

  Admin({
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.permissions,
    required this.isActive,
    this.lastLogin,
    required this.loginCount,
    required this.createdAt,
    this.deviceToken,
    this.telegram2faChatId,
    List<TelegramBot>? telegramBots,
  }) : telegramBots = telegramBots ?? [];

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      loginCount: json['login_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      deviceToken: json['device_token'],
      telegram2faChatId: json['telegram_2fa_chat_id'],
      telegramBots: json['telegram_bots'] != null
          ? (json['telegram_bots'] as List)
              .map((bot) => TelegramBot.fromJson(bot))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'permissions': permissions,
      'is_active': isActive,
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      'login_count': loginCount,
      'created_at': createdAt.toIso8601String(),
      if (deviceToken != null) 'device_token': deviceToken,
      if (telegram2faChatId != null) 'telegram_2fa_chat_id': telegram2faChatId,
      'telegram_bots': telegramBots.map((bot) => bot.toJson()).toList(),
    };
  }

  // Role Helpers
  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin';
  bool get isViewer => role == 'viewer';

  // Telegram Helpers
  bool get has2FA => telegram2faChatId != null && telegram2faChatId!.isNotEmpty;
  bool get hasTelegramBots => telegramBots.isNotEmpty;
  int get botCount => telegramBots.length;

  // Get specific bot by ID
  TelegramBot? getBotById(int botId) {
    try {
      return telegramBots.firstWhere((bot) => bot.botId == botId);
    } catch (e) {
      return null;
    }
  }

  // Device Token Helpers
  bool get hasDeviceToken => deviceToken != null && deviceToken!.isNotEmpty;

  Admin copyWith({
    String? username,
    String? email,
    String? fullName,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? lastLogin,
    int? loginCount,
    DateTime? createdAt,
    String? deviceToken,
    String? telegram2faChatId,
    List<TelegramBot>? telegramBots,
  }) {
    return Admin(
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      loginCount: loginCount ?? this.loginCount,
      createdAt: createdAt ?? this.createdAt,
      deviceToken: deviceToken ?? this.deviceToken,
      telegram2faChatId: telegram2faChatId ?? this.telegram2faChatId,
      telegramBots: telegramBots ?? this.telegramBots,
    );
  }
}

/// Admin Create Request
class AdminCreate {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String role;
  final List<String>? permissions;
  final String? telegram2faChatId;
  final List<TelegramBot>? telegramBots;

  AdminCreate({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.role = 'viewer',
    this.permissions,
    this.telegram2faChatId,
    this.telegramBots,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role,
      if (permissions != null) 'permissions': permissions,
      if (telegram2faChatId != null) 'telegram_2fa_chat_id': telegram2faChatId,
      if (telegramBots != null)
        'telegram_bots': telegramBots!.map((bot) => bot.toJson()).toList(),
    };
  }
}

/// Admin Update Request
class AdminUpdate {
  final String? email;
  final String? fullName;
  final String? role;
  final List<String>? permissions;
  final bool? isActive;
  final String? telegram2faChatId;
  final List<TelegramBot>? telegramBots;

  AdminUpdate({
    this.email,
    this.fullName,
    this.role,
    this.permissions,
    this.isActive,
    this.telegram2faChatId,
    this.telegramBots,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (email != null) data['email'] = email;
    if (fullName != null) data['full_name'] = fullName;
    if (role != null) data['role'] = role;
    if (permissions != null) data['permissions'] = permissions;
    if (isActive != null) data['is_active'] = isActive;
    if (telegram2faChatId != null) data['telegram_2fa_chat_id'] = telegram2faChatId;
    if (telegramBots != null) {
      data['telegram_bots'] = telegramBots!.map((bot) => bot.toJson()).toList();
    }
    return data;
  }
}

/// Admin Role Enum
class AdminRole {
  static const String superAdmin = 'super_admin';
  static const String admin = 'admin';
  static const String viewer = 'viewer';

  static List<String> get allRoles => [superAdmin, admin, viewer];
  
  static String getDisplayName(String role) {
    switch (role) {
      case superAdmin:
        return 'Super Admin';
      case admin:
        return 'Admin';
      case viewer:
        return 'Viewer';
      default:
        return role;
    }
  }
}

/// Admin Permission Enum
class AdminPermission {
  static const String viewDevices = 'view_devices';
  static const String manageDevices = 'manage_devices';
  static const String sendCommands = 'send_commands';
  static const String viewSms = 'view_sms';
  static const String viewContacts = 'view_contacts';
  static const String deleteData = 'delete_data';
  static const String manageAdmins = 'manage_admins';
  static const String viewAdminLogs = 'view_admin_logs';
  static const String changeSettings = 'change_settings';

  static List<String> get allPermissions => [
        viewDevices,
        manageDevices,
        sendCommands,
        viewSms,
        viewContacts,
        deleteData,
        manageAdmins,
        viewAdminLogs,
        changeSettings,
      ];

  static String getDisplayName(String permission) {
    switch (permission) {
      case viewDevices:
        return 'View Devices';
      case manageDevices:
        return 'Manage Devices';
      case sendCommands:
        return 'Send Commands';
      case viewSms:
        return 'View SMS';
      case viewContacts:
        return 'View Contacts';
      case deleteData:
        return 'Delete Data';
      case manageAdmins:
        return 'Manage Admins';
      case viewAdminLogs:
        return 'View Admin Logs';
      case changeSettings:
        return 'Change Settings';
      default:
        return permission;
    }
  }
}

/// Role Permissions Map
class RolePermissions {
  static List<String> getPermissions(String role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminPermission.allPermissions;
      case AdminRole.admin:
        return [
          AdminPermission.viewDevices,
          AdminPermission.manageDevices,
          AdminPermission.sendCommands,
          AdminPermission.viewSms,
          AdminPermission.viewContacts,
          AdminPermission.changeSettings,
        ];
      case AdminRole.viewer:
        return [
          AdminPermission.viewDevices,
          AdminPermission.viewSms,
          AdminPermission.viewContacts,
        ];
      default:
        return [];
    }
  }
}
