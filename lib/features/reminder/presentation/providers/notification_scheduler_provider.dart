import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';

final notificationSchedulerProvider = FutureProvider<void>((ref) async {
  final settings = ref.watch(settingsProvider);
  final prayerTimesState = ref.watch(prayerTimesProvider);

  final todayTimes = prayerTimesState.todayTimes;
  final tomorrowTimes = prayerTimesState.tomorrowTimes;

  if (todayTimes.isEmpty || tomorrowTimes.isEmpty) return;

  try {
    final allTimes = {...todayTimes, ...tomorrowTimes};

    await NotificationService.schedulePrayerNotifications(
      prayerTimes: allTimes,
      adhanSound: settings.adhanSound,
      notificationEnabled: settings.notificationEnabled,
      azanSoundEnabled: settings.azanSoundEnabled,
    );
  } catch (error) {
    debugPrint('Error scheduling notifications: $error');
  }
});
