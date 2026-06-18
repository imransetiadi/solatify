import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/tracker/data/models/prayer_log_dto.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/repositories/tracker_repository.dart';
import 'package:solatify/features/tracker/domain/usecases/get_weekly_stats.dart';
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';

class MockTrackerRepository implements TrackerRepository {
  List<PrayerLogEntity> mockLogs = [];
  DateTime? requestedDate;

  @override
  Future<PrayerLogEntity> getLogByDate(DateTime date) async {
    requestedDate = date;
    return mockLogs.first;
  }

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

  @override
  Future<void> updateHabitStatus(
    DateTime date,
    String habitKey,
    bool isDone,
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

    test(
      'should build 14-day heatmap progress from prayers and habits',
      () async {
        final today = DateTime(2026, 6, 18);
        repository.mockLogs = [
          PrayerLogEntity(
            date: today,
            prayers: {
              'subuh': true,
              'dzuhur': true,
              'ashar': true,
              'magrib': true,
              'isya': true,
            },
            habits: {
              'tahajud': true,
              'dhuha': true,
              'shalawat': true,
              'sedekah': true,
              'puasa_sunnah': true,
              'murojaah': true,
            },
          ),
          PrayerLogEntity(
            date: today.subtract(const Duration(days: 1)),
            prayers: {'subuh': true},
            habits: {'dhuha': true},
          ),
        ];

        final stats = await useCase.execute(today);

        expect(stats.heatmap.length, 14);
        expect(stats.heatmap.first.progress, 1.0);
        expect(stats.heatmap[1].progress, closeTo(2 / 11, 0.001));
        expect(
          stats.heatmap.last.date,
          today.subtract(const Duration(days: 13)),
        );
      },
    );
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

    test('custom habits default to empty and can be toggled', () {
      final log = PrayerLogEntity(date: DateTime.now(), prayers: const {});

      final updated = log.copyWithHabit('dhuha', true);

      expect(log.habits, isEmpty);
      expect(updated.isHabitDone('dhuha'), isTrue);
      expect(
        updated.copyWithHabit('dhuha', false).isHabitDone('dhuha'),
        isFalse,
      );
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

    test('DTO reads missing habits as empty and persists habit statuses', () {
      final log = PrayerLogDto.fromJson({
        'date': DateTime(2026, 6, 18).toIso8601String(),
        'prayers': {'subuh': true},
      });

      final updated = PrayerLogDto.fromEntity(
        log.copyWithHabit('tahajud', true),
      );
      final json = updated.toJson();

      expect(log.habits, isEmpty);
      expect(json['habits']['tahajud'], isTrue);
    });
  });

  group('TrackerNotifier selected date', () {
    test('loads tracker log for selected history date', () async {
      final repository = MockTrackerRepository()
        ..mockLogs = [
          PrayerLogEntity(
            date: DateTime(2026, 6, 17),
            prayers: {'subuh': true},
          ),
        ];
      final notifier = TrackerNotifier(repository);
      final selectedDate = DateTime(2026, 6, 17);

      await notifier.loadLogForDate(selectedDate);

      expect(repository.requestedDate, selectedDate);
      expect(notifier.state, isA<AsyncData<PrayerLogEntity>>());
      expect(notifier.state.value?.date, selectedDate);
    });
  });

  group('Custom habit list', () {
    test('adds trimmed custom habit names once', () async {
      final notifier = CustomHabitNotifier(const []);

      notifier.addHabit(' Baca Al-Kahfi ');
      notifier.addHabit('Baca Al-Kahfi');

      expect(notifier.state, ['Baca Al-Kahfi']);
    });
  });
}
