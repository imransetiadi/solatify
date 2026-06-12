import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/azan_audio_service.dart';
import '../../../settings/presentation/settings_provider.dart';

final azanAudioProvider = FutureProvider<void>((ref) async {
  final settings = ref.watch(settingsProvider);
  try {
    await AzanAudioService.init(adhanSound: settings.adhanSound);
  } catch (error) {
    debugPrint('Error initializing azan audio: $error');
  }
});
