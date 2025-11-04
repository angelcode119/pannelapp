import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../../core/constants/api_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Notifications enabled' : 'Notifications disabled',
          ),
          backgroundColor: value ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final t = localeProvider.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('settings')),
      ),
      body: ListView(
        children: [

          _SectionHeader(title: t('notifications')),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.8, vertical: 6.4),
            child: SwitchListTile(
              secondary: Icon(
                _notificationsEnabled 
                    ? Icons.notifications_active 
                    : Icons.notifications_off,
                color: _notificationsEnabled 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
              ),
              title: Text(t('pushNotifications')),
              subtitle: Text(
                _notificationsEnabled 
                    ? 'Receive notifications from admins' 
                    : 'Notifications are disabled',
              ),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),

          const SizedBox(height: 16),

          _SectionHeader(title: t('appearance')),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.8, vertical: 6.4),
            child: Column(
              children: [

                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: Text(t('theme')),
                  subtitle: Text(_getThemeText(themeProvider.themeMode, t)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context),
                ),

                const Divider(height: 1),

                SwitchListTile(
                  secondary: const Icon(Icons.brightness_6),
                  title: Text(t('darkMode')),
                  subtitle: const Text('Quick toggle to dark theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    if (value) {
                      themeProvider.setThemeMode(ThemeMode.dark);
                    } else {
                      themeProvider.setThemeMode(ThemeMode.light);
                    }
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(t('language')),
                  subtitle: Text(_getLanguageText(localeProvider.locale.languageCode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, localeProvider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SectionHeader(title: t('about')),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.8, vertical: 6.4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(t('appVersion')),
                  subtitle: const Text('1.0.0'),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(t('serverAddress')),
                  subtitle: Text("Unknow"),
                  trailing: const Icon(Icons.copy, size: 16),
                  onTap: () {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address copied')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.8, vertical: 6.4),
            child: InkWell(
              onTap: () => _launchTelegram(),
              borderRadius: BorderRadius.circular(7.68),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7.68),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9.6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.code,
                        color: Theme.of(context).primaryColor,
                        size: 22.4,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Developed by',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Suki',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeText(ThemeMode mode, Function t) {
    switch (mode) {
      case ThemeMode.light:
        return t('lightMode');
      case ThemeMode.dark:
        return t('darkMode');
      case ThemeMode.system:
        return t('systemDefault');
    }
  }

  String _getLanguageText(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      default:
        return 'English';
    }
  }

  Future<void> _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) async {
    final t = localeProvider.t;
    final currentLang = localeProvider.locale.languageCode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(t('chooseLanguage')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('English'),
              value: 'en',
              groupValue: currentLang,
              onChanged: (value) async {
                Navigator.pop(context);
                await localeProvider.setLocale(Locale(value!));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localeProvider.t('languageChanged')),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी'),
              subtitle: const Text('Hindi'),
              value: 'hi',
              groupValue: currentLang,
              onChanged: (value) async {
                Navigator.pop(context);
                await localeProvider.setLocale(Locale(value!));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localeProvider.t('languageChanged')),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final t = context.read<LocaleProvider>().t;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('chooseTheme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(t('lightMode')),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(t('darkMode')),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(t('systemDefault')),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchTelegram() async {
    final Uri telegramUrl = Uri.parse('https://t.me/L0VES0UTHK0REA');

    try {
      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(
          telegramUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {

        final Uri webUrl = Uri.parse('https://t.me/L0VES0UTHK0REA');
        await launchUrl(webUrl);
      }
    } catch (e) {
      debugPrint('Error launching Telegram: $e');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}