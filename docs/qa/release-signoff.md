# Release Signoff

**Purpose:** Final release gate for Solatify before shipping a build.

## Release Info
- Version: Not set in this audit
- Build Number: Not set in this audit
- Branch / Commit: `fix-android-adhan-playback` / `0f09718` plus Phase 17 evidence docs
- Date: 2026-06-18 09:50 WIB
- Release Owner: Codex Phase 17 real-device QA evidence audit
- Test Devices Detected: Android `2602BPC18G` on Android 16, Android emulator `emulator-5554` on Android 17, cabled iOS `Satelit88` on iOS 18.5, macOS, Chrome
- Evidence Location: Terminal output from Phase 16/17 commands and this document

## Authoritative Commands
- `flutter analyze`
- `flutter test`
- `flutter devices`
- `flutter build apk --debug`
- `flutter build ios --no-codesign`

## Command Evidence - 2026-06-18
- [x] `flutter analyze` — Passed, `No issues found!`
- [x] `flutter test` — Passed, `135/135` tests passed
- [x] `flutter devices` — Passed, detected Android physical, Android emulator, cabled iOS, macOS, and Chrome targets
- [x] `flutter build apk --debug` — Passed, built `build/app/outputs/flutter-apk/app-debug.apk`
- [x] `flutter build apk --profile` — Passed, built `build/app/outputs/flutter-apk/app-profile.apk` at 89.3 MB
- [x] `flutter build ios --no-codesign` — Passed, built `build/ios/iphoneos/Runner.app` at 22.8 MB
- [x] `flutter test -d GMFYIJQKVOM7AIYP integration_test/app_test.dart` — Passed on Android physical `2602BPC18G`, `2/2` tests passed; native Android prayer alarms were scheduled in logs
- [x] `flutter test -d emulator-5554 integration_test/app_test.dart` — Passed on Android emulator, `2/2` tests passed
- [x] `flutter test -d 00008140-000518E42EB8401C integration_test/app_test.dart` — Passed on cabled iOS physical `Satelit88`, `2/2` tests passed; iOS prayer notifications were scheduled in logs

## Automated Coverage Summary
- [x] Notification v2 settings, pre-prayer reminder, per-prayer toggle, sound mode, and history are covered by unit/source/widget tests
- [x] Settings and Notification Health Center verify notification permission after returning from system settings in source guard tests
- [x] Android native adhan/beep/silent/reminder metadata is covered by service/native source tests
- [x] Quran reading mode controls are covered by source and provider tests
- [x] Global Islamic Content search is covered by widget/provider tests
- [x] Typed route constants and internal navigation guardrails are covered by source tests
- [x] Compact-width smoke coverage exists for Home, Schedule, Quran, Settings, and Islamic Content
- [x] Performance and asset budget guardrails are covered by deterministic tests

## Required Manual Device Evidence Before Public Release
- [x] iOS: cold start and main navigation on iPhone via cabled integration test
- [ ] iOS: notification permission prompt accept/reject flow — manual visible prompt evidence pending
- [ ] iOS: return from notification settings and confirm Notification Health refreshes/reschedules automatically
- [ ] iOS: visible test notification and scheduled diagnostic notification delivery — integration logs show scheduled prayer notifications, visible delivery evidence pending
- [x] Android physical: cold start and main navigation on phone via integration test
- [ ] Android physical: POST_NOTIFICATIONS prompt accept/reject flow
- [ ] Android physical: exact alarm settings flow, if surfaced by OS
- [ ] Android physical: return from notification/exact alarm settings and confirm Notification Health refreshes/reschedules automatically
- [ ] Android physical: visible test notification and scheduled diagnostic notification delivery
- [ ] Mosque map/search and directions open a map/browser or show failure snackbar on iOS and Android
- [ ] Profile-mode performance evidence filled in `docs/qa/performance-baseline-template.md`; profile APK build exists, DevTools/manual frame evidence pending
- [ ] Store signing readiness: Android release AAB signing and iOS Apple Developer signing/provisioning

## Notification UX Checks
- [x] Settings shows notification controls without automated layout failures
- [x] Notification Health Center exposes readiness, pending IDs, history, test notification, settings shortcut, and reschedule actions
- [x] Post-permission return verification is wired in Settings and Notification Health Center lifecycle callbacks
- [x] Failure states show SnackBar/source-handled fallback instead of crashing Settings
- [ ] Real visible notification delivery on Android physical device — manual evidence pending
- [ ] Real visible notification delivery on iOS physical device — manual evidence pending

## iOS Verification
- [x] iOS no-codesign build succeeds
- [x] Cabled install/launch/navigation on iPhone passed via integration test
- [ ] iPad responsive run — manual evidence pending
- [ ] Notification permission and visible delivery — scheduled in integration logs, manual visible delivery evidence pending
- [ ] Map route deep link/browser behavior — manual evidence pending
- [ ] Profile-mode performance run — profile APK builds, DevTools/manual frame evidence pending

## Android Verification
- [x] Android debug APK build succeeds
- [x] Android physical device and emulator are detected by `flutter devices`
- [x] Install/launch/navigation on Android physical device passed via integration test
- [ ] Notification permission, exact alarm, and delivery — manual evidence pending
- [ ] Map route deep link/browser behavior — manual evidence pending
- [ ] Profile-mode performance run — profile APK builds, DevTools/manual frame evidence pending

## Build Artifacts
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Profile APK: `build/app/outputs/flutter-apk/app-profile.apk`
- iOS no-codesign app: `build/ios/iphoneos/Runner.app`

## Known Warnings / Risks
- Flutter warns that `flutter_local_notifications` and `flutter_compass_v2` do not support Swift Package Manager for iOS; currently warning-only, future Flutter versions may make this stricter.
- Flutter warns that `audio_session`, `flutter_compass_v2`, and `package_info_plus` apply Kotlin Gradle Plugin; future Flutter versions may require plugin upgrades.
- iOS build is no-codesign only; TestFlight/App Store still requires Apple Developer team, signing certificate, provisioning profile, archive signing, and upload.
- Public Android release still requires signed release build/AAB and Play Console checks.

## Final Decision
- [ ] Approved for public release
- [x] Blocked from public release pending manual device QA and signed release evidence
- [x] Automated readiness passed for current branch

## Signoff Notes
- Summary: Static analysis, full automated tests, Android debug/profile builds, iOS no-codesign build, Android physical integration test, Android emulator integration test, cabled iOS physical integration test, and device discovery pass on 2026-06-18.
- Release blocker: public release still needs real iOS/Android visible permission/delivery evidence, map deep-link evidence, profile-mode DevTools baseline evidence, and signed store build evidence.
- Next action: run manual notification/map QA on both phones, fill `docs/qa/performance-baseline-template.md` with DevTools evidence, then update this signoff from blocked to approved only if all required manual evidence passes.
