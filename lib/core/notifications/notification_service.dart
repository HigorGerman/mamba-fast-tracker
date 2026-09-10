import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermissions();
  Future<void> showFastStartedNotification({
    required String protocolTitle,
    required Duration targetDuration,
  });
  Future<void> scheduleFastCompletedNotification({
    required String protocolTitle,
    required DateTime targetEndTime,
  });
  Future<void> cancelAllNotifications();
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  static const int _fastCompletedNotificationId = 1001;
  static const int _fastStartedNotificationId = 1000;

  NotificationServiceImpl({FlutterLocalNotificationsPlugin? notificationsPlugin})
      : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    if (kIsWeb) return; // Skip native local notifications on Web
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      debugPrint('Notification init exception: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await androidImplementation?.requestNotificationsPermission();

      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return (androidGranted ?? true) && (iosGranted ?? true);
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> showFastStartedNotification({
    required String protocolTitle,
    required Duration targetDuration,
  }) async {
    if (kIsWeb) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'fasting_channel_id',
        'Fasting Notifications',
        channelDescription: 'Notifications regarding intermittent fasting progress',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final hours = targetDuration.inHours;
      await _notificationsPlugin.show(
        _fastStartedNotificationId,
        '⚡ Mamba Fasting Started!',
        'Protocol $protocolTitle activated ($hours hours target). Stay disciplined!',
        details,
      );
    } catch (e) {
      debugPrint('Notification show error: $e');
    }
  }

  @override
  Future<void> scheduleFastCompletedNotification({
    required String protocolTitle,
    required DateTime targetEndTime,
  }) async {
    if (kIsWeb) return;
    try {
      final scheduledDate = tz.TZDateTime.from(targetEndTime, tz.local);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      const androidDetails = AndroidNotificationDetails(
        'fasting_completion_channel_id',
        'Fasting Goal Completion',
        channelDescription: 'Notifications triggered when fasting goal is completed',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        _fastCompletedNotificationId,
        '🎉 Fasting Goal Achieved!',
        'Congratulations! You have completed your $protocolTitle fast. Time to refuel!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Notification schedule error: $e');
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Notification cancel error: $e');
    }
  }
}
