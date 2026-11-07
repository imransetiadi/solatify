import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/performance/performance_tuning.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';

class CountdownState {
  factory CountdownState.initial() {
    return CountdownState(
      activePrayerName: '-',
      nextPrayerName: '-',
      nextPrayerKey: '',
      remainingDuration: Duration.zero,
      formattedTime: '00:00:00',
    );
  }

  CountdownState({
    required this.activePrayerName,
    required this.nextPrayerName,
    required this.nextPrayerKey,
    required this.remainingDuration,
    required this.formattedTime,
  });

  final String activePrayerName;
  final String nextPrayerName;
  final String nextPrayerKey;
  final Duration remainingDuration;
  final String formattedTime; // HH:mm:ss
}

class CountdownNotifier extends StateNotifier<CountdownState> {
  CountdownNotifier(this._ref) : super(CountdownState.initial()) {
    _startTimer();
  }

  final Ref _ref;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _updateCountdown(); // Run immediately
    _timer = Timer.periodic(
      PerformanceTuning.countdownTickInterval,
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final timesState = _ref.read(prayerTimesProvider);
    final today = timesState.todayTimes;
    final tomorrow = timesState.tomorrowTimes;

    // Safety check: ensure all required keys exist before proceeding
    const requiredKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
    final hasAllToday = requiredKeys.every((k) => today.containsKey(k));
    final hasTomorrowSubuh = tomorrow.containsKey('subuh');

    if (!hasAllToday || !hasTomorrowSubuh) return;

    // Prayer times are absolute instants (TZDateTime compares by instant), so
    // the device clock is enough here — no timezone database work per tick.
    final now = DateTime.now();

    // The schedule is out of date (e.g. the app slept past midnight and the
    // rollover timer was delayed). Ask for a fresh one instead of showing a
    // negative countdown.
    if (!now.isBefore(tomorrow['subuh']!)) {
      _requestFreshSchedule();
      return;
    }

    // Extract prayer times (already TZDateTime)
    final subuh = today['subuh']!;
    final dzuhur = today['dzuhur']!;
    final ashar = today['ashar']!;
    final magrib = today['magrib']!;
    final isya = today['isya']!;
    final esokSubuh = tomorrow['subuh']!;

    String activeName = '';
    String nextName = '';
    String nextKey = '';
    DateTime nextTime;

    if (now.isBefore(subuh)) {
      activeName = 'Isya';
      nextName = 'Subuh';
      nextKey = 'subuh';
      nextTime = subuh;
    } else if (now.isBefore(dzuhur)) {
      activeName = 'Subuh';
      nextName = 'Dzuhur';
      nextKey = 'dzuhur';
      nextTime = dzuhur;
    } else if (now.isBefore(ashar)) {
      activeName = 'Dzuhur';
      nextName = 'Ashar';
      nextKey = 'ashar';
      nextTime = ashar;
    } else if (now.isBefore(magrib)) {
      activeName = 'Ashar';
      nextName = 'Magrib';
      nextKey = 'magrib';
      nextTime = magrib;
    } else if (now.isBefore(isya)) {
      activeName = 'Magrib';
      nextName = 'Isya';
      nextKey = 'isya';
      nextTime = isya;
    } else {
      activeName = 'Isya';
      nextName = 'Subuh';
      nextKey = 'subuh';
      nextTime = esokSubuh; // Tomorrow Fajr
    }

    final rawDiff = nextTime.difference(now);
    final diff = rawDiff.isNegative ? Duration.zero : rawDiff;

    // Format duration
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    state = CountdownState(
      activePrayerName: activeName,
      nextPrayerName: nextName,
      nextPrayerKey: nextKey,
      remainingDuration: diff,
      formattedTime: '$hours:$minutes:$seconds',
    );
  }

  DateTime? _lastRefreshRequest;

  void _requestFreshSchedule() {
    final now = DateTime.now();
    final last = _lastRefreshRequest;
    // Throttle: the timer ticks every second while the refresh is running.
    if (last != null && now.difference(last) < const Duration(seconds: 30)) {
      return;
    }
    _lastRefreshRequest = now;
    _ref.read(prayerTimesProvider.notifier).refreshIfStale();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Auto-disposed so the 1-second timer only runs while something on screen
/// (Home) is listening, instead of ticking app-wide forever.
final countdownProvider =
    StateNotifierProvider.autoDispose<CountdownNotifier, CountdownState>((ref) {
      return CountdownNotifier(ref);
    });
