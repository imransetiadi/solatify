import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solatify/core/database/hive_constants.dart';
import 'package:solatify/features/tracker/data/datasources/tracker_local_data_source.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('tracker_rename_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(HiveConstants.trackerBox);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('renaming a custom habit keeps its history', () async {
    final box = Hive.box<dynamic>(HiveConstants.trackerBox);
    await box.put('2026-06-17', {
      'date': '2026-06-17T00:00:00.000',
      'prayers': {'subuh': true},
      'habits': {'custom:Tilawah': true, 'tahajud': true},
      'habitProgress': {'custom:Tilawah': 5},
    });
    await box.put('2026-06-18', {
      'date': '2026-06-18T00:00:00.000',
      'prayers': <String, bool>{},
      'habits': {'tahajud': false},
      'habitProgress': <String, int>{},
    });

    await const TrackerLocalDataSourceImpl().renameHabitKey(
      'custom:Tilawah',
      'custom:Tilawah Quran',
    );

    final day = Map<String, dynamic>.from(box.get('2026-06-17') as Map);
    expect(day['habits'], {'custom:Tilawah Quran': true, 'tahajud': true});
    expect(day['habitProgress'], {'custom:Tilawah Quran': 5});
    // Days without the habit are left as they were.
    final other = Map<String, dynamic>.from(box.get('2026-06-18') as Map);
    expect(other['habits'], {'tahajud': false});
  });
}
