import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('app_icon');

    // iOS initialization settings
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

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    // Request permissions for iOS 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Get proper prayer name in Indonesian
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

  /// Generate proper notification title for each prayer
  static String getNotificationTitle(String prayerKey, String location) {
    final prayerName = getPrayerNameInIndonesian(prayerKey);

    return 'Waktu $prayerName - $location';
  }

  /// Generate proper notification message for each prayer
  static String getNotificationMessage(
    String prayerKey,
    String location,
    String prayerTime,
  ) {
    final prayerName = getPrayerNameInIndonesian(prayerKey);

    // Proper Indonesian messages for each prayer
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

  /// Show prayer time notification
  Future<void> showPrayerNotification({
    required String prayerKey,
    required String location,
    required String prayerTime,
    required int notificationId,
  }) async {
    try {
      final title = getNotificationTitle(prayerKey, location);
      final body = getNotificationMessage(prayerKey, location, prayerTime);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'prayer_times_channel',
            'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
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
    } catch (e) {
      debugPrint('Error showing prayer notification: $e');
    }
  }

  /// Schedule notification for a specific time
  Future<void> schedulePrayerNotification({
    required String prayerKey,
    required String location,
    required String prayerTime,
    required DateTime notificationTime,
    required int notificationId,
  }) async {
    try {
      final title = getNotificationTitle(prayerKey, location);
      final body = getNotificationMessage(prayerKey, location, prayerTime);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'prayer_times_channel',
            'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime for scheduling
      final localTimezone = tz.local;
      final scheduledDate = tz.TZDateTime.from(notificationTime, localTimezone);

      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerKey,
      );

      debugPrint('Prayer notification scheduled for $notificationTime: $title');
    } catch (e) {
      debugPrint('Error scheduling prayer notification: $e');
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Notification $notificationId cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
