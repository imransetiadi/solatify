import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final service = NotificationService();
  final capturedMethods = <MethodCall>[];

  setUp(() async {
    capturedMethods.clear();
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
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

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
      'prayer_times_adhan_channel_v2',
    );
  });

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

  test('Android manifest declares exact alarm permissions', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(manifest, contains('android.permission.USE_EXACT_ALARM'));
  });

  test('reports pending notification count from the platform API', () async {
    final count = await service.getPendingNotificationsCount();

    expect(count, 2);
    expect(capturedMethods.last.method, 'pendingNotificationRequests');
  });

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
