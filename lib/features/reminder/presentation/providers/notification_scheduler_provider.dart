import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';
import '../../../prayer_schedule/data/prayer_timezone_service.dart';

final notificationSchedulerProvider = FutureProvider<void>((ref) async {
  final settings = ref.watch(settingsProvider);
  final location = ref.watch(locationProvider);
  final prayerTimesState = ref.watch(prayerTimesProvider);

  final todayTimes = prayerTimesState.todayTimes;
  final tomorrowTimes = prayerTimesState.tomorrowTimes;

  if (todayTimes.isEmpty || tomorrowTimes.isEmpty) return;

  try {
    final timezoneName = PrayerTimezoneService.inferTimezoneName(
      latitude: location.latitude,
      longitude: location.longitude,
      country: location.country,
    );
    final allTimes = {
      ...todayTimes,
      for (final entry in tomorrowTimes.entries)
        'besok_${entry.key}': entry.value,
    };

    await NotificationService.schedulePrayerNotifications(
      prayerTimes: allTimes,
      adhanSound: settings.adhanSound,
      notificationEnabled: settings.notificationEnabled,
      azanSoundEnabled: settings.azanSoundEnabled,
      timezoneName: timezoneName,
    );
  } catch (error) {
    debugPrint('Error scheduling notifications: $error');
  }
});
