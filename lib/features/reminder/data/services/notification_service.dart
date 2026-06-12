import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'azan_audio_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static String _timezoneName = 'Asia/Jakarta';

  static Future<void> init() async {
    if (_initialized) return;

    _configureTimeZone(_timezoneName);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTapped,
    );
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    try {
      await init();

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        return await androidPlugin.requestNotificationsPermission() ?? false;
      }

      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to request notification permission: $error\n$stackTrace',
      );
      return false;
    }
  }

  static Future<void> schedulePrayerNotifications({
    required Map<String, DateTime> prayerTimes,
    required String adhanSound,
    required bool notificationEnabled,
    required bool azanSoundEnabled,
    String timezoneName = 'Asia/Jakarta',
  }) async {
    if (kIsWeb) return;

    try {
      _timezoneName = timezoneName;
      _configureTimeZone(timezoneName);
      await init();
      await _notificationsPlugin.cancelAll();

      if (!notificationEnabled) return;

      final notificationDetails = _buildNotificationDetails(adhanSound);
      final now = DateTime.now();
      var notificationId = 0;

      for (final entry in prayerTimes.entries) {
        final prayerTime = entry.value;
        if (!prayerTime.isAfter(now)) continue;

        await _notificationsPlugin.zonedSchedule(
          id: notificationId++,
          title: 'Waktu Salat ${_formatPrayerLabel(entry.key)}',
          body:
              'Telah masuk waktu salat ${_formatPrayerLabel(entry.key)} untuk wilayah Anda.',
          scheduledDate: tz.TZDateTime.from(prayerTime, tz.local),
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: azanSoundEnabled ? 'play_azan' : '',
        );
      }
    } catch (error, stackTrace) {
      final message = '$error\n$stackTrace';
      if (message.contains('LateInitializationError') &&
          message.contains('FlutterLocalNotificationsPlatform')) {
        return;
      }
      debugPrint(
        'Failed to schedule prayer notifications: $error\n$stackTrace',
      );
    }
  }

  static void _handleNotificationTapped(
    NotificationResponse notificationResponse,
  ) {
    if (notificationResponse.payload == 'play_azan') {
      AzanAudioService.playAzan(enabled: true);
    }
  }

  static void _configureTimeZone(String timezoneName) {
    tz.initializeTimeZones();

    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error) {
      debugPrint('Failed to configure notification timezone: $error');
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
  }

  static NotificationDetails _buildNotificationDetails(String adhanSound) {
    final playSound = adhanSound != 'silent';
    final androidSound = playSound && adhanSound != 'default'
        ? RawResourceAndroidNotificationSound(adhanSound)
        : null;
    final iosSound = playSound && adhanSound != 'default'
        ? '$adhanSound.caf'
        : null;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'solatify_adhan_channel',
        'Solatify Adzan Reminder',
        channelDescription: 'Diputar saat masuk waktu salat',
        importance: Importance.max,
        priority: Priority.high,
        sound: androidSound,
        playSound: playSound,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        sound: iosSound,
      ),
    );
  }

  static String _formatPrayerLabel(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1);
  }
}
