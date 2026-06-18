# Android Native Notification Sound Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pass sound mode and reminder metadata into Android native prayer alarms and make the native receiver honor them.

**Architecture:** Flutter remains the source of scheduling intent. Native Android stores the extra payload in `PendingIntent`; `PrayerAlarmReceiver` maps that payload to notification channels and message copy.

**Tech Stack:** Flutter, Dart MethodChannel, Kotlin Android BroadcastReceiver, Android NotificationChannel.

---

### Task 1: Flutter Payload

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Extend native scheduler signature**

Add `soundMode` and `isReminder` parameters to `scheduleAndroidPrayerAlarm`.

- [ ] **Step 2: Forward payload**

Include `soundMode` and `isReminder` in `_androidPrayerAlarmChannel.invokeMethod('schedulePrayerAlarm', ...)`.

- [ ] **Step 3: Pass from schedulePrayerNotification**

When native Android path is used, pass existing `soundMode` and `isReminder` values through.

### Task 2: Android Native Receiver

**Files:**
- Modify: `android/app/src/main/kotlin/com/solatify/app/solatify/MainActivity.kt`
- Modify: `android/app/src/main/kotlin/com/solatify/app/solatify/notifications/PrayerAlarmReceiver.kt`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Persist extras**

Add `EXTRA_SOUND_MODE` and `EXTRA_IS_REMINDER` to the scheduled alarm intent.

- [ ] **Step 2: Add native channels**

Add adhan, beep, and silent channel constants matching Flutter channel IDs.

- [ ] **Step 3: Select channel and content**

Use sound mode/reminder values to choose channel, sound behavior, title, and body.

### Task 3: Docs And Validation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention native Android honors adhan/beep/silent sound modes.

- [ ] **Step 2: Format code**

Run `dart format` on Dart/test files and rely on existing Kotlin style.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Honor Android native notification sound modes` and push current branch.
