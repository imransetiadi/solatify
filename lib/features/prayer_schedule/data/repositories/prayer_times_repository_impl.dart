import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/prayer_times_local_data_source.dart';

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  const PrayerTimesRepositoryImpl({required this.localDataSource});

  final PrayerTimesLocalDataSource localDataSource;

  @override
  Future<void> cacheSchedule(String dateKey, Map<String, DateTime> times) async {
    final Map<String, String> cacheData = {};
    times.forEach((key, value) {
      cacheData[key] = value.toIso8601String();
    });
    await localDataSource.cacheSchedule(dateKey, cacheData);
  }

  @override
  Future<Map<String, DateTime>?> getCachedSchedule(String dateKey) async {
    final data = await localDataSource.getCachedSchedule(dateKey);
    if (data == null) return null;
    
    final Map<String, DateTime> times = {};
    data.forEach((key, value) {
      if (value is String) {
        times[key] = DateTime.parse(value);
      }
    });
    return times;
  }
}
