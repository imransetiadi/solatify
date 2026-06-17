import 'package:solatify/core/database/hive_service.dart';

abstract class PrayerTimesLocalDataSource {
  Future<void> cacheSchedule(String dateKey, Map<String, String> cacheData);
  Future<Map<String, dynamic>?> getCachedSchedule(String dateKey);
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  const PrayerTimesLocalDataSourceImpl();

  @override
  Future<void> cacheSchedule(
    String dateKey,
    Map<String, String> cacheData,
  ) async {
    await HiveService.cachePrayerSchedules(dateKey, cacheData);
  }

  @override
  Future<Map<String, dynamic>?> getCachedSchedule(String dateKey) async {
    return HiveService.getCachedPrayerSchedule(dateKey);
  }
}
