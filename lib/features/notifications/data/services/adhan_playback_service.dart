import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// State of the full-length adhan the iOS app plays itself.
@immutable
class AdhanPlaybackState {
  const AdhanPlaybackState({this.isPlaying = false, this.prayerKey});

  factory AdhanPlaybackState.fromPlatform(Object? arguments) {
    if (arguments is! Map) return const AdhanPlaybackState();
    final isPlaying = arguments['playing'] == true;
    final prayerKey = arguments['prayerKey'];
    return AdhanPlaybackState(
      isPlaying: isPlaying,
      prayerKey: isPlaying && prayerKey is String ? prayerKey : null,
    );
  }

  final bool isPlaying;

  /// Prayer the adhan is for (`subuh`, `dzuhur`, ...), when known.
  final String? prayerKey;

  @override
  bool operator ==(Object other) =>
      other is AdhanPlaybackState &&
      other.isPlaying == isPlaying &&
      other.prayerKey == prayerKey;

  @override
  int get hashCode => Object.hash(isPlaying, prayerKey);
}

/// Bridge to the native iOS adhan player (`AdhanPlayer` in AppDelegate.swift).
///
/// iOS cuts notification sounds off at 30 seconds, so the app plays the full
/// adhan when an adhan notification arrives in the foreground or is tapped.
/// Other platforms have no native player; there every call is a no-op.
class AdhanPlaybackService {
  AdhanPlaybackService({MethodChannel? channel, TargetPlatform? platform})
    : _channel = channel ?? const MethodChannel('solatify/ios_adhan'),
      _platform = platform;

  final MethodChannel _channel;
  final TargetPlatform? _platform;

  bool get _isSupported =>
      !kIsWeb && (_platform ?? defaultTargetPlatform) == TargetPlatform.iOS;

  /// Calls [onChanged] whenever the native player starts or stops.
  void listen(ValueChanged<AdhanPlaybackState> onChanged) {
    if (!_isSupported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'adhanStateChanged') {
        onChanged(AdhanPlaybackState.fromPlatform(call.arguments));
      }
      return null;
    });
  }

  void cancel() {
    if (!_isSupported) return;
    _channel.setMethodCallHandler(null);
  }

  /// Current state, e.g. an adhan started by tapping the notification
  /// before the Flutter side was listening.
  Future<AdhanPlaybackState> currentState() async {
    if (!_isSupported) return const AdhanPlaybackState();
    try {
      return AdhanPlaybackState.fromPlatform(
        await _channel.invokeMethod<Object?>('getState'),
      );
    } catch (e) {
      debugPrint('Error reading adhan playback state: $e');
      return const AdhanPlaybackState();
    }
  }

  Future<void> stop() async {
    if (!_isSupported) return;
    try {
      await _channel.invokeMethod<bool>('stop');
    } catch (e) {
      debugPrint('Error stopping adhan playback: $e');
    }
  }
}
