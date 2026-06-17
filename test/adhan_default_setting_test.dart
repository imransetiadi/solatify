import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solatify/core/database/hive_service.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('solatify_hive_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'init resets adhan notifications to off for manual permission flow',
    () async {
      final settingsBox = await Hive.openBox<dynamic>(
        HiveService.settingsBoxName,
      );
      await settingsBox.put('adhan_notifications_enabled', true);

      await HiveService.ensureManualAdhanNotificationDefault();

      expect(HiveService.getSetting('adhan_notifications_enabled'), isFalse);
      expect(
        HiveService.getSetting('adhan_notifications_manual_default_migrated'),
        isTrue,
      );
    },
  );
}
