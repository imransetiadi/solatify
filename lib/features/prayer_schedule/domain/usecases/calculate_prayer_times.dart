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
        date: now.add(const Duration(days: 1)),
        method: method,
        timezoneName: timezoneName,
        offsets: offsets,
      );

      // Save today's calculation to cache asynchronously
      await repository.cacheSchedule(dateKey, today);

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
