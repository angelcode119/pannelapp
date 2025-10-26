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
    };
  }

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin';
  bool get isViewer => role == 'viewer';
}