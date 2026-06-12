import 'package:flutter/foundation.dart';

class PrayerTimeErrorHandler {
  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🔴 Prayer Time Error: $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   Stack: $stackTrace');
    }
  }

  static void logWarning(String message) {
    if (kDebugMode) {
      print('⚠️ Prayer Time Warning: $message');
    }
  }

  static void logInfo(String message) {
    if (kDebugMode) {
      print('ℹ️ Prayer Time Info: $message');
    }
  }

  static void logSuccess(String message) {
    if (kDebugMode) {
      print('✅ Prayer Time Success: $message');
    }
  }

  /// Validates prayer times and provides detailed error messages
  static ValidatonResult validatePrayerTimes(
    Map<String, DateTime> prayers,
  ) {
    try {
      // Check all prayers exist
      const required = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
      for (final prayer in required) {
        if (!prayers.containsKey(prayer)) {
          return ValidatonResult(
            isValid: false,
            error: 'Missing prayer time: $prayer',
          );
        }
      }

      // Check prayer times are in correct order
      final times = required.map((p) => prayers[p]!).toList();
      for (int i = 0; i < times.length - 1; i++) {
        if (times[i].isAfter(times[i + 1])) {
          return ValidatonResult(
            isValid: false,
            error: 'Prayer times not in correct order at ${required[i]}',
          );
        }

        // Check minimum time gap (30 minutes)
        final gap = times[i + 1].difference(times[i]).inMinutes;
        if (gap < 30) {
          logWarning(
            'Small gap between ${required[i]} and ${required[i + 1]}: $gap minutes',
          );
        }
      }

      return ValidatonResult(isValid: true);
    } catch (e) {
      return ValidatonResult(
        isValid: false,
        error: 'Validation error: $e',
      );
    }
  }
}

class ValidatonResult {
  final bool isValid;
  final String? error;

  ValidatonResult({required this.isValid, this.error});

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}
