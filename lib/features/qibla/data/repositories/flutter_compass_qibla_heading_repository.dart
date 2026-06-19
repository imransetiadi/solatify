import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';
import 'package:solatify/features/qibla/domain/repositories/qibla_heading_repository.dart';

class FlutterCompassQiblaHeadingRepository implements QiblaHeadingRepository {
  const FlutterCompassQiblaHeadingRepository();

  @override
  Stream<QiblaHeading> watchHeading() {
    return FlutterCompass.events.map(
      (event) => QiblaHeading(degrees: event.heading),
    );
  }
}
