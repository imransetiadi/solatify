import '../../domain/entities/prayer_log_entity.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../datasources/tracker_local_data_source.dart';
import '../models/prayer_log_dto.dart';

class TrackerRepositoryImpl implements TrackerRepository {
  const TrackerRepositoryImpl({required this.localDataSource});

  final TrackerLocalDataSource localDataSource;

  @override
  Future<PrayerLogEntity> getLogByDate(DateTime date) async {
    final dateKey = _getDateKey(date);
    final dto = await localDataSource.getLog(dateKey);
    
    if (dto == null) {
      return PrayerLogEntity(
        date: date,
        prayers: {
          'subuh': false,
          'dzuhur': false,
          'ashar': false,
          'magrib': false,
          'isya': false,
        },
      );
    }
    return dto;
  }

  @override
  Future<void> updatePrayerStatus(DateTime date, String prayerKey, bool isDone) async {
    final log = await getLogByDate(date);
    final updatedPrayers = Map<String, bool>.from(log.prayers);
    updatedPrayers[prayerKey] = isDone;
    
    await localDataSource.saveLog(
      PrayerLogDto(date: date, prayers: updatedPrayers),
    );
  }

  @override
  Future<List<PrayerLogEntity>> getWeeklyLogs(DateTime endDate) async {
    final dateKeys = <String>[];
    for (int i = 0; i < 7; i++) {
      final date = endDate.subtract(Duration(days: i));
      dateKeys.add(_getDateKey(date));
    }
    
    final dtos = await localDataSource.getLogsRange(dateKeys);
    return dtos;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
