# Notification Health Center Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated Notification Health Center page from Settings with live status, history, and safe recovery actions.

**Architecture:** The feature stays in Settings presentation and consumes existing notification service/scheduler providers. It adds route/UI wiring and focused tests without changing core scheduling behavior.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, flutter_local_notifications, Hive-backed notification history.

---

### Task 1: Route And Settings Entry

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Create: `lib/features/settings/presentation/screens/notification_health_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add screen skeleton**

Create a `NotificationHealthScreen` using the existing responsive/background/card patterns and initial labels for title, summary, and actions.

- [ ] **Step 2: Add route constant/wiring**

Register a `/settings/notification-health` route and navigate to it from Settings.

- [ ] **Step 3: Add Settings entry**

Add a compact `GlassContainer` entry card in notification settings that opens the health page.

- [ ] **Step 4: Add smoke/source checks**

Assert source contains `NotificationHealthScreen`, health route, and Settings entry label.

### Task 2: Live Health Data And Actions

**Files:**
- Modify: `lib/features/settings/presentation/screens/notification_health_screen.dart`
- Modify: `lib/features/notifications/data/services/notification_service.dart` if an existing helper is missing
- Test: `test/notification_service_test.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Read notification state**

Load `areNotificationsEnabled`, exact alarm capability, pending notification IDs/count, and `NotificationHistoryEntry`.

- [ ] **Step 2: Add refresh and reschedule actions**

Provide buttons for refresh and forced `notificationSchedulerProvider.refreshSchedules(force: true)`.

- [ ] **Step 3: Add test notification action**

Call `NotificationService.scheduleDiagnosticNotification` or `showTestNotification` with feedback state.

- [ ] **Step 4: Add system settings action**

Use existing app settings helper if available, or `openAppNotificationSettings` in `NotificationService` if already exposed.

### Task 3: Validation And Documentation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention Notification Health Center under notification notes.

- [ ] **Step 2: Format code**

Run `dart format` on changed Dart files.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Add notification health center` and push current branch.
