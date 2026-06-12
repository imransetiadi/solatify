import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../prayer_schedule/presentation/prayer_times_provider.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../data/services/azan_audio_service.dart';

final foregroundAdhanAlarmProvider = Provider<ForegroundAdhanAlarm>((ref) {
  final alarm = ForegroundAdhanAlarm(ref);
  ref.onDispose(alarm.dispose);
  return alarm;
});

class ForegroundAdhanAlarm {
  ForegroundAdhanAlarm(this._ref) {
    _start();
  }

  final Ref _ref;
  Timer? _timer;
  String? _lastPlayedKey;

  void _start() {
    _timer?.cancel();
    _checkPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkPrayerTimes();
    });
  }

  void _checkPrayerTimes() {
    try {
      final settings = _ref.read(settingsProvider);
      if (!settings.fullAdhanAlarmEnabled || !settings.azanSoundEnabled) {
        return;
      }

      final times = _ref.read(prayerTimesProvider).todayTimes;
      if (times.isEmpty) return;

      final now = DateTime.now();
      for (final entry in times.entries) {
        final prayerTime = entry.value;
        final diff = now.difference(prayerTime).inSeconds;
        if (diff < 0 || diff > 20) continue;

        final playKey = '${entry.key}-${prayerTime.toIso8601String()}';
        if (_lastPlayedKey == playKey) return;

        _lastPlayedKey = playKey;
        AzanAudioService.playAzan(
          enabled: true,
          adhanSound: settings.adhanSound,
        );
        debugPrint('Foreground full adhan alarm played: $playKey');
        return;
      }
    } catch (error, stackTrace) {
      debugPrint('Foreground adhan alarm error: $error\n$stackTrace');
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
