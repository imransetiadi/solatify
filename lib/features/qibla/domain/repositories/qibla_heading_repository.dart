import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';

abstract class QiblaHeadingRepository {
  Stream<QiblaHeading> watchHeading();
}
