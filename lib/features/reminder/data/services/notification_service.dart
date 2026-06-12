import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'azan_audio_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _iosNotificationChannel = MethodChannel(
    'solatify/notifications',
  );
  static bool _initialized = false;
  static String _timezoneName = 'Asia/Jakarta';
  static Future<void> _scheduleChain = Future.value();

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
    if (kIsWeb || _isFlutterTest) return;

    _scheduleChain = _scheduleChain.then(
      (_) => _schedulePrayerNotificationsSafely(
        prayerTimes: prayerTimes,
        adhanSound: adhanSound,
        notificationEnabled: notificationEnabled,
        azanSoundEnabled: azanSoundEnabled,
        timezoneName: timezoneName,
      ),
    );
    return _scheduleChain;
  }

  static Future<void> _schedulePrayerNotificationsSafely({
    required Map<String, DateTime> prayerTimes,
    required String adhanSound,
    required bool notificationEnabled,
    required bool azanSoundEnabled,
    required String timezoneName,
  }) async {
    try {
      if (Platform.isIOS) {
        await _schedulePrayerNotificationsNatively(
          prayerTimes: prayerTimes,
          adhanSound: adhanSound,
          notificationEnabled: notificationEnabled,
          azanSoundEnabled: azanSoundEnabled,
        );
        return;
      }

      _timezoneName = timezoneName;
      _configureTimeZone(timezoneName);
      await init();
      await _notificationsPlugin.cancelAll();

      if (!notificationEnabled) return;

      final notificationDetails = _buildNotificationDetails(
        adhanSound: adhanSound,
        azanSoundEnabled: azanSoundEnabled,
      );
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
          payload: azanSoundEnabled ? 'play_azan:$adhanSound' : '',
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

  static Future<void> scheduleTestAdhanNotification({
    required String adhanSound,
    required bool azanSoundEnabled,
  }) async {
    if (kIsWeb || _isFlutterTest) return;

    if (Platform.isIOS) {
      debugPrint('Scheduling native iOS test adhan: $adhanSound');
      try {
        await _iosNotificationChannel
            .invokeMethod('scheduleTestAdhanNotification', {
              'soundName': _iosSoundFileName(adhanSound),
              'playSound': azanSoundEnabled && adhanSound != 'silent',
            });
        debugPrint('Native iOS test adhan scheduled');
        return;
      } catch (error, stackTrace) {
        debugPrint(
          'Native iOS test adhan failed, using plugin fallback: $error\n$stackTrace',
        );
      }
    }

    await init();
    await _notificationsPlugin.zonedSchedule(
      id: 9001,
      title: 'Tes Adzan Solatify',
      body: 'Jika ini muncul dan berbunyi, notifikasi adzan aktif.',
      scheduledDate: tz.TZDateTime.from(
        DateTime.now().add(const Duration(seconds: 10)),
        tz.local,
      ),
      notificationDetails: _buildNotificationDetails(
        adhanSound: adhanSound,
        azanSoundEnabled: azanSoundEnabled,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: azanSoundEnabled ? 'play_azan:$adhanSound' : '',
    );
  }

  static void _handleNotificationTapped(
    NotificationResponse notificationResponse,
  ) {
    final payload = notificationResponse.payload ?? '';
    if (payload.startsWith('play_azan')) {
      final sound = payload.contains(':')
          ? payload.split(':').last
          : 'adhan_makkah';
      AzanAudioService.playAzan(enabled: true, adhanSound: sound);
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

  static NotificationDetails _buildNotificationDetails({
    required String adhanSound,
    required bool azanSoundEnabled,
  }) {
    final playSound = azanSoundEnabled && adhanSound != 'silent';
    final nativeSoundName = _nativeNotificationSoundName(adhanSound);
    final androidSound = playSound && nativeSoundName != null
        ? RawResourceAndroidNotificationSound(nativeSoundName)
        : null;
    final iosSound = playSound && nativeSoundName != null
        ? '$nativeSoundName.caf'
        : null;
    final channelSuffix = playSound ? nativeSoundName ?? 'default' : 'silent';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'solatify_adhan_channel_v6_$channelSuffix',
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
        presentBanner: true,
        presentList: true,
        presentSound: playSound,
        sound: iosSound,
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }

  static String? _nativeNotificationSoundName(String adhanSound) {
    if (adhanSound == 'silent' || adhanSound == 'default') return null;
    if (adhanSound == 'adhan_madinah') return 'adhan_madinah';
    return 'adhan_makkah';
  }

  static Future<void> _schedulePrayerNotificationsNatively({
    required Map<String, DateTime> prayerTimes,
    required String adhanSound,
    required bool notificationEnabled,
    required bool azanSoundEnabled,
  }) async {
    final now = DateTime.now();
    var notificationId = 0;
    final notifications = <Map<String, Object>>[];

    for (final entry in prayerTimes.entries) {
      final prayerTime = entry.value;
      if (!prayerTime.isAfter(now)) continue;
      final label = _formatPrayerLabel(entry.key);
      notifications.add({
        'id': notificationId++,
        'title': 'Waktu Salat $label',
        'body': 'Telah masuk waktu salat $label untuk wilayah Anda.',
        'timestampMs': prayerTime.millisecondsSinceEpoch.toDouble(),
      });
    }

    await _iosNotificationChannel.invokeMethod('schedulePrayerNotifications', {
      'notificationEnabled': notificationEnabled,
      'playSound': azanSoundEnabled && adhanSound != 'silent',
      'soundName': _iosSoundFileName(adhanSound),
      'notifications': notifications,
    });
    debugPrint(
      'Native iOS prayer notifications scheduled: ${notifications.length}',
    );
  }

  static String? _iosSoundFileName(String adhanSound) {
    final nativeName = _nativeNotificationSoundName(adhanSound);
    return nativeName == null ? null : '$nativeName.aiff';
  }

  static bool get _isFlutterTest {
    var isTest = false;
    assert(() {
      try {
        isTest = WidgetsBinding.instance.runtimeType.toString().contains(
          'Test',
        );
      } catch (_) {
        isTest = true;
      }
      return true;
    }());
    return isTest;
  }

  static String _formatPrayerLabel(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1);
  }
}
