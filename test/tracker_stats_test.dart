import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/repositories/tracker_repository.dart';
import 'package:solatify/features/tracker/domain/usecases/get_weekly_stats.dart';

class MockTrackerRepository implements TrackerRepository {
  List<PrayerLogEntity> mockLogs = [];
  
  @override
  Future<PrayerLogEntity> getLogByDate(DateTime date) async => mockLogs.first;
  
  @override
  Future<List<PrayerLogEntity>> getWeeklyLogs(DateTime endDate) async => mockLogs;
  
  @override
  Future<void> updatePrayerStatus(DateTime date, String prayerKey, bool isDone) async {}
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
        PrayerLogEntity(date: DateTime.now(), prayers: {'subuh': true, 'dzuhur': true}),
        PrayerLogEntity(date: DateTime.now(), prayers: {'subuh': true, 'dzuhur': false}),
      ];

      final stats = await useCase.execute(DateTime.now());

      expect(stats.completionRates['subuh'], 100.0);
      expect(stats.completionRates['dzuhur'], 50.0);
      expect(stats.totalDone, 3);
    });
  });
}
