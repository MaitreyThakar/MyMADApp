import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  log('FCM background message: ${message.notification?.title}');
}

// ignore: avoid_classes_with_only_static_members
class FcmService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await messaging.getToken();
    log('FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('FCM foreground: ${message.notification?.title}');
      if (message.notification != null) {
        NotificationService.showBookingConfirmation(
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? '',
          '',
        );
      }
    });

    // Background tap (app was in background, user tapped notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('FCM opened from background: ${message.notification?.title}');
      globalNavigatorKey?.currentState
          ?.pushNamedAndRemoveUntil('/appointments', (r) => false);
    });

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle terminated state
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      globalNavigatorKey?.currentState
          ?.pushNamedAndRemoveUntil('/appointments', (r) => false);
    }
  }
}
