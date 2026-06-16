# Tracker Move And Notification Delivery Repair Design

## Goal
Move the daily worship tracker out of Home into a dedicated Tracker entry under More, and repair test notification delivery when Settings reports success but no system notification appears.

## Confirmed Behavior
- Home currently contains `Ceklis Ibadah Hari Ini`, which should no longer live on Home.
- The tracker should not be deleted. It should move to a dedicated screen reachable from More.
- `Kirim notifikasi uji` currently shows success snackbar, but no system notification appears in foreground or background.
- This means the tap path and `showTestNotification()` call are running; the likely failure is platform delivery/channel/config rather than button wiring.

## Scope
In scope:
- Remove the tracker checklist card from `HomeScreen`.
- Add a dedicated `TrackerScreen` that reuses the existing tracker provider/data.
- Add `Tracker Ibadah` access from the existing More/Islamic content area.
- Add a route for the tracker screen.
- Repair test notification delivery using a diagnostic notification channel and unique test notification IDs.
- Add automated tests and QA checklist updates.

Out of scope:
- Deleting tracker providers, repositories, Hive boxes, or tracker tests.
- Adding tracker to the bottom navigation.
- Redesigning the entire More/Islamic content screen.
- Replacing `flutter_local_notifications`.
- Changing real prayer notification copy unless required by delivery diagnostics.

## Tracker Design
Home should focus on location, countdown, and prayer schedule. The daily worship checklist is moved out so the Home screen is cleaner.

`TrackerScreen` should:
- Use existing `trackerProvider`.
- Use `ResponsiveCenter`, `ResponsiveLayout`, `IslamicBackground`, and `GlassContainer`.
- Show title `Tracker Ibadah`.
- Show a short status/subtitle for today's worship checklist.
- Render the same prayer toggle chips currently shown on Home.
- Keep toggle behavior through `ref.read(trackerProvider.notifier).togglePrayer(prayer)`.
- Handle loading/error states without crashing.

Navigation:
- Add route `/tracker`.
- Add a More/Islamic content menu item labeled `Tracker Ibadah`.
- Use icon `Icons.check_circle_outline` or equivalent.

## Notification Delivery Design
Because the Settings snackbar appears, the UI action reaches `NotificationService.showTestNotification()`. The repair should focus on platform delivery.

`showTestNotification()` should:
- Use a diagnostic channel with a new ID, for example `solatify_diagnostic_channel_v2`.
- Use channel name `Solatify Diagnostic`.
- Use `Importance.max` and `Priority.high` on Android.
- Use default notification sound for the diagnostic channel to avoid being blocked by a custom sound/channel mismatch.
- Use a unique notification ID derived from the current timestamp instead of fixed `9001`, so each test creates a fresh notification instead of updating an old one.
- Keep iOS foreground presentation enabled with `presentAlert`, `presentBadge`, and `presentSound`.
- Log the notification ID/channel/payload with `debugPrint`.

Settings behavior:
- Keep the success snackbar, but status text should make clear that the command was sent to the OS.
- If a user sees the snackbar but no notification, QA should check OS notification permission and Android channel settings.

Android behavior:
- Create the diagnostic channel during notification initialization.
- Keep the existing Adhan prayer channel for prayer notifications.
- Keep `POST_NOTIFICATIONS` permission handling.
- Manual QA should verify App Info > Notifications > `Solatify Diagnostic` is enabled.

iOS behavior:
- Keep permission request/check path.
- Manual QA should verify notification permission and foreground/background alert delivery.

## Testing Plan
Automated tests:
- Home smoke/widget test verifies `Ceklis Ibadah Hari Ini` is absent from Home.
- Tracker screen smoke/widget test verifies `Tracker Ibadah` renders and checklist chips appear.
- Router/navigation smoke verifies `/tracker` route can render if existing tests cover route-level screens.
- Notification service test verifies `showTestNotification()` calls `show` with:
  - non-`9001` ID,
  - title `Tes Notifikasi Solatify`,
  - Android channel ID `solatify_diagnostic_channel_v2`.
- Existing Settings smoke test still verifies `Kirim notifikasi uji` renders.

Manual QA:
- Android:
  - Fresh install or clear app data.
  - Grant notification permission.
  - Tap `Kirim notifikasi uji`.
  - Verify system notification appears in foreground and background.
  - Verify Android notification channel `Solatify Diagnostic` is enabled.
- iOS:
  - Fresh install or reset notification permission.
  - Grant notification permission.
  - Tap `Kirim notifikasi uji`.
  - Verify alert appears in foreground and background.
- Navigation:
  - Verify Home no longer shows the tracker checklist.
  - Verify Tracker opens from More.
  - Verify tracker toggles still work.

## Risks
- Android channels are sticky. Existing installs may need app data clear or a new diagnostic channel ID to pick up channel changes. This design uses a new channel ID.
- Some OEMs suppress notifications due to battery or notification category settings. Diagnostics should make OS/channel settings easier to inspect.
- If More is implemented as Islamic Content rather than a literal More screen, the tracker entry should be added to that existing menu surface without broad navigation refactor.

## Success Criteria
- Home is clean and no longer contains `Ceklis Ibadah Hari Ini`.
- Tracker is reachable from More and still toggles daily prayers.
- `Kirim notifikasi uji` creates a visible system notification on Android/iOS QA devices.
- Tests and analyzer pass.
- Android debug build and iOS no-codesign build pass.
