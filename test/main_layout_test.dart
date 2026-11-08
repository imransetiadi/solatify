import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/navigation/router.dart';
import 'package:solatify/core/theme/theme.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainLayoutScreen(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const SizedBox.expand(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone in landscape: the rail scrolls instead of overflowing', (
    tester,
  ) async {
    // iPhone 16 Pro / Pixel-class phone turned sideways.
    await pumpShell(tester, const Size(874, 402));

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationRail), findsOneWidget);

    // The last destination (Settings) can be scrolled to and tapped.
    final settingsIcon = find.byIcon(Icons.settings_outlined);
    await tester.ensureVisible(settingsIcon);
    await tester.pumpAndSettle();
    expect(tester.getRect(settingsIcon).bottom, lessThanOrEqualTo(402));
  });

  testWidgets('tablet keeps the labelled rail without overflow', (
    tester,
  ) async {
    await pumpShell(tester, const Size(820, 1180));

    expect(tester.takeException(), isNull);
    expect(find.text('Pengaturan'), findsOneWidget);
  });
}
