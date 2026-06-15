import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

void main() {
  late Directory tempDir;

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('crash_recovery_test_dir');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await Hive.openBox<dynamic>(HiveService.settingsBoxName);
    await Hive.openBox<dynamic>(HiveService.trackerBoxName);
    await Hive.openBox<dynamic>(HiveService.locationBoxName);
    await Hive.openBox<dynamic>(HiveService.scheduleBoxName);
    await Hive.openBox<dynamic>(HiveService.quranIndexBoxName);
    await Hive.openBox<dynamic>(HiveService.quranDetailBoxName);
    await Hive.openBox<dynamic>(HiveService.quranBookmarksBoxName);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('PrayerTimes provider survives a PARTIAL cached schedule', () async {
    final box = Hive.box<dynamic>(HiveService.scheduleBoxName);
    box.put(dateKey(DateTime.now()), {
      'subuh': DateTime.now().toIso8601String(),
      'dzuhur': DateTime.now().toIso8601String(),
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Poll until state is populated or timeout
    int retries = 0;
    while (container.read(prayerTimesProvider).todayTimes.length < 5 && retries < 20) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      retries++;
    }

    final state = container.read(prayerTimesProvider);
    expect(state.todayTimes.length, 5);
  });

  test('PrayerTimes provider survives a CORRUPT cached schedule', () async {
    final box = Hive.box<dynamic>(HiveService.scheduleBoxName);
    box.put(dateKey(DateTime.now()), {
      'subuh': 'not-a-valid-date',
      'dzuhur': 12345,
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    int retries = 0;
    while (container.read(prayerTimesProvider).todayTimes.length < 5 && retries < 20) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      retries++;
    }

    expect(() => container.read(prayerTimesProvider), returnsNormally);
    final list = container.read(prayerListProvider);
    expect(list.length == 5 || list.isEmpty, isTrue);
  });

  test('Tracker provider survives corrupt entries', () {
    final box = Hive.box<dynamic>(HiveService.quranBookmarksBoxName);
    box.put('last_read', 'unexpected-string');
    box.put('list', 'unexpected-string');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(quranBookmarksProvider), returnsNormally);
    final state = container.read(quranBookmarksProvider);
    expect(state.bookmarkedKeys, isEmpty);
  });

  test('Settings provider returns safe defaults on corrupt data', () {
    final box = Hive.box<dynamic>(HiveService.settingsBoxName);
    box.put('prayer_offsets', 'not-a-map');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(settingsProvider), returnsNormally);
    final state = container.read(settingsProvider);
    expect(state.calculationMethod, 'Kemenag');
    expect(state.prayerOffsets.length, 5);
  });
}
