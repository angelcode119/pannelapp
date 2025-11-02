import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/admin.dart';
import '../../providers/admin_provider.dart';

class CreateAdminFullScreen extends StatefulWidget {
  const CreateAdminFullScreen({super.key});

  @override
  State<CreateAdminFullScreen> createState() => _CreateAdminFullScreenState();
}

class _CreateAdminFullScreenState extends State<CreateAdminFullScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Basic info controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  // 2FA Telegram
  final _telegram2faChatIdController = TextEditingController();
  
  // Bot controllers (5 bots)
  final List<TextEditingController> _botNameControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _botTokenControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _botChatIdControllers =
      List.generate(5, (_) => TextEditingController());

  String _selectedRole = 'admin';
  bool _obscurePassword = true;
  bool _isLoading = false;
  DateTime? _expiresAt;
  
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Set default bot names
    _botNameControllers[0].text = 'devices_bot';
    _botNameControllers[1].text = 'sms_bot';
    _botNameControllers[2].text = 'logs_bot';
    _botNameControllers[3].text = 'auth_bot';
    _botNameControllers[4].text = 'future_bot';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _telegram2faChatIdController.dispose();
    
    for (var controller in _botNameControllers) {
      controller.dispose();
    }
    for (var controller in _botTokenControllers) {
      controller.dispose();
    }
    for (var controller in _botChatIdControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) {
      // Show error and switch to the tab with error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create telegram bots list
    final List<TelegramBot> telegramBots = [];
    for (int i = 0; i < 5; i++) {
      telegramBots.add(TelegramBot(
        botId: i + 1,
        botName: _botNameControllers[i].text.trim().isEmpty
            ? 'bot_${i + 1}'
            : _botNameControllers[i].text.trim(),
        token: _botTokenControllers[i].text.trim(),
        chatId: _botChatIdControllers[i].text.trim(),
      ));
    }

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.createAdmin(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      role: _selectedRole,
      telegram2faChatId: _telegram2faChatIdController.text.trim().isEmpty
          ? null
          : _telegram2faChatIdController.text.trim(),
      telegramBots: telegramBots,
      expiresAt: _expiresAt,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.errorMessage ?? 'Error creating admin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Admin'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _currentTab = index),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Basic Info'),
            Tab(icon: Icon(Icons.telegram), text: '2FA & Bots'),
            Tab(icon: Icon(Icons.preview), text: 'Review'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Basic Info
            _buildBasicInfoTab(isDark),
            
            // Tab 2: Telegram Bots
            _buildTelegramBotsTab(isDark),
            
            // Tab 3: Review
            _buildReviewTab(isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildBasicInfoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Administrator Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the basic information for the new administrator',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),

          // Username
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username *',
              prefixIcon: const Icon(Icons.person),
              hintText: 'e.g., john_admin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username is required';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: const Icon(Icons.badge),
              hintText: 'e.g., John Doe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email *',
              prefixIcon: const Icon(Icons.email),
              hintText: 'e.g., john@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Email is not valid';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password *',
              prefixIcon: const Icon(Icons.lock),
              hintText: 'At least 6 characters',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Role
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'Role *',
              prefixIcon: const Icon(Icons.admin_panel_settings),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'super_admin',
                child: Text('Super Admin'),
              ),
              DropdownMenuItem(
                value: 'admin',
                child: Text('Admin'),
              ),
              DropdownMenuItem(
                value: 'viewer',
                child: Text('Viewer'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Expiry Date Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.event_busy, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Account Expiry (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set an expiration date for this account. Leave empty for unlimited access.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() {
                        _expiresAt = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          23,
                          59,
                          59,
                        );
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _expiresAt == null
                              ? 'No Expiry (Unlimited)'
                              : 'Expires: ${_expiresAt!.year}-${_expiresAt!.month.toString().padLeft(2, '0')}-${_expiresAt!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _expiresAt == null ? Colors.grey : null,
                          ),
                        ),
                        Icon(
                          _expiresAt == null
                              ? Icons.calendar_today
                              : Icons.event,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _expiresAt = null;
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.red),
                      label: const Text(
                        'Clear Expiry Date',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelegramBotsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2FA Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.security, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '2FA Bot (Shared)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Telegram Chat ID for receiving OTP codes',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telegram2faChatIdController,
                  decoration: InputDecoration(
                    labelText: 'Telegram Chat ID',
                    prefixIcon: const Icon(Icons.telegram),
                    hintText: 'e.g., -1001234567890',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification Bots
          Text(
            'Notification Bots (5 Required)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure 5 Telegram bots for different notifications',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // 5 Bots
          ...List.generate(5, (index) => _buildBotCard(index, isDark)),
        ],
      ),
    );
  }

  Widget _buildBotCard(int index, bool isDark) {
    final botPurposes = [
      '?? Device Notifications',
      '?? SMS Notifications',
      '?? Admin Activity Logs',
      '?? Login/Logout Logs',
      '?? Reserved for Future',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bot ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  botPurposes[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bot Name
          TextFormField(
            controller: _botNameControllers[index],
            decoration: InputDecoration(
              labelText: 'Bot Name',
              prefixIcon: const Icon(Icons.label, size: 20),
              hintText: 'e.g., my_device_bot',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),

          const SizedBox(height: 12),

          // Bot Token
          TextFormField(
            controller: _botTokenControllers[index],
            decoration: InputDecoration(
              labelText: 'Bot Token',
              prefixIcon: const Icon(Icons.key, size: 20),
              hintText: '1234567890:AAA...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),

          const SizedBox(height: 12),

          // Chat ID
          TextFormField(
            controller: _botChatIdControllers[index],
            decoration: InputDecoration(
              labelText: 'Chat ID',
              prefixIcon: const Icon(Icons.tag, size: 20),
              hintText: '-1001234567890',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review all information before creating',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Basic Info Card
          _buildReviewCard(
            'Basic Information',
            [
              _buildReviewItem('Username', _usernameController.text),
              _buildReviewItem('Full Name', _fullNameController.text),
              _buildReviewItem('Email', _emailController.text),
              _buildReviewItem('Role', _selectedRole.replaceAll('_', ' ').toUpperCase()),
            ],
            isDark,
          ),

          const SizedBox(height: 16),

          // Telegram Info Card
          _buildReviewCard(
            'Telegram Configuration',
            [
              _buildReviewItem(
                '2FA Chat ID',
                _telegram2faChatIdController.text.isEmpty
                    ? 'Not configured'
                    : _telegram2faChatIdController.text,
              ),
              _buildReviewItem(
                'Configured Bots',
                '${_botTokenControllers.where((c) => c.text.isNotEmpty).length} of 5',
              ),
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      String title, List<Widget> children, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1F2E).withOpacity(0.95),
                    const Color(0xFF0B0F19),
                  ]
                : [
                    Colors.white.withOpacity(0.95),
                    Colors.grey.shade50,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentTab;
                  final isCompleted = index < _currentTab;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [
                                        const Color(0xFF6366F1),
                                        const Color(0xFF8B5CF6),
                                      ],
                                    )
                                  : null,
                              color: isActive
                                  ? null
                                  : (isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (index < 2)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isCompleted
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF059669),
                                      ],
                                    )
                                  : null,
                              color: isCompleted
                                  ? null
                                  : (isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.shade300),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  // Back Button
                  if (_currentTab > 0) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading
                              ? null
                              : () {
                                  _tabController.animateTo(_currentTab - 1);
                                  setState(() => _currentTab--);
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Next/Create Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading
                              ? null
                              : () {
                                  if (_currentTab < 2) {
                                    _tabController.animateTo(_currentTab + 1);
                                    setState(() => _currentTab++);
                                  } else {
                                    _createAdmin();
                                  }
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_currentTab == 2)
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      if (_currentTab == 2)
                                        const SizedBox(width: 8),
                                      Text(
                                        _currentTab < 2
                                            ? 'Continue'
                                            : 'Create Admin',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      if (_currentTab < 2)
                                        const SizedBox(width: 8),
                                      if (_currentTab < 2)
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
