import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/features/prayer_schedule/presentation/screens/prayer_schedule_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('prayer_schedule_test_dir');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<dynamic>('prayer_tracker');
    await Hive.openBox<dynamic>('location_cache');
    await Hive.openBox<dynamic>('prayer_schedules');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('PrayerScheduleScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PrayerScheduleScreen())),
    );

    await tester.pump();

    // Verify it renders the title
    expect(find.text('Jadwal Salat'), findsOneWidget);
  });

  testWidgets('can change manual city without layout exception', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PrayerScheduleScreen())),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Ubah'));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Lokasi'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Bekasi');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bekasi').first);
    await tester.pumpAndSettle();

    expect(find.text('Bekasi'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark mode selected date uses dark accent color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const PrayerScheduleScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final tomorrow = DateTime.now().add(const Duration(days: 1)).day.toString();
    await tester.tap(find.text(tomorrow).first);
    await tester.pumpAndSettle();

    final selectedDateCards = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .where((widget) {
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == AppTheme.redAccentDark;
        })
        .toList();

    expect(selectedDateCards, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  test(
    'offline city list covers Indonesian regions and searchable province text',
    () {
      final cities = LocationService.defaultCities;

      expect(
        cities.where((city) => city.country.contains('Indonesia')).length,
        greaterThanOrEqualTo(80),
      );
      expect(
        cities.any(
          (city) =>
              city.name == 'Sorong' &&
              city.country.contains('Papua Barat Daya'),
        ),
        isTrue,
      );
      expect(
        cities.any(
          (city) =>
              city.name == 'Tanjung Selor' &&
              city.country.contains('Kalimantan Utara'),
        ),
        isTrue,
      );
      expect(
        cities.any(
          (city) =>
              city.name == 'Mamuju' && city.country.contains('Sulawesi Barat'),
        ),
        isTrue,
      );
      expect(
        cities.any(
          (city) =>
              city.name == 'Kupang' &&
              city.country.contains('Nusa Tenggara Timur'),
        ),
        isTrue,
      );
    },
  );
}
