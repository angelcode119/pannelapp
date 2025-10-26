import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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