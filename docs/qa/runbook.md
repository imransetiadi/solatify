# Solatify QA Runbook

**Purpose:** Repeatable end-to-end QA for iOS and Android with explicit commands, evidence capture, and release-ready pass/fail criteria.

## Required Inputs
- Fresh build from the current branch
- Target device list: at least one iPhone or iPad and one Android phone or tablet
- Test data and location access available on the device(s)
- A place to store screenshots, recordings, and log exports

## Canonical Command Order
1. `flutter test`
2. `flutter analyze`
3. `flutter test integration_test/app_test.dart`
4. iOS device QA
5. Android device QA
6. Performance profiling on both platforms
7. Collect evidence and sign off

## Evidence to Capture
- Build identifier, branch, commit, tester name, and test date
- Device model, OS version, and app install method
- Screenshot or screen recording for UI defects
- Relevant log excerpt for every failure
- Timestamped notes for each pass/fail decision

## Automated Checks
- [ ] `flutter test`
- [ ] `flutter analyze`
- [ ] `flutter test integration_test/app_test.dart`

## iOS Device QA
- [ ] Verify the app launches from a cold start on iPhone
- [ ] Verify the app launches from a cold start on iPad
- [ ] Complete onboarding if shown
- [ ] Open Home, Schedule, Quran, Content, and More
- [ ] Open Qibla, Mosque, and Settings from More
- [ ] Rotate between portrait and landscape on phone and tablet
- [ ] Confirm notification permission prompts can be accepted or rejected cleanly
- [ ] Confirm exact alarm or scheduling permission flow works if surfaced by the OS
- [ ] Verify prayer notifications appear at the expected time

## Android Device QA
- [ ] Verify the app launches from a cold start on phone
- [ ] Verify the app launches from a cold start on tablet or large-screen emulator
- [ ] Complete onboarding if shown
- [ ] Open Home, Schedule, Quran, Content, and More
- [ ] Open Qibla, Mosque, and Settings from More
- [ ] Rotate between portrait and landscape on phone and tablet
- [ ] Confirm location permission prompts can be accepted or rejected cleanly
- [ ] Confirm notification permission prompts can be accepted or rejected cleanly
- [ ] Confirm exact alarm permission flow works if required by the device
- [ ] Reboot the device or emulator and confirm future notifications still schedule

## Performance Profiling
- [ ] Run `flutter run --profile`
- [ ] Open Flutter DevTools
- [ ] Measure cold start to first usable screen
- [ ] Scroll Home, Quran, and Schedule while watching frame times
- [ ] Rapidly switch tabs and open or close the More menu
- [ ] Repeat the same checks on iOS and Android
- [ ] Fill `docs/qa/performance-baseline-template.md` with timing, frame, memory, and log evidence

## Pass / Fail Log
| Date | Platform | Device | OS | Build | Test Area | Result | Evidence |
|------|----------|--------|----|-------|-----------|--------|----------|
|      | iOS      |        |    |       | Automated |        |          |
|      | iOS      |        |    |       | Navigation |        |          |
|      | iOS      |        |    |       | Notifications |     |          |
|      | iOS      |        |    |       | Performance |     |          |
|      | Android  |        |    |       | Automated |        |          |
|      | Android  |        |    |       | Navigation |        |          |
|      | Android  |        |    |       | Notifications |     |          |
|      | Android  |        |    |       | Performance |     |          |

## Failure Notes
- [ ] Reproduce the issue with exact steps and the same build
- [ ] Capture screenshot or screen recording
- [ ] Copy the relevant device log excerpt
- [ ] Record the platform, OS version, and build number
- [ ] Assign an owner and a next action

## Exit Criteria
- [ ] No crashes in automated checks or device QA
- [ ] No blocking navigation issues
- [ ] No broken responsive layouts on iOS or Android
- [ ] Notifications work as expected
- [ ] Performance stays within `performance-checklist.md`
