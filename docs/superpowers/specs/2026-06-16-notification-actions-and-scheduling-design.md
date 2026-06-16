# Notification Actions And Scheduling Repair Design

## Goal
Fix the remaining notification issues and harden mosque map actions without changing the broader product flow.

Current confirmed behavior:
- Android 13+: immediate test notification can appear, but real prayer-time scheduled notifications do not appear after waiting for the actual prayer time.
- Android and iOS: Settings notification buttons can feel like no-ops because taps do not always produce visible feedback.
- Mosque `Lihat Peta` and `Rute` currently work, but should fail visibly if a device cannot open the map URL.

## Scope
In scope:
- Make Settings notification actions observable on Android and iOS.
- Add diagnostics that distinguish immediate notifications, near-future scheduled notifications, and real prayer schedule notifications.
- Improve scheduling observability so failures are visible in logs/status instead of hidden.
- Add minimal mosque map-launch hardening with snackbar/log fallback.
- Add automated tests and manual QA steps for Android and iOS.

Out of scope:
- Redesigning Settings or Mosque screens.
- Adding a new map SDK or map dependency.
- Rewriting the notification scheduler architecture wholesale.
- Changing prayer calculation behavior unless evidence shows bad schedule input.

## Architecture
`NotificationService` remains the boundary around `flutter_local_notifications` platform APIs. It owns immediate notification, scheduled notification, permission checks, pending request inspection, and new scheduled diagnostic test behavior.

`NotificationSchedulerNotifier` remains responsible for building real prayer notification requests from prayer-time data. It should become more observable by logging and exposing enough state to verify what was scheduled.

`SettingsScreen` remains the user-facing diagnostics surface. It should render simple status text and buttons that always provide feedback after a tap.

`NearbyMosqueScreen` keeps its existing external map URL flow. It only gets defensive launch handling so a failed launch shows a snackbar instead of silently doing nothing.

## Notification UX Requirements
Settings notification actions must be cross-platform observable:
- Tapping `Kirim notifikasi uji` shows a loading state briefly and then a success or failure snackbar.
- Tapping the permission/check action never feels disabled without explanation.
- If notifications are already active, the permission/check action refreshes readiness and shows `Notifikasi sudah aktif.`
- If permission is missing, the action requests permission and shows whether the status became active or still needs attention.
- If the platform call fails, the UI shows a failure snackbar and logs with `debugPrint`.

The section should include light diagnostics:
- Current readiness title/message.
- Pending scheduled notification count when available.
- Last action/status text such as `Tes terkirim`, `Jadwal uji tersimpan`, or `Belum ada jadwal aktif`.

## Scheduling Requirements
The app must separate three notification paths:
1. Immediate notification via `show`.
2. Near-future scheduled diagnostic notification via `zonedSchedule`.
3. Real prayer schedule notification via built prayer requests.

Scheduling must be observable:
- Log readiness before scheduling.
- Log request count built from prayer data.
- Log each prayer key, notification ID, target timestamp, and whether it is future/past.
- Log Android schedule mode (`exactAllowWhileIdle` or `inexactAllowWhileIdle`).
- Log pending scheduled notification IDs/count after scheduling.
- Only mark a prayer notification as scheduled after `zonedSchedule` completes successfully.

Android behavior:
- Check `POST_NOTIFICATIONS` state before scheduling.
- Request exact alarm permission when needed, but keep fallback to inexact scheduling if denied.
- Keep manifest on the General/Play-Store-safe path with `SCHEDULE_EXACT_ALARM` rather than `USE_EXACT_ALARM`.

iOS behavior:
- Permission check/request must produce visible UI feedback.
- Scheduled diagnostic notification should use the same channel/details path as prayer scheduling where applicable.

## Mosque Requirements
The mosque map buttons should keep the current external URL behavior:
- `Lihat Peta` opens a search URL for the mosque coordinates.
- `Rute` opens a directions URL for the mosque coordinates.

Hardening:
- Prefer attempting `launchUrl()` and checking its returned bool instead of relying only on `canLaunchUrl()`, because `canLaunchUrl()` can false-negative on some devices.
- If launch fails, show `Tidak dapat membuka aplikasi peta.`
- Log launch failures with `debugPrint`.

## Testing Plan
Automated tests:
- `NotificationService` immediate test still sends `show`.
- `NotificationService` scheduled diagnostic test sends `zonedSchedule` with a future timestamp.
- Readiness and pending count methods remain covered.
- Settings smoke/widget test verifies the notification section and action buttons render.
- Mosque screen smoke test verifies `Lihat Peta` and `Rute` buttons render.
- If launcher logic is extracted, add unit coverage for launch failure returning user-visible failure.

Manual QA:
- Android 13+:
  - Grant notification permission.
  - Tap `Kirim notifikasi uji`; verify snackbar and visible notification.
  - Trigger near-future scheduled diagnostic notification; verify it appears.
  - Wait for real prayer time or use near-future test data; verify prayer notification appears.
  - Verify Settings pending count/status updates.
- iOS:
  - Grant notification permission.
  - Repeat immediate and near-future scheduled notification checks.
  - Verify Settings buttons always show feedback.
- Mosque on Android and iOS:
  - Tap `Lihat Peta`; verify map/browser opens.
  - Tap `Rute`; verify directions opens.
  - If map launch cannot complete, verify snackbar appears instead of a silent no-op.

## Risks
- Scheduled notification behavior can differ by OEM battery policy on Android. The fix should make failures observable, but device-level battery restrictions may still require manual QA.
- Exact alarm permission denial can make timing less precise; fallback remains intentional.
- iOS notification delivery depends on simulator/device settings and foreground presentation behavior.

## Success Criteria
- Android and iOS Settings notification actions always provide visible feedback after tap.
- Immediate and near-future scheduled diagnostic notification paths both work in QA.
- Real prayer notifications are either delivered or produce clear diagnostic evidence explaining why not.
- Mosque map buttons keep working and no longer fail silently if launch is unavailable.
- `flutter test`, `flutter analyze`, Android build QA, and iOS build QA pass.
