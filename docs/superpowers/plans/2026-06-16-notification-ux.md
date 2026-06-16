# Notification UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a compact user-facing notification readiness and test-notification section to Settings.

**Architecture:** Keep plugin-specific notification checks inside `NotificationService`, expose a small `NotificationReadiness` value object, and let `SettingsScreen` render simple user-facing rows from that state. The UI stays inside the existing Settings screen and uses the existing `GlassContainer`/`ListTile` style.

**Tech Stack:** Flutter, Riverpod, `flutter_local_notifications`, Flutter widget tests, method-channel mocks.

---

## File Structure

- Modify `lib/features/notifications/data/services/notification_service.dart`: add readiness model, readiness checks, test notification method, and permission-state helpers.
- Modify `lib/features/settings/presentation/screens/settings_screen.dart`: add `Notifikasi` section with readiness status, permission action, and test action.
- Modify `test/notification_service_test.dart`: add method-channel mock coverage for readiness and test notification behavior.
- Modify `test/routed_screen_smoke_test.dart`: assert Settings renders the notification section.

---

### Task 1: Add Notification Readiness Model And Tests

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Add failing readiness tests**

Add these tests to `test/notification_service_test.dart` after the existing pending-count test:

```dart
  test('reports ready readiness when permissions are available', () async {
    final readiness = NotificationReadiness.ready();

    expect(readiness.status, NotificationReadinessStatus.ready);
    expect(readiness.title, 'Notifikasi aktif');
    expect(readiness.needsPermissionAction, isFalse);
    expect(readiness.canSendTestNotification, isTrue);
  });

  test('reports notification permission action when permission is denied', () async {
    final readiness = NotificationReadiness.needsNotificationPermission();

    expect(
      readiness.status,
      NotificationReadinessStatus.needsNotificationPermission,
    );
    expect(readiness.title, 'Perlu izin notifikasi');
    expect(readiness.needsPermissionAction, isTrue);
    expect(readiness.canSendTestNotification, isFalse);
  });

  test('reports less precise schedule when exact alarms are unavailable', () async {
    final readiness = NotificationReadiness.inexactScheduling();

    expect(readiness.status, NotificationReadinessStatus.inexactScheduling);
    expect(readiness.title, 'Jadwal mungkin tidak tepat');
    expect(readiness.needsPermissionAction, isTrue);
    expect(readiness.canSendTestNotification, isTrue);
  });
```

- [ ] **Step 2: Run readiness tests and confirm failure**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: fails because `NotificationReadiness` and `NotificationReadinessStatus` do not exist.

- [ ] **Step 3: Add readiness value type**

Add this code above `class NotificationService` in `lib/features/notifications/data/services/notification_service.dart`:

```dart
enum NotificationReadinessStatus {
  ready,
  needsNotificationPermission,
  inexactScheduling,
  unknown,
}

class NotificationReadiness {
  const NotificationReadiness({
    required this.status,
    required this.title,
    required this.message,
    required this.needsPermissionAction,
    required this.canSendTestNotification,
  });

  factory NotificationReadiness.ready() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.ready,
      title: 'Notifikasi aktif',
      message: 'Pengingat waktu salat siap digunakan.',
      needsPermissionAction: false,
      canSendTestNotification: true,
    );
  }

  factory NotificationReadiness.needsNotificationPermission() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.needsNotificationPermission,
      title: 'Perlu izin notifikasi',
      message: 'Aktifkan izin agar pengingat waktu salat dapat muncul.',
      needsPermissionAction: true,
      canSendTestNotification: false,
    );
  }

  factory NotificationReadiness.inexactScheduling() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.inexactScheduling,
      title: 'Jadwal mungkin tidak tepat',
      message: 'Aktifkan alarm tepat waktu agar pengingat lebih akurat.',
      needsPermissionAction: true,
      canSendTestNotification: true,
    );
  }

  factory NotificationReadiness.unknown() {
    return const NotificationReadiness(
      status: NotificationReadinessStatus.unknown,
      title: 'Periksa izin notifikasi',
      message: 'Status notifikasi belum dapat dipastikan.',
      needsPermissionAction: true,
      canSendTestNotification: false,
    );
  }

  final NotificationReadinessStatus status;
  final String title;
  final String message;
  final bool needsPermissionAction;
  final bool canSendTestNotification;
}
```

- [ ] **Step 4: Run readiness tests and confirm pass**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: all tests in `test/notification_service_test.dart` pass.

- [ ] **Step 5: Commit Task 1**

Run:

```bash
git add lib/features/notifications/data/services/notification_service.dart test/notification_service_test.dart
git commit -m "feat: add notification readiness model"
```

---

### Task 2: Add Service Methods For Readiness And Test Notification

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Add failing service behavior tests**

Extend the method-channel handler in `test/notification_service_test.dart` with these cases:

```dart
            case 'areNotificationsEnabled':
              return true;
            case 'show':
              return null;
```

Add these tests after the readiness model tests:

```dart
  test('getReadinessStatus returns inexact scheduling when exact alarm is denied', () async {
    await service.init();

    final readiness = await service.getReadinessStatus();

    expect(readiness.status, NotificationReadinessStatus.inexactScheduling);
    expect(readiness.title, 'Jadwal mungkin tidak tepat');
  });

  test('showTestNotification sends an immediate notification', () async {
    await service.init();

    await service.showTestNotification();

    final showCall = capturedMethods.lastWhere((call) => call.method == 'show');
    expect(showCall.arguments['id'], 9001);
    expect(showCall.arguments['title'], 'Tes Notifikasi Solatify');
  });
```

- [ ] **Step 2: Run tests and confirm failure**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: fails because `getReadinessStatus()` and `showTestNotification()` do not exist.

- [ ] **Step 3: Add notification permission helper**

Add this private helper inside `NotificationService`, after `requestAndroidPermissions()`:

```dart
  Future<bool> _areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.areNotificationsEnabled() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final permissions = await iosImplementation?.checkPermissions();
      return permissions?.isEnabled ?? true;
    }

    return true;
  }
```

- [ ] **Step 4: Add readiness and test notification methods**

Add these public methods before `cancelNotification()` in `NotificationService`:

```dart
  Future<NotificationReadiness> getReadinessStatus() async {
    try {
      await _ensureInitialized();
      final notificationsEnabled = await _areNotificationsEnabled();

      if (!notificationsEnabled) {
        return NotificationReadiness.needsNotificationPermission();
      }

      if (defaultTargetPlatform == TargetPlatform.android && !_canUseExactAlarms) {
        return NotificationReadiness.inexactScheduling();
      }

      return NotificationReadiness.ready();
    } catch (e) {
      debugPrint('Error checking notification readiness: $e');
      return NotificationReadiness.unknown();
    }
  }

  Future<void> showTestNotification() async {
    await showPrayerNotification(
      prayerKey: 'subuh',
      location: 'Solatify',
      prayerTime: 'sekarang',
      notificationId: 9001,
    );
  }
```

- [ ] **Step 5: Run service tests and confirm pass**

Run:

```bash
flutter test test/notification_service_test.dart
```

Expected: all tests in `test/notification_service_test.dart` pass.

- [ ] **Step 6: Commit Task 2**

Run:

```bash
git add lib/features/notifications/data/services/notification_service.dart test/notification_service_test.dart
git commit -m "feat: expose notification readiness and test action"
```

---

### Task 3: Add Notifications Section To Settings

**Files:**
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add failing Settings smoke assertion**

In `test/routed_screen_smoke_test.dart`, extend `Settings screen renders` with:

```dart
    expect(find.text('NOTIFIKASI'), findsOneWidget);
    expect(find.text('Kirim notifikasi uji'), findsOneWidget);
```

- [ ] **Step 2: Run the Settings smoke test and confirm failure**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
```

Expected: fails because the `NOTIFIKASI` section and test action do not exist.

- [ ] **Step 3: Import notification service in Settings**

Add this import to `lib/features/settings/presentation/screens/settings_screen.dart`:

```dart
import 'package:solatify/features/notifications/data/services/notification_service.dart';
```

- [ ] **Step 4: Convert Settings to stateful widget and add readiness state**

Replace the `SettingsScreen` class declaration in `lib/features/settings/presentation/screens/settings_screen.dart`:

```dart
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final ValueNotifier<NotificationReadiness> _notificationReadiness =
      ValueNotifier<NotificationReadiness>(NotificationReadiness.unknown());

  @override
  void initState() {
    super.initState();
    _refreshNotificationReadiness();
  }

  @override
  void dispose() {
    _notificationReadiness.dispose();
    super.dispose();
  }
```

Move the existing methods into `_SettingsScreenState`; their bodies do not change unless a later step explicitly changes them.

- [ ] **Step 5: Add Settings notification helpers**

Add these methods inside `_SettingsScreenState`, before `build()`:

```dart
  Future<void> _refreshNotificationReadiness() async {
    _notificationReadiness.value = await NotificationService().getReadinessStatus();
  }

  Future<void> _requestNotificationPermissions(BuildContext context) async {
    try {
      await NotificationService().requestAndroidPermissions();
      await _refreshNotificationReadiness();
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin notifikasi belum dapat diperbarui.')),
        );
      }
    }
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    try {
      await NotificationService().showTestNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi uji dikirim.')),
        );
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi uji belum dapat dikirim.')),
        );
      }
    }
  }
```

- [ ] **Step 6: Add notification section widget**

Add this method inside `_SettingsScreenState`, after `_buildSectionHeader()`:

```dart
  Widget _buildNotificationSection(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color textSecondary,
    Color dividerColor,
  ) {
    return ValueListenableBuilder<NotificationReadiness>(
      valueListenable: _notificationReadiness,
      builder: (context, readiness, _) {
        return GlassContainer(
          blur: 15,
          opacity: isDark ? 0.03 : 0.015,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  readiness.title,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
                subtitle: Text(
                  readiness.message,
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                leading: Icon(
                  readiness.status == NotificationReadinessStatus.ready
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (readiness.needsPermissionAction) ...[
                Divider(color: dividerColor, height: 16),
                ListTile(
                  title: Text(
                    'Aktifkan izin notifikasi',
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                  trailing: Icon(Icons.chevron_right, color: textSecondary),
                  onTap: () => _requestNotificationPermissions(context),
                ),
              ],
              Divider(color: dividerColor, height: 16),
              ListTile(
                title: Text(
                  'Kirim notifikasi uji',
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
                subtitle: Text(
                  'Pastikan suara dan tampilan notifikasi berjalan.',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                trailing: Icon(Icons.send_rounded, color: textSecondary),
                enabled: readiness.canSendTestNotification,
                onTap: readiness.canSendTestNotification
                    ? () => _sendTestNotification(context)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
```

- [ ] **Step 7: Insert section into Settings build**

Insert this UI block after the general settings `GlassContainer` and before `KOREKSI WAKTU SALAT`:

```dart
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'NOTIFIKASI'),
                  const SizedBox(height: 12),
                  _buildNotificationSection(
                    context,
                    isDark,
                    textColor,
                    textSecondary,
                    dividerColor,
                  ),
                  const SizedBox(height: 32),
```

- [ ] **Step 8: Run Settings smoke test**

Run:

```bash
flutter test test/routed_screen_smoke_test.dart
```

Expected: all tests pass and no `tester.takeException()` failures occur.

- [ ] **Step 9: Commit Task 3**

Run:

```bash
git add lib/features/settings/presentation/screens/settings_screen.dart test/routed_screen_smoke_test.dart
git commit -m "feat: add notification status to settings"
```

---

### Task 4: Add Final Verification

**Files:**
- Verify only; no required file changes.

- [ ] **Step 1: Run focused notification tests**

Run:

```bash
flutter test test/notification_service_test.dart test/routed_screen_smoke_test.dart
```

Expected: all tests pass.

- [ ] **Step 2: Run full test suite**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Run focused analyzer**

Run:

```bash
flutter analyze lib/features/notifications/data/services/notification_service.dart lib/features/settings/presentation/screens/settings_screen.dart test/notification_service_test.dart test/routed_screen_smoke_test.dart
```

Expected: no analyzer issues in the changed files.

- [ ] **Step 4: Document manual QA requirement in PR notes**

Add this manual verification note to the PR description or release signoff:

```markdown
- [ ] Open Settings on Android and iOS, confirm `Notifikasi` section renders.
- [ ] Tap `Kirim notifikasi uji`, confirm notification appears with sound.
- [ ] Deny notification permission and confirm Settings shows `Perlu izin notifikasi`.
- [ ] On Android 12+, deny exact alarms and confirm Settings shows `Jadwal mungkin tidak tepat`.
```

- [ ] **Step 5: Commit release-signoff update**

After adding the manual QA checks to `docs/qa/release-signoff.md`, run:

```bash
git add docs/qa/release-signoff.md
git commit -m "docs: add notification UX QA checks"
```

---

## Self-Review

- Spec coverage: Tasks cover readiness state, permission action, test notification action, Settings UI, user-facing language, hidden diagnostics, error handling, and tests.
- Red-flag scan: The plan contains no unfinished markers or open-ended implementation steps.
- Type consistency: `NotificationReadiness`, `NotificationReadinessStatus`, `getReadinessStatus()`, and `showTestNotification()` are defined before use in later tasks.
