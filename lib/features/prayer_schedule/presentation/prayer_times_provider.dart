import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_provider.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/prayer_calculation_service.dart';
import '../../../core/database/hive_service.dart';

import '../../reminder/data/services/notification_service.dart';

class PrayerTimesState {
  final Map<String, DateTime> todayTimes;
  final Map<String, DateTime> tomorrowTimes;
  final bool isOfflineCached;

  PrayerTimesState({
    required this.todayTimes,
    required this.tomorrowTimes,
    this.isOfflineCached = false,
  });
}

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final Ref _ref;

  PrayerTimesNotifier(this._ref) : super(_calculateInitialState(_ref)) {
    // Schedule initially
    _scheduleNotifications();

    // Listen to changes in location and settings to recalculate
    _ref.listen(locationProvider, (previous, next) {
      _recalculate();
    });
    _ref.listen(settingsProvider, (previous, next) {
      if (previous?.calculationMethod != next.calculationMethod ||
          previous?.notificationEnabled != next.notificationEnabled ||
          previous?.adhanSound != next.adhanSound ||
          previous?.prayerOffsets != next.prayerOffsets) {
        _recalculate();
      }
    });
  }

  static PrayerTimesState _calculateInitialState(Ref ref) {
    final location = ref.read(locationProvider);
    final settings = ref.read(settingsProvider);

    // Check if we have cached schedule for today
    final dateKey = _getDateKey(DateTime.now());
    final cached = HiveService.getCachedPrayerSchedule(dateKey);

    if (cached != null) {
      try {
        final Map<String, DateTime> today = {};
        cached.forEach((key, value) {
          if (value is String) {
            today[key] = DateTime.parse(value);
          }
        });

        // Calculate tomorrow's times (often not cached, so calculate)
        final tomorrow = PrayerCalculationService.calculatePrayerTimes(
          latitude: location.latitude,
          longitude: location.longitude,
          date: DateTime.now().add(const Duration(days: 1)),
          method: settings.calculationMethod,
          offsets: settings.prayerOffsets,
        );

        return PrayerTimesState(
          todayTimes: today,
          tomorrowTimes: tomorrow,
          isOfflineCached: true,
        );
      } catch (_) {
        // Fallback to recalculate if cache parsing fails
      }
    }

    // Recalculate fresh
    final today = PrayerCalculationService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: DateTime.now(),
      method: settings.calculationMethod,
      offsets: settings.prayerOffsets,
    );

    final tomorrow = PrayerCalculationService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: DateTime.now().add(const Duration(days: 1)),
      method: settings.calculationMethod,
      offsets: settings.prayerOffsets,
    );

    // Save today's calculation to cache asynchronously
    _cacheSchedule(dateKey, today);

    return PrayerTimesState(
      todayTimes: today,
      tomorrowTimes: tomorrow,
      isOfflineCached: false,
    );
  }

  void _recalculate() {
    final location = _ref.read(locationProvider);
    final settings = _ref.read(settingsProvider);

    final today = PrayerCalculationService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: DateTime.now(),
      method: settings.calculationMethod,
      offsets: settings.prayerOffsets,
    );

    final tomorrow = PrayerCalculationService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: DateTime.now().add(const Duration(days: 1)),
      method: settings.calculationMethod,
      offsets: settings.prayerOffsets,
    );

    final dateKey = _getDateKey(DateTime.now());
    _cacheSchedule(dateKey, today);

    state = PrayerTimesState(
      todayTimes: today,
      tomorrowTimes: tomorrow,
      isOfflineCached: false,
    );

    _scheduleNotifications();
  }

  void _scheduleNotifications() {
    final settings = _ref.read(settingsProvider);
    // Schedule today's notifications
    NotificationService.schedulePrayerNotifications(
      prayerTimes: state.todayTimes,
      adhanSound: settings.adhanSound,
      enabled: settings.notificationEnabled,
    );
    // Also schedule tomorrow's notifications
    NotificationService.schedulePrayerNotifications(
      prayerTimes: state.tomorrowTimes,
      adhanSound: settings.adhanSound,
      enabled: settings.notificationEnabled,
    );
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static void _cacheSchedule(String dateKey, Map<String, DateTime> times) {
    final Map<String, String> cacheData = {};
    times.forEach((key, value) {
      cacheData[key] = value.toIso8601String();
    });
    HiveService.cachePrayerSchedules(dateKey, cacheData);
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
      return PrayerTimesNotifier(ref);
    });

// Helper model to represent a single prayer entry in list views
class PrayerItem {
  final String name;
  final DateTime time;
  final String key; // subuh, dzuhur, ashar, magrib, isya

  PrayerItem({required this.name, required this.time, required this.key});
}

final prayerListProvider = Provider<List<PrayerItem>>((ref) {
  final timesState = ref.watch(prayerTimesProvider);
  final times = timesState.todayTimes;

  if (times.isEmpty) return [];

  return [
    PrayerItem(name: 'Subuh', time: times['subuh']!, key: 'subuh'),
    PrayerItem(name: 'Dzuhur', time: times['dzuhur']!, key: 'dzuhur'),
    PrayerItem(name: 'Ashar', time: times['ashar']!, key: 'ashar'),
    PrayerItem(name: 'Magrib', time: times['magrib']!, key: 'magrib'),
    PrayerItem(name: 'Isya', time: times['isya']!, key: 'isya'),
  ];
});
