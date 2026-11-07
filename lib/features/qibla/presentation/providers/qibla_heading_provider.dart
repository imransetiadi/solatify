import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/qibla/data/repositories/native_compass_qibla_heading_repository.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';
import 'package:solatify/features/qibla/domain/repositories/qibla_heading_repository.dart';

final qiblaHeadingRepositoryProvider = Provider<QiblaHeadingRepository>(
  (ref) => const NativeCompassQiblaHeadingRepository(),
);

/// Auto-disposed so the compass sensors stop as soon as the Qibla screen is
/// left, instead of running in the background for the rest of the session.
final qiblaHeadingProvider = StreamProvider.autoDispose<QiblaHeading>((ref) {
  final location = ref.watch(
    locationProvider.select((l) => (l.latitude, l.longitude)),
  );
  return ref
      .watch(qiblaHeadingRepositoryProvider)
      .watchHeading(latitude: location.$1, longitude: location.$2);
});
