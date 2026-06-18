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
  Future<void> updatePrayerStatus(
    DateTime date,
    String prayerKey,
    bool isDone,
  ) async {
    final log = await getLogByDate(date);
    final updatedPrayers = Map<String, bool>.from(log.prayers);
    final updatedStatuses = Map<String, PrayerStatus>.from(log.prayerStatuses);
    updatedPrayers[prayerKey] = isDone;
    if (isDone) {
      updatedStatuses[prayerKey] =
          log.getPrayerStatus(prayerKey) ?? PrayerStatus.onTime;
    } else {
      updatedStatuses.remove(prayerKey);
    }

    await localDataSource.saveLog(
      PrayerLogDto(
        date: date,
        prayers: updatedPrayers,
        prayerStatuses: updatedStatuses,
      ),
    );
  }

  @override
  Future<void> updatePrayerStatusDetail(
    DateTime date,
    String prayerKey,
    PrayerStatus status,
  ) async {
    final log = await getLogByDate(date);
    await localDataSource.saveLog(
      PrayerLogDto.fromEntity(log.copyWithStatus(prayerKey, status)),
    );
  }

  @override
  Future<void> updateHabitStatus(
    DateTime date,
    String habitKey,
    bool isDone,
  ) async {
    final log = await getLogByDate(date);
    await localDataSource.saveLog(
      PrayerLogDto.fromEntity(log.copyWithHabit(habitKey, isDone)),
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
