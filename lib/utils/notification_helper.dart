import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInitialize = AndroidInitializationSettings('app_icon');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 通知タップ時の処理
      },
    );

    _initialized = true;
  }

  static Future<void> scheduleEventNotification(Event event, {
    Duration? reminderBefore,
  }) async {
    await initialize();

    reminderBefore ??= const Duration(minutes: 30);
    final scheduledDate = event.startTime.subtract(reminderBefore);

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.zonedSchedule(
      event.id.hashCode,
      '予定のリマインダー',
      '${event.title} が ${reminderBefore.inMinutes} 分後に開始します',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminder',
          'Event Reminders',
          channelDescription: 'Notifications for calendar events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelEventNotification(Event event) async {
    await _notifications.cancel(event.id.hashCode);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
