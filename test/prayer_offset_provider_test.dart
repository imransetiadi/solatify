import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';
import 'package:solatify/features/settings/presentation/screens/settings_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('prayer_offset_provider');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<dynamic>('location_cache');
    await Hive.openBox<dynamic>('prayer_schedules');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('changing offset recalculates provider times accurately', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = await _waitForSubuh(container);

    await container
        .read(settingsProvider.notifier)
        .updatePrayerOffsets('subuh', 7);

    final shifted = await _waitForSubuh(container, previous: initial);

    expect(shifted, initial.add(const Duration(minutes: 7)));
  });

  test('normalizes manual offset input safely', () {
    expect(normalizePrayerOffsetInput('7'), 7);
    expect(normalizePrayerOffsetInput('-5'), -5);
    expect(normalizePrayerOffsetInput('--5'), 0);
    expect(normalizePrayerOffsetInput('1-2'), 0);
    expect(normalizePrayerOffsetInput('90'), 60);
    expect(normalizePrayerOffsetInput('-90'), -60);
  });
}

Future<DateTime> _waitForSubuh(
  ProviderContainer container, {
  DateTime? previous,
}) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    final subuh = container.read(prayerTimesProvider).todayTimes['subuh'];
    if (subuh != null && subuh != previous) return subuh;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  throw StateError('Subuh time was not recalculated');
}
