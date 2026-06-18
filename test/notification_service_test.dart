import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const androidPrayerAlarmChannel = MethodChannel(
    'solatify/android_prayer_alarms',
  );
  final service = NotificationService();
  final capturedMethods = <MethodCall>[];
  final capturedNativeAlarmMethods = <MethodCall>[];

  test(
    'notification history entry serializes schedule and failure metadata',
    () {
      final entry = NotificationHistoryEntry(
        lastScheduledAt: DateTime(2026, 6, 18, 7),
        lastScheduledCount: 6,
        lastFailedAt: DateTime(2026, 6, 18, 8),
        lastFailedReason: 'permission denied',
        lastPermissionStatus: 'ready',
      );

      final restored = NotificationHistoryEntry.fromJson(entry.toJson());

      expect(restored.lastScheduledAt, DateTime(2026, 6, 18, 7));
      expect(restored.lastScheduledCount, 6);
      expect(restored.lastFailedAt, DateTime(2026, 6, 18, 8));
      expect(restored.lastFailedReason, 'permission denied');
      expect(restored.lastPermissionStatus, 'ready');
    },
  );

  test('notification service exposes history recording helpers', () {
    final source = File(
      'lib/features/notifications/data/services/notification_service.dart',
    ).readAsStringSync();

    expect(source, contains('recordScheduleSuccess'));
    expect(source, contains('recordScheduleFailure'));
    expect(source, contains('notification_history'));
  });

  setUp(() async {
    capturedMethods.clear();
    capturedNativeAlarmMethods.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          capturedMethods.add(call);
          switch (call.method) {
            case 'initialize':
            case 'createNotificationChannel':
            case 'requestNotificationsPermission':
              return true;
            case 'requestExactAlarmsPermission':
              return false;
            case 'canScheduleExactNotifications':
              return false;
            case 'areNotificationsEnabled':
              return true;
            case 'pendingNotificationRequests':
              return [
                <String, dynamic>{
                  'id': 1,
                  'title': 'A',
                  'body': 'B',
                  'payload': 'C',
                },
                <String, dynamic>{
                  'id': 2,
                  'title': 'D',
                  'body': 'E',
                  'payload': 'F',
                },
              ];
            case 'zonedSchedule':
              return null;
            case 'show':
              return null;
            default:
              return null;
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidPrayerAlarmChannel, (
          MethodCall call,
        ) async {
          capturedNativeAlarmMethods.add(call);
          if (call.method == 'getPendingPrayerAlarmIds') return <int>[];
          if (call.method == 'isIgnoringBatteryOptimizations') return true;
          if (call.method == 'openBatteryOptimizationSettings') return true;
          return false;
        });
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidPrayerAlarmChannel, null);
  });

  test(
    'initializes without requesting Android notification permission',
    () async {
      await service.init();

      expect(
        capturedMethods.where(
          (call) => call.method == 'requestNotificationsPermission',
        ),
        isEmpty,
      );
      expect(
        capturedMethods.where(
          (call) => call.method == 'requestExactAlarmsPermission',
        ),
        isEmpty,
      );
    },
  );

  test('falls back to inexact scheduling when exact alarm is denied', () async {
    await service.init();
    await service.schedulePrayerNotification(
      prayerKey: 'subuh',
      location: 'Jakarta, Indonesia',
      prayerTime: '04:30',
      notificationTime: DateTime.now().add(const Duration(minutes: 10)),
      timezoneName: 'Asia/Jakarta',
      notificationId: 1001,
    );

    final zonedSchedule = capturedMethods.lastWhere(
      (call) => call.method == 'zonedSchedule',
    );
    expect(
      zonedSchedule.arguments['platformSpecifics']['scheduleMode'],
      'inexactAllowWhileIdle',
    );
  });

  test('schedules prayer adzan in the selected prayer timezone', () async {
    await service.init();
    final makassar = tz.getLocation('Asia/Makassar');
    final prayerTime = tz.TZDateTime.now(
      makassar,
    ).add(const Duration(minutes: 10));

    await service.schedulePrayerNotification(
      prayerKey: 'dzuhur',
      location: 'Makassar, Indonesia',
      prayerTime: '12:00',
      notificationTime: prayerTime,
      timezoneName: 'Asia/Makassar',
      notificationId: 1002,
    );

    final zonedSchedule = capturedMethods.lastWhere(
      (call) => call.method == 'zonedSchedule',
    );
    expect(zonedSchedule.arguments['id'], 1002);
    expect(zonedSchedule.arguments['payload'], 'dzuhur');
    expect(zonedSchedule.arguments['timeZoneName'], 'Asia/Makassar');
    expect(
      zonedSchedule.arguments['scheduledDateTimeISO8601'],
      prayerTime.toIso8601String(),
    );
    expect(
      zonedSchedule.arguments['platformSpecifics']['channelId'],
      'prayer_times_adhan_channel',
    );
  });

  test(
    'can skip repeated exact-alarm capability refresh while batching',
    () async {
      await service.init();

      await service.schedulePrayerNotification(
        prayerKey: 'ashar',
        location: 'Jakarta, Indonesia',
        prayerTime: '15:20',
        notificationTime: DateTime.now().add(const Duration(minutes: 10)),
        timezoneName: 'Asia/Jakarta',
        notificationId: 1003,
        refreshExactAlarmCapability: false,
      );

      expect(
        capturedMethods.where(
          (call) => call.method == 'canScheduleExactNotifications',
        ),
        isEmpty,
      );
      expect(
        capturedMethods.where((call) => call.method == 'zonedSchedule'),
        hasLength(1),
      );
    },
  );

  test(
    'uses matching prayer notification channels across Flutter and native Android',
    () {
      final notificationService = File(
        'lib/features/notifications/data/services/notification_service.dart',
      ).readAsStringSync();
      final receiver = File(
        'android/app/src/main/kotlin/com/solatify/app/solatify/notifications/PrayerAlarmReceiver.kt',
      ).readAsStringSync();

      expect(
        notificationService,
        contains("_prayerChannelId = 'prayer_times_adhan_channel'"),
      );
      expect(receiver, contains('CHANNEL_ID = "prayer_times_adhan_channel"'));
      expect(
        receiver,
        contains('BEEP_CHANNEL_ID = "prayer_times_beep_channel"'),
      );
      expect(
        receiver,
        contains('SILENT_CHANNEL_ID = "prayer_times_silent_channel"'),
      );
      expect(receiver, contains('channelIdFor(soundMode)'));
      expect(receiver, contains('SOUND_MODE_BEEP'));
      expect(receiver, contains('SOUND_MODE_SILENT'));
      expect(notificationService, contains('deleteNotificationChannel'));
    },
  );

  test('native Android alarm model persists sound mode and reminder metadata', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/com/solatify/app/solatify/MainActivity.kt',
    ).readAsStringSync();
    final scheduler = File(
      'android/app/src/main/kotlin/com/solatify/app/solatify/notifications/PrayerAlarmScheduler.kt',
    ).readAsStringSync();
    final receiver = File(
      'android/app/src/main/kotlin/com/solatify/app/solatify/notifications/PrayerAlarmReceiver.kt',
    ).readAsStringSync();

    expect(mainActivity, contains('call.argument<Boolean>("isReminder")'));
    expect(mainActivity, contains('call.argument<String>("soundMode")'));
    expect(scheduler, contains('EXTRA_IS_REMINDER'));
    expect(scheduler, contains('EXTRA_SOUND_MODE'));
    expect(scheduler, contains('.put("isReminder", isReminder)'));
    expect(scheduler, contains('.put("soundMode", soundMode)'));
    expect(
      receiver,
      contains('getBooleanExtra(PrayerAlarmScheduler.EXTRA_IS_REMINDER'),
    );
    expect(
      receiver,
      contains('getStringExtra(PrayerAlarmScheduler.EXTRA_SOUND_MODE)'),
    );
    expect(
      receiver,
      contains('if (soundMode == SOUND_MODE_ADHAN && !isReminder)'),
    );
  });

  test(
    'uses native Android alarm scheduler for prayer notifications',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidPrayerAlarmChannel, (
            MethodCall call,
          ) async {
            capturedNativeAlarmMethods.add(call);
            return true;
          });

      await service.init();
      final scheduledAt = DateTime.now().add(const Duration(minutes: 10));

      await service.schedulePrayerNotification(
        prayerKey: 'isya',
        location: 'Jakarta, Indonesia',
        prayerTime: '19:15',
        notificationTime: scheduledAt,
        timezoneName: 'Asia/Jakarta',
        notificationId: 1005,
      );

      expect(capturedNativeAlarmMethods, hasLength(1));
      expect(capturedNativeAlarmMethods.single.method, 'schedulePrayerAlarm');
      expect(capturedNativeAlarmMethods.single.arguments['id'], 1005);
      expect(capturedNativeAlarmMethods.single.arguments['prayerKey'], 'isya');
      expect(capturedNativeAlarmMethods.single.arguments['soundMode'], 'adhan');
      expect(
        capturedNativeAlarmMethods.single.arguments['isReminder'],
        isFalse,
      );
      expect(
        capturedNativeAlarmMethods.single.arguments['title'],
        'Waktu Isya - Jakarta, Indonesia',
      );
      expect(
        capturedMethods.where((call) => call.method == 'zonedSchedule'),
        isEmpty,
      );
      expect(
        capturedMethods.where((call) => call.method == 'cancel'),
        hasLength(1),
      );
    },
  );

  test(
    'passes sound mode and reminder metadata to native Android scheduler',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidPrayerAlarmChannel, (
            MethodCall call,
          ) async {
            capturedNativeAlarmMethods.add(call);
            return true;
          });

      await service.init();

      await service.schedulePrayerNotification(
        prayerKey: 'subuh',
        location: 'Jakarta, Indonesia',
        prayerTime: '04:30',
        notificationTime: DateTime.now().add(const Duration(minutes: 10)),
        timezoneName: 'Asia/Jakarta',
        notificationId: 3001,
        isReminder: true,
        soundMode: 'silent',
      );

      expect(capturedNativeAlarmMethods.single.method, 'schedulePrayerAlarm');
      expect(
        capturedNativeAlarmMethods.single.arguments['soundMode'],
        'silent',
      );
      expect(capturedNativeAlarmMethods.single.arguments['isReminder'], isTrue);
    },
  );

  test(
    'uses exact scheduling when Android reports exact notifications allowed',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            capturedMethods.add(call);
            switch (call.method) {
              case 'initialize':
              case 'createNotificationChannel':
              case 'requestNotificationsPermission':
                return true;
              case 'requestExactAlarmsPermission':
                return false;
              case 'canScheduleExactNotifications':
              case 'areNotificationsEnabled':
                return true;
              case 'zonedSchedule':
                return null;
              default:
                return null;
            }
          });

      await service.init();
      await service.schedulePrayerNotification(
        prayerKey: 'ashar',
        location: 'Jakarta, Indonesia',
        prayerTime: '15:20',
        notificationTime: DateTime.now().add(const Duration(minutes: 10)),
        timezoneName: 'Asia/Jakarta',
        notificationId: 1003,
      );

      final zonedSchedule = capturedMethods.lastWhere(
        (call) => call.method == 'zonedSchedule',
      );
      expect(
        zonedSchedule.arguments['platformSpecifics']['scheduleMode'],
        'exactAllowWhileIdle',
      );
    },
  );

  test('uses lightweight beep channel for beep notification mode', () async {
    await service.init();

    await service.schedulePrayerNotification(
      prayerKey: 'dzuhur',
      location: 'Jakarta, Indonesia',
      prayerTime: '12:00',
      notificationTime: DateTime.now().add(const Duration(minutes: 10)),
      timezoneName: 'Asia/Jakarta',
      notificationId: 1102,
      soundMode: 'beep',
    );

    final zonedSchedule = capturedMethods.lastWhere(
      (call) => call.method == 'zonedSchedule',
    );
    expect(
      zonedSchedule.arguments['platformSpecifics']['channelId'],
      'prayer_times_beep_channel',
    );
    expect(zonedSchedule.arguments['platformSpecifics']['playSound'], isTrue);
  });

  test('disables sound for silent notification mode', () async {
    await service.init();

    await service.schedulePrayerNotification(
      prayerKey: 'ashar',
      location: 'Jakarta, Indonesia',
      prayerTime: '15:20',
      notificationTime: DateTime.now().add(const Duration(minutes: 10)),
      timezoneName: 'Asia/Jakarta',
      notificationId: 1103,
      soundMode: 'silent',
    );

    final zonedSchedule = capturedMethods.lastWhere(
      (call) => call.method == 'zonedSchedule',
    );
    expect(
      zonedSchedule.arguments['platformSpecifics']['channelId'],
      'prayer_times_silent_channel',
    );
    expect(zonedSchedule.arguments['platformSpecifics']['playSound'], isFalse);
  });

  test(
    'retries prayer scheduling inexactly when exact scheduling is rejected',
    () async {
      var zonedScheduleAttempts = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            capturedMethods.add(call);
            switch (call.method) {
              case 'initialize':
              case 'createNotificationChannel':
              case 'requestNotificationsPermission':
                return true;
              case 'requestExactAlarmsPermission':
              case 'canScheduleExactNotifications':
              case 'areNotificationsEnabled':
                return true;
              case 'zonedSchedule':
                zonedScheduleAttempts++;
                if (zonedScheduleAttempts == 1) {
                  throw PlatformException(
                    code: 'exact_alarms_not_permitted',
                    message: 'Exact alarms are not permitted',
                  );
                }
                return null;
              default:
                return null;
            }
          });

      await service.init();
      await service.schedulePrayerNotification(
        prayerKey: 'magrib',
        location: 'Jakarta, Indonesia',
        prayerTime: '18:00',
        notificationTime: DateTime.now().add(const Duration(minutes: 10)),
        timezoneName: 'Asia/Jakarta',
        notificationId: 1004,
      );

      final scheduleModes = capturedMethods
          .where((call) => call.method == 'zonedSchedule')
          .map((call) => call.arguments['platformSpecifics']['scheduleMode'])
          .toList();
      expect(scheduleModes, ['exactAllowWhileIdle', 'inexactAllowWhileIdle']);
    },
  );

  test('Android manifest declares one exact alarm permission', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(manifest, isNot(contains('android.permission.USE_EXACT_ALARM')));
    expect(
      manifest,
      contains('android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
    );
  });

  test('Android manifest declares native prayer alarm receivers', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('.notifications.PrayerAlarmReceiver'));
    expect(manifest, contains('.notifications.PrayerAlarmBootReceiver'));
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });

  test('Android manifest declares adhan playback foreground service', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
    expect(
      manifest,
      contains('android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK'),
    );
    expect(manifest, contains('.service.AdhanPlaybackService'));
    expect(manifest, contains('android:foregroundServiceType="mediaPlayback"'));
  });

  test('Android host can open app notification settings', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/com/solatify/app/solatify/MainActivity.kt',
    ).readAsStringSync();
    final notificationService = File(
      'lib/features/notifications/data/services/notification_service.dart',
    ).readAsStringSync();

    expect(mainActivity, contains('openNotificationSettings'));
    expect(mainActivity, contains('Settings.ACTION_APP_NOTIFICATION_SETTINGS'));
    expect(notificationService, contains('openAndroidNotificationSettings'));
  });

  test('settings notification toggle only opens Android settings', () {
    final settingsScreen = File(
      'lib/features/settings/presentation/screens/settings_screen.dart',
    ).readAsStringSync();

    expect(settingsScreen, contains('openPlatformNotificationSettings'));
    expect(settingsScreen, isNot(contains('requestAndroidPermissions')));
  });

  test('settings exposes notification reliability shortcuts', () {
    final settingsScreen = File(
      'lib/features/settings/presentation/screens/settings_screen.dart',
    ).readAsStringSync();
    final notificationService = File(
      'lib/features/notifications/data/services/notification_service.dart',
    ).readAsStringSync();

    expect(settingsScreen, contains('notificationReliability'));
    expect(settingsScreen, contains('forceStopWarningMessage'));
    expect(settingsScreen, contains('openPlatformNotificationSettings'));
    expect(settingsScreen, contains('openAndroidExactAlarmSettings'));
    expect(settingsScreen, contains('openAndroidBatteryOptimizationSettings'));
    expect(notificationService, contains('openAndroidExactAlarmSettings'));
  });

  test(
    'settings exposes direct test notification action instead of health center entry',
    () {
      final settingsScreen = File(
        'lib/features/settings/presentation/screens/settings_screen.dart',
      ).readAsStringSync();

      expect(settingsScreen, contains('sendTestNotificationTitle'));
      expect(settingsScreen, contains('_sendTestNotification'));
      expect(
        settingsScreen,
        contains('defaultTargetPlatform == TargetPlatform.iOS'),
      );
      expect(settingsScreen, contains('requestIosPermissions'));
      expect(settingsScreen, contains('openPlatformNotificationSettings'));
      expect(settingsScreen, contains('sendTestNotificationInProgress'));
      expect(settingsScreen, contains('showTestNotification'));
      expect(settingsScreen, contains('refreshSchedules(force: true)'));
      expect(settingsScreen, isNot(contains('notificationHealthEntryTitle')));
      expect(settingsScreen, isNot(contains('AppRoutes.notificationHealth')));
    },
  );

  test('settings verifies notification permission after returning to app', () {
    final settingsScreen = File(
      'lib/features/settings/presentation/screens/settings_screen.dart',
    ).readAsStringSync();
    final healthScreen = File(
      'lib/features/settings/presentation/screens/notification_health_screen.dart',
    ).readAsStringSync();

    expect(settingsScreen, contains('didChangeAppLifecycleState'));
    expect(settingsScreen, contains('AppLifecycleState.resumed'));
    expect(
      settingsScreen,
      contains('_verifyNotificationPermissionAfterReturn'),
    );
    expect(settingsScreen, contains('_areAdhanNotificationsAllowed'));
    expect(settingsScreen, contains('refreshSchedules(force: true)'));
    expect(settingsScreen, contains('cancelAllNotifications'));
    expect(
      settingsScreen,
      contains('syncAdhanNotificationsWithPermission(false)'),
    );
    expect(healthScreen, contains('didChangeAppLifecycleState'));
    expect(healthScreen, contains('AppLifecycleState.resumed'));
    expect(healthScreen, contains('_refreshHealth'));
  });

  test('iOS notification permission is requested before opening settings', () {
    final notificationService = File(
      'lib/features/notifications/data/services/notification_service.dart',
    ).readAsStringSync();
    final settingsScreen = File(
      'lib/features/settings/presentation/screens/settings_screen.dart',
    ).readAsStringSync();
    final appDelegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();

    expect(notificationService, contains('requestAlertPermission: false'));
    expect(notificationService, contains('requestIosPermissions'));
    expect(notificationService, contains('requestPermissions('));
    expect(notificationService, contains('alert: true'));
    expect(notificationService, contains('badge: true'));
    expect(notificationService, contains('sound: true'));
    expect(settingsScreen, contains('requestIosPermissions'));
    expect(notificationService, contains('openIosNotificationSettings'));
    expect(appDelegate, contains('registerIosSettingsChannel'));
    expect(
      appDelegate,
      contains('registrar(forPlugin: "SolatifyIosSettings")'),
    );
    expect(appDelegate, contains('openNotificationSettings'));
    expect(appDelegate, contains('UIApplication.openSettingsURLString'));
  });

  test('prayer notification tap opens Solatify schedule screen', () {
    final notificationService = File(
      'lib/features/notifications/data/services/notification_service.dart',
    ).readAsStringSync();
    final receiver = File(
      'android/app/src/main/kotlin/com/solatify/app/solatify/notifications/PrayerAlarmReceiver.kt',
    ).readAsStringSync();

    expect(notificationService, contains('goRouter.go(AppRoutes.schedule)'));
    expect(receiver, contains('.setContentIntent('));
    expect(receiver, contains('buildContentIntent'));
  });

  test('Adhan playback notification declares stop action', () {
    final service = File(
      'android/app/src/main/kotlin/com/solatify/app/solatify/service/AdhanPlaybackService.kt',
    ).readAsStringSync();

    expect(service, contains('ACTION_STOP_ADHAN'));
    expect(service, contains('.addAction'));
    expect(service, contains('"Berhenti"'));
    expect(service, contains('stopSelf()'));
  });

  test('iOS prayer notifications use a short bundled adhan sound', () {
    final notificationService = File(
      'lib/features/notifications/data/services/notification_service.dart',
    ).readAsStringSync();
    final xcodeProject = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    final adhanSound = File('ios/Runner/adhan_short.caf');

    expect(notificationService, contains('presentSound: true'));
    expect(notificationService, contains("sound: 'adhan_short.caf'"));
    expect(notificationService, isNot(contains("sound: 'adhan.caf'")));
    expect(xcodeProject, contains('adhan_short.caf in Resources'));
    expect(adhanSound.existsSync(), isTrue);
    expect(adhanSound.lengthSync(), greaterThan(0));
    expect(adhanSound.lengthSync(), lessThan(250 * 1000));
  });

  test('reports pending notification count from the platform API', () async {
    final count = await service.getPendingNotificationsCount();

    expect(count, 2);
    expect(capturedMethods.last.method, 'pendingNotificationRequests');
  });

  test(
    'cancels stale prayer notifications on native Android and plugin',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await service.cancelNotification(1004);

      expect(
        capturedNativeAlarmMethods.any(
          (call) =>
              call.method == 'cancelPrayerAlarm' &&
              call.arguments['id'] == 1004,
        ),
        isTrue,
      );
      expect(
        capturedMethods.any(
          (call) => call.method == 'cancel' && call.arguments['id'] == 1004,
        ),
        isTrue,
      );
    },
  );

  test('reports ready readiness when permissions are available', () async {
    final readiness = NotificationReadiness.ready();

    expect(readiness.status, NotificationReadinessStatus.ready);
    expect(readiness.title, 'Notifikasi aktif');
    expect(readiness.needsPermissionAction, isFalse);
    expect(readiness.canSendTestNotification, isTrue);
  });

  test(
    'reports notification permission action when permission is denied',
    () async {
      final readiness = NotificationReadiness.needsNotificationPermission();

      expect(
        readiness.status,
        NotificationReadinessStatus.needsNotificationPermission,
      );
      expect(readiness.title, 'Perlu izin notifikasi');
      expect(readiness.needsPermissionAction, isTrue);
      expect(readiness.canSendTestNotification, isFalse);
    },
  );

  test(
    'reports less precise schedule when exact alarms are unavailable',
    () async {
      final readiness = NotificationReadiness.inexactScheduling();

      expect(readiness.status, NotificationReadinessStatus.inexactScheduling);
      expect(readiness.title, 'Jadwal mungkin tidak tepat');
      expect(readiness.needsPermissionAction, isTrue);
      expect(readiness.canSendTestNotification, isTrue);
    },
  );

  test(
    'getReadinessStatus returns inexact scheduling when exact alarm is denied',
    () async {
      await service.init();

      final readiness = await service.getReadinessStatus();

      expect(readiness.status, NotificationReadinessStatus.inexactScheduling);
      expect(readiness.title, 'Jadwal mungkin tidak tepat');
    },
  );

  test('showTestNotification sends an immediate notification', () async {
    await service.init();

    await service.showTestNotification();

    final showCall = capturedMethods.lastWhere((call) => call.method == 'show');
    expect(showCall.arguments['id'], isNot(9001));
    expect(showCall.arguments['id'], isA<int>());
    expect(showCall.arguments['title'], 'Tes Notifikasi Solatify');
    expect(
      showCall.arguments['platformSpecifics']['channelId'],
      'solatify_diagnostic_channel_v2',
    );
  });

  test('getPendingNotificationIds reports platform pending IDs', () async {
    final ids = await service.getPendingNotificationIds();

    expect(ids, [1, 2]);
    expect(capturedMethods.last.method, 'pendingNotificationRequests');
  });

  test(
    'scheduleDiagnosticNotification schedules a near-future notification',
    () async {
      await service.init();

      final scheduledAt = DateTime.now().add(const Duration(minutes: 2));
      await service.scheduleDiagnosticNotification(scheduledAt: scheduledAt);

      final zonedSchedule = capturedMethods.lastWhere(
        (call) => call.method == 'zonedSchedule',
      );
      expect(zonedSchedule.arguments['id'], 9002);
      expect(
        zonedSchedule.arguments['title'],
        'Tes Jadwal Notifikasi Solatify',
      );
      expect(zonedSchedule.arguments['body'], contains('terjadwal'));
    },
  );
}
