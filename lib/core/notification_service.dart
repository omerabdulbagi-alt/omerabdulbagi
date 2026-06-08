import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (!_isAndroid) return;
    try {
      tz_data.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      );
      await _plugin.initialize(settings);
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (error, stackTrace) {
      debugPrint('Notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> syncTask(ManualTask task) async {
    final id = task.id;
    if (!_isAndroid || id == null) return;
    try {
      await _plugin.cancel(id);
      final reminder = task.reminderAt;
      if (task.completed ||
          reminder == null ||
          !reminder.isAfter(DateTime.now())) {
        return;
      }

      await _plugin.zonedSchedule(
        id,
        'My Tasks reminder',
        task.title,
        tz.TZDateTime.from(reminder.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task reminders',
            channelDescription: 'Reminders for scheduled tasks',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'task:$id',
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to schedule task reminder: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> cancelTask(int id) async {
    if (!_isAndroid) return;
    try {
      await _plugin.cancel(id);
    } catch (error) {
      debugPrint('Unable to cancel task reminder: $error');
    }
  }
}
