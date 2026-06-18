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

    test('keeps route transitions fast and subtle', () {
      expect(
        PerformanceTuning.routeTransitionDuration,
        lessThanOrEqualTo(const Duration(milliseconds: 240)),
      );
      expect(
        PerformanceTuning.routeReverseTransitionDuration,
        lessThanOrEqualTo(const Duration(milliseconds: 180)),
      );
      expect(PerformanceTuning.routeTransitionYOffset, lessThanOrEqualTo(0.02));
      expect(
        PerformanceTuning.routeTransitionScaleBegin,
        greaterThanOrEqualTo(0.99),
      );
    });

    test('defines repeatable golden path performance budgets', () {
      expect(
        PerformanceTuning.coldStartBudget,
        lessThanOrEqualTo(const Duration(seconds: 5)),
      );
      expect(
        PerformanceTuning.warmResumeBudget,
        lessThanOrEqualTo(const Duration(seconds: 2)),
      );
      expect(
        PerformanceTuning.frameBuildBudget,
        lessThanOrEqualTo(const Duration(milliseconds: 16)),
      );
      expect(
        PerformanceTuning.frameRasterBudget,
        lessThanOrEqualTo(const Duration(milliseconds: 16)),
      );
      expect(PerformanceTuning.compactWidthSmokeScreenCount, 5);
    });
  });
}
