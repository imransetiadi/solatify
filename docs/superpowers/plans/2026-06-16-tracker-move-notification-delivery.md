# Tracker Move And Notification Delivery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the daily tracker out of Home into the More menu and repair test notification delivery by using a fresh diagnostic channel and unique notification IDs.

**Architecture:** Keep tracker state/data in the existing tracker feature and move only its presentation from Home to a new `TrackerScreen`. Add `/tracker` to the existing shell router and include it in the mobile More sheet. Keep notification delivery inside `NotificationService`, adding a diagnostic channel and dynamic test IDs without changing real prayer notification copy.

**Tech Stack:** Flutter, Riverpod, GoRouter, Hive-backed tracker provider, `flutter_local_notifications`, Flutter widget/unit tests.

---

## File Structure

- Modify `lib/features/home/presentation/screens/home_screen.dart`
  - Remove tracker provider import/usage and the `Ceklis Ibadah Hari Ini` card.
- Create `lib/features/tracker/presentation/screens/tracker_screen.dart`
  - New dedicated tracker UI using existing `trackerProvider`.
- Modify `lib/core/navigation/router.dart`
  - Import `TrackerScreen`.
  - Add `/tracker` route.
  - Add `Tracker Ibadah` to `_moreDestinations`.
- Modify `lib/features/notifications/data/services/notification_service.dart`
  - Add diagnostic channel constants/channel creation.
  - Make `showTestNotification()` use diagnostic channel and unique IDs.
- Modify `test/routed_screen_smoke_test.dart`
  - Add Home absence assertion and Tracker render smoke test.
- Modify `test/notification_service_test.dart`
  - Assert test notification uses dynamic ID and diagnostic channel.
- Modify `docs/qa/release-signoff.md`
  - Add manual QA checks for Tracker navigation and diagnostic notification channel.

---

### Task 1: Move Tracker UI Out Of Home

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`
- Create: `lib/features/tracker/presentation/screens/tracker_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add failing Home absence assertion and Tracker smoke test**

In `test/routed_screen_smoke_test.dart`, add this import:

```dart
import 'package:solatify/features/home/presentation/screens/home_screen.dart';
import 'package:solatify/features/tracker/presentation/screens/tracker_screen.dart';
```

Add this test after the `Qibla screen renders` test:

```dart
  testWidgets('Home screen no longer renders tracker checklist', (tester) async {
    await tester.pumpWidget(wrap(const HomeScreen()));

    await tester.pump();

    expect(find.text('Ceklis Ibadah Hari Ini'), findsNothing);
    expect(find.textContaining('Jadwal Salat'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
```

Add this test after the Home test:

```dart
  testWidgets('Tracker screen renders worship checklist', (tester) async {
    await tester.pumpWidget(wrap(const TrackerScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Tracker Ibadah'), findsOneWidget);
    expect(find.text('Ceklis Ibadah Hari Ini'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
```

- [ ] **Step 2: Run smoke test and confirm failure**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
```

Expected: fails because `TrackerScreen` does not exist and Home still renders the tracker checklist.

- [ ] **Step 3: Create TrackerScreen**

Create `lib/features/tracker/presentation/screens/tracker_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerAsync = ref.watch(trackerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final mutedColor = isDark ? const Color(0xFFE0D4C4) : const Color(0xFFAFA19A);
    final brightGreen = isDark ? const Color(0xFF4CAF50) : const Color(0xFF0E4D31);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Tracker Ibadah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveLayout.pagePadding(context).copyWith(
                top: 24,
                bottom: 96,
              ),
              child: trackerAsync.when(
                data: (log) => GlassContainer(
                  blur: 15,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ceklis Ibadah Hari Ini',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tandai salat yang sudah ditunaikan hari ini.',
                        style: TextStyle(color: mutedColor, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: log.prayers.keys.map((prayer) {
                          final isDone = log.prayers[prayer] ?? false;
                          return InkWell(
                            onTap: () => ref
                                .read(trackerProvider.notifier)
                                .togglePrayer(prayer),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? brightGreen.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDone
                                      ? brightGreen
                                      : mutedColor.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 16,
                                    color: isDone ? brightGreen : mutedColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    prayer[0].toUpperCase() + prayer.substring(1),
                                    style: TextStyle(
                                      color: isDone ? brightGreen : textColor,
                                      fontWeight: isDone
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => GlassContainer(
                  blur: 15,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Tracker ibadah belum dapat dimuat.',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Remove tracker card from Home**

In `lib/features/home/presentation/screens/home_screen.dart`:

Remove this import:

```dart
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';
```

Remove these local variables from `build()`:

```dart
    final trackerAsync = ref.watch(trackerProvider);
    final brightGreen = isDark ? const Color(0xFF4CAF50) : const Color(0xFF0E4D31);
```

Remove the full `SliverToBoxAdapter` block that contains the text `Ceklis Ibadah Hari Ini` and the `trackerAsync.when(...)` checklist card.

- [ ] **Step 5: Format and run smoke tests**

Run:

```bash
dart format lib/features/home/presentation/screens/home_screen.dart lib/features/tracker/presentation/screens/tracker_screen.dart test/routed_screen_smoke_test.dart
flutter test test/routed_screen_smoke_test.dart
```

Expected: smoke tests pass.

- [ ] **Step 6: Commit Task 1**

Run:

```bash
git add lib/features/home/presentation/screens/home_screen.dart lib/features/tracker/presentation/screens/tracker_screen.dart test/routed_screen_smoke_test.dart
git commit -m "feat: move tracker from home to dedicated screen"
```

---

### Task 2: Add Tracker Route To More Menu

**Files:**
- Modify: `lib/core/navigation/router.dart`

- [ ] **Step 1: Add TrackerScreen import**

In `lib/core/navigation/router.dart`, add:

```dart
import '../../features/tracker/presentation/screens/tracker_screen.dart';
```

- [ ] **Step 2: Add `/tracker` route**

Inside the `ShellRoute` route list, after the `/islamic-content/dhikr` route, add:

```dart
        GoRoute(
          path: '/tracker',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const TrackerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
```

- [ ] **Step 3: Add Tracker to More destinations**

In `_moreDestinations`, add this destination before Settings:

```dart
    _MainDestination(
      Icons.check_circle_outline,
      Icons.check_circle,
      'Tracker Ibadah',
      '/tracker',
    ),
```

- [ ] **Step 4: Keep mobile More selected for Tracker**

In `_calculateMobileSelectedIndex()`, add `/tracker` to the More bucket before `return 4`:

```dart
    if (location.startsWith('/tracker')) return 4;
```

In `_calculateSelectedIndex()`, return a safe index for `/tracker` by adding:

```dart
    if (location.startsWith('/tracker')) return 0;
```

- [ ] **Step 5: Format and analyze router**

Run:

```bash
dart format lib/core/navigation/router.dart
flutter analyze lib/core/navigation/router.dart
```

Expected: no issues found.

- [ ] **Step 6: Commit Task 2**

Run:

```bash
git add lib/core/navigation/router.dart
git commit -m "feat: add tracker to more menu"
```

---

### Task 3: Repair Test Notification Delivery Channel

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Update failing notification test expectations**

In `test/notification_service_test.dart`, update `showTestNotification sends an immediate notification` to:

```dart
  test('showTestNotification sends an immediate diagnostic notification', () async {
    await service.init();

    await service.showTestNotification();

    final showCall = capturedMethods.lastWhere((call) => call.method == 'show');
    expect(showCall.arguments['id'], isNot(9001));
    expect(showCall.arguments['title'], 'Tes Notifikasi Solatify');
    expect(
      showCall.arguments['platformSpecifics']['channelId'],
      'solatify_diagnostic_channel_v2',
    );
  });
```

- [ ] **Step 2: Run failing notification service test**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: fails because `showTestNotification()` still uses fixed ID/channel.

- [ ] **Step 3: Add diagnostic channel constants**

Inside `NotificationService`, before `_flutterLocalNotificationsPlugin`, add:

```dart
  static const String _prayerChannelId = 'prayer_times_adhan_channel_v1';
  static const String _diagnosticChannelId = 'solatify_diagnostic_channel_v2';
```

- [ ] **Step 4: Create diagnostic channel during init**

Replace `_createNotificationChannel()` with:

```dart
  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    const prayerChannel = AndroidNotificationChannel(
      _prayerChannelId,
      'Prayer Times Adhan',
      description: 'Adhan notifications for prayer times',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      enableLights: true,
    );

    const diagnosticChannel = AndroidNotificationChannel(
      _diagnosticChannelId,
      'Solatify Diagnostic',
      description: 'Test notifications for verifying Solatify notification delivery',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(prayerChannel);
    await androidPlugin?.createNotificationChannel(diagnosticChannel);
    debugPrint('Notification channels created: $_prayerChannelId, $_diagnosticChannelId');
  }
```

- [ ] **Step 5: Use diagnostic channel and dynamic ID in `showTestNotification()`**

Inside `showTestNotification()`, replace the Android details with:

```dart
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _diagnosticChannelId,
        'Solatify Diagnostic',
        channelDescription:
            'Test notifications for verifying Solatify notification delivery',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        icon: '@mipmap/ic_launcher',
      );
```

Before calling `show()`, add:

```dart
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
```

Replace the first argument to `_flutterLocalNotificationsPlugin.show()` from `9001` to `notificationId`.

Replace:

```dart
      debugPrint('Test notification sent');
```

with:

```dart
      debugPrint(
        'Test notification sent: id=$notificationId channel=$_diagnosticChannelId',
      );
```

- [ ] **Step 6: Use channel constants where straightforward**

In prayer notification Android details and channel creation, replace literal `'prayer_times_adhan_channel_v1'` with `_prayerChannelId` where Dart allows const usage. Keep behavior unchanged.

- [ ] **Step 7: Format and run notification tests**

Run:

```bash
dart format lib/features/notifications/data/services/notification_service.dart test/notification_service_test.dart
flutter test test/notification_service_test.dart
```

Expected: all notification service tests pass.

- [ ] **Step 8: Commit Task 3**

Run:

```bash
git add lib/features/notifications/data/services/notification_service.dart test/notification_service_test.dart
git commit -m "fix: use diagnostic channel for test notifications"
```

---

### Task 4: Update QA Documentation

**Files:**
- Modify: `docs/qa/release-signoff.md`

- [ ] **Step 1: Add Tracker QA checks**

Under `## Required Evidence`, add:

```markdown
- Screenshot or recording showing Tracker moved from Home into More
```

Under `## iOS Verification`, add:

```markdown
- [ ] Home no longer shows `Ceklis Ibadah Hari Ini`
- [ ] More menu opens `Tracker Ibadah`
- [ ] Tracker checklist toggle works
```

Under `## Android Verification`, add:

```markdown
- [ ] Home no longer shows `Ceklis Ibadah Hari Ini`
- [ ] More menu opens `Tracker Ibadah`
- [ ] Tracker checklist toggle works
```

- [ ] **Step 2: Add diagnostic channel QA check**

Under `## Notification UX Checks`, add:

```markdown
- [ ] Android diagnostic channel `Solatify Diagnostic` is enabled in system notification settings
- [ ] `Kirim notifikasi uji` creates a new visible system notification each tap
```

- [ ] **Step 3: Commit Task 4**

Run:

```bash
git add docs/qa/release-signoff.md
git commit -m "docs: add tracker and diagnostic notification QA checks"
```

---

### Task 5: Final Verification And Push

**Files:**
- No planned source modifications.

- [ ] **Step 1: Run targeted tests**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart test/notification_service_test.dart
```

Expected: all targeted tests pass.

- [ ] **Step 2: Run full test suite**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: no issues found.

- [ ] **Step 4: Run Android build QA**

Run:

```bash
flutter build apk --debug
```

Expected: debug APK builds successfully.

- [ ] **Step 5: Run iOS build QA**

Run:

```bash
flutter build ios --no-codesign
```

Expected: iOS app builds successfully without codesigning.

- [ ] **Step 6: Clean unrelated generated files**

Run:

```bash
git status --short
```

If `ios/Podfile.lock` changed only because the build registered `integration_test`, run:

```bash
git checkout -- ios/Podfile.lock
```

Remove known generated artifacts if present:

```bash
rm -rf android/.kotlin/
```

- [ ] **Step 7: Push branch**

Run:

```bash
git push
```

Expected: PR #8 updates.

- [ ] **Step 8: Report final QA evidence**

Report:

```markdown
- `flutter test test/routed_screen_smoke_test.dart test/notification_service_test.dart` result
- `flutter test` result
- `flutter analyze` result
- `flutter build apk --debug` result
- `flutter build ios --no-codesign` result
- PR URL: https://github.com/imransetiadi/solatify/pull/8
- Manual QA still required: Android/iOS visible system notification after tapping `Kirim notifikasi uji`, including Android channel `Solatify Diagnostic` enabled.
```
