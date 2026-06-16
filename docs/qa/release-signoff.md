# Release Signoff

**Purpose:** Final release gate for Solatify before shipping a build.

## Release Info
- Version:
- Build Number:
- Branch / Commit:
- Date:
- Release Owner:
- Test Devices:
- Evidence Location:

## Authoritative Commands
- `flutter test`
- `flutter analyze`
- `flutter test integration_test/app_test.dart`

## Required Evidence
- Pass result for each command above
- iOS and Android device logs for any issue found
- Screenshot or recording for any UI regression
- Screenshot or recording showing `Ceklis Ibadah Hari Ini` moved from Beranda into More → `Tracker Ibadah`
- Performance notes if any threshold is near or exceeded

## Notification UX Checks
- [ ] Settings shows the `NOTIFIKASI` section without layout overflow
- [ ] Status text updates after notification permission changes
- [ ] `Aktifkan izin notifikasi` opens or requests the platform permission flow when action is needed
- [ ] `Kirim notifikasi uji` sends a visible test notification when notifications are available
- [ ] Android: diagnostic channel `Solatify Diagnostic` is enabled in system notification settings
- [ ] Android: `Kirim notifikasi uji` shows snackbar and creates a new visible system notification on every tap
- [ ] Android: `Jadwalkan tes 2 menit` shows snackbar and delivers after roughly 2 minutes
- [ ] Android: next real prayer notification delivery verified or diagnostic logs captured
- [ ] iOS: `Kirim notifikasi uji` shows snackbar and creates a new visible system notification on every tap
- [ ] iOS: `Jadwalkan tes 2 menit` shows snackbar and delivers after roughly 2 minutes
- [ ] iOS: Settings notification buttons never fail silently after tap
- [ ] Failure states show a SnackBar instead of crashing the Settings screen
- [ ] Android exact-alarm denial shows the less precise schedule status and still allows a test notification

## iOS Verification
- [ ] Cold start works on the tested iPhone and iPad devices
- [ ] Main navigation works
- [ ] Beranda no longer shows `Ceklis Ibadah Hari Ini`
- [ ] More opens `Tracker Ibadah`
- [ ] Tracker prayer toggle updates checked/unchecked state
- [ ] Responsive layout checked on phone and tablet
- [ ] Notification permission flow checked
- [ ] Mosque `Lihat Peta` opens map/browser or shows failure snackbar
- [ ] Mosque `Rute` opens directions or shows failure snackbar
- [ ] Prayer notification delivery verified
- [ ] No blocking crash or layout bug found

## Android Verification
- [ ] Cold start works on the tested phone and tablet devices
- [ ] Main navigation works
- [ ] Beranda no longer shows `Ceklis Ibadah Hari Ini`
- [ ] More opens `Tracker Ibadah`
- [ ] Tracker prayer toggle updates checked/unchecked state
- [ ] Responsive layout checked on phone and tablet
- [ ] Notification permission flow checked
- [ ] Exact alarm flow checked if applicable
- [ ] Mosque `Lihat Peta` opens map/browser or shows failure snackbar
- [ ] Mosque `Rute` opens directions or shows failure snackbar
- [ ] Prayer notification delivery verified
- [ ] Reboot and reschedule behavior checked
- [ ] No blocking crash, freeze, or layout bug found

## Performance Gate
- [ ] Startup meets the thresholds in `performance-checklist.md`
- [ ] Main screens scroll smoothly
- [ ] Tab switching is stable
- [ ] No obvious memory growth during repeated navigation
- [ ] No repeated background exception spam in logs

## Open Issues
| Severity | Issue | Platform | Owner | Status | Evidence |
|----------|-------|----------|--------|--------|----------|
|          |       |          |        |        |          |

## Final Decision
- [ ] Approved for release
- [ ] Blocked from release

## Signoff Notes
- Summary:
- Risks accepted:
- Follow-up items after release:
