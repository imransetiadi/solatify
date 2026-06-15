import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/prayer_schedule/data/datasources/prayer_times_local_data_source.dart';
import 'package:solatify/features/prayer_schedule/data/repositories/prayer_times_repository_impl.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_item_entity.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_times_state_entity.dart';
import 'package:solatify/features/prayer_schedule/domain/repositories/prayer_times_repository.dart';
import 'package:solatify/features/prayer_schedule/domain/usecases/calculate_prayer_times.dart';

import '../../settings/presentation/providers/settings_provider.dart';
import 'location_provider.dart';

// Data Source
final prayerTimesLocalDataSourceProvider = Provider<PrayerTimesLocalDataSource>((ref) {
  return const PrayerTimesLocalDataSourceImpl();
});

// Repository
final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  final localDataSource = ref.watch(prayerTimesLocalDataSourceProvider);
  return PrayerTimesRepositoryImpl(localDataSource: localDataSource);
});

// UseCase
final calculatePrayerTimesUseCaseProvider = Provider<CalculatePrayerTimes>((ref) {
  final repository = ref.watch(prayerTimesRepositoryProvider);
  return CalculatePrayerTimes(repository);
});

class PrayerTimesNotifier extends StateNotifier<PrayerTimesStateEntity> {
  PrayerTimesNotifier(this._ref, this._calculatePrayerTimes)
      : super(const PrayerTimesStateEntity(todayTimes: {}, tomorrowTimes: {})) {
    _init();
  }

  final Ref _ref;
  final CalculatePrayerTimes _calculatePrayerTimes;
  Timer? _dateRefreshTimer;

  Future<void> _init() async {
    await _recalculate();

    // Safety check if the provider is still mounted before listening
    if (!mounted) return;

    // Listen to changes in location and settings to recalculate
    _ref.listen(locationProvider, (previous, next) {
      if (mounted) _recalculate();
    });
    _ref.listen(settingsProvider, (previous, next) {
      if (mounted && (previous?.calculationMethod != next.calculationMethod ||
          previous?.prayerOffsets != next.prayerOffsets)) {
        _recalculate();
      }
    });
  }

  Future<void> _recalculate() async {
    try {
      final location = _ref.read(locationProvider);
      final settings = _ref.read(settingsProvider);

      final newState = await _calculatePrayerTimes.execute(
        latitude: location.latitude,
        longitude: location.longitude,
        country: location.country,
        method: settings.calculationMethod,
        offsets: settings.prayerOffsets,
      );

      state = newState;
      _scheduleDateRefresh();
    } catch (e) {
      // Keep previous state if recalculation fails
    }
  }

  void _scheduleDateRefresh() {
    _dateRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextRefresh = DateTime(now.year, now.month, now.day + 1, 0, 1);
    _dateRefreshTimer = Timer(nextRefresh.difference(now), _recalculate);
  }

  @override
  void dispose() {
    _dateRefreshTimer?.cancel();
    super.dispose();
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesStateEntity>((ref) {
  final calculateUseCase = ref.watch(calculatePrayerTimesUseCaseProvider);
  return PrayerTimesNotifier(ref, calculateUseCase);
});

final prayerListProvider = Provider<List<PrayerItemEntity>>((ref) {
  final timesState = ref.watch(prayerTimesProvider);
  final times = timesState.todayTimes;

  if (times.isEmpty) return [];

  const config = [
    ['Subuh', 'subuh'],
    ['Dzuhur', 'dzuhur'],
    ['Ashar', 'ashar'],
    ['Magrib', 'magrib'],
    ['Isya', 'isya'],
  ];

  final hasAll = config.every((c) => times[c[1]] != null);
  if (!hasAll) return [];

  return [
    for (final c in config)
      PrayerItemEntity(name: c[0], time: times[c[1]]!, key: c[1]),
  ];
});
