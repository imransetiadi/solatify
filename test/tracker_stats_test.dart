import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/tracker/data/models/prayer_log_dto.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/entities/weekly_stats_entity.dart';
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

  @override
  Future<void> updateHabitProgress(
    DateTime date,
    String habitKey,
    int progress,
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

    test('should calculate streak and actionable smart insights', () async {
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
          habits: {'dhuha': true, 'shalawat': true},
        ),
        PrayerLogEntity(
          date: today.subtract(const Duration(days: 1)),
          prayers: {
            'subuh': true,
            'dzuhur': true,
            'ashar': true,
            'magrib': true,
            'isya': true,
          },
          habits: {'dhuha': true},
        ),
        PrayerLogEntity(
          date: today.subtract(const Duration(days: 2)),
          prayers: {'subuh': true, 'dzuhur': true, 'magrib': true},
          habits: {'dhuha': true},
        ),
        PrayerLogEntity(
          date: today.subtract(const Duration(days: 3)),
          prayers: {'subuh': true},
        ),
      ];

      final stats = await useCase.execute(today);

      expect(stats.currentStreakDays, 3);
      expect(stats.bestDayLabel, 'Hari ini');
      expect(stats.strongestItemLabel, 'Subuh');
      expect(stats.weakestItemLabel, 'Isya');
      expect(stats.smartInsightMessage, contains('streak 3 hari'));
      expect(stats.smartInsightAction, contains('Isya'));
    });

    test(
      'should show motivational empty insight when no tracker data exists',
      () async {
        repository.mockLogs = const [];

        final stats = await useCase.execute(DateTime(2026, 6, 18));

        expect(stats.currentStreakDays, 0);
        expect(stats.bestDayLabel, 'Belum ada data');
        expect(stats.strongestItemLabel, 'Mulai hari ini');
        expect(stats.weakestItemLabel, 'Pilih satu ibadah');
        expect(
          stats.smartInsightMessage,
          contains('Mulai dari satu checklist'),
        );
      },
    );

    test('should build a shareable weekly progress summary', () async {
      const stats = WeeklyStatsEntity(
        completionRates: {},
        totalDone: 18,
        currentStreakDays: 4,
        bestDayLabel: 'Hari ini',
        strongestItemLabel: 'Subuh',
        weakestItemLabel: 'Isya',
        smartInsightMessage: 'MasyaAllah, kamu sedang menjaga streak 4 hari.',
        smartInsightAction: 'Fokus kecil berikutnya: kuatkan Isya.',
      );

      final summary = stats.shareSummaryText;

      expect(summary, contains('Progress Ibadah Mingguan'));
      expect(summary, contains('Total salat: 18'));
      expect(summary, contains('Streak: 4 hari'));
      expect(summary, contains('Hari terbaik: Hari ini'));
      expect(summary, contains('Terkuat: Subuh'));
      expect(summary, contains('Perlu fokus: Isya'));
      expect(summary, contains('Dibuat dengan Solatify'));
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

    test('habit progress defaults to zero and can be incremented', () {
      final log = PrayerLogEntity(date: DateTime.now(), prayers: const {});

      final updated = log.copyWithHabitProgress('custom:100 Shalawat', 25);

      expect(log.getHabitProgress('custom:100 Shalawat'), 0);
      expect(updated.getHabitProgress('custom:100 Shalawat'), 25);
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

    test('renames custom habit when new name is valid and unique', () async {
      final notifier = CustomHabitNotifier(const ['Baca Al-Kahfi']);

      notifier.renameHabit('Baca Al-Kahfi', ' Infak Jumat ');

      expect(notifier.state, ['Infak Jumat']);
    });

    test('deletes custom habit by name', () async {
      final notifier = CustomHabitNotifier(const [
        'Baca Al-Kahfi',
        'Infak Jumat',
      ]);

      notifier.deleteHabit('Baca Al-Kahfi');

      expect(notifier.state, ['Infak Jumat']);
    });

    test('stores optional target metadata for new custom habit', () async {
      final notifier = CustomHabitTargetNotifier(const {});

      notifier.setTarget('100 Shalawat', target: 100, unit: 'kali');

      expect(notifier.state['100 Shalawat']?.target, 100);
      expect(notifier.state['100 Shalawat']?.unit, 'kali');
    });
  });
}
