import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/qibla/data/repositories/native_compass_qibla_heading_repository.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('native compass events', () {
    test('parses heading and accuracy', () {
      final heading = NativeCompassQiblaHeadingRepository.parseCompassEvent({
        'heading': 295.4,
        'accuracy': 12.0,
      });
      expect(heading.degrees, 295.4);
      expect(heading.accuracy, 12.0);
      expect(heading.needsCalibration, isFalse);
    });

    test('normalises headings to 0–360', () {
      final heading = NativeCompassQiblaHeadingRepository.parseCompassEvent({
        'heading': 370.0,
      });
      expect(heading.degrees, closeTo(10.0, 1e-9));
    });

    test('flags inaccurate readings for calibration', () {
      final heading = NativeCompassQiblaHeadingRepository.parseCompassEvent({
        'heading': 10,
        'accuracy': 45,
      });
      expect(heading.needsCalibration, isTrue);
    });

    test('malformed events mean "no heading"', () {
      expect(
        NativeCompassQiblaHeadingRepository.parseCompassEvent('x').degrees,
        isNull,
      );
    });

    test('a platform error becomes "no heading" instead of an error', () async {
      const channel = EventChannel('test/compass_unavailable');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(
            channel,
            MockStreamHandler.inline(
              onListen: (arguments, events) {
                expect(arguments, {'latitude': -6.2, 'longitude': 106.8});
                events.error(code: 'unavailable', message: 'No compass');
              },
            ),
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(channel, null);
      });

      final repository = NativeCompassQiblaHeadingRepository(channel: channel);
      final first = await repository
          .watchHeading(latitude: -6.2, longitude: 106.8)
          .first;

      expect(first, isA<QiblaHeading>());
      expect(first.hasSensorHeading, isFalse);
    });
  });
}
