import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';
import '../../../prayer_schedule/data/prayer_timezone_service.dart';

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

    // Safety check: ensure all required keys exist before proceeding
    const requiredKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
    final hasAllToday = requiredKeys.every((k) => today.containsKey(k));
    final hasTomorrowSubuh = tomorrow.containsKey('subuh');

    if (!hasAllToday || !hasTomorrowSubuh) return;

    tzdata.initializeTimeZones();
    final selectedLocation = _ref.read(locationProvider);
    final timezoneName = PrayerTimezoneService.inferTimezoneName(
      latitude: selectedLocation.latitude,
      longitude: selectedLocation.longitude,
      country: selectedLocation.country,
    );
    final prayerLocation = tz.getLocation(timezoneName);

    // Get current time in the selected city's timezone, not the device timezone.
    final now = tz.TZDateTime.now(prayerLocation);

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
