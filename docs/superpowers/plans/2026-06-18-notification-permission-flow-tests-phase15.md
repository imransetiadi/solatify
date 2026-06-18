# Notification Permission Flow Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add lifecycle-based notification permission verification and tests for iOS/Android permission recovery flow.

**Architecture:** Use Flutter lifecycle callbacks in presentation screens to trigger existing notification domain/provider methods. Keep OS-specific permission APIs inside `NotificationService` and keep tests deterministic through source guards and widget smoke tests.

**Tech Stack:** Flutter, Riverpod, flutter_local_notifications, existing notification scheduler provider.

---

### Task 1: Lifecycle Permission Verification

**Files:**
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Modify: `lib/features/settings/presentation/screens/notification_health_screen.dart`

- [ ] **Step 1: Add WidgetsBindingObserver**

Register observer in `initState`, remove in `dispose`, and handle `AppLifecycleState.resumed`.

- [ ] **Step 2: Reschedule after permission return**

When settings show adhan enabled and notifications are allowed, call `refreshSchedules(force: true)` after resume.

- [ ] **Step 3: Cancel when permission is denied**

When permission is denied, sync adhan setting off and cancel notifications.

### Task 2: Permission Flow Tests

**Files:**
- Modify: `test/routed_screen_smoke_test.dart`
- Modify: `test/notification_service_test.dart`

- [ ] **Step 1: Add lifecycle source guards**

Assert Settings and Notification Health use `WidgetsBindingObserver`, add/remove observer, and handle `AppLifecycleState.resumed`.

- [ ] **Step 2: Add platform flow source guards**

Assert iOS request permission, Android exact alarm/settings shortcuts, post-permission verification, and forced reschedule hooks remain wired.

### Task 3: Docs And Validation

**Files:**
- Modify: `docs/qa/runbook.md`
- Modify: `README.md`

- [ ] **Step 1: Update QA runbook**

Mention returning from system notification/exact alarm settings must trigger auto verification/reschedule.

- [ ] **Step 2: Update README count**

Mention lifecycle verification and update test count.

- [ ] **Step 3: Verify and publish**

Run `dart format`, `flutter analyze`, `flutter test`, then commit and push.
