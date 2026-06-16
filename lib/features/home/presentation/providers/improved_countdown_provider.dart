import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/performance/performance_tuning.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../prayer_schedule/data/prayer_timezone_service.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';

class CountdownState {
  CountdownState({
    required this.activePrayerName,
    required this.nextPrayerName,
    required this.nextPrayerKey,
    required this.remainingDuration,
    required this.formattedTime,
    required this.nextPrayerTime,
    required this.isAccurate,
  });

  factory CountdownState.initial() {
    return CountdownState(
      activePrayerName: '-',
      nextPrayerName: '-',
      nextPrayerKey: '',
      remainingDuration: Duration.zero,
      formattedTime: '00:00:00',
      nextPrayerTime: DateTime.now(),
      isAccurate: false,
    );
  }

  final String activePrayerName;
  final String nextPrayerName;
  final String nextPrayerKey;
  final Duration remainingDuration;
  final String formattedTime; // HH:mm:ss
  final DateTime nextPrayerTime;
  final bool isAccurate;
}

class ImprovedCountdownNotifier extends StateNotifier<CountdownState> {
  ImprovedCountdownNotifier(this._ref) : super(CountdownState.initial()) {
    _startTimer();
  }

  final Ref _ref;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(
      PerformanceTuning.countdownTickInterval,
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    try {
      final timesState = _ref.read(prayerTimesProvider);
      final today = timesState.todayTimes;
      final tomorrow = timesState.tomorrowTimes;

      // Validate all required keys exist
      const requiredKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
      final hasAllToday = requiredKeys.every((k) => today.containsKey(k));
      final hasTomorrowSubuh = tomorrow.containsKey('subuh');

      if (!hasAllToday || !hasTomorrowSubuh) {
        return;
      }

      tzdata.initializeTimeZones();
      final selectedLocation = _ref.read(locationProvider);
      final timezoneName = PrayerTimezoneService.inferTimezoneName(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        country: selectedLocation.country,
      );
      final now = tz.TZDateTime.now(tz.getLocation(timezoneName));

      // Extract and validate prayer times
      final prayers = <String, DateTime>{
        'subuh': today['subuh']!,
        'dzuhur': today['dzuhur']!,
        'ashar': today['ashar']!,
        'magrib': today['magrib']!,
        'isya': today['isya']!,
      };

      // Validate times are in correct order (basic sanity check)
      final isValid = _validatePrayerTimes(prayers);
      if (!isValid) return;

      // Find current and next prayer
      final result = _findCurrentAndNextPrayer(
        now,
        prayers,
        tomorrow['subuh']!,
      );

      state = CountdownState(
        activePrayerName: result['activeName'] as String,
        nextPrayerName: result['nextName'] as String,
        nextPrayerKey: result['nextKey'] as String,
        remainingDuration: result['duration'] as Duration,
        formattedTime: _formatDuration(result['duration'] as Duration),
        nextPrayerTime: result['nextTime'] as DateTime,
        isAccurate: true,
      );
    } catch (e, stackTrace) {
      debugPrint('Countdown update error: $e\n$stackTrace');
      // Keep previous state on error
    }
  }

  bool _validatePrayerTimes(Map<String, DateTime> prayers) {
    final times = prayers.values.toList();
    for (int i = 0; i < times.length - 1; i++) {
      // Ensure each prayer time is before the next one
      if (times[i].isAfter(times[i + 1])) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> _findCurrentAndNextPrayer(
    DateTime now,
    Map<String, DateTime> todayPrayers,
    DateTime tomorrowSubuh,
  ) {
    final prayers = [
      ('subuh', todayPrayers['subuh']!),
      ('dzuhur', todayPrayers['dzuhur']!),
      ('ashar', todayPrayers['ashar']!),
      ('magrib', todayPrayers['magrib']!),
      ('isya', todayPrayers['isya']!),
    ];

    // Find which prayer period we're in
    String activeName = 'Isya';
    String nextName = 'Subuh';
    String nextKey = 'subuh';
    DateTime nextTime = tomorrowSubuh;

    for (int i = 0; i < prayers.length; i++) {
      final (name, time) = prayers[i];
      if (now.isBefore(time)) {
        nextName = _getPrayerLabel(name);
        nextKey = name;
        nextTime = time;

        // Get active prayer name
        if (i > 0) {
          final (prevName, _) = prayers[i - 1];
          activeName = _getPrayerLabel(prevName);
        } else {
          activeName = 'Isya';
        }
        break;
      }
    }

    // If we're past Isya, next is tomorrow's Subuh
    if (now.isAfter(prayers.last.$2)) {
      activeName = 'Isya';
      nextName = 'Subuh';
      nextKey = 'subuh';
      nextTime = tomorrowSubuh;
    }

    final duration = nextTime.difference(now);

    return {
      'activeName': activeName,
      'nextName': nextName,
      'nextKey': nextKey,
      'nextTime': nextTime,
      'duration': duration,
    };
  }

  String _getPrayerLabel(String key) {
    switch (key) {
      case 'subuh':
        return 'Subuh';
      case 'dzuhur':
        return 'Dzuhur';
      case 'ashar':
        return 'Ashar';
      case 'magrib':
        return 'Magrib';
      case 'isya':
        return 'Isya';
      default:
        return '-';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00:00';
    }
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final improvedCountdownProvider =
    StateNotifierProvider<ImprovedCountdownNotifier, CountdownState>((ref) {
      return ImprovedCountdownNotifier(ref);
    });
