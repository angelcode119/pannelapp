// Stub file for web platform where Firebase is not needed
// This prevents compilation errors when building for web

class Firebase {
  static Future<void> initializeApp() async {
    // Stub implementation - does nothing on web
  }
}

class FirebaseMessaging {
  static void onBackgroundMessage(Function callback) {
    // Stub implementation - does nothing on web
  }
}

class RemoteMessage {
  String? messageId;
  Map<String, dynamic> data = {};
  RemoteNotification? notification;
}

class RemoteNotification {
  String? title;
  String? body;
}
