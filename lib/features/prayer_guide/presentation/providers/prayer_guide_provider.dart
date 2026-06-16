import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/prayer_guide/data/datasources/prayer_guide_local_data_source.dart';
import 'package:solatify/features/prayer_guide/domain/models/prayer_guide_step.dart';

final prayerGuideLocalDataSourceProvider = Provider<PrayerGuideLocalDataSource>(
  (ref) => const PrayerGuideLocalDataSource(),
);

final prayerGuideSummariesProvider = Provider<List<PrayerGuideSummary>>((ref) {
  return ref.watch(prayerGuideLocalDataSourceProvider).getSummaries();
});

final prayerGuideStepsProvider = Provider<List<PrayerGuideStep>>((ref) {
  return ref.watch(prayerGuideLocalDataSourceProvider).getPrayerSteps();
});

final postPrayerDhikrProvider = Provider<List<PostPrayerDhikr>>((ref) {
  return ref.watch(prayerGuideLocalDataSourceProvider).getPostPrayerDhikr();
});
