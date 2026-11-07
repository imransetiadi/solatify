import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';
import 'package:solatify/features/qibla/domain/repositories/qibla_heading_repository.dart';

/// Reads the compass through the app's own `solatify/compass` event channel
/// (AppDelegate on iOS, CompassStreamHandler on Android).
///
/// This replaces the unmaintained flutter_compass_v2 plugin, which crashed
/// iOS debug builds at launch, started motion updates at app start, and
/// ignored magnetic declination on Android. The native side only runs the
/// sensors while this stream has a listener.
class NativeCompassQiblaHeadingRepository implements QiblaHeadingRepository {
  const NativeCompassQiblaHeadingRepository({EventChannel? channel})
    : _channel = channel ?? NativeCompassQiblaHeadingRepository.channel;

  static const channel = EventChannel('solatify/compass');

  final EventChannel _channel;

  @override
  Stream<QiblaHeading> watchHeading({double? latitude, double? longitude}) {
    return _channel
        .receiveBroadcastStream({'latitude': latitude, 'longitude': longitude})
        .map(parseCompassEvent)
        .transform(
          StreamTransformer<QiblaHeading, QiblaHeading>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              // No compass (e.g. emulators) or the platform refused: report
              // "no heading" so the screen shows its fallback view.
              debugPrint('Compass unavailable: $error');
              sink.add(const QiblaHeading(degrees: null));
            },
          ),
        );
  }

  @visibleForTesting
  static QiblaHeading parseCompassEvent(dynamic event) {
    if (event is! Map) return const QiblaHeading(degrees: null);
    final heading = event['heading'];
    final accuracy = event['accuracy'];
    return QiblaHeading(
      degrees: heading is num ? heading.toDouble() % 360 : null,
      accuracy: accuracy is num ? accuracy.toDouble() : null,
    );
  }
}
