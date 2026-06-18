# Notification Domain Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract notification scheduling planning into domain entities/services while preserving existing behavior.

**Architecture:** Pure planning logic moves from the Riverpod notifier into domain-layer files. The presentation provider imports and delegates to the planner, while `NotificationService` remains the platform adapter for actual local/native notification calls.

**Tech Stack:** Flutter, Dart, Riverpod, existing notification scheduling tests.

---

### Task 1: Domain Entities

**Files:**
- Create: `lib/features/notifications/domain/entities/prayer_notification_request.dart`
- Create: `lib/features/notifications/domain/entities/notification_schedule_plan.dart`
- Modify: `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`
- Test: `test/notification_scheduler_test.dart`

- [ ] **Step 1: Move request entity**

Move `PrayerNotificationRequest` unchanged into the domain entity file.

- [ ] **Step 2: Move schedule plan entity**

Move `NotificationSchedulePlan` unchanged into the domain entity file.

- [ ] **Step 3: Update provider imports**

Remove entity declarations from provider and import the domain entities.

### Task 2: Domain Planner Service

**Files:**
- Create: `lib/features/notifications/domain/services/prayer_notification_planner.dart`
- Modify: `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`
- Test: `test/notification_scheduler_test.dart`

- [ ] **Step 1: Move request key function**

Move `buildPrayerNotificationRequestKey` into the planner service.

- [ ] **Step 2: Move request builder**

Move `buildPrayerNotificationRequests` and private helper logic into the planner service.

- [ ] **Step 3: Move diff planner**

Move `buildNotificationSchedulePlan` into the planner service.

- [ ] **Step 4: Update provider**

Provider calls planner functions from the domain service with no behavior changes.

### Task 3: Tests, Docs, Validation

**Files:**
- Modify: `test/notification_scheduler_test.dart`
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update imports and source assertions**

Tests import domain entities/services directly and assert provider delegates to planner.

- [ ] **Step 2: Update README**

Mention the notification domain planner in architecture notes.

- [ ] **Step 3: Format code**

Run `dart format` on changed Dart/test files.

- [ ] **Step 4: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 5: Commit and push**

Commit as `Extract notification scheduling domain planner` and push current branch.
