# Android Native Notification Sound Mode Design

## Goal
Make Android native prayer alarms respect Solatify Notification v2 sound modes and reminder metadata, so native scheduling behaves consistently with Flutter plugin fallback scheduling.

## Scope
Phase 8 updates the Android MethodChannel payload and native alarm receiver. It does not change user-facing settings UI or the notification planner.

## User Experience
- `adhan` mode continues using the adhan channel/sound.
- `beep` mode uses a lightweight/default sound channel.
- `silent` mode uses a silent channel without sound.
- Reminder notifications use reminder copy and avoid full adhan-style messaging.

## Architecture
- Flutter `NotificationService.scheduleAndroidPrayerAlarm` passes `soundMode` and `isReminder` to the native MethodChannel.
- Android `MainActivity` writes those values into alarm `Intent` extras.
- `PrayerAlarmReceiver` reads extras and chooses channel ID, channel name, sound, priority, and copy.
- Existing fallback plugin channel behavior remains unchanged.

## Validation
- Dart tests assert MethodChannel payload includes `soundMode` and `isReminder`.
- Source tests assert Kotlin receiver handles `soundMode`, `isReminder`, beep, and silent channels.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Instrumented Android test for actual system notification sound behavior.
- User-selectable custom adhan/beep audio files.
- Native delivered-history event callbacks.
