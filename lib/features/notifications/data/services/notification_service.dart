import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/navigation/router.dart';
import 'package:solatify/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationReadinessStatus {
  ready,
  needsNotificationPermission,
  inexactScheduling,
  unknown,
}

class NotificationReadiness {
  const NotificationReadiness({
    required this.status,
    required this.title,
    required this.message,
    required this.needsPermissionAction,
    required this.canSendTestNotification,
  });

  factory NotificationReadiness.ready() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.ready,
      title: 'Notifikasi aktif',
      message: 'Pengingat waktu salat siap digunakan.',
      needsPermissionAction: false,
      canSendTestNotification: true,
    );
  }

  factory NotificationReadiness.needsNotificationPermission() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.needsNotificationPermission,
      title: 'Perlu izin notifikasi',
      message: 'Aktifkan izin agar pengingat waktu salat dapat muncul.',
      needsPermissionAction: true,
      canSendTestNotification: false,
    );
  }

  factory NotificationReadiness.inexactScheduling() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.inexactScheduling,
      title: 'Jadwal mungkin tidak tepat',
      message: 'Aktifkan alarm tepat waktu agar pengingat lebih akurat.',
      needsPermissionAction: true,
      canSendTestNotification: true,
    );
  }

  factory NotificationReadiness.unknown() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.unknown,
      title: 'Periksa izin notifikasi',
      message: 'Status notifikasi belum dapat dipastikan.',
      needsPermissionAction: true,
      canSendTestNotification: false,
    );
  }

  final NotificationReadinessStatus status;
  final String title;
  final String message;
  final bool needsPermissionAction;
  final bool canSendTestNotification;
}

class NotificationService {
  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }
  static final NotificationService _instance = NotificationService._internal();

  static const String _prayerChannelId = 'prayer_times_adhan_channel';
  static const String _prayerBeepChannelId = 'prayer_times_beep_channel';
  static const String _prayerSilentChannelId = 'prayer_times_silent_channel';
  static const String _diagnosticChannelId = 'solatify_diagnostic_channel_v2';
  static const String _notificationHistoryKey = 'notification_history';
  static const List<String> _legacyPrayerChannelIds = [
    'prayer_times_adhan_channel_v2',
    'prayer_times_adhan_channel_v7',
  ];
  static const MethodChannel _androidPrayerAlarmChannel = MethodChannel(
    'solatify/android_prayer_alarms',
  );
  static const MethodChannel _iosSettingsChannel = MethodChannel(
    'solatify/ios_settings',
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _canUseExactAlarms = true;

  Future<bool> scheduleAndroidPrayerAlarm({
    required String prayerKey,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required int notificationId,
    required bool isReminder,
    required String soundMode,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;

    try {
      final scheduled = await _androidPrayerAlarmChannel
          .invokeMethod<bool>('schedulePrayerAlarm', <String, Object?>{
            'id': notificationId,
            'prayerKey': prayerKey,
            'title': title,
            'body': body,
            'scheduledAtMillis': scheduledAt.millisecondsSinceEpoch,
            'isReminder': isReminder,
            'soundMode': soundMode,
          });
      return scheduled ?? false;
    } catch (e, stack) {
      debugPrint('Error scheduling native Android prayer alarm: $e\n$stack');
      return false;
    }
  }

  Future<void> cancelAllAndroidPrayerAlarms() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _androidPrayerAlarmChannel.invokeMethod<void>(
        'cancelAllPrayerAlarms',
      );
    } catch (e) {
      debugPrint('Error cancelling native Android prayer alarms: $e');
    }
  }

  Future<void> cancelAndroidPrayerAlarm(int notificationId) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _androidPrayerAlarmChannel.invokeMethod<void>('cancelPrayerAlarm', {
        'id': notificationId,
      });
    } catch (e) {
      debugPrint('Error cancelling native Android prayer alarm: $e');
    }
  }

  Future<List<int>> getPendingAndroidPrayerAlarmIds() async {
    if (defaultTargetPlatform != TargetPlatform.android) return const [];

    try {
      final ids = await _androidPrayerAlarmChannel.invokeMethod<List<dynamic>>(
        'getPendingPrayerAlarmIds',
      );
      return ids?.whereType<int>().toList(growable: false) ?? const [];
    } catch (e) {
      debugPrint('Error reading native Android prayer alarm IDs: $e');
      return const [];
    }
  }

  Future<bool> isIgnoringAndroidBatteryOptimizations() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    try {
      return await _androidPrayerAlarmChannel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          true;
    } catch (e) {
      debugPrint('Error checking Android battery optimization status: $e');
      return true;
    }
  }

  Future<bool> openAndroidBatteryOptimizationSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;

    try {
      return await _androidPrayerAlarmChannel.invokeMethod<bool>(
            'openBatteryOptimizationSettings',
          ) ??
          false;
    } catch (e) {
      debugPrint('Error opening Android battery optimization settings: $e');
      return false;
    }
  }

  Future<bool> openAndroidNotificationSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;

    try {
      return await _androidPrayerAlarmChannel.invokeMethod<bool>(
            'openNotificationSettings',
          ) ??
          false;
    } catch (e) {
      debugPrint('Error opening Android notification settings: $e');
      return false;
    }
  }

  Future<bool> openIosNotificationSettings() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;

    try {
      return await _iosSettingsChannel.invokeMethod<bool>(
            'openNotificationSettings',
          ) ??
          false;
    } catch (e) {
      debugPrint('Error opening iOS notification settings: $e');
      return false;
    }
  }

  Future<bool> requestIosPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return true;

    try {
      await _ensureInitialized();
      final nativeGranted = await _iosSettingsChannel.invokeMethod<bool>(
        'requestNotificationPermissions',
      );
      if (nativeGranted != null) {
        debugPrint(
          'Native iOS notification permission granted: $nativeGranted',
        );
        return nativeGranted;
      }

      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS notification permission granted: $granted');
      return granted ?? false;
    } catch (e, stack) {
      debugPrint('Error requesting iOS notification permission: $e\n$stack');
      return false;
    }
  }

  Future<bool> openPlatformNotificationSettings() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return openIosNotificationSettings();
    }

    return openAndroidNotificationSettings();
  }

  Future<bool> openAndroidExactAlarmSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;

    try {
      return await _androidPrayerAlarmChannel.invokeMethod<bool>(
            'openExactAlarmSettings',
          ) ??
          false;
    } catch (e) {
      debugPrint('Error opening Android exact alarm settings: $e');
      return false;
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    final didInit = await _flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    debugPrint('flutter_local_notifications initialized: $didInit');

    // Create Android notification channel explicitly (Android 8+)
    await _createNotificationChannel();

    _initialized = true;
    debugPrint('NotificationService fully initialized');
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    if (_isPrayerNotificationPayload(payload)) {
      goRouter.go(AppRoutes.schedule);
    }
  }

  bool _isPrayerNotificationPayload(String payload) {
    return const {
      'subuh',
      'dzuhur',
      'ashar',
      'magrib',
      'isya',
    }.contains(payload.toLowerCase());
  }

  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    const AndroidNotificationChannel prayerChannel = AndroidNotificationChannel(
      _prayerChannelId,
      'Prayer Times Adhan',
      description: 'Adhan notifications for prayer times',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      enableLights: true,
    );

    const AndroidNotificationChannel diagnosticChannel =
        AndroidNotificationChannel(
          _diagnosticChannelId,
          'Solatify Diagnostic',
          description: 'Diagnostic test notifications for Solatify',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );
    const AndroidNotificationChannel beepChannel = AndroidNotificationChannel(
      _prayerBeepChannelId,
      'Prayer Times Beep',
      description: 'Short sound notifications for prayer times',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    const AndroidNotificationChannel silentChannel = AndroidNotificationChannel(
      _prayerSilentChannelId,
      'Prayer Times Silent',
      description: 'Silent notifications for prayer times',
      importance: Importance.max,
      playSound: false,
      enableVibration: false,
      enableLights: true,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    for (final legacyChannelId in _legacyPrayerChannelIds) {
      await androidPlugin?.deleteNotificationChannel(
        channelId: legacyChannelId,
      );
    }
    await androidPlugin?.createNotificationChannel(prayerChannel);
    await androidPlugin?.createNotificationChannel(beepChannel);
    await androidPlugin?.createNotificationChannel(silentChannel);
    await androidPlugin?.createNotificationChannel(diagnosticChannel);
    debugPrint('Notification channel created: $_prayerChannelId');
    debugPrint('Notification channel created: $_diagnosticChannelId');
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
    final canScheduleExact = await androidImplementation
        .canScheduleExactNotifications();
    _canUseExactAlarms = canScheduleExact ?? alarmGranted ?? false;
    debugPrint(
      'Android exact alarm request result: $alarmGranted, '
      'can schedule exact: $canScheduleExact',
    );
  }

  Future<bool> _areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.areNotificationsEnabled() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final nativeEnabled = await _iosSettingsChannel.invokeMethod<bool>(
        'areNotificationsEnabled',
      );
      if (nativeEnabled != null) return nativeEnabled;

      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final permissions = await iosImplementation?.checkPermissions();
      return permissions?.isEnabled ?? true;
    }

    return true;
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

  bool _isExactAlarmPermissionError(Object error) {
    if (error is! PlatformException) return false;

    final code = error.code.toLowerCase();
    final message = error.message?.toLowerCase() ?? '';
    return code.contains('exact') ||
        code.contains('alarm') ||
        message.contains('exact alarm') ||
        message.contains('schedule_exact_alarm');
  }

  /// Ensures init() has been called before any notification operation.
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  Future<void> _refreshExactAlarmCapability() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final canScheduleExact = await androidImplementation
        ?.canScheduleExactNotifications();
    if (canScheduleExact != null) {
      _canUseExactAlarms = canScheduleExact;
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
            _prayerChannelId,
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
        sound: 'adhan_short.caf',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
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
    required String timezoneName,
    required int notificationId,
    bool isReminder = false,
    String soundMode = 'adhan',
    bool refreshExactAlarmCapability = true,
  }) async {
    try {
      await _ensureInitialized();
      if (refreshExactAlarmCapability) {
        await _refreshExactAlarmCapability();
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final granted = await requestIosPermissions();
        if (!granted) {
          await recordScheduleFailure(
            reason: 'iOS notification permission denied',
            permissionStatus:
                NotificationReadinessStatus.needsNotificationPermission.name,
          );
          debugPrint('Skipping iOS prayer schedule; notification denied.');
          return;
        }
      }

      final title = getNotificationTitle(prayerKey, location);
      final body = getNotificationMessage(prayerKey, location, prayerTime);
      final notificationDetails = _prayerNotificationDetails(soundMode);

      if (defaultTargetPlatform == TargetPlatform.android) {
        final prayerLocation = tz.getLocation(timezoneName);
        final scheduledDate = tz.TZDateTime.from(
          notificationTime,
          prayerLocation,
        );
        final scheduledNatively = await scheduleAndroidPrayerAlarm(
          prayerKey: prayerKey,
          title: title,
          body: body,
          scheduledAt: scheduledDate,
          notificationId: notificationId,
          isReminder: isReminder,
          soundMode: soundMode,
        );
        if (scheduledNatively) {
          await _flutterLocalNotificationsPlugin.cancel(id: notificationId);
          debugPrint(
            'Native Android prayer alarm scheduled for $notificationTime '
            'timezone=$timezoneName: $title',
          );
          return;
        }
        debugPrint(
          'Native Android prayer alarm unavailable; falling back to plugin scheduling.',
        );
      }

      final prayerLocation = tz.getLocation(timezoneName);
      final scheduledDate = tz.TZDateTime.from(
        notificationTime,
        prayerLocation,
      );

      final scheduleMode = _androidScheduleMode();
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: scheduleMode,
          payload: prayerKey,
        );
      } catch (e) {
        if (scheduleMode != AndroidScheduleMode.exactAllowWhileIdle ||
            !_isExactAlarmPermissionError(e)) {
          rethrow;
        }

        _canUseExactAlarms = false;
        debugPrint(
          'Exact alarm scheduling failed; retrying prayer notification '
          'with inexact scheduling: $e',
        );
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: prayerKey,
        );
      }
      debugPrint(
        'Prayer notification scheduled for $notificationTime '
        'timezone=$timezoneName: $title',
      );
    } catch (e, stack) {
      debugPrint('Error scheduling prayer notification: $e\n$stack');
      rethrow;
    }
  }

  NotificationDetails _prayerNotificationDetails(String soundMode) {
    switch (soundMode) {
      case 'silent':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _prayerSilentChannelId,
            'Prayer Times Silent',
            channelDescription: 'Silent notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: false,
            playSound: false,
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          ),
        );
      case 'beep':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _prayerBeepChannelId,
            'Prayer Times Beep',
            channelDescription: 'Short sound notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );
      default:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _prayerChannelId,
            'Prayer Times Adhan',
            channelDescription: 'Adhan notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan'),
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'adhan_short.caf',
          ),
        );
    }
  }

  Future<NotificationReadiness> getReadinessStatus() async {
    try {
      await _ensureInitialized();
      await _refreshExactAlarmCapability();
      final notificationsEnabled = await _areNotificationsEnabled();

      if (!notificationsEnabled) {
        return NotificationReadiness.needsNotificationPermission();
      }

      if (defaultTargetPlatform == TargetPlatform.android &&
          !_canUseExactAlarms) {
        return NotificationReadiness.inexactScheduling();
      }

      return NotificationReadiness.ready();
    } catch (e) {
      debugPrint('Error checking notification readiness: $e');
      return NotificationReadiness.unknown();
    }
  }

  NotificationHistoryEntry getNotificationHistory() {
    final raw = HiveService.getSetting(_notificationHistoryKey);
    if (raw is Map) return NotificationHistoryEntry.fromJson(raw);
    return const NotificationHistoryEntry();
  }

  Future<void> recordScheduleSuccess({
    required int scheduledCount,
    required String permissionStatus,
  }) async {
    final current = getNotificationHistory();
    final next = current.copyWith(
      lastScheduledAt: DateTime.now(),
      lastScheduledCount: scheduledCount,
      lastPermissionStatus: permissionStatus,
    );
    await HiveService.saveSetting(_notificationHistoryKey, next.toJson());
  }

  Future<void> recordScheduleFailure({
    required String reason,
    String? permissionStatus,
  }) async {
    final current = getNotificationHistory();
    final next = current.copyWith(
      lastFailedAt: DateTime.now(),
      lastFailedReason: reason,
      lastPermissionStatus: permissionStatus,
    );
    await HiveService.saveSetting(_notificationHistoryKey, next.toJson());
  }

  Future<void> showTestNotification() async {
    try {
      await _ensureInitialized();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final shownNatively = await _iosSettingsChannel.invokeMethod<bool>(
          'showTestNotification',
        );
        if (shownNatively == true) {
          debugPrint('Native iOS test notification sent');
          return;
        }
        debugPrint(
          'Native iOS test notification unavailable; falling back to plugin.',
        );
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        1000000,
      );

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _diagnosticChannelId,
            'Solatify Diagnostic',
            channelDescription: 'Diagnostic test notifications for Solatify',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: 'Tes Notifikasi Solatify',
        body: 'Jika notifikasi ini muncul, pengingat salat siap digunakan.',
        notificationDetails: notificationDetails,
        payload: 'test_notification',
      );
      debugPrint(
        'Test notification sent: id=$notificationId channel=$_diagnosticChannelId',
      );
    } catch (e, stack) {
      debugPrint('Error showing test notification: $e\n$stack');
      rethrow;
    }
  }

  Future<void> scheduleDiagnosticNotification({DateTime? scheduledAt}) async {
    try {
      await _ensureInitialized();

      final targetTime =
          scheduledAt ?? DateTime.now().add(const Duration(minutes: 2));

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _diagnosticChannelId,
            'Solatify Diagnostic',
            channelDescription: 'Diagnostic test notifications for Solatify',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledDate = tz.TZDateTime.from(targetTime, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 9002,
        title: 'Tes Jadwal Notifikasi Solatify',
        body:
            'Jika notifikasi terjadwal ini muncul, jadwal pengingat siap digunakan.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: _androidScheduleMode(),
        payload: 'scheduled_test_notification',
      );
      debugPrint('Diagnostic scheduled notification set for $targetTime');
    } catch (e, stack) {
      debugPrint('Error scheduling diagnostic notification: $e\n$stack');
      rethrow;
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await cancelAndroidPrayerAlarm(notificationId);
      await _flutterLocalNotificationsPlugin.cancel(id: notificationId);
      debugPrint('Notification $notificationId cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await cancelAllAndroidPrayerAlarms();
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

  Future<List<int>> getPendingNotificationIds() async {
    try {
      final pendingNotifications = await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      final nativeIds = await getPendingAndroidPrayerAlarmIds();
      final ids = <int>{
        ...pendingNotifications.map((request) => request.id),
        ...nativeIds,
      }.toList()..sort();

      debugPrint('Pending scheduled notification IDs: $ids');
      return ids;
    } catch (e) {
      debugPrint('Error retrieving pending notification IDs: $e');
      return const [];
    }
  }
}
