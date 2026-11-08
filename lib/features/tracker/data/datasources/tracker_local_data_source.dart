import 'package:hive/hive.dart';
import 'package:solatify/core/database/hive_constants.dart';
import '../models/prayer_log_dto.dart';

abstract class TrackerLocalDataSource {
  Future<PrayerLogDto?> getLog(String dateKey);
  Future<void> saveLog(PrayerLogDto log);
  Future<List<PrayerLogDto>> getLogsRange(List<String> dateKeys);

  /// Moves a habit's ticks and progress from [oldKey] to [newKey] in every
  /// stored day (used when a custom habit is renamed).
  Future<void> renameHabitKey(String oldKey, String newKey);
}

class TrackerLocalDataSourceImpl implements TrackerLocalDataSource {
  const TrackerLocalDataSourceImpl();

  @override
  Future<PrayerLogDto?> getLog(String dateKey) async {
    final box = await Hive.openBox<dynamic>(HiveConstants.trackerBox);
    final data = box.get(dateKey);
    if (data == null) return null;
    return PrayerLogDto.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> saveLog(PrayerLogDto log) async {
    final box = await Hive.openBox<dynamic>(HiveConstants.trackerBox);
    final dateKey = _getDateKey(log.date);
    await box.put(dateKey, log.toJson());
  }

  @override
  Future<List<PrayerLogDto>> getLogsRange(List<String> dateKeys) async {
    final box = await Hive.openBox<dynamic>(HiveConstants.trackerBox);
    final logs = <PrayerLogDto>[];
    for (final key in dateKeys) {
      final data = box.get(key);
      if (data != null) {
        logs.add(PrayerLogDto.fromJson(Map<String, dynamic>.from(data as Map)));
      }
    }
    return logs;
  }

  @override
  Future<void> renameHabitKey(String oldKey, String newKey) async {
    if (oldKey == newKey) return;
    final box = await Hive.openBox<dynamic>(HiveConstants.trackerBox);
    final updates = <dynamic, Map<String, dynamic>>{};
    for (final key in box.keys) {
      final data = box.get(key);
      if (data is! Map) continue;
      final json = Map<String, dynamic>.from(data);
      var changed = false;
      for (final field in const ['habits', 'habitProgress']) {
        final values = json[field];
        if (values is Map && values.containsKey(oldKey)) {
          final moved = Map<String, dynamic>.from(values);
          moved[newKey] = moved.remove(oldKey);
          json[field] = moved;
          changed = true;
        }
      }
      if (changed) updates[key] = json;
    }
    if (updates.isNotEmpty) await box.putAll(updates);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
