import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:solatify/features/prayer_widget/domain/android_prayer_widget_service.dart';

class IosPrayerWidgetService {
  IosPrayerWidgetService({MethodChannel? channel})
    : _channel = channel ?? IosPrayerWidgetService.channel;

  static const channel = MethodChannel('solatify/ios_prayer_widget');

  final MethodChannel _channel;

  Future<bool> sync(PrayerWidgetPayload payload) async {
    try {
      final synced = await _channel.invokeMethod<bool>(
        'syncPrayerWidget',
        payload.toMap(),
      );
      return synced ?? false;
    } catch (error, stackTrace) {
      debugPrint('iOS prayer widget sync failed: $error\n$stackTrace');
      return false;
    }
  }
}
