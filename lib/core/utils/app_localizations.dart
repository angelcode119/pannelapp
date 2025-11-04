import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error loading translations: $e');
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Helper getters for common strings
  String get appTitle => translate('appTitle');
  String get devices => translate('devices');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get management => translate('management');
  String get logout => translate('logout');
  String get login => translate('login');
  String get username => translate('username');
  String get password => translate('password');
  String get email => translate('email');
  String get fullName => translate('fullName');
  String get online => translate('online');
  String get offline => translate('offline');
  String get active => translate('active');
  String get pending => translate('pending');
  String get refresh => translate('refresh');
  String get export => translate('export');
  String get search => translate('search');
  String get filter => translate('filter');
  String get all => translate('all');
  String get sms => translate('sms');
  String get calls => translate('calls');
  String get contacts => translate('contacts');
  String get logs => translate('logs');
  String get info => translate('info');
  String get battery => translate('battery');
  String get storage => translate('storage');
  String get ram => translate('ram');
  String get network => translate('network');
  String get model => translate('model');
  String get manufacturer => translate('manufacturer');
  String get osVersion => translate('osVersion');
  String get deviceId => translate('deviceId');
  String get lastPing => translate('lastPing');
  String get registeredAt => translate('registeredAt');
  String get sendSms => translate('sendSms');
  String get syncSms => translate('syncSms');
  String get message => translate('message');
  String get send => translate('send');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get yes => translate('yes');
  String get no => translate('no');
  String get notifications => translate('notifications');
  String get pushNotifications => translate('pushNotifications');
  String get appearance => translate('appearance');
  String get theme => translate('theme');
  String get lightMode => translate('lightMode');
  String get darkMode => translate('darkMode');
  String get systemDefault => translate('systemDefault');
  String get language => translate('language');
  String get english => translate('english');
  String get hindi => translate('hindi');
  String get about => translate('about');
  String get appVersion => translate('appVersion');
  String get serverAddress => translate('serverAddress');
  String get exportSuccess => translate('exportSuccess');
  String get exportFailed => translate('exportFailed');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get noData => translate('noData');
  String get searchDevices => translate('searchDevices');
  String get searchMessages => translate('searchMessages');
  String get searchContacts => translate('searchContacts');
  String get exportDevices => translate('exportDevices');
  String get exportSms => translate('exportSms');
  String get exportCalls => translate('exportCalls');
  String get exportContacts => translate('exportContacts');
  String get chooseFormat => translate('chooseFormat');
  String get refreshFromServer => translate('refreshFromServer');
  String get syncViaFirebase => translate('syncViaFirebase');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
