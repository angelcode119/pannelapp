import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'access_token');
  }

  Future<void> saveAdminInfo(Map<String, dynamic> admin) async {
    await _secureStorage.write(key: 'admin_info', value: jsonEncode(admin));
  }

  Future<Map<String, dynamic>?> getAdminInfo() async {
    final data = await _secureStorage.read(key: 'admin_info');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> deleteAdminInfo() async {
    await _secureStorage.delete(key: 'admin_info');
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  Future<void> setLanguage(String lang) async {
    await _prefs?.setString('language', lang);
  }

  String getLanguage() {
    return _prefs?.getString('language') ?? 'en';
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}