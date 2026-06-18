import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PrayerWidgetPayload {
  const PrayerWidgetPayload({
    required this.nextPrayerName,
    required this.nextPrayerTimeLabel,
    required this.countdownLabel,
    required this.locationLabel,
    required this.hijriLabel,
  });

  factory PrayerWidgetPayload.empty() {
    return const PrayerWidgetPayload(
      nextPrayerName: '-',
      nextPrayerTimeLabel: '--:--',
      countdownLabel: '--:--',
      locationLabel: 'Solatify',
      hijriLabel: 'Jadwal salat',
    );
  }

  final String nextPrayerName;
  final String nextPrayerTimeLabel;
  final String countdownLabel;
  final String locationLabel;
  final String hijriLabel;

  Map<String, String> toMap() {
    return {
      'nextPrayerName': nextPrayerName,
      'nextPrayerTimeLabel': nextPrayerTimeLabel,
      'countdownLabel': countdownLabel,
      'locationLabel': locationLabel,
      'hijriLabel': hijriLabel,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is PrayerWidgetPayload &&
        other.nextPrayerName == nextPrayerName &&
        other.nextPrayerTimeLabel == nextPrayerTimeLabel &&
        other.countdownLabel == countdownLabel &&
        other.locationLabel == locationLabel &&
        other.hijriLabel == hijriLabel;
  }

  @override
  int get hashCode => Object.hash(
    nextPrayerName,
    nextPrayerTimeLabel,
    countdownLabel,
    locationLabel,
    hijriLabel,
  );
}

class AndroidPrayerWidgetService {
  AndroidPrayerWidgetService({MethodChannel? channel})
    : _channel = channel ?? AndroidPrayerWidgetService.channel;

  static const channel = MethodChannel('solatify/android_prayer_widget');

  final MethodChannel _channel;

  Future<bool> sync(PrayerWidgetPayload payload) async {
    try {
      final synced = await _channel.invokeMethod<bool>(
        'syncPrayerWidget',
        payload.toMap(),
      );
      return synced ?? false;
    } catch (error, stackTrace) {
      debugPrint('Prayer widget sync failed: $error\n$stackTrace');
      return false;
    }
  }
}
