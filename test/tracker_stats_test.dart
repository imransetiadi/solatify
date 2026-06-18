import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/tracker/data/models/prayer_log_dto.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/repositories/tracker_repository.dart';
import 'package:solatify/features/tracker/domain/usecases/get_weekly_stats.dart';

class MockTrackerRepository implements TrackerRepository {
  List<PrayerLogEntity> mockLogs = [];

  @override
  Future<PrayerLogEntity> getLogByDate(DateTime date) async => mockLogs.first;

  @override
  Future<List<PrayerLogEntity>> getWeeklyLogs(DateTime endDate) async =>
      mockLogs;

  @override
  Future<void> updatePrayerStatus(
    DateTime date,
    String prayerKey,
    bool isDone,
  ) async {}

  @override
  Future<void> updatePrayerStatusDetail(
    DateTime date,
    String prayerKey,
    PrayerStatus status,
  ) async {}
}

void main() {
  group('GetWeeklyStats UseCase Tests', () {
    late MockTrackerRepository repository;
    late GetWeeklyStats useCase;

    setUp(() {
      repository = MockTrackerRepository();
      useCase = GetWeeklyStats(repository);
    });

    test('should calculate correct weekly statistics', () async {
      repository.mockLogs = [
        PrayerLogEntity(
          date: DateTime.now(),
          prayers: {'subuh': true, 'dzuhur': true},
        ),
        PrayerLogEntity(
          date: DateTime.now(),
          prayers: {'subuh': true, 'dzuhur': false},
        ),
      ];

      final stats = await useCase.execute(DateTime.now());

      expect(stats.completionRates['subuh'], 100.0);
      expect(stats.completionRates['dzuhur'], 50.0);
      expect(stats.totalDone, 3);
      expect(stats.statusCounts[PrayerStatus.onTime], 3);
      expect(stats.statusCounts[PrayerStatus.late], 0);
    });

    test('should calculate weekly status counts', () async {
      repository.mockLogs = [
        PrayerLogEntity(
          date: DateTime.now(),
          prayers: {'subuh': true, 'dzuhur': true, 'ashar': true},
          prayerStatuses: {
            'subuh': PrayerStatus.onTime,
            'dzuhur': PrayerStatus.late,
            'ashar': PrayerStatus.qadha,
          },
        ),
      ];

      final stats = await useCase.execute(DateTime.now());

      expect(stats.statusCounts[PrayerStatus.onTime], 1);
      expect(stats.statusCounts[PrayerStatus.late], 1);
      expect(stats.statusCounts[PrayerStatus.qadha], 1);
    });
  });

  group('PrayerLogEntity status migration', () {
    test('checked boolean prayers default to on time status', () {
      final log = PrayerLogEntity(
        date: DateTime.now(),
        prayers: {'subuh': true, 'dzuhur': false},
      );

      expect(log.isPrayerDone('subuh'), isTrue);
      expect(log.getPrayerStatus('subuh'), PrayerStatus.onTime);
      expect(log.getPrayerStatus('dzuhur'), isNull);
    });

    test('DTO reads legacy boolean and persists status details', () {
      final log = PrayerLogDto.fromJson({
        'date': DateTime(2026, 6, 18).toIso8601String(),
        'prayers': {'subuh': true, 'dzuhur': false},
      });

      final updated = log.copyWithStatus('subuh', PrayerStatus.late);
      final json = PrayerLogDto.fromEntity(updated).toJson();

      expect(log.getPrayerStatus('subuh'), PrayerStatus.onTime);
      expect(json['prayerStatuses']['subuh'], 'late');
    });
  });
}
