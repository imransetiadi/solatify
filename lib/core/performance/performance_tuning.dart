class PerformanceTuning {
  const PerformanceTuning._();

  static const double maxGlassBlurSigma = 8;
  static const Duration countdownTickInterval = Duration(seconds: 1);
  static const Duration notificationScheduleAuditInterval = Duration(
    minutes: 15,
  );
  static const Duration routeTransitionDuration = Duration(milliseconds: 220);
  static const Duration routeReverseTransitionDuration = Duration(
    milliseconds: 160,
  );
  static const double routeTransitionYOffset = 0.018;
  static const double routeTransitionScaleBegin = 0.992;
  static const Duration coldStartBudget = Duration(seconds: 5);
  static const Duration warmResumeBudget = Duration(seconds: 2);
  static const Duration frameBuildBudget = Duration(milliseconds: 16);
  static const Duration frameRasterBudget = Duration(milliseconds: 16);
  static const int compactWidthSmokeScreenCount = 5;
}
