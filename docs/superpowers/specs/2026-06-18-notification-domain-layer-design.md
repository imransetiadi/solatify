# Notification Domain Layer Design

## Goal
Separate notification scheduling planning from Riverpod presentation code so Solatify's adzan notification flow is easier to test, maintain, and extend.

## Scope
Phase 7 focuses on extracting pure planning logic and schedule-plan entities from `notification_scheduler_provider.dart`. Platform scheduling remains in `NotificationService`, and native Android sound-mode propagation is deferred unless it is a small follow-up.

## User Experience
- No visible UX changes are expected.
- Existing Notification v2 controls, reminders, per-prayer toggles, sound mode, health center, and post-permission refresh behavior must keep working.

## Architecture
- Create notification domain entities for `PrayerNotificationRequest` and `NotificationSchedulePlan`.
- Create `PrayerNotificationPlanner` as a pure domain service for request generation, request keys, and schedule diffing.
- Keep `NotificationSchedulerNotifier` responsible for orchestration only: read providers/settings, call planner, call platform adapter, update state/history.
- Tests move planner assertions to domain imports rather than presentation-provider internals.

## Validation
- Update existing notification scheduler tests to cover the domain planner directly.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Native Android sound-mode payload plumbing for the Kotlin alarm receiver.
- Full use-case class wrapping platform scheduling side effects.
- Notification delivery history callbacks from native/platform notification taps.
