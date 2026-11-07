import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';

abstract class QiblaHeadingRepository {
  /// Streams the device heading. [latitude]/[longitude] let platforms that
  /// only measure magnetic north (Android) correct for magnetic declination.
  Stream<QiblaHeading> watchHeading({double? latitude, double? longitude});
}
