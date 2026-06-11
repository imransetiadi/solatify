import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    // Use a default fallback location, or try to detect local timezone
    try {
      // Set local to a default region like Jakarta if not auto-set,
      // but in Flutter, timezone package sets a default or throws.
      // We set Asia/Jakarta as default if local is not set.
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      // Ignore location error if timezone is already set or fails
    }

    // 2. Configure Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Configure iOS Initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 4. Initialize Plugin
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification click if needed
      },
    );
  }

  static Future<void> schedulePrayerNotifications({
    required Map<String, DateTime> prayerTimes,
    required String
    adhanSound, // default, custom_1 (Makkah), custom_2 (Medinah), silent
    required bool enabled,
  }) async {
    if (kIsWeb) return;

    // Always clear existing notifications first to avoid duplicates
    await _notificationsPlugin.cancelAll();

    if (!enabled) return;

    final androidAdhanSound = adhanSound == 'default'
        ? null
        : RawResourceAndroidNotificationSound(
            adhanSound,
          ); // adhan_makkah.mp3 / adhan_madinah.mp3 in res/raw

    final androidPlatformChannelSpecificsAdhan = AndroidNotificationDetails(
      'solatify_adhan_channel',
      'Solatify Adzan Reminder',
      channelDescription: 'Diputar saat masuk waktu salat',
      importance: Importance.max,
      priority: Priority.high,
      sound: androidAdhanSound,
      playSound: adhanSound != 'silent',
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
    );

    final iosPlatformChannelSpecificsAdhan = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: adhanSound != 'silent',
      sound: adhanSound == 'default'
          ? null
          : '$adhanSound.caf', // custom iOS audio in bundle
    );

    final notificationDetailsAdhan = NotificationDetails(
      android: androidPlatformChannelSpecificsAdhan,
      iOS: iosPlatformChannelSpecificsAdhan,
    );

    int id = 0;
    final now = DateTime.now();

    prayerTimes.forEach((key, time) async {
      // Only schedule if the prayer time is in the future
      if (time.isAfter(now)) {
        final tzTime = tz.TZDateTime.from(time, tz.local);
        final prayerLabel = key[0].toUpperCase() + key.substring(1);

        try {
          await _notificationsPlugin.zonedSchedule(
            id: id++,
            title: 'Waktu Salat $prayerLabel',
            body: 'Telah masuk waktu salat $prayerLabel untuk wilayah Anda.',
            scheduledDate: tzTime,
            notificationDetails: notificationDetailsAdhan,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Failed to schedule notification for $key: $e');
          }
        }
      }
    });
  }
}
