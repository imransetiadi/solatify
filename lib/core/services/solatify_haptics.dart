import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SolatifyHaptics {
  const SolatifyHaptics._();

  static Future<void> selection() => _run(HapticFeedback.selectionClick);

  static Future<void> light() => _run(HapticFeedback.lightImpact);

  static Future<void> success() => _run(HapticFeedback.mediumImpact);

  static Future<void> _run(Future<void> Function() feedback) async {
    try {
      await feedback();
    } catch (error) {
      debugPrint('Haptic feedback skipped: $error');
    }
  }
}
