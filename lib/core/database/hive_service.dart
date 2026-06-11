import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String settingsBoxName = 'settings';
  static const String trackerBoxName = 'prayer_tracker';
  static const String locationBoxName = 'location_cache';
  static const String scheduleBoxName = 'prayer_schedules';
  static const String quranIndexBoxName = 'quran_index';
  static const String quranDetailBoxName = 'quran_surah_details';
  static const String quranBookmarksBoxName = 'quran_bookmarks';

  static bool _initialized = false;
  static bool _hiveInitialized = false;

  static bool get isInitialized => _initialized;

  static final List<String> _allBoxNames = [
    settingsBoxName,
    trackerBoxName,
    locationBoxName,
    scheduleBoxName,
    quranIndexBoxName,
    quranDetailBoxName,
    quranBookmarksBoxName,
  ];

  static Future<void> ensureBoxesOpen() async {
    try {
      // Ensure Hive itself is initialized first
      if (!_hiveInitialized) {
        await Hive.initFlutter();
        _hiveInitialized = true;
      }

      for (final name in _allBoxNames) {
        await _openBoxSafe(name);
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Error ensuring boxes are open: $e');
    }
  }

  static Future<void> init() async {
    if (!_hiveInitialized) {
      await Hive.initFlutter();
      _hiveInitialized = true;
    }

    for (final name in _allBoxNames) {
      await _openBoxSafe(name);
    }
    _initialized = true;
  }

  /// Opens a box safely. If the box is corrupted (common after force-close),
  /// deletes and recreates it.
  static Future<void> _openBoxSafe(String name) async {
    if (Hive.isBoxOpen(name)) return;

    try {
      await Hive.openBox(name);
    } catch (e) {
      debugPrint('Error opening box "$name": $e. Attempting recovery...');
      try {
        // Delete corrupted box and recreate
        await Hive.deleteBoxFromDisk(name);
        await Hive.openBox(name);
        debugPrint('Box "$name" recovered successfully.');
      } catch (e2) {
        debugPrint('Failed to recover box "$name": $e2');
      }
    }
  }

  // Generic helpers — now safe against uninitialized state
  static Box getBox(String name) {
    if (!Hive.isBoxOpen(name)) {
      // Return a fallback: try to get it, but if it fails, we handle gracefully
      throw HiveError(
        'Box "$name" is not open. Call HiveService.ensureBoxesOpen() first.',
      );
    }
    return Hive.box(name);
  }

  /// Safe version of getBox that returns null if the box is not open.
  static Box? tryGetBox(String name) {
    if (!Hive.isBoxOpen(name)) return null;
    try {
      return Hive.box(name);
    } catch (e) {
      debugPrint('Error accessing box "$name": $e');
      return null;
    }
  }

  // Keep internal reference for backward compat
  static Box? _tryGetBox(String name) => tryGetBox(name);

  // Settings helpers
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = _tryGetBox(settingsBoxName);
    if (box == null) return;

    await box.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = _tryGetBox(settingsBoxName);
    if (box == null) return defaultValue;

    return box.get(key, defaultValue: defaultValue);
  }

  // Location helpers
  static Future<void> cacheLocation(Map<String, dynamic> locationData) async {
    final box = _tryGetBox(locationBoxName);
    if (box == null) return;

    await box.put('current', locationData);
  }

  static Map<String, dynamic>? getCachedLocation() {
    final box = _tryGetBox(locationBoxName);
    if (box == null) return null;

    final data = box.get('current');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // Tracker helpers
  static Future<void> saveTrackerEntry(String key, String status) async {
    final box = _tryGetBox(trackerBoxName);
    if (box == null) return;

    await box.put(key, {
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic>? getTrackerEntry(String key) {
    final box = _tryGetBox(trackerBoxName);
    if (box == null) return null;

    final data = box.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static List<Map<String, dynamic>> getAllTrackerEntries() {
    final box = _tryGetBox(trackerBoxName);
    if (box == null) return const [];

    final entries = <Map<String, dynamic>>[];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        final map = Map<String, dynamic>.from(value);
        map['key'] = key;
        entries.add(map);
      }
    }
    return entries;
  }

  // Schedule helpers
  static Future<void> cachePrayerSchedules(
    String dateKey,
    Map<String, dynamic> schedules,
  ) async {
    final box = _tryGetBox(scheduleBoxName);
    if (box == null) return;

    await box.put(dateKey, schedules);
  }

  static Map<String, dynamic>? getCachedPrayerSchedule(String dateKey) {
    final box = _tryGetBox(scheduleBoxName);
    if (box == null) return null;

    final data = box.get(dateKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // Prayer time offsets helpers
  static Future<void> savePrayerOffsets(Map<String, int> offsets) async {
    await saveSetting('prayer_offsets', offsets);
  }

  static Map<String, int> getPrayerOffsets() {
    final data = getSetting('prayer_offsets', defaultValue: {});
    
    final result = {
      'subuh': 0,
      'dzuhur': 0,
      'ashar': 0,
      'magrib': 0,
      'isya': 0,
    };

    if (data is Map) {
      for (final key in result.keys) {
        if (data.containsKey(key)) {
          final val = data[key];
          if (val is int) {
            result[key] = val;
          } else if (val is num) {
            result[key] = val.toInt();
          }
        }
      }
    }
    return result;
  }
}
