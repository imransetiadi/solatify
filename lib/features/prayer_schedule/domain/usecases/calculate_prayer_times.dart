import 'package:flutter/foundation.dart';

import '../../data/prayer_calculation_service.dart';
import '../../data/prayer_timezone_service.dart';
import '../entities/prayer_times_state_entity.dart';
import '../repositories/prayer_times_repository.dart';

class CalculatePrayerTimes {
  const CalculatePrayerTimes(this.repository);

  final PrayerTimesRepository repository;

  Future<PrayerTimesStateEntity> execute({
    required double latitude,
    required double longitude,
    required String country,
    required String method,
    required Map<String, int> offsets,
  }) async {
    try {
      final now = DateTime.now();
      final dateKey = _getDateKey(now);
      final timezoneName = PrayerTimezoneService.inferTimezoneName(
        latitude: latitude,
        longitude: longitude,
        country: country,
      );

      final today = PrayerCalculationService.calculatePrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: now,
        method: method,
        timezoneName: timezoneName,
        offsets: offsets,
      );

      final tomorrow = PrayerCalculationService.calculatePrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: PrayerCalculationService.cityNoon(timezoneName, now, 1),
        method: method,
        timezoneName: timezoneName,
        offsets: offsets,
      );

      // Caching is best-effort: a failed write (box closed, disk full) must
      // not throw away a schedule that was calculated successfully.
      try {
        await repository.cacheSchedule(dateKey, today);
      } catch (e) {
        debugPrint('Prayer schedule cache write failed: $e');
      }

      return PrayerTimesStateEntity(
        todayTimes: today,
        tomorrowTimes: tomorrow,
        isOfflineCached: false,
      );
    } catch (e) {
      // Last-resort safe state — UI handles empty maps gracefully.
      return const PrayerTimesStateEntity(todayTimes: {}, tomorrowTimes: {});
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
