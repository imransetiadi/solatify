class QiblaHeading {
  const QiblaHeading({required this.degrees, this.accuracy});

  /// Heading relative to true north in degrees (0–360), or null when the
  /// device has no usable compass.
  final double? degrees;

  /// Estimated error in degrees (iOS), or the Android sensor status mapped
  /// to an approximate error. Null when unknown.
  final double? accuracy;

  bool get hasSensorHeading => degrees != null;

  /// True when the compass reports a large error and should be calibrated
  /// (move the phone in a figure-eight).
  bool get needsCalibration => accuracy != null && accuracy! > 25;
}
