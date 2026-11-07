import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/notifications/data/services/adhan_playback_service.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';

/// Tracks the full-length adhan played by the iOS app and lets the user stop
/// it. Quran recitation is paused when the adhan starts so both do not play
/// at once.
class AdhanPlaybackNotifier extends StateNotifier<AdhanPlaybackState> {
  AdhanPlaybackNotifier(this._service, {VoidCallback? onAdhanStarted})
    : _onAdhanStarted = onAdhanStarted,
      super(const AdhanPlaybackState()) {
    _service.listen(_apply);
    _loadInitialState();
  }

  final AdhanPlaybackService _service;
  final VoidCallback? _onAdhanStarted;

  Future<void> _loadInitialState() async {
    final initial = await _service.currentState();
    if (mounted) _apply(initial);
  }

  void _apply(AdhanPlaybackState next) {
    if (!mounted) return;
    final started = next.isPlaying && !state.isPlaying;
    state = next;
    if (started) _onAdhanStarted?.call();
  }

  Future<void> stop() async {
    await _service.stop();
    if (mounted) state = const AdhanPlaybackState();
  }

  @override
  void dispose() {
    _service.cancel();
    super.dispose();
  }
}

final adhanPlaybackServiceProvider = Provider<AdhanPlaybackService>(
  (ref) => AdhanPlaybackService(),
);

final adhanPlaybackProvider =
    StateNotifierProvider<AdhanPlaybackNotifier, AdhanPlaybackState>((ref) {
      return AdhanPlaybackNotifier(
        ref.watch(adhanPlaybackServiceProvider),
        onAdhanStarted: () {
          // Only touch the Quran player if it already exists; reading the
          // provider would otherwise create a player just to pause it.
          if (!ref.exists(quranAudioProvider)) return;
          if (!ref.read(quranAudioProvider).isPlaying) return;
          ref
              .read(quranAudioProvider.notifier)
              .pause()
              .catchError(
                (Object e) => debugPrint('Pausing Quran for adhan failed: $e'),
              );
        },
      );
    });
