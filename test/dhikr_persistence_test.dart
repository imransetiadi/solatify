import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/dhikr/presentation/providers/dhikr_provider.dart';
import 'package:solatify/features/dhikr/presentation/screens/dhikr_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('dhikr_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(HiveService.settingsBoxName);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  String todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'dhikr_counts_${now.year}-$m-$d';
  }

  Future<void> pumpDhikr(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DhikrScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('counts survive leaving the screen, but not a new day', (
    tester,
  ) async {
    final box = Hive.box<dynamic>(HiveService.settingsBoxName);
    final first = ProviderContainer().read(morningDhikrProvider).first;
    // Real I/O cannot complete inside the widget test's fake clock.
    await tester.runAsync(() async {
      await box.put(todayKey(), {
        'morning': {'${first.id}': 2},
        'evening': <String, int>{},
      });
      await box.put('dhikr_counts_2000-01-01', {
        'morning': {'${first.id}': 9},
      });
    });

    await pumpDhikr(tester);

    expect(find.textContaining('2 / '), findsWidgets);
    expect(find.textContaining('9 / '), findsNothing);
  });
}
