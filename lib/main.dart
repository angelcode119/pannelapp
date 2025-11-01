import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'core/theme/app_theme.dart';

// Global navigator key برای navigate از هر جایی
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تنظیم System UI برای edge-to-edge
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  // تنظیم orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await StorageService().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<bool>? _sessionExpiredSubscription;

  @override
  void initState() {
    super.initState();
    
    // Listen به session expired events
    _sessionExpiredSubscription = ApiService().sessionExpiredStream.listen((_) {
      _handleSessionExpired();
    });
  }

  void _handleSessionExpired() {
    // نمایش snackbar
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Session expired! You were logged in from another device.',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    
    // Navigate به Login و حذف تمام stack
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey, // اضافه کردن navigator key
            title: 'Admin Panel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // ✅✅✅ کل سحر اینجاست! همه صفحات خودکار سینک میشن
            builder: (context, child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;

              // تنظیم خودکار System UI با تم
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  // Status Bar (بالای صفحه)
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness: isDark ? Brightness.dark : Brightness.light,

                  // Navigation Bar (دکمه‌های پایین صفحه - Home, Back, Recent)
                  systemNavigationBarColor: isDark
                      ? const Color(0xFF0B0F19)  // dark background از تم
                      : const Color(0xFFF8FAFC), // light background از تم
                  systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarDividerColor: isDark
                      ? const Color(0xFF0B0F19)
                      : const Color(0xFFF8FAFC),
                  systemNavigationBarContrastEnforced: false,
                ),
              );

              return child!;
            },

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}