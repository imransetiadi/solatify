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

  static bool get isInitialized => _initialized;

  static Future<void> init() async {
    await Hive.initFlutter();
    await _openBox(settingsBoxName);
    await _openBox(trackerBoxName);
    await _openBox(locationBoxName);
    await _openBox(scheduleBoxName);
    await _openBox(quranIndexBoxName);
    await _openBox(quranDetailBoxName);
    await _openBox(quranBookmarksBoxName);
    _initialized = true;
  }

  static Future<void> _openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox(name);
    }
  }

  // Generic helpers
  static Box getBox(String name) => Hive.box(name);

  static Box? _tryGetBox(String name) {
    if (!Hive.isBoxOpen(name)) return null;

    return Hive.box(name);
  }

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
    if (data is Map) {
      return Map<String, int>.from(data);
    }
    return {'subuh': 0, 'dzuhur': 0, 'ashar': 0, 'magrib': 0, 'isya': 0};
  }
}
