import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:solatify/features/mosque/presentation/screens/nearby_mosque_screen.dart';
import 'package:solatify/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:solatify/features/settings/presentation/screens/settings_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('routed_screen_smoke_test');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
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

  Widget wrap(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  testWidgets('Qibla screen renders', (tester) async {
    await tester.pumpWidget(wrap(const QiblaScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Arah Kiblat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mosque screen renders', (tester) async {
    await tester.pumpWidget(wrap(const NearbyMosqueScreen()));

    await tester.pump();

    expect(find.textContaining('Masjid'), findsWidgets);
    expect(find.text('Peta Area'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings screen renders', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));

    await tester.pumpAndSettle();

    expect(find.textContaining('Pengaturan'), findsWidgets);
    expect(find.text('NOTIFIKASI'), findsOneWidget);
    expect(find.text('Kirim notifikasi uji'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hijri calendar screen renders', (tester) async {
    await tester.pumpWidget(wrap(const HijriCalendarScreen()));

    await tester.pumpAndSettle();

    expect(find.textContaining('Hijriah'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
