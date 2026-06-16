import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _canUseExactAlarms = true;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    final didInit = await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    debugPrint('flutter_local_notifications initialized: $didInit');

    // Create Android notification channel explicitly (Android 8+)
    await _createNotificationChannel();

    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request Android 13+ POST_NOTIFICATIONS permission
    await requestAndroidPermissions();

    _initialized = true;
    debugPrint('NotificationService fully initialized');
  }

  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_times_adhan_channel_v1',
      'Prayer Times Adhan',
      description: 'Adhan notifications for prayer times',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      enableLights: true,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
    debugPrint('Notification channel created: prayer_times_adhan_channel_v1');
  }

  Future<void> requestAndroidPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return;

    final notifGranted = await androidImplementation
        .requestNotificationsPermission();
    debugPrint('Android POST_NOTIFICATIONS permission granted: $notifGranted');

    final alarmGranted = await androidImplementation
        .requestExactAlarmsPermission();
    _canUseExactAlarms = alarmGranted ?? false;
    debugPrint(
      'Android SCHEDULE_EXACT_ALARM permission granted: $alarmGranted',
    );
  }

  AndroidScheduleMode _androidScheduleMode() {
    if (_canUseExactAlarms) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    debugPrint(
      'Exact alarm permission denied; falling back to inexact scheduling.',
    );
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Ensures init() has been called before any notification operation.
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  static String getPrayerNameInIndonesian(String prayerKey) {
    switch (prayerKey) {
      case 'subuh':
        return 'Subuh';
      case 'dzuhur':
        return 'Dzuhur';
      case 'ashar':
        return 'Ashar';
      case 'magrib':
        return 'Magrib';
      case 'isya':
        return 'Isya';
      default:
        return prayerKey;
    }
  }

  static String getNotificationTitle(String prayerKey, String location) {
    final prayerName = getPrayerNameInIndonesian(prayerKey);
    return 'Waktu $prayerName - $location';
  }

  static String getNotificationMessage(
    String prayerKey,
    String location,
    String prayerTime,
  ) {
    final prayerName = getPrayerNameInIndonesian(prayerKey);
    switch (prayerKey) {
      case 'subuh':
        return 'Telah masuk waktu salat Subuh di wilayah $location pada pukul $prayerTime. Mulailah persiapan untuk menunaikan ibadah Subuh.';
      case 'dzuhur':
        return 'Telah masuk waktu salat Dzuhur di wilayah $location pada pukul $prayerTime. Segera menunaikan ibadah Dzuhur Anda.';
      case 'ashar':
        return 'Telah masuk waktu salat Ashar di wilayah $location pada pukul $prayerTime. Jangan lewatkan waktu salat Ashar.';
      case 'magrib':
        return 'Telah masuk waktu salat Magrib di wilayah $location pada pukul $prayerTime. Bukalah puasa (jika sedang berpuasa) dan segera salat Magrib.';
      case 'isya':
        return 'Telah masuk waktu salat Isya di wilayah $location pada pukul $prayerTime. Sempurnakannya ibadah Isya Anda sebelum tidur.';
      default:
        return 'Telah masuk waktu salat $prayerName di wilayah $location pada pukul $prayerTime.';
    }
  }

  Future<void> showPrayerNotification({
    required String prayerKey,
    required String location,
    required String prayerTime,
    required int notificationId,
  }) async {
    try {
      await _ensureInitialized();

      final title = getNotificationTitle(prayerKey, location);
      final body = getNotificationMessage(prayerKey, location, prayerTime);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'prayer_times_adhan_channel_v1',
            'Prayer Times Adhan',
            channelDescription: 'Adhan notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan'),
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3', // Requires manual Xcode import
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: prayerKey,
      );
      debugPrint('Prayer notification sent: $title - $body');
    } catch (e, stack) {
      debugPrint('Error showing prayer notification: $e\n$stack');
    }
  }

  Future<void> schedulePrayerNotification({
    required String prayerKey,
    required String location,
    required String prayerTime,
    required DateTime notificationTime,
    required int notificationId,
  }) async {
    try {
      await _ensureInitialized();

      final title = getNotificationTitle(prayerKey, location);
      final body = getNotificationMessage(prayerKey, location, prayerTime);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'prayer_times_adhan_channel_v1',
            'Prayer Times Adhan',
            channelDescription: 'Adhan notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan'),
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3', // Requires manual Xcode import
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final localTimezone = tz.local;
      final scheduledDate = tz.TZDateTime.from(notificationTime, localTimezone);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: _androidScheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerKey,
      );
      debugPrint('Prayer notification scheduled for $notificationTime: $title');
    } catch (e, stack) {
      debugPrint('Error scheduling prayer notification: $e\n$stack');
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Notification $notificationId cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Retrieves pending scheduled notifications for debugging and observability.
  /// Returns the count of notifications awaiting delivery.
  Future<int> getPendingNotificationsCount() async {
    try {
      final pendingNotifications = await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      final count = pendingNotifications.length;

      debugPrint('Pending scheduled notifications: $count');
      return count;
    } catch (e) {
      debugPrint('Error retrieving pending notifications: $e');
      return 0;
    }
  }
}
