import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/core/performance/performance_tuning.dart';

void main() {
  group('PerformanceTuning', () {
    test('uses lightweight visual defaults for shared cards', () {
      expect(PerformanceTuning.maxGlassBlurSigma, 8);
    });

    test(
      'uses second-level countdown ticks instead of sub-second rebuilds',
      () {
        expect(
          PerformanceTuning.countdownTickInterval,
          const Duration(seconds: 1),
        );
      },
    );

    test('uses a coarse notification audit interval', () {
      expect(
        PerformanceTuning.notificationScheduleAuditInterval,
        const Duration(minutes: 15),
      );
    });
  });
}
