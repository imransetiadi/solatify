import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AzanAudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> init() async {
    try {
      // Configure audio player for notification sound
      await _audioPlayer.setAudioSource(
        AudioSource.asset('assets/azan.mp3'),
        initialPosition: Duration.zero,
      );
    } catch (error) {
      debugPrint('Failed to initialize azan audio: $error');
    }
  }

  static Future<void> playAzan({bool enabled = true}) async {
    if (!enabled || _isPlaying) return;

    try {
      _isPlaying = true;
      
      // Reset to beginning
      await _audioPlayer.seek(Duration.zero);
      
      // Play azan
      await _audioPlayer.play();
      
      debugPrint('Azan playing...');
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
}
