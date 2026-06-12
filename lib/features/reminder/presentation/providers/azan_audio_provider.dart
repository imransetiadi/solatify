import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/azan_audio_service.dart';

final azanAudioProvider = FutureProvider<void>((ref) async {
  try {
    await AzanAudioService.init();
  } catch (error) {
    debugPrint('Error initializing azan audio: $error');
  }
});
