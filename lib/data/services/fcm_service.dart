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
    debugPrint('?? ===== INITIALIZING FCM SERVICE =====');
    
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
    
    debugPrint('?? Notification permission status: ${settings.authorizationStatus}');
    debugPrint('?? Alert: ${settings.alert}');
    debugPrint('?? Sound: ${settings.sound}');
    debugPrint('?? Badge: ${settings.badge}');
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('? User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('?? User granted provisional permission');
    } else {
      debugPrint('? User declined notification permission');
    }
    
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
    debugPrint('?? FCM Token: $_fcmToken');
    if (_fcmToken == null) {
      debugPrint('? Failed to get FCM token!');
    } else {
      debugPrint('? FCM Token obtained successfully');
    }
    
    // Save token
    if (_fcmToken != null) {
      await _saveToken(_fcmToken!);
    }
    
    // Listen for token refresh
    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _saveToken(token);
      debugPrint('?? FCM Token refreshed: $token');
    });
    
    // Handle foreground messages
    debugPrint('?? Setting up foreground message listener...');
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps (when app is in background)
    debugPrint('?? Setting up background message tap listener...');
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Check if app was opened from notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('?? App opened from notification: ${initialMessage.messageId}');
      _handleNotificationTap(initialMessage);
    }
    
    debugPrint('? ===== FCM SERVICE INITIALIZED SUCCESSFULLY =====');
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
    debugPrint('?? ===== FOREGROUND MESSAGE RECEIVED =====');
    debugPrint('?? Message ID: ${message.messageId}');
    debugPrint('?? From: ${message.from}');
    debugPrint('?? Data: ${message.data}');
    debugPrint('?? Notification Title: ${message.notification?.title}');
    debugPrint('?? Notification Body: ${message.notification?.body}');
    
    RemoteNotification? notification = message.notification;
    
    if (notification != null) {
      debugPrint('?? Showing notification from RemoteNotification...');
      _showLocalNotification(
        notification.title ?? 'Notification',
        notification.body ?? '',
        message.data,
      );
    } else if (message.data.isNotEmpty) {
      // ??? ??? data ????? ????? ? notification ?????? ?????
      debugPrint('?? No notification payload, creating from data...');
      _showLocalNotification(
        message.data['title'] ?? '?? New Notification',
        message.data['body'] ?? 'You have a new notification',
        message.data,
      );
    } else {
      debugPrint('?? Message has no notification and no data!');
    }
  }
  
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    debugPrint('?? ===== SHOWING LOCAL NOTIFICATION =====');
    debugPrint('?? Title: $title');
    debugPrint('?? Body: $body');
    debugPrint('?? Data: $data');
    
    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    debugPrint('?? Notifications enabled in settings: $notificationsEnabled');
    
    if (!notificationsEnabled) {
      debugPrint('?? Notifications disabled by user - skipping');
      return;
    }
    
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      debugPrint('?? Notification ID: $notificationId');
      
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
      debugPrint('? Local notification shown successfully!');
    } catch (e) {
      debugPrint('? Error showing local notification: $e');
      debugPrint('? Stack trace: ${StackTrace.current}');
    }
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('?? ===== NOTIFICATION TAPPED =====');
    debugPrint('?? Message ID: ${message.messageId}');
    debugPrint('?? Data: ${message.data}');
    
    String? type = message.data['type'];
    
    if (type == 'device_registered') {
      String deviceId = message.data['device_id'] ?? '';
      String model = message.data['model'] ?? '';
      
      debugPrint('?? Should navigate to device: $deviceId ($model)');
      
      // TODO: Navigate to device details
      // You can use a global navigator key or event bus
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(response.payload!);
        
        if (data['type'] == 'device_registered') {
          String deviceId = data['device_id'] ?? '';
          debugPrint('?? Should navigate to device: $deviceId');
          // TODO: Navigate to device details
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }
}
