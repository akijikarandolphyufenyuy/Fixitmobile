import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Top-level handler required by FCM for background messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM on Android.
  // Save to Firestore if userId is in data payload.
  final userId = message.data['user_id'];
  if (userId != null && userId.toString().isNotEmpty) {
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': userId,
      'title': message.notification?.title ?? message.data['title'] ?? 'Notification',
      'message': message.notification?.body ?? message.data['message'] ?? '',
      'created_at': FieldValue.serverTimestamp(),
      'is_read': false,
      'type': message.data['type'] ?? 'system',
    });
  }
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Called once from main() after Firebase.initializeApp().
  Future<void> init({required void Function(RemoteMessage) onForegroundMessage}) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Init local notifications for foreground display
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android notification channel
    if (defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        'fixit_high_importance',
        'Fixit Notifications',
        description: 'Fixit app notifications',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Foreground messages — show local notification + call callback for in-app popup
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      onForegroundMessage(message);
    });

    // Subscribe to topic for broadcast notifications
    await _messaging.subscribeToTopic('all_users');
  }

  Future<String?> getToken() => _messaging.getToken();

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fixit_high_importance',
          'Fixit Notifications',
          channelDescription: 'Fixit app notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
