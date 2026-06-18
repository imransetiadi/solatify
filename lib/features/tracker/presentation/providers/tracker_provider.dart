import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/tracker_local_data_source.dart';
import '../../data/repositories/tracker_repository_impl.dart';
import '../../domain/entities/prayer_log_entity.dart';
import '../../domain/entities/weekly_stats_entity.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../../domain/usecases/get_weekly_stats.dart';

final trackerLocalDataSourceProvider = Provider<TrackerLocalDataSource>((ref) {
  return const TrackerLocalDataSourceImpl();
});

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  final localDataSource = ref.watch(trackerLocalDataSourceProvider);
  return TrackerRepositoryImpl(localDataSource: localDataSource);
});

class TrackerNotifier extends StateNotifier<AsyncValue<PrayerLogEntity>> {
  TrackerNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTodayLog();
  }

  final TrackerRepository _repository;

  Future<void> loadTodayLog() async {
    await loadLogForDate(DateTime.now());
  }

  Future<void> loadLogForDate(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final log = await _repository.getLogByDate(date);
      state = AsyncValue.data(log);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePrayer(String prayerKey) async {
    final currentLog = state.value;
    if (currentLog == null) return;

    final newStatus = !currentLog.isPrayerDone(prayerKey);

    // Optimistic UI update
    final updatedPrayers = Map<String, bool>.from(currentLog.prayers);
    final updatedStatuses = Map<String, PrayerStatus>.from(
      currentLog.prayerStatuses,
    );
    updatedPrayers[prayerKey] = newStatus;
    if (newStatus) {
      updatedStatuses[prayerKey] = PrayerStatus.onTime;
    } else {
      updatedStatuses.remove(prayerKey);
    }
    state = AsyncValue.data(
      currentLog.copyWith(
        prayers: updatedPrayers,
        prayerStatuses: updatedStatuses,
      ),
    );

    try {
      await _repository.updatePrayerStatus(
        currentLog.date,
        prayerKey,
        newStatus,
      );
    } catch (e, st) {
      // Rollback on error
      state = AsyncValue.data(currentLog);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePrayerStatusDetail(
    String prayerKey,
    PrayerStatus status,
  ) async {
    final currentLog = state.value;
    if (currentLog == null) return;

    final updatedLog = currentLog.copyWithStatus(prayerKey, status);
    state = AsyncValue.data(updatedLog);

    try {
      await _repository.updatePrayerStatusDetail(
        currentLog.date,
        prayerKey,
        status,
      );
    } catch (e, st) {
      state = AsyncValue.data(currentLog);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleHabit(String habitKey) async {
    final currentLog = state.value;
    if (currentLog == null) return;

    final isDone = !currentLog.isHabitDone(habitKey);
    final updatedLog = currentLog.copyWithHabit(habitKey, isDone);
    state = AsyncValue.data(updatedLog);

    try {
      await _repository.updateHabitStatus(currentLog.date, habitKey, isDone);
    } catch (e, st) {
      state = AsyncValue.data(currentLog);
      state = AsyncValue.error(e, st);
    }
  }
}

final trackerProvider =
    StateNotifierProvider<TrackerNotifier, AsyncValue<PrayerLogEntity>>((ref) {
      final repository = ref.watch(trackerRepositoryProvider);
      return TrackerNotifier(repository);
    });

final trackerSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final trackerWeeklyStatsProvider = FutureProvider<WeeklyStatsEntity>((ref) {
  final repository = ref.watch(trackerRepositoryProvider);
  return GetWeeklyStats(repository).execute(DateTime.now());
});
