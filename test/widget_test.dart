import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/main.dart';

void main() {
  late Directory tempDir;
  const notificationChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('solatify_test');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<dynamic>('prayer_tracker');
    await Hive.openBox<dynamic>('location_cache');
    await Hive.openBox<dynamic>('prayer_schedules');
    await Hive.openBox<dynamic>('quran_index');
    await Hive.openBox<dynamic>('quran_surah_details');
    await Hive.openBox<dynamic>('quran_bookmarks');
    debugDefaultTargetPlatformOverride = null;
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationChannel, null);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('App splash screen render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SolatifyApp()));
    await tester.pump();

    // Verify that the title 'SOLATIFY' is displayed
    expect(find.text('SOLATIFY'), findsOneWidget);

    // Settle transition timer and animations to prevent pending timers
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });

  test('startup permission prompt gate stays removed', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, isNot(contains('ExactAlarmPromptGate')));
    expect(mainSource, isNot(contains('_maybeShowExactAlarmPrompt')));
    expect(mainSource, isNot(contains('_maybeShowBatteryOptimizationPrompt')));
  });
}
