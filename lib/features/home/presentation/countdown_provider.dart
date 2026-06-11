import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../prayer_schedule/presentation/prayer_times_provider.dart';

class CountdownState {
  final String activePrayerName;
  final String nextPrayerName;
  final String nextPrayerKey;
  final Duration remainingDuration;
  final String formattedTime; // HH:mm:ss

  CountdownState({
    required this.activePrayerName,
    required this.nextPrayerName,
    required this.nextPrayerKey,
    required this.remainingDuration,
    required this.formattedTime,
  });

  factory CountdownState.initial() {
    return CountdownState(
      activePrayerName: '-',
      nextPrayerName: '-',
      nextPrayerKey: '',
      remainingDuration: Duration.zero,
      formattedTime: '00:00:00',
    );
  }
}

class CountdownNotifier extends StateNotifier<CountdownState> {
  final Ref _ref;
  Timer? _timer;

  CountdownNotifier(this._ref) : super(CountdownState.initial()) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _updateCountdown(); // Run immediately
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final timesState = _ref.read(prayerTimesProvider);
    final today = timesState.todayTimes;
    final tomorrow = timesState.tomorrowTimes;

    if (today.isEmpty || tomorrow.isEmpty) return;

    final now = DateTime.now();

    // Extract prayer times
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

    final diff = nextTime.difference(now);

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final countdownProvider =
    StateNotifierProvider<CountdownNotifier, CountdownState>((ref) {
      return CountdownNotifier(ref);
    });
