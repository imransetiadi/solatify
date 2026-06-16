import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    expect(showCall.arguments['id'], 9001);
    expect(showCall.arguments['title'], 'Tes Notifikasi Solatify');
  });
}
