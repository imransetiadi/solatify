import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';
import 'package:solatify/features/qibla/domain/repositories/qibla_heading_repository.dart';

final qiblaHeadingRepositoryProvider = Provider<QiblaHeadingRepository>(
  (ref) => const FlutterCompassQiblaHeadingRepository(),
);

final qiblaHeadingProvider = StreamProvider<QiblaHeading>((ref) {
  return ref.watch(qiblaHeadingRepositoryProvider).watchHeading();
});
