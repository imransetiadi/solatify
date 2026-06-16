# Release Signoff

**Purpose:** Final release gate for Solatify before shipping a build.

## Release Info
- Version: Not set in this audit
- Build Number: Not set in this audit
- Branch / Commit: `fix-android-notifications` / `8be2e45` plus working-tree QA changes
- Date: 2026-06-16 19:04 WIB
- Release Owner: Codex QA audit
- Test Devices: iOS physical `Satelit88` on iOS 18.5; Android device not connected; macOS and Chrome also detected
- Evidence Location: Terminal output from this QA run and this document

## Authoritative Commands
- `flutter test`
- `flutter analyze`
- `flutter test integration_test/app_test.dart`

## Command Evidence - 2026-06-16
- [x] `flutter analyze --no-pub` — Passed, `No issues found!`
- [x] `flutter test --no-pub` — Passed, `57/57` tests passed
- [ ] `flutter test integration_test/app_test.dart` — Blocked/failed on iOS device execution: tests launched and scheduled prayer notification, then did not complete; Flutter finalization also hit temporary-directory `PathNotFoundException`
- [x] `flutter build apk --debug` — Passed, built `build/app/outputs/flutter-apk/app-debug.apk`
- [x] `flutter build ios --no-codesign` — Passed, built `build/ios/iphoneos/Runner.app`
- [x] `flutter devices` — Passed, found iOS physical device `Satelit88`; no Android device detected

## Required Evidence
- Pass result for each command above
- iOS and Android device logs for any issue found
- Screenshot or recording for any UI regression
- Screenshot or recording showing `Ceklis Ibadah Hari Ini` moved from Beranda into More → `Tracker Ibadah`
- Performance notes if any threshold is near or exceeded

## Notification UX Checks
- [x] Settings shows the `NOTIFIKASI` section without layout overflow in widget/build coverage
- [x] Status text updates after notification permission changes in service/readiness coverage
- [ ] `Aktifkan izin notifikasi` opens or requests the platform permission flow when action is needed — requires manual iOS/Android device evidence
- [x] `Kirim notifikasi uji` sends a visible test notification when notifications are available in platform-channel test coverage; real visible notification requires device evidence
- [ ] Android: diagnostic channel `Solatify Diagnostic` is enabled in system notification settings
- [ ] Android: `Kirim notifikasi uji` shows snackbar and creates a new visible system notification on every tap
- [ ] Android: `Jadwalkan tes 2 menit` shows snackbar and delivers after roughly 2 minutes
- [x] Android: next real prayer notification delivery verified or diagnostic logs captured in scheduler logs during integration attempt; real Android delivery still requires device evidence
- [ ] iOS: `Kirim notifikasi uji` shows snackbar and creates a new visible system notification on every tap — requires manual device evidence
- [ ] iOS: `Jadwalkan tes 2 menit` shows snackbar and delivers after roughly 2 minutes — requires manual device evidence
- [ ] iOS: Settings notification buttons never fail silently after tap
- [x] Failure states show a SnackBar instead of crashing the Settings screen in source/test coverage
- [x] Android exact-alarm denial shows the less precise schedule status and still allows a test notification in service tests

## iOS Verification
- [ ] Cold start works on the tested iPhone and iPad devices — iPhone app launched during integration attempt; iPad not tested
- [ ] Main navigation works — integration attempt did not complete, manual evidence required
- [x] Beranda no longer shows `Ceklis Ibadah Hari Ini` in automated widget/source coverage
- [x] More opens `Tracker Ibadah` in automated widget coverage
- [x] Tracker prayer toggle updates checked/unchecked state in automated tracker tests
- [ ] Responsive layout checked on phone and tablet — tablet widget coverage exists; physical device evidence pending
- [ ] Notification permission flow checked
- [ ] Mosque `Lihat Peta` opens map/browser or shows failure snackbar
- [ ] Mosque `Rute` opens directions or shows failure snackbar
- [ ] Prayer notification delivery verified — scheduling observed in logs, real delivery pending manual evidence
- [ ] No blocking crash or layout bug found — cannot mark pass while integration test is incomplete

## Android Verification
- [ ] Cold start works on the tested phone and tablet devices — Android device not connected in this audit
- [ ] Main navigation works — Android device not connected in this audit
- [x] Beranda no longer shows `Ceklis Ibadah Hari Ini` in automated widget/source coverage
- [x] More opens `Tracker Ibadah` in automated widget coverage
- [x] Tracker prayer toggle updates checked/unchecked state in automated tracker tests
- [x] Responsive layout checked on phone and tablet via widget/integration-style viewport coverage; physical Android evidence pending
- [ ] Notification permission flow checked
- [ ] Exact alarm flow checked if applicable
- [ ] Mosque `Lihat Peta` opens map/browser or shows failure snackbar
- [ ] Mosque `Rute` opens directions or shows failure snackbar
- [ ] Prayer notification delivery verified — scheduling/channel behavior covered by tests; real device delivery pending
- [ ] Reboot and reschedule behavior checked
- [ ] No blocking crash, freeze, or layout bug found

## Performance Gate
- [ ] Startup meets the thresholds in `performance-checklist.md` — profile-mode timing not run in this audit
- [ ] Main screens scroll smoothly — profile-mode frame evidence not collected
- [ ] Tab switching is stable — automated navigation coverage exists, profile/manual evidence pending
- [ ] No obvious memory growth during repeated navigation — DevTools memory evidence not collected
- [ ] No repeated background exception spam in logs — no app exception spam seen in unit/build output; device log profiling pending

## Open Issues
| Severity | Issue | Platform | Owner | Status | Evidence |
|----------|-------|----------|--------|--------|----------|
| High | `flutter test integration_test/app_test.dart` did not complete on iOS device and Flutter finalization reported temporary-directory `PathNotFoundException` | iOS / Flutter tool | QA | Open | Integration command output from 2026-06-16 |
| Medium | Android device QA could not be executed because no Android device/emulator was connected | Android | QA | Pending device access | `flutter devices` listed iOS, macOS, Chrome only |
| Medium | Profile-mode performance thresholds were not measured on device | iOS / Android | QA | Pending profiling run | `docs/qa/performance-checklist.md` requires `flutter run --profile` |

## Final Decision
- [ ] Approved for release
- [x] Blocked from release

## Signoff Notes
- Summary: Static analysis, full unit/widget tests, Android debug build, and iOS no-codesign build pass. Release signoff remains blocked because integration QA did not complete and Android/device performance evidence was not collected.
- Risks accepted: None for release approval. Automated readiness is good, but device-level release evidence is incomplete.
- Follow-up items after release: None; required before release are rerunning integration QA to completion, Android physical/emulator QA, manual notification/GPS/map-route checks, and profile-mode performance capture.
