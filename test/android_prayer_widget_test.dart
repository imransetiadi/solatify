import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/prayer_widget/domain/android_prayer_widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sync sends compact prayer widget payload to Android', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidPrayerWidgetService.channel, (
          call,
        ) async {
          calls.add(call);
          return true;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AndroidPrayerWidgetService.channel, null);
    });

    final service = AndroidPrayerWidgetService();
    final synced = await service.sync(
      const PrayerWidgetPayload(
        nextPrayerName: 'Magrib',
        nextPrayerTimeLabel: '18:04',
        countdownLabel: '00:12:30',
        locationLabel: 'Jakarta',
        hijriLabel: '12 Dzulhijjah 1447 H',
      ),
    );

    expect(synced, isTrue);
    expect(calls.single.method, 'syncPrayerWidget');
    expect(calls.single.arguments, {
      'nextPrayerName': 'Magrib',
      'nextPrayerTimeLabel': '18:04',
      'countdownLabel': '00:12:30',
      'locationLabel': 'Jakarta',
      'hijriLabel': '12 Dzulhijjah 1447 H',
    });
  });

  test('sync returns false when Android channel fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidPrayerWidgetService.channel, (
          call,
        ) async {
          throw PlatformException(code: 'widget_error');
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AndroidPrayerWidgetService.channel, null);
    });

    final service = AndroidPrayerWidgetService();
    final synced = await service.sync(PrayerWidgetPayload.empty());

    expect(synced, isFalse);
  });
}
