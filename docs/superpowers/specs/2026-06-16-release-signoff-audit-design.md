# Release Signoff Audit Design

## Goal
Run a release-grade audit across Solatify’s primary features and menus, verify automated QA/build health, and update the release signoff record with evidence-backed status.

## Scope
The audit covers the main user-facing areas: Beranda, Jadwal, Qur’an, Konten, More, Kiblat, Masjid, Tracker, Pengaturan, and Notifikasi. It also covers platform-sensitive flows: GPS/location permission, nearby mosque search, map and route launching, prayer-time notification scheduling, adzan sound setup, permission states, dark mode readability, and responsive layout behavior.

## Approach
Use existing QA assets as the source of truth: `docs/qa/runbook.md`, `docs/qa/release-signoff.md`, `docs/qa/android-checklist.md`, `docs/qa/ios-checklist.md`, and `docs/qa/performance-checklist.md`. Execute automated checks first so code-level regressions are found before manual/device-level claims. Only mark an item as passed when there is fresh command output or directly observed evidence.

## Automated QA
Run the repository’s core verification commands:

- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter test integration_test/app_test.dart`
- `flutter build apk --debug`
- `flutter build ios --no-codesign`

If a command fails, record the failing command, relevant error output, likely impact, and blocker status in the release signoff document before attempting any fix.

## Manual and Device QA
If devices or simulators are available, install/run the current build on Android and iOS and verify launch, navigation, responsive behavior, location/GPS, mosque map/route actions, notification permission flows, diagnostic notifications, scheduled notifications, and real prayer notification scheduling. If a physical device or profile run is not available, record the item as not fully verified instead of claiming pass.

## Performance QA
Use `docs/qa/performance-checklist.md` thresholds. Prefer `flutter run --profile` on Android and iOS devices. Measure startup, tab switching, heavy scrolling, repeated navigation, memory behavior, and log spam. If profile-mode execution is not available, record a performance-readiness status and leave profiling as a required manual follow-up.

## Documentation Output
Update `docs/qa/release-signoff.md` with:

- branch and commit under test
- commands executed and results
- feature/menu audit status
- Android and iOS verification status
- performance status
- open issues, blockers, and accepted risks
- follow-up checklist for any item without direct evidence

## Pass Criteria
The branch can be considered release-ready only if automated QA passes, Android and iOS builds succeed, no blocking navigation/layout crashes are found, notification scheduling remains observable, and any unverified device-only item is explicitly listed as pending evidence. A clean automated run alone is not enough to claim full device QA completion.

## Constraints
Do not make broad refactors during the audit. Patch only small, isolated defects with a clear root cause. Larger issues must be documented as release blockers with reproduction steps and recommended next action.
