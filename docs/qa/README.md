# QA Documentation

Use these documents as the single source of truth for Solatify QA, release readiness, and bug reporting.

## Canonical Command Paths
- Automated baseline: `flutter test` and `flutter analyze`
- Integration test command: `flutter test integration_test/app_test.dart`
- Device logs: `adb logcat` on Android, Xcode Console on iOS
- Performance profiling: `flutter run --profile`

## What to Use When
- `runbook.md` — end-to-end QA flow with required evidence
- `device-commands.md` — exact terminal commands and log capture commands
- `ios-checklist.md` — iPhone and iPad verification checklist
- `android-checklist.md` — Android phone and tablet verification checklist
- `performance-checklist.md` — profiling steps and thresholds
- `weekly-qa-checklist.md` — weekly regression checklist
- `release-signoff.md` — pre-release approval gate
- `.github/ISSUE_TEMPLATE/qa-bug-report.md` — bug report template for QA findings

## Required Evidence
- Test date, build number, branch or commit, and device model / OS version
- Pass/fail result for every checklist area
- Screenshot, screen recording, or log excerpt for every failure
- Device logs for crashes, ANRs, hangs, and permission issues

## Thresholds
- No crashes in baseline or device QA
- No blocking navigation or layout overflow on tested devices
- No repeated exception spam in logs
- Performance must stay within the limits listed in `performance-checklist.md`
