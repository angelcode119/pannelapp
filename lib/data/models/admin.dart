// Telegram Bot Model
class TelegramBot {
  final int botId;
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

  bool get isConfigured => token.isNotEmpty && chatId.isNotEmpty;
  
  String get botPurpose {
    switch (botId) {
      case 1:
        return 'Device Notifications';
      case 2:
        return 'SMS Notifications';
      case 3:
        return 'Admin Activity Logs';
      case 4:
        return 'Login/Logout Logs';
      case 5:
        return 'Reserved for Future';
      default:
        return 'Unknown';
    }
  }
}

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
  final String? deviceToken;
  final String? telegram2faChatId;
  final List<TelegramBot>? telegramBots;

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
    this.telegramBots,
  });

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
      createdAt: DateTime.parse(json['created_at']),
      deviceToken: json['device_token'],
      telegram2faChatId: json['telegram_2fa_chat_id'],
      telegramBots: json['telegram_bots'] != null
          ? (json['telegram_bots'] as List)
              .map((bot) => TelegramBot.fromJson(bot))
              .toList()
          : null,
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
      'last_login': lastLogin?.toIso8601String(),
      'login_count': loginCount,
      'created_at': createdAt.toIso8601String(),
      if (deviceToken != null) 'device_token': deviceToken,
      if (telegram2faChatId != null) 'telegram_2fa_chat_id': telegram2faChatId,
      if (telegramBots != null)
        'telegram_bots': telegramBots!.map((bot) => bot.toJson()).toList(),
    };
  }

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin';
  bool get isViewer => role == 'viewer';
  
  bool get hasTelegramBots => telegramBots != null && telegramBots!.isNotEmpty;
  bool get has2faConfigured => telegram2faChatId != null && telegram2faChatId!.isNotEmpty;
  
  int get configuredBotsCount {
    if (telegramBots == null) return 0;
    return telegramBots!.where((bot) => bot.isConfigured).length;
  }
}