import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:medimatch/models/reminder.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    debugPrint('NotificationHelper: initialize() called');

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
        // Handle notification tap
      },
    );
  }

  static Future<bool> requestPermissions() async {
    debugPrint('NotificationHelper: requestPermissions() called');

    final androidPermission =
        await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

    final iosPermission = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidPermission ?? iosPermission ?? false;
  }

  static Future<void> scheduleReminder(Reminder reminder) async {
    debugPrint(
      'NotificationHelper: scheduleReminder() called for ${reminder.medicineName}',
    );

    // Parse time (format: "8:00 AM")
    final timeParts = reminder.time.split(' ');
    final timeValue = timeParts[0].split(':');
    int hour = int.parse(timeValue[0]);
    final int minute = int.parse(timeValue[1]);

    // Handle AM/PM
    final amPm = timeParts[1].toUpperCase();
    if (amPm == 'PM' && hour < 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }

    // Schedule for each day of the week
    for (final day in reminder.daysOfWeek) {
      final nextDate = _getNextDayOfWeek(day, hour, minute);

      final androidDetails = AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Notifications for medicine reminders',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF2196F3),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = '${reminder.id}_$day'.hashCode;

      await _notifications.zonedSchedule(
        id,
        'Medicine Reminder: ${reminder.medicineName}',
        reminder.note,
        nextDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: reminder.id,
      );

      debugPrint(
        'Scheduled notification for ${reminder.medicineName} on day $day at $hour:$minute',
      );
    }
  }

  static Future<void> cancelReminder(String reminderId) async {
    debugPrint('NotificationHelper: cancelReminder() called for $reminderId');

    // Cancel notifications for all days of the week
    for (int day = 1; day <= 7; day++) {
      final id = '${reminderId}_$day'.hashCode;
      await _notifications.cancel(id);
    }
  }

  static tz.TZDateTime _getNextDayOfWeek(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();

    // Convert from Monday=1 to Sunday=0 format for calculations
    final targetDayOfWeek = dayOfWeek % 7;
    final currentDayOfWeek = now.weekday % 7;

    int daysToAdd = targetDayOfWeek - currentDayOfWeek;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }

    final nextDate = DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );

    return tz.TZDateTime.from(nextDate, tz.local);
  }
}
