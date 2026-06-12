import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AzanAudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  static String? _loadedAsset;

  static Future<void> init({String adhanSound = 'adhan_makkah'}) async {
    try {
      await _loadAsset(_assetForSound(adhanSound));
    } catch (error) {
      debugPrint('Failed to initialize azan audio: $error');
    }
  }

  static Future<void> playAzan({
    bool enabled = true,
    String adhanSound = 'adhan_makkah',
  }) async {
    if (!enabled || _isPlaying) return;

    try {
      _isPlaying = true;
      await _loadAsset(_assetForSound(adhanSound));
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      debugPrint('Azan playing: $adhanSound');
    } catch (error) {
      debugPrint('Failed to play azan: $error');
      _isPlaying = false;
    }
  }

  static Future<void> stopAzan() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      debugPrint('Azan stopped');
    } catch (error) {
      debugPrint('Failed to stop azan: $error');
    }
  }

  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (error) {
      debugPrint('Failed to dispose azan audio player: $error');
    }
  }

  static bool get isPlaying => _isPlaying;

  static Future<void> _loadAsset(String assetPath) async {
    if (_loadedAsset == assetPath) return;
    await _audioPlayer.setAudioSource(
      AudioSource.asset(assetPath),
      initialPosition: Duration.zero,
    );
    _loadedAsset = assetPath;
  }

  static String _assetForSound(String adhanSound) {
    if (adhanSound == 'adhan_madinah') {
      return 'assets/audio/azan_madinah.mp3';
    }
    return 'assets/audio/azan_makkah.mp3';
  }
}
