import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:solatify/core/database/hive_constants.dart';
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

  Future<void> updateHabitProgress(String habitKey, int progress) async {
    final currentLog = state.value;
    if (currentLog == null) return;

    final updatedLog = currentLog.copyWithHabitProgress(habitKey, progress);
    state = AsyncValue.data(updatedLog);

    try {
      await _repository.updateHabitProgress(
        currentLog.date,
        habitKey,
        updatedLog.getHabitProgress(habitKey),
      );
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

class CustomHabitNotifier extends StateNotifier<List<String>> {
  CustomHabitNotifier(super.initialHabits, {this.persistChanges = false});

  static const storageKey = 'tracker_custom_habits';

  final bool persistChanges;

  void addHabit(String habitName) {
    final normalized = habitName.trim();
    if (normalized.isEmpty || state.contains(normalized)) return;

    state = [...state, normalized];
    if (persistChanges) unawaited(_persist());
  }

  void renameHabit(String oldName, String newName) {
    final normalized = newName.trim();
    if (normalized.isEmpty || !state.contains(oldName)) return;
    if (normalized != oldName && state.contains(normalized)) return;

    state = [for (final habit in state) habit == oldName ? normalized : habit];
    if (persistChanges) unawaited(_persist());
  }

  void deleteHabit(String habitName) {
    if (!state.contains(habitName)) return;

    state = state.where((habit) => habit != habitName).toList(growable: false);
    if (persistChanges) unawaited(_persist());
  }

  Future<void> _persist() async {
    final box = await Hive.openBox<dynamic>(HiveConstants.settingsBox);
    await box.put(storageKey, state);
  }
}

final customHabitProvider =
    StateNotifierProvider<CustomHabitNotifier, List<String>>((ref) {
      final box = Hive.isBoxOpen(HiveConstants.settingsBox)
          ? Hive.box<dynamic>(HiveConstants.settingsBox)
          : null;
      final stored = box?.get(CustomHabitNotifier.storageKey);
      final habits = stored is List
          ? stored.whereType<String>().toList(growable: false)
          : const <String>[];
      return CustomHabitNotifier(habits, persistChanges: true);
    });

class CustomHabitTarget {
  const CustomHabitTarget({required this.target, required this.unit});

  factory CustomHabitTarget.fromJson(Map<dynamic, dynamic> json) {
    final rawTarget = json['target'];
    final rawUnit = json['unit'];
    final target = rawTarget is int
        ? rawTarget
        : int.tryParse('$rawTarget') ?? 0;
    final unit = rawUnit is String && rawUnit.trim().isNotEmpty
        ? rawUnit.trim()
        : 'kali';

    return CustomHabitTarget(target: target, unit: unit);
  }

  final int target;
  final String unit;

  Map<String, dynamic> toJson() => {'target': target, 'unit': unit};
}

class CustomHabitTargetNotifier
    extends StateNotifier<Map<String, CustomHabitTarget>> {
  CustomHabitTargetNotifier(
    super.initialTargets, {
    this.persistChanges = false,
  });

  static const storageKey = 'tracker_custom_habit_targets';

  final bool persistChanges;

  void setTarget(
    String habitName, {
    required int target,
    required String unit,
  }) {
    final normalizedName = habitName.trim();
    final normalizedUnit = unit.trim().isEmpty ? 'kali' : unit.trim();
    if (normalizedName.isEmpty || target <= 0) return;

    state = {
      ...state,
      normalizedName: CustomHabitTarget(target: target, unit: normalizedUnit),
    };
    if (persistChanges) unawaited(_persist());
  }

  void renameHabit(String oldName, String newName) {
    final target = state[oldName];
    final normalized = newName.trim();
    if (target == null || normalized.isEmpty) return;
    if (normalized != oldName && state.containsKey(normalized)) return;

    final updatedTargets = Map<String, CustomHabitTarget>.from(state)
      ..remove(oldName)
      ..[normalized] = target;
    state = updatedTargets;
    if (persistChanges) unawaited(_persist());
  }

  void deleteHabit(String habitName) {
    if (!state.containsKey(habitName)) return;

    final updatedTargets = Map<String, CustomHabitTarget>.from(state)
      ..remove(habitName);
    state = updatedTargets;
    if (persistChanges) unawaited(_persist());
  }

  Future<void> _persist() async {
    final box = await Hive.openBox<dynamic>(HiveConstants.settingsBox);
    final payload = state.map((key, value) => MapEntry(key, value.toJson()));
    await box.put(storageKey, payload);
  }
}

final customHabitTargetProvider =
    StateNotifierProvider<
      CustomHabitTargetNotifier,
      Map<String, CustomHabitTarget>
    >((ref) {
      final box = Hive.isBoxOpen(HiveConstants.settingsBox)
          ? Hive.box<dynamic>(HiveConstants.settingsBox)
          : null;
      final stored = box?.get(CustomHabitTargetNotifier.storageKey);
      final targets = <String, CustomHabitTarget>{};
      if (stored is Map) {
        for (final entry in stored.entries) {
          final key = entry.key;
          final value = entry.value;
          if (key is String && value is Map) {
            final target = CustomHabitTarget.fromJson(value);
            if (target.target > 0) targets[key] = target;
          }
        }
      }
      return CustomHabitTargetNotifier(targets, persistChanges: true);
    });
