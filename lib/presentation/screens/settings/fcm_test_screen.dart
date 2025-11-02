import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../data/services/fcm_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMTestScreen extends StatefulWidget {
  const FCMTestScreen({super.key});

  @override
  State<FCMTestScreen> createState() => _FCMTestScreenState();
}

class _FCMTestScreenState extends State<FCMTestScreen> {
  String? _fcmToken;
  NotificationSettings? _notificationSettings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFCMInfo();
  }

  Future<void> _loadFCMInfo() async {
    setState(() => _isLoading = true);
    
    try {
      // Get FCM token
      _fcmToken = await FCMService().getToken();
      
      // Get notification settings
      _notificationSettings = await FirebaseMessaging.instance.getNotificationSettings();
      
      debugPrint('?? FCM Token: $_fcmToken');
      debugPrint('?? Permission: ${_notificationSettings?.authorizationStatus}');
    } catch (e) {
      debugPrint('? Error loading FCM info: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testNotification() async {
    try {
      debugPrint('?? Testing local notification...');
      
      final notifications = FlutterLocalNotificationsPlugin();
      
      await notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '?? Test Notification',
        'This is a test notification from FCM Test Screen',
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
          ),
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Test notification sent!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('? Error testing notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.copy, color: Colors.white),
              SizedBox(width: 12),
              Text('Token copied to clipboard'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Test & Debug'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFCMInfo,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Permission Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getPermissionColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getPermissionIcon(),
                                  color: _getPermissionColor(),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notification Permission',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getPermissionText(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_notificationSettings != null) ...[
                            _buildInfoRow('Alert', _notificationSettings!.alert.toString()),
                            _buildInfoRow('Sound', _notificationSettings!.sound.toString()),
                            _buildInfoRow('Badge', _notificationSettings!.badge.toString()),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // FCM Token Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.vpn_key,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'FCM Token',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _copyToken,
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copy token',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                              ),
                            ),
                            child: SelectableText(
                              _fcmToken ?? 'No token available',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: _fcmToken != null
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Test Notification Button
                  ElevatedButton.icon(
                    onPressed: _testNotification,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Send Test Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Refresh Button
                  OutlinedButton.icon(
                    onPressed: _loadFCMInfo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Info'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Debug Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bug_report,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Debug Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Check the console logs for detailed FCM debug information:\n\n'
                            '?? FCM initialization logs\n'
                            '?? Token information\n'
                            '?? Message received logs\n'
                            '? Notification display status',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPermissionColor() {
    if (_notificationSettings == null) return Colors.grey;
    
    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return Colors.green;
      case AuthorizationStatus.provisional:
        return Colors.orange;
      case AuthorizationStatus.denied:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPermissionIcon() {
    if (_notificationSettings == null) return Icons.help_outline;
    
    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return Icons.check_circle;
      case AuthorizationStatus.provisional:
        return Icons.warning;
      case AuthorizationStatus.denied:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getPermissionText() {
    if (_notificationSettings == null) return 'Unknown';
    
    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return 'Authorized - Notifications enabled';
      case AuthorizationStatus.provisional:
        return 'Provisional - Limited notifications';
      case AuthorizationStatus.denied:
        return 'Denied - Notifications disabled';
      case AuthorizationStatus.notDetermined:
        return 'Not determined - Permission not requested';
      default:
        return 'Unknown status';
    }
  }
}
