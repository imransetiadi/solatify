import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/tracker_local_data_source.dart';
import '../../data/repositories/tracker_repository_impl.dart';
import '../../domain/entities/prayer_log_entity.dart';
import '../../domain/repositories/tracker_repository.dart';

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
    state = const AsyncValue.loading();
    try {
      final log = await _repository.getLogByDate(DateTime.now());
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
    updatedPrayers[prayerKey] = newStatus;
    state = AsyncValue.data(currentLog.copyWith(prayers: updatedPrayers));

    try {
      await _repository.updatePrayerStatus(currentLog.date, prayerKey, newStatus);
    } catch (e, st) {
      // Rollback on error
      state = AsyncValue.data(currentLog);
      state = AsyncValue.error(e, st);
    }
  }
}

final trackerProvider = StateNotifierProvider<TrackerNotifier, AsyncValue<PrayerLogEntity>>((ref) {
  final repository = ref.watch(trackerRepositoryProvider);
  return TrackerNotifier(repository);
});
