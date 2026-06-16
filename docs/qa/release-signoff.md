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
- Performance notes if any threshold is near or exceeded

## iOS Verification
- [ ] Cold start works on the tested iPhone and iPad devices
- [ ] Main navigation works
- [ ] Responsive layout checked on phone and tablet
- [ ] Notification permission flow checked
- [ ] Prayer notification delivery verified
- [ ] No blocking crash or layout bug found

## Android Verification
- [ ] Cold start works on the tested phone and tablet devices
- [ ] Main navigation works
- [ ] Responsive layout checked on phone and tablet
- [ ] Notification permission flow checked
- [ ] Exact alarm flow checked if applicable
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
