import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/tracker/presentation/tracker_provider.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';
import 'package:solatify/features/settings/presentation/settings_provider.dart';

/// These tests reproduce the state the app is left in after a force-close
/// (abrupt termination via the app switcher): boxes may contain partial or
/// corrupt data. The providers must build a valid state without throwing.
void main() {
  late Directory tempDir;

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('crash_recovery_test_dir');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await Hive.openBox(HiveService.settingsBoxName);
    await Hive.openBox(HiveService.trackerBoxName);
    await Hive.openBox(HiveService.locationBoxName);
    await Hive.openBox(HiveService.scheduleBoxName);
    await Hive.openBox(HiveService.quranIndexBoxName);
    await Hive.openBox(HiveService.quranDetailBoxName);
    await Hive.openBox(HiveService.quranBookmarksBoxName);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('PrayerTimes provider survives a PARTIAL cached schedule', () {
    // Simulate a half-written cache (only some prayers) from a force-kill.
    final box = Hive.box(HiveService.scheduleBoxName);
    box.put(dateKey(DateTime.now()), {
      'subuh': DateTime.now().toIso8601String(),
      'dzuhur': DateTime.now().toIso8601String(),
      // missing ashar, magrib, isya
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Should not throw; should recalculate a complete set.
    final state = container.read(prayerTimesProvider);
    expect(state.todayTimes.length, 5);

    // prayerListProvider must not throw on force-unwrap.
    final list = container.read(prayerListProvider);
    expect(list.length, 5);
  });

  test('PrayerTimes provider survives a CORRUPT cached schedule', () {
    final box = Hive.box(HiveService.scheduleBoxName);
    box.put(dateKey(DateTime.now()), {
      'subuh': 'not-a-valid-date',
      'dzuhur': 12345, // wrong type
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(prayerTimesProvider), returnsNormally);
    final list = container.read(prayerListProvider);
    // Either a full recalculated list or an empty one — never a crash.
    expect(list.length == 5 || list.isEmpty, isTrue);
  });

  test('Tracker provider survives corrupt entries', () {
    final box = Hive.box(HiveService.trackerBoxName);
    final today = dateKey(DateTime.now());
    box.put('${today}_subuh', 'corrupt-string-instead-of-map');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(trackerProvider), returnsNormally);
    final state = container.read(trackerProvider);
    expect(state.todayStatus.length, 5);
  });

  test('Quran bookmarks provider survives unexpected stored shapes', () {
    final box = Hive.box(HiveService.quranBookmarksBoxName);
    box.put('last_read', 'unexpected-string');
    box.put('list', 'unexpected-string');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(quranBookmarksProvider), returnsNormally);
    final state = container.read(quranBookmarksProvider);
    expect(state.bookmarkedKeys, isEmpty);
  });

  test('Settings provider returns safe defaults on corrupt data', () {
    final box = Hive.box(HiveService.settingsBoxName);
    box.put('notification_enabled', 'not-a-bool');
    box.put('prayer_offsets', 'not-a-map');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(settingsProvider), returnsNormally);
    final state = container.read(settingsProvider);
    expect(state.notificationEnabled, isTrue); // safe default
    expect(state.prayerOffsets.length, 5);
  });
}
