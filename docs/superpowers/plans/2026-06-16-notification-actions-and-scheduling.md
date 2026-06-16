# Notification Actions And Scheduling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make notification actions and scheduled prayer notifications observable/reliable on Android and iOS, and harden mosque map launch failures.

**Architecture:** Keep platform notification behavior inside `NotificationService`, expose small diagnostic methods/value objects, and let `SettingsScreen` render user-facing feedback. Keep real prayer scheduling in `NotificationSchedulerNotifier`, but add explicit diagnostics and only mark requests scheduled after platform scheduling succeeds. Keep mosque map actions in `NearbyMosqueScreen` with a focused launch helper that attempts the launch and reports failures.

**Tech Stack:** Flutter, Riverpod, `flutter_local_notifications`, `url_launcher`, Flutter widget/unit tests, method-channel mocks.

---

## File Structure

- Modify `lib/features/notifications/data/services/notification_service.dart`
  - Add scheduled diagnostic notification support.
  - Add pending notification ID diagnostics.
  - Let schedule failures propagate to caller after logging.
- Modify `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`
  - Log readiness/request details before scheduling.
  - Log pending IDs/count after scheduling.
  - Keep marking requests scheduled only after successful `zonedSchedule`.
- Modify `lib/features/settings/presentation/screens/settings_screen.dart`
  - Add action loading state, visible snackbar feedback, pending count/status text, and scheduled diagnostic action.
  - Ensure permission/check action is not a silent disabled no-op.
- Modify `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart`
  - Add launch helper for map route/search actions.
  - Show snackbar and `debugPrint` when launch fails.
- Modify `test/notification_service_test.dart`
  - Cover scheduled diagnostic notification and pending IDs.
- Modify `test/routed_screen_smoke_test.dart`
  - Cover Settings diagnostic action text and Mosque map buttons render.
- Create `test/mosque_launch_test.dart` only if the launch helper is extracted into a top-level/testable pure function. Otherwise cover via smoke test and manual QA.
- Modify `docs/qa/release-signoff.md`
  - Add manual QA checks for immediate notification, scheduled diagnostic notification, real prayer notification, and map button failure fallback.

---

### Task 1: Add Notification Service Diagnostics

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Add failing tests for pending IDs and scheduled diagnostic notification**

Add these tests after `showTestNotification sends an immediate notification` in `test/notification_service_test.dart`:

```dart
  test('getPendingNotificationIds reports platform pending IDs', () async {
    final ids = await service.getPendingNotificationIds();

    expect(ids, [1, 2]);
    expect(capturedMethods.last.method, 'pendingNotificationRequests');
  });

  test('scheduleDiagnosticNotification schedules a near-future notification', () async {
    await service.init();

    final scheduledAt = DateTime.now().add(const Duration(minutes: 2));
    await service.scheduleDiagnosticNotification(scheduledAt: scheduledAt);

    final zonedSchedule = capturedMethods.lastWhere(
      (call) => call.method == 'zonedSchedule',
    );
    expect(zonedSchedule.arguments['id'], 9002);
    expect(zonedSchedule.arguments['title'], 'Tes Jadwal Notifikasi Solatify');
    expect(zonedSchedule.arguments['body'], contains('terjadwal'));
  });
```

- [ ] **Step 2: Run the failing service tests**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: fails because `getPendingNotificationIds()` and `scheduleDiagnosticNotification()` do not exist.

- [ ] **Step 3: Add pending ID diagnostics method**

Add this method below `getPendingNotificationsCount()` in `lib/features/notifications/data/services/notification_service.dart`:

```dart
  Future<List<int>> getPendingNotificationIds() async {
    try {
      final pendingNotifications = await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      final ids = pendingNotifications.map((request) => request.id).toList();

      debugPrint('Pending scheduled notification IDs: $ids');
      return ids;
    } catch (e) {
      debugPrint('Error retrieving pending notification IDs: $e');
      return const [];
    }
  }
```

- [ ] **Step 4: Add scheduled diagnostic notification method**

Add this method before `cancelNotification()` in `lib/features/notifications/data/services/notification_service.dart`:

```dart
  Future<void> scheduleDiagnosticNotification({DateTime? scheduledAt}) async {
    try {
      await _ensureInitialized();

      final targetTime = scheduledAt ?? DateTime.now().add(const Duration(minutes: 2));

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'prayer_times_adhan_channel_v1',
        'Prayer Times Adhan',
        channelDescription: 'Adhan notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan'),
        enableLights: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledDate = tz.TZDateTime.from(targetTime, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        9002,
        'Tes Jadwal Notifikasi Solatify',
        'Jika notifikasi terjadwal ini muncul, jadwal pengingat siap digunakan.',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: _androidScheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled_test_notification',
      );
      debugPrint('Diagnostic scheduled notification set for $targetTime');
    } catch (e, stack) {
      debugPrint('Error scheduling diagnostic notification: $e\n$stack');
      rethrow;
    }
  }
```

- [ ] **Step 5: Let schedulePrayerNotification failures propagate**

In `schedulePrayerNotification()`, replace the catch block:

```dart
    } catch (e, stack) {
      debugPrint('Error scheduling prayer notification: $e\n$stack');
    }
```

with:

```dart
    } catch (e, stack) {
      debugPrint('Error scheduling prayer notification: $e\n$stack');
      rethrow;
    }
```

- [ ] **Step 6: Run service tests**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: all notification service tests pass.

- [ ] **Step 7: Commit Task 1**

Run:

```bash
git add lib/features/notifications/data/services/notification_service.dart test/notification_service_test.dart
git commit -m "feat: add notification scheduling diagnostics"
```

---

### Task 2: Make Prayer Scheduling Observable

**Files:**
- Modify: `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`

- [ ] **Step 1: Add diagnostic logging around built requests**

In `scheduleNotifications()`, immediately after `final requests = buildPrayerNotificationRequests(...)`, add:

```dart
      debugPrint('Prayer notification request count: ${requests.length}');
      for (final request in requests) {
        debugPrint(
          'Prayer notification request: prayer=${request.prayerKey}, '
          'id=${request.notificationId}, target=${request.prayerTime.toIso8601String()}, '
          'isFuture=${request.prayerTime.isAfter(now)}',
        );
      }
```

- [ ] **Step 2: Log pending IDs after scheduling**

Replace this existing line near the end of `scheduleNotifications()`:

```dart
      await NotificationService().getPendingNotificationsCount();
```

with:

```dart
      final pendingIds = await NotificationService().getPendingNotificationIds();
      debugPrint('Pending prayer notification IDs after scheduling: $pendingIds');
```

- [ ] **Step 3: Add readiness logging before scheduling**

Before the `for (final request in requests)` loop, add:

```dart
      final readiness = await NotificationService().getReadinessStatus();
      debugPrint(
        'Notification readiness before prayer scheduling: '
        '${readiness.status.name} - ${readiness.title}',
      );
```

- [ ] **Step 4: Verify scheduler still compiles**

Run:

```bash
flutter analyze lib/features/notifications/presentation/providers/notification_scheduler_provider.dart
```

Expected: no issues found.

- [ ] **Step 5: Run related tests**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit Task 2**

Run:

```bash
git add lib/features/notifications/presentation/providers/notification_scheduler_provider.dart
git commit -m "fix: add prayer notification scheduling diagnostics"
```

---

### Task 3: Make Settings Notification Buttons Observable

**Files:**
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add failing smoke assertions for diagnostic UI**

In `test/routed_screen_smoke_test.dart`, inside `Settings screen renders`, add these assertions after the existing `Kirim notifikasi uji` assertion:

```dart
    expect(find.text('Jadwalkan tes 2 menit'), findsOneWidget);
    expect(find.textContaining('Belum ada status aksi'), findsOneWidget);
```

- [ ] **Step 2: Run the failing smoke test**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
```

Expected: fails because scheduled diagnostic button/status text do not exist yet.

- [ ] **Step 3: Add Settings state fields**

Inside `_SettingsScreenState`, after `_notificationReadiness`, add:

```dart
  final ValueNotifier<String> _notificationActionStatus =
      ValueNotifier<String>('Belum ada status aksi.');
  final ValueNotifier<int> _pendingNotificationCount = ValueNotifier<int>(0);
  bool _isNotificationActionRunning = false;
```

Update `dispose()` to dispose the new notifiers:

```dart
    _notificationActionStatus.dispose();
    _pendingNotificationCount.dispose();
```

- [ ] **Step 4: Refresh pending count with readiness**

At the end of `_refreshNotificationReadiness()`, after setting `_notificationReadiness.value`, add:

```dart
    _pendingNotificationCount.value =
        await _notificationService.getPendingNotificationsCount();
```

Keep the existing `if (!mounted) return;` guard before writing notifiers.

- [ ] **Step 5: Add action runner helper**

Add this method inside `_SettingsScreenState` before `_requestNotificationPermissions()`:

```dart
  Future<void> _runNotificationAction(Future<void> Function() action) async {
    if (_isNotificationActionRunning) return;

    setState(() {
      _isNotificationActionRunning = true;
    });

    try {
      await action();
    } finally {
      if (!mounted) return;
      setState(() {
        _isNotificationActionRunning = false;
      });
    }
  }
```

- [ ] **Step 6: Update permission action to always give feedback**

Replace `_requestNotificationPermissions()` with:

```dart
  Future<void> _requestNotificationPermissions() async {
    await _runNotificationAction(() async {
      try {
        final before = _notificationReadiness.value;
        await _notificationService.requestAndroidPermissions();
        await _refreshNotificationReadiness();
        final after = _notificationReadiness.value;

        final message = after.status == NotificationReadinessStatus.ready
            ? 'Notifikasi sudah aktif.'
            : after.title;
        _notificationActionStatus.value = message;

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        debugPrint(
          'Notification permission action: before=${before.status.name}, after=${after.status.name}',
        );
      } catch (e) {
        debugPrint('Error requesting notification permissions: $e');
        _notificationActionStatus.value =
            'Izin notifikasi belum dapat diperbarui.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi belum dapat diperbarui.'),
          ),
        );
      }
    });
  }
```

- [ ] **Step 7: Update immediate test action to always give feedback**

Replace `_sendTestNotification()` with:

```dart
  Future<void> _sendTestNotification() async {
    await _runNotificationAction(() async {
      try {
        await _notificationService.showTestNotification();
        _notificationActionStatus.value = 'Tes terkirim.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi uji dikirim.')),
        );
        await _refreshNotificationReadiness();
      } catch (e) {
        debugPrint('Error sending test notification from settings: $e');
        _notificationActionStatus.value =
            'Notifikasi uji belum dapat dikirim.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi uji belum dapat dikirim.')),
        );
      }
    });
  }
```

- [ ] **Step 8: Add scheduled diagnostic action**

Add this method after `_sendTestNotification()`:

```dart
  Future<void> _scheduleDiagnosticNotification() async {
    await _runNotificationAction(() async {
      try {
        final scheduledAt = DateTime.now().add(const Duration(minutes: 2));
        await _notificationService.scheduleDiagnosticNotification(
          scheduledAt: scheduledAt,
        );
        await _refreshNotificationReadiness();
        _notificationActionStatus.value =
            'Jadwal uji tersimpan untuk ${TimeOfDay.fromDateTime(scheduledAt).format(context)}.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi terjadwal untuk 2 menit lagi.')),
        );
      } catch (e) {
        debugPrint('Error scheduling diagnostic notification from settings: $e');
        _notificationActionStatus.value =
            'Jadwal uji belum dapat disimpan.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal uji belum dapat disimpan.')),
        );
      }
    });
  }
```

- [ ] **Step 9: Update notification section UI**

In `_buildNotificationSection()`, replace the current two-button `Row` and preceding `Divider` with this block:

```dart
          Divider(color: dividerColor, height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _pendingNotificationCount,
            builder: (context, pendingCount, _) {
              return ValueListenableBuilder<String>(
                valueListenable: _notificationActionStatus,
                builder: (context, actionStatus, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Status aksi',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                    subtitle: Text(
                      '$actionStatus Pending: $pendingCount',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  );
                },
              );
            },
          ),
          Divider(color: dividerColor, height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isNotificationActionRunning
                      ? null
                      : _requestNotificationPermissions,
                  child: Text(
                    readiness.needsPermissionAction
                        ? 'Aktifkan izin notifikasi'
                        : 'Periksa izin notifikasi',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isNotificationActionRunning
                      ? null
                      : _sendTestNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kirim notifikasi uji'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isNotificationActionRunning
                  ? null
                  : _scheduleDiagnosticNotification,
              icon: const Icon(Icons.schedule, size: 17),
              label: const Text('Jadwalkan tes 2 menit'),
            ),
          ),
```

- [ ] **Step 10: Run Settings smoke test**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
```

Expected: all smoke tests pass.

- [ ] **Step 11: Run analyzer on Settings**

Run:

```bash
flutter analyze lib/features/settings/presentation/screens/settings_screen.dart test/routed_screen_smoke_test.dart
```

Expected: no issues found.

- [ ] **Step 12: Commit Task 3**

Run:

```bash
git add lib/features/settings/presentation/screens/settings_screen.dart test/routed_screen_smoke_test.dart
git commit -m "fix: make notification settings actions observable"
```

---

### Task 4: Harden Mosque Map Launch Actions

**Files:**
- Modify: `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add smoke assertions for map action buttons**

In `test/routed_screen_smoke_test.dart`, inside `Mosque screen renders`, add these assertions after `Peta Area`:

```dart
    expect(find.text('Lihat Peta'), findsWidgets);
    expect(find.text('Rute'), findsWidgets);
```

- [ ] **Step 2: Run the mosque smoke test**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
```

Expected: passes if cards are present in fixture state, or fails if the app only shows loading/error during smoke. If it fails because no mosque card is available, keep this test limited to `Peta Area` and validate button behavior manually in QA.

- [ ] **Step 3: Add launch helper**

Replace `_openInMap()` and `_openRoute()` in `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart` with:

```dart
  Future<void> _launchMapUri(Uri uri) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;

      debugPrint('Map launch returned false for $uri');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
      );
    } catch (e) {
      debugPrint('Error launching map URL $uri: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
      );
    }
  }

  Future<void> _openInMap(MosqueItem mosque) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${mosque.latitude},${mosque.longitude}',
    });
    await _launchMapUri(uri);
  }

  Future<void> _openRoute(MosqueItem mosque) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${mosque.latitude},${mosque.longitude}',
    });
    await _launchMapUri(uri);
  }
```

- [ ] **Step 4: Remove unused canLaunchUrl import usage**

Keep `import 'package:url_launcher/url_launcher.dart';` because `launchUrl`, `LaunchMode`, and `Uri` usage remain needed. Do not import anything else.

- [ ] **Step 5: Run mosque smoke and analyzer**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
flutter analyze lib/features/mosque/presentation/screens/nearby_mosque_screen.dart test/routed_screen_smoke_test.dart
```

Expected: tests pass and analyzer has no issues.

- [ ] **Step 6: Commit Task 4**

Run:

```bash
git add lib/features/mosque/presentation/screens/nearby_mosque_screen.dart test/routed_screen_smoke_test.dart
git commit -m "fix: show map launch failures"
```

---

### Task 5: Update QA Documentation

**Files:**
- Modify: `docs/qa/release-signoff.md`

- [ ] **Step 1: Add notification diagnostic QA checks**

In `docs/qa/release-signoff.md`, under `## Notification UX Checks`, add:

```markdown
- [ ] Android: `Kirim notifikasi uji` shows snackbar and visible notification
- [ ] Android: `Jadwalkan tes 2 menit` shows snackbar and delivers after roughly 2 minutes
- [ ] Android: next real prayer notification delivery verified or diagnostic logs captured
- [ ] iOS: `Kirim notifikasi uji` shows snackbar and visible notification
- [ ] iOS: `Jadwalkan tes 2 menit` shows snackbar and delivers after roughly 2 minutes
- [ ] iOS: Settings notification buttons never fail silently after tap
```

- [ ] **Step 2: Add mosque map QA checks**

Under `## Android Verification`, add:

```markdown
- [ ] Mosque `Lihat Peta` opens map/browser or shows failure snackbar
- [ ] Mosque `Rute` opens directions or shows failure snackbar
```

Under `## iOS Verification`, add:

```markdown
- [ ] Mosque `Lihat Peta` opens map/browser or shows failure snackbar
- [ ] Mosque `Rute` opens directions or shows failure snackbar
```

- [ ] **Step 3: Commit Task 5**

Run:

```bash
git add docs/qa/release-signoff.md
git commit -m "docs: add notification and mosque action QA checks"
```

---

### Task 6: Final Verification And PR Update

**Files:**
- No source files modified unless verification reveals a bug.

- [ ] **Step 1: Run targeted tests**

Run:

```bash
flutter test test/notification_service_test.dart test/routed_screen_smoke_test.dart test/mosque_search_test.dart
```

Expected: all tests pass.

- [ ] **Step 2: Run full unit/widget suite**

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

- [ ] **Step 6: Revert unrelated build artifacts**

Run:

```bash
git status --short
```

If `ios/Podfile.lock` changed only because the iOS build registered `integration_test`, run:

```bash
git checkout -- ios/Podfile.lock
```

If generated build directories appear untracked, remove only known generated artifacts such as:

```bash
rm -rf android/.kotlin/
```

- [ ] **Step 7: Push branch**

Run:

```bash
git push
```

Expected: branch pushes successfully and PR #8 updates.

- [ ] **Step 8: Report QA evidence**

Report:

```markdown
- `flutter test` result
- `flutter analyze` result
- `flutter build apk --debug` result
- `flutter build ios --no-codesign` result
- PR URL: https://github.com/imransetiadi/solatify/pull/8
- Manual QA still required on physical/emulated Android 13+ and iOS devices for actual notification delivery timing.
```
