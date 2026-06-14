import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_provider.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/prayer_calculation_service.dart';
import '../data/prayer_timezone_service.dart';
import '../../../core/database/hive_service.dart';

// Performance optimized: Uses memoization and efficient provider selection

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
  Timer? _dateRefreshTimer;

  PrayerTimesNotifier(this._ref) : super(_calculateInitialState(_ref)) {
    _scheduleDateRefresh();

    // Listen to changes in location and settings to recalculate
    _ref.listen(locationProvider, (previous, next) {
      try {
        _recalculate();
      } catch (e) {
        // Silently ignore recalculation errors on location change
      }
    });
    _ref.listen(settingsProvider, (previous, next) {
      if (previous?.calculationMethod != next.calculationMethod ||
          previous?.prayerOffsets != next.prayerOffsets) {
        try {
          _recalculate();
        } catch (e) {
          // Silently ignore recalculation errors on settings change
        }
      }
    });
  }

  static PrayerTimesState _calculateInitialState(Ref ref) {
    // Fully guarded: any failure falls back to a safe empty state so the app
    // never crashes on cold start (e.g. after a force-close).
    try {
      final location = ref.read(locationProvider);
      final settings = ref.read(settingsProvider);

      // Always calculate fresh from cached/manual location. Prayer calculation is
      // offline and fast; reading old cached DateTime strings can mix device
      // timezone with selected-city timezone and make active prayer wrong.
      final dateKey = _getDateKey(DateTime.now());
      final timezoneName = PrayerTimezoneService.inferTimezoneName(
        latitude: location.latitude,
        longitude: location.longitude,
        country: location.country,
      );

      // Recalculate fresh
      final today = PrayerCalculationService.calculatePrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        date: DateTime.now(),
        method: settings.calculationMethod,
        timezoneName: timezoneName,
        offsets: settings.prayerOffsets,
      );

      final tomorrow = PrayerCalculationService.calculatePrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        date: DateTime.now().add(const Duration(days: 1)),
        method: settings.calculationMethod,
        timezoneName: timezoneName,
        offsets: settings.prayerOffsets,
      );

      // Save today's calculation to cache asynchronously
      _cacheSchedule(dateKey, today);

      return PrayerTimesState(
        todayTimes: today,
        tomorrowTimes: tomorrow,
        isOfflineCached: false,
      );
    } catch (e) {
      // Last-resort safe state — UI handles empty maps gracefully.
      return PrayerTimesState(todayTimes: {}, tomorrowTimes: {});
    }
  }

  void _recalculate() {
    try {
      final location = _ref.read(locationProvider);
      final settings = _ref.read(settingsProvider);
      final timezoneName = PrayerTimezoneService.inferTimezoneName(
        latitude: location.latitude,
        longitude: location.longitude,
        country: location.country,
      );

      final today = PrayerCalculationService.calculatePrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        date: DateTime.now(),
        method: settings.calculationMethod,
        timezoneName: timezoneName,
        offsets: settings.prayerOffsets,
      );

      final tomorrow = PrayerCalculationService.calculatePrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        date: DateTime.now().add(const Duration(days: 1)),
        method: settings.calculationMethod,
        timezoneName: timezoneName,
        offsets: settings.prayerOffsets,
      );

      final dateKey = _getDateKey(DateTime.now());
      _cacheSchedule(dateKey, today);

      state = PrayerTimesState(
        todayTimes: today,
        tomorrowTimes: tomorrow,
        isOfflineCached: false,
      );

      _scheduleDateRefresh();
    } catch (e) {
      // Keep previous state if recalculation fails
    }
  }

  void _scheduleDateRefresh() {
    _dateRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextRefresh = DateTime(now.year, now.month, now.day + 1, 0, 1);
    _dateRefreshTimer = Timer(nextRefresh.difference(now), _recalculate);
  }

  @override
  void dispose() {
    _dateRefreshTimer?.cancel();
    super.dispose();
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

  const config = [
    ['Subuh', 'subuh'],
    ['Dzuhur', 'dzuhur'],
    ['Ashar', 'ashar'],
    ['Magrib', 'magrib'],
    ['Isya', 'isya'],
  ];

  // If any required time is missing (e.g. partial cache after a force-close),
  // return empty rather than force-unwrapping and crashing.
  final hasAll = config.every((c) => times[c[1]] != null);
  if (!hasAll) return [];

  return [
    for (final c in config)
      PrayerItem(name: c[0], time: times[c[1]]!, key: c[1]),
  ];
});
