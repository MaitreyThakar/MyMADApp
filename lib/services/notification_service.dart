import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../config/constants.dart';

// Global navigator key – set from main.dart
GlobalKey<NavigatorState>? globalNavigatorKey;

// ignore: avoid_classes_with_only_static_members
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        globalNavigatorKey?.currentState
            ?.pushNamedAndRemoveUntil('/appointments', (r) => false);
      },
    );

    const channel = AndroidNotificationChannel(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      description: 'Appointment booking alerts and reminders',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showBookingConfirmation(
      String serviceName, String date, String timeSlot) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
      'Appointment Confirmed ✔',
      '$serviceName on $date at $timeSlot',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showProviderApplicationApproved(String applicantName) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
      '✅ Application Approved!',
      'Congratulations $applicantName! Your provider application has been approved.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showProviderApplicationRejected(String applicantName, String reason) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
      '❌ Application Not Approved',
      'Sorry $applicantName. Reason: $reason',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleAppointmentReminder(
    int id,
    String serviceName,
    DateTime appointmentDateTime,
  ) async {
    final reminderTime =
        appointmentDateTime.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      'Upcoming Appointment Reminder',
      'Your $serviceName appointment is in 1 hour',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
