# Solatify Development Notes

Last updated: 2026-06-18

## Current Workflow Checkpoint

- Active development branch: `feature/next-solatify-improvements`.
- `main` already contains the completed phase work through `f1b036b Fix iOS notification delivery flow`.
- Use `feature/next-solatify-improvements` for the next improvement so the Pull Request has meaningful changes.
- Preferred workflow: implement in small phases, run QA, commit, push, then open PR to `main`.

## Collaboration Preferences

- Keep updates concise, direct, and in Indonesian when possible.
- Be honest about device and OS limitations; never claim iOS/Android delivery is guaranteed without fresh device evidence.
- Stop long-running iOS integration/device commands if they appear stuck; report the actual state instead of waiting indefinitely.
- Before saying work is complete, run the relevant verification command and report the exact evidence.

## QA Baseline

Latest reliable automated baseline:

- `flutter analyze --no-pub` passes with no issues.
- `flutter test --no-pub` passes with `138/138` tests.
- `flutter build apk --debug --no-pub` succeeds.
- `flutter build ios --no-codesign --no-pub` succeeds.
- Android emulator integration previously passed `2/2`; evidence log: `/tmp/solatify_android_integration.log`.

Manual/device caveat:

- iOS integration runner on the physical iPhone `Satelit88` can hang in this CLI environment.
- Prefer Xcode for iOS real-device validation: open `ios/Runner.xcworkspace`, select `Satelit88`, then run `Product > Run`.
- If iOS notification delivery fails, inspect Xcode Console for `Solatify iOS notification...` logs.

## Notification System Notes

Settings now exposes a direct `Kirim Test Notifikasi` action instead of the previous Notification Health Center entry.

Recent iOS notification hardening:

- `ios/Runner/AppDelegate.swift` sets `UNUserNotificationCenter.current().delegate`.
- Foreground notifications use banner/list/sound/badge presentation.
- Native iOS method channel supports notification permission request, permission check, and native test notification delivery.
- `NotificationService` tries the native iOS path first for test notification, with plugin fallback.
- Prayer/adzan scheduling checks iOS notification permission before scheduling to avoid silent failures.

Known iOS validation caveat:

- `flutter install` can fail for `build/ios/iphoneos/Runner.app` when the app is built with `--no-codesign`.
- `flutter run --release -d 00008140-000518E42EB8401C` may hang in the CLI harness.
- Use Xcode for the final manual check of `Kirim Test Notifikasi`, salat-time notification, and bundled adzan sound.

## Repository Rules Reminder

Follow `AGENTS.md` and keep changes aligned with Clean Architecture:

- Internal imports should use `package:solatify/...`.
- Use `debugPrint`, not `print`.
- Keep UI responsive with existing shared layout and theme widgets.
- Avoid unrelated refactors while fixing a targeted issue.
- Dispose timers, controllers, and subscriptions.
