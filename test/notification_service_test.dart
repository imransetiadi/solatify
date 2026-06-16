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
}
