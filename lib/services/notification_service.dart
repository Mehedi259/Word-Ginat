import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/dictionary_data.dart';
import '../models/word_model.dart';
import 'storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap here if needed
        },
      );

      // Initial scheduling based on settings
      if (StorageService.getDailyReminder()) {
        await scheduleDailyWordNotification();
      }
    } catch (e, stack) {
      debugPrint('NotificationService.init error: $e\n$stack');
    }
  }

  static Future<void> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission on Android 13+ (POST_NOTIFICATIONS)
      await androidImplementation?.requestNotificationsPermission();
      // NOTE: We deliberately do NOT request exact alarm permissions here.
      // Inexact scheduling (inexactAllowWhileIdle) does not require exact alarm permissions,
      // which complies with Google Play policies and prevents SecurityException crashes.
    } catch (e) {
      debugPrint('NotificationService.requestPermissions error: $e');
    }
  }

  static Future<void> scheduleDailyWordNotification() async {
    try {
      await requestPermissions();

      // Get a random word
      List<WordModel> words = await DictionaryData.getRandomWords(count: 1);
      if (words.isEmpty) return;
      
      final word = words.first;

      final hasSound = StorageService.getSoundEffects();

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_word_channel',
        'Daily Word Reminder',
        channelDescription: 'Notifications for daily word learning',
        importance: Importance.high,
        priority: Priority.high,
        playSound: hasSound,
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentSound: hasSound,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule for 10:00 AM every day.
      // We use `inexactAllowWhileIdle` so it works reliably during Doze without
      // requiring SCHEDULE_EXACT_ALARM or USE_EXACT_ALARM permissions.
      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Word of the Day: ${word.word}',
        body: word.definition,
        scheduledDate: _nextInstanceOfTenAM(),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, stack) {
      debugPrint('NotificationService.scheduleDailyWordNotification error: $e\n$stack');
    }
  }

  static Future<void> cancelDailyReminder() async {
    try {
      await _notificationsPlugin.cancel(id: 0);
    } catch (e) {
      debugPrint('NotificationService.cancelDailyReminder error: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
