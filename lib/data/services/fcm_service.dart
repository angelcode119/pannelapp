import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'admin_notifications',
      'Admin Notifications',
      description: 'Notifications for admin activities',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // Get FCM token
    _fcmToken = await _fcm.getToken();
    
    // Save token
    if (_fcmToken != null) {
      await _saveToken(_fcmToken!);
    }
    
    // Listen for token refresh
    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _saveToken(token);
    });
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Check if app was opened from notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }
  
  Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    
    if (notification != null) {
      _showLocalNotification(
        notification.title ?? 'Notification',
        notification.body ?? '',
        message.data,
      );
    } else if (message.data.isNotEmpty) {
      // ??? ??? data ????? ????? ? notification ?????? ?????
      _showLocalNotification(
        message.data['title'] ?? '?? New Notification',
        message.data['body'] ?? 'You have a new notification',
        message.data,
      );
    }
  }
  
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!notificationsEnabled) {
      return;
    }
    
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'admin_notifications',
            'Admin Notifications',
            channelDescription: 'Notifications for admin activities',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
            showWhen: true,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    String? type = message.data['type'];
    
    if (type == 'device_registered') {
      // TODO: Navigate to device details
      // You can use a global navigator key or event bus
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(response.payload!);
        
        if (data['type'] == 'device_registered') {
          // TODO: Navigate to device details
        }
      } catch (e) {
        // Silent fail
      }
    }
  }
}
