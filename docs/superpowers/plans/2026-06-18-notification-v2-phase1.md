# Notification v2 Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first Notification v2 slice: per-prayer toggles, pre-prayer reminder requests, sound mode settings, post-permission reschedule, and schedule history basics.

**Architecture:** Extend existing settings and notification scheduler with focused pure functions first, then wire persistence and UI. Keep platform scheduling in `NotificationService`, request planning in `notification_scheduler_provider.dart`, and user options in `SettingsState`/Hive.

**Tech Stack:** Flutter, Riverpod, Hive settings, `flutter_local_notifications`, existing native Android alarm channel, Flutter widget/unit tests.

---

### Task 1: Notification Settings Model

**Files:**
- Modify: `lib/features/settings/domain/entities/settings_state.dart`
- Modify: `lib/features/settings/data/datasources/settings_local_data_source.dart`
- Modify: `lib/features/settings/domain/repositories/settings_repository.dart`
- Modify: `lib/features/settings/data/repositories/settings_repository_impl.dart`
- Modify: `lib/features/settings/presentation/providers/settings_provider.dart`
- Test: `test/notification_scheduler_test.dart`

- [ ] **Step 1: Write failing test**

Add assertions that default notification options are all prayers enabled, reminder disabled, and sound mode adhan.

- [ ] **Step 2: Run test**

Run: `flutter test test/notification_scheduler_test.dart`
Expected: FAIL because settings fields do not exist.

- [ ] **Step 3: Implement settings fields**

Add `enabledPrayerNotifications`, `preNotificationMinutes`, and `notificationSoundMode` to settings state, local data source, repository, and notifier.

- [ ] **Step 4: Run test**

Run: `flutter test test/notification_scheduler_test.dart`
Expected: PASS.

### Task 2: Scheduler Request Planning

**Files:**
- Modify: `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`
- Test: `test/notification_scheduler_test.dart`

- [ ] **Step 1: Write failing tests**

Add tests for filtering disabled prayer keys and adding reminder request 10 minutes before prayer with separate notification ID.

- [ ] **Step 2: Run test**

Run: `flutter test test/notification_scheduler_test.dart`
Expected: FAIL because request builder does not accept prayer toggles or reminder minutes.

- [ ] **Step 3: Implement request options**

Extend `PrayerNotificationRequest` with `isReminder`, add optional parameters to `buildPrayerNotificationRequests`, and wire notifier settings into request building.

- [ ] **Step 4: Run test**

Run: `flutter test test/notification_scheduler_test.dart`
Expected: PASS.

### Task 3: Sound Mode Scheduling

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Modify: `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Write failing tests**

Add tests that beep and silent modes use distinct channel/sound behavior from adhan.

- [ ] **Step 2: Run test**

Run: `flutter test test/notification_service_test.dart`
Expected: FAIL because sound mode is not accepted.

- [ ] **Step 3: Implement sound mode**

Add sound mode parameter to schedule/show prayer notification details. Use adhan channel for adhan, diagnostic/default channel for beep, and no sound for silent.

- [ ] **Step 4: Run test**

Run: `flutter test test/notification_service_test.dart`
Expected: PASS.

### Task 4: Settings UI and Post-Permission Reschedule

**Files:**
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Write failing widget/source tests**

Assert Settings exposes per-prayer notification labels, reminder options, and sound mode labels.

- [ ] **Step 2: Run tests**

Run: `flutter test test/routed_screen_smoke_test.dart`
Expected: FAIL because UI controls do not exist.

- [ ] **Step 3: Implement Settings controls**

Add compact controls under notification reliability/settings. Ensure iOS permission request path reschedules after permission success by calling `refreshSchedules(force: true)`.

- [ ] **Step 4: Run tests**

Run: `flutter test test/routed_screen_smoke_test.dart`
Expected: PASS.

### Task 5: Notification History Basics

**Files:**
- Create: `lib/features/notifications/domain/entities/notification_history_entry.dart`
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Write failing tests**

Assert successful scheduling records `lastScheduledAt/count` and failed scheduling records `lastFailedAt/reason` through a serializable history object.

- [ ] **Step 2: Run tests**

Run: `flutter test test/notification_service_test.dart`
Expected: FAIL because history object does not exist.

- [ ] **Step 3: Implement minimal history object and writes**

Persist a small JSON-like map in Hive settings via `HiveService.saveSetting` for schedule success/failure metadata.

- [ ] **Step 4: Run tests**

Run: `flutter test test/notification_service_test.dart`
Expected: PASS.

### Task 6: Final Validation

**Files:**
- Modify: `README.md` if user-facing behavior changes need documentation.

- [ ] **Step 1: Format**

Run: `dart format <changed dart files>`
Expected: files formatted.

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Full test**

Run: `flutter test`
Expected: all tests passed.
