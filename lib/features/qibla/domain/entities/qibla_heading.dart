class QiblaHeading {
  const QiblaHeading({required this.degrees});

  final double? degrees;

  bool get hasSensorHeading => degrees != null;
}
