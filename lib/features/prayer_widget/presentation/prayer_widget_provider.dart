import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/features/home/presentation/providers/countdown_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_widget/domain/android_prayer_widget_service.dart';
import 'package:solatify/features/prayer_widget/domain/ios_prayer_widget_service.dart';

final androidPrayerWidgetServiceProvider = Provider<AndroidPrayerWidgetService>(
  (ref) => AndroidPrayerWidgetService(),
);

final iosPrayerWidgetServiceProvider = Provider<IosPrayerWidgetService>(
  (ref) => IosPrayerWidgetService(),
);

final prayerWidgetPayloadProvider = Provider<PrayerWidgetPayload>((ref) {
  final countdown = ref.watch(countdownProvider);
  final timesState = ref.watch(prayerTimesProvider);
  final location = ref.watch(locationProvider);
  final nextTime =
      timesState.todayTimes[countdown.nextPrayerKey] ??
      timesState.tomorrowTimes[countdown.nextPrayerKey];
  final timeLabel = nextTime == null
      ? '--:--'
      : DateFormat.Hm().format(nextTime);
  final locationLabel = location.city.trim().isEmpty
      ? location.country
      : '${location.city}, ${location.country}';

  return PrayerWidgetPayload(
    nextPrayerName: countdown.nextPrayerName,
    nextPrayerTimeLabel: timeLabel,
    countdownLabel: countdown.formattedTime,
    locationLabel: locationLabel,
    hijriLabel: 'Jadwal salat hari ini',
  );
});
