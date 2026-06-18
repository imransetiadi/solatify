# Notification Health Center Design

## Goal
Build a dedicated Notification Health Center page reachable from Settings so users can verify Solatify notification readiness, inspect recent scheduling state, and trigger safe recovery actions.

## Scope
Phase 2 focuses on notification trust and debugging without changing the core scheduler algorithm from Phase 1.

## User Experience
- Settings shows a clear entry card/button: Notification Health Center.
- The detail page summarizes notification permission, exact alarm availability when detectable, pending scheduled notifications, and latest notification history.
- Users can refresh status, reschedule prayer notifications, send a diagnostic notification, and open system notification settings.
- Empty or unavailable data is shown with friendly copy instead of raw null values.

## Architecture
- Keep the page in `features/settings/presentation` because it is Settings-owned UX.
- Reuse existing `NotificationService` and `notificationSchedulerProvider` rather than introducing a new domain layer in this phase.
- Add small presentation helpers only if needed; avoid broad refactors.

## Validation
- Add widget/source smoke coverage for the Settings entry and the new screen labels/actions.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Full delivered-notification event log.
- Native Android sound-mode propagation for native alarm path.
- Deep mocked integration tests for iOS/Android permission panels.
