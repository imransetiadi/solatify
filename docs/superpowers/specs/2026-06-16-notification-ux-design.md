# Notification UX Design

## Goal
Give users a simple way to understand whether prayer notifications are ready and to send a test notification from Settings.

## Scope
This design adds a compact user-facing notification section to Settings. It does not add a separate notification screen, advanced debug UI, notification scheduling preferences, or per-prayer notification toggles.

## User Experience
The Settings screen gains a `Notifikasi` section placed after general settings and before prayer time offsets.

The section shows a simple readiness state:

- `Notifikasi aktif` when notification permission is available and scheduling can proceed normally.
- `Perlu izin notifikasi` when notification permission needs user action.
- `Jadwal mungkin tidak tepat` when notifications can be scheduled but exact alarm permission is unavailable on Android.

The section includes two actions:

- `Aktifkan izin notifikasi`, shown when notification permission or scheduling permission needs attention.
- `Kirim notifikasi uji`, always visible when the service is initialized so users can verify sound, alert display, and permission state.

Helper text appears only when action is needed. It should use plain user-facing language and avoid raw implementation details such as plugin names, scheduled IDs, or pending request counts.

## Architecture
Notification readiness logic stays inside the notification feature, not inside the Settings widget. Settings should call a small service API and render the resulting user-facing state.

Add a `NotificationReadiness` value type in `lib/features/notifications/data/services/notification_service.dart` or a nearby notification model file if the service grows too large. It should expose enough information for Settings to render status and actions without leaking plugin internals.

`NotificationService` gets two new public methods:

- `Future<NotificationReadiness> getReadinessStatus()`
- `Future<void> showTestNotification()`

The existing diagnostic methods, such as pending notification counting, remain available for logs and QA but are not shown as raw values in the Settings UI.

## Data Flow
1. `SettingsScreen` renders the notification section.
2. On build or refresh, it requests readiness from `NotificationService`.
3. The service checks platform notification permission state and exact alarm scheduling readiness where available.
4. Settings maps readiness to one of the simple user-facing messages.
5. When the user taps `Aktifkan izin notifikasi`, Settings calls the existing permission request path and refreshes readiness.
6. When the user taps `Kirim notifikasi uji`, Settings calls `showTestNotification()` and shows a lightweight success or failure SnackBar.

## Error Handling
Permission checks and test notification calls must be wrapped in `try-catch`. Failures should use `debugPrint` and show a short recoverable message in the UI.

If readiness cannot be determined, Settings should show `Periksa izin notifikasi` with an action to retry permission setup.

If the test notification fails, the UI should not crash. It should show a SnackBar explaining that the test notification could not be sent.

## Testing
Add or extend tests for:

- Readiness status mapping when notification permission is granted.
- Readiness status mapping when notification permission is denied.
- Android exact alarm unavailable state maps to `Jadwal mungkin tidak tepat`.
- Settings smoke test confirms the `Notifikasi` section renders.
- Test notification method invokes the existing notification channel and does not throw when the platform mock succeeds.

Existing notification scheduler tests should continue to pass unchanged.

## Non-Goals
- No separate Notification Settings screen.
- No debug panel for scheduled notification IDs or pending counts.
- No per-prayer notification toggles.
- No redesign of the Settings screen.
- No change to existing prayer notification copy or adhan sound assets.

## Acceptance Criteria
- Users can see a clear notification readiness state in Settings.
- Users can request notification permission from Settings when action is needed.
- Users can send a test notification from Settings.
- The UI remains concise and consistent with existing Settings rows.
- Automated tests cover readiness mapping and the Settings section render path.
