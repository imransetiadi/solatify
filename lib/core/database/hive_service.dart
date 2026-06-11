import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String settingsBoxName = 'settings';
  static const String trackerBoxName = 'prayer_tracker';
  static const String locationBoxName = 'location_cache';
  static const String scheduleBoxName = 'prayer_schedules';
  static const String quranIndexBoxName = 'quran_index';
  static const String quranDetailBoxName = 'quran_surah_details';
  static const String quranBookmarksBoxName = 'quran_bookmarks';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(trackerBoxName);
    await Hive.openBox(locationBoxName);
    await Hive.openBox(scheduleBoxName);
    await Hive.openBox(quranIndexBoxName);
    await Hive.openBox(quranDetailBoxName);
    await Hive.openBox(quranBookmarksBoxName);
  }

  // Generic helpers
  static Box getBox(String name) => Hive.box(name);

  // Settings helpers
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = getBox(settingsBoxName);
    await box.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = getBox(settingsBoxName);
    return box.get(key, defaultValue: defaultValue);
  }

  // Location helpers
  static Future<void> cacheLocation(Map<String, dynamic> locationData) async {
    final box = getBox(locationBoxName);
    await box.put('current', locationData);
  }

  static Map<String, dynamic>? getCachedLocation() {
    final box = getBox(locationBoxName);
    final data = box.get('current');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // Tracker helpers
  static Future<void> saveTrackerEntry(String key, String status) async {
    final box = getBox(trackerBoxName);
    await box.put(key, {
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic>? getTrackerEntry(String key) {
    final box = getBox(trackerBoxName);
    final data = box.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static List<Map<String, dynamic>> getAllTrackerEntries() {
    final box = getBox(trackerBoxName);
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
    final box = getBox(scheduleBoxName);
    await box.put(dateKey, schedules);
  }

  static Map<String, dynamic>? getCachedPrayerSchedule(String dateKey) {
    final box = getBox(scheduleBoxName);
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
    return {
      'subuh': 0,
      'dzuhur': 0,
      'ashar': 0,
      'magrib': 0,
      'isya': 0,
    };
  }
}
