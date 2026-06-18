import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/prayer_widget/domain/android_prayer_widget_service.dart';
import 'package:solatify/features/prayer_widget/domain/ios_prayer_widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'sync sends compact prayer widget payload to iOS WidgetKit bridge',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(IosPrayerWidgetService.channel, (
            call,
          ) async {
            calls.add(call);
            return true;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(IosPrayerWidgetService.channel, null);
      });

      final service = IosPrayerWidgetService();
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
    },
  );
}
