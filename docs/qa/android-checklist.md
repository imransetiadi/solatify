# Android QA Checklist

**Goal:** Verify Solatify core flows, notifications, and device compatibility across Android phones and tablets.

## Device Matrix
- One Android phone running Android 13 or newer
- One Android tablet or large-screen emulator
- Optional older Android device for compatibility checks

## Required Evidence
- Device model, Android version, and build identifier
- Screenshot or screen recording for every visual defect
- `adb logcat` excerpt for crashes, ANRs, permission failures, and notification failures

## Pre-flight
- Install the app via `flutter run`, APK, or an internal build
- Open `adb logcat` before starting the test run
- Accept or deny location permission when prompted, then verify the app recovers
- Accept or deny notification permission when prompted, then verify the app recovers
- If Android opens exact alarm settings, enable exact alarms for the app
- Confirm the app starts after a cold boot

## Core Flows
- Launch the app from a cold start
- Complete onboarding if shown
- Open each main menu item: Home, Schedule, Quran, Content, More
- From More, open Qibla, Mosque, and Settings
- Verify each screen can navigate back without getting stuck

## Screen Checks
- Home: main dashboard loads and scrolls
- Schedule: prayer times and date selection render correctly
- Quran: surah list loads and detail pages open
- Content: Islamic content cards render cleanly
- Qibla: compass and heading updates do not crash
- Mosque: location-based list or empty state is shown correctly
- Settings: language, offsets, and calculation method options work

## Responsiveness
- Test portrait and landscape on phone and tablet
- Verify bottom navigation does not overlap system gesture areas
- Verify tablet layout switches to a wider navigation arrangement
- Verify dialog content remains scrollable on small screens

## Notification Checks
- Confirm `POST_NOTIFICATIONS` permission is requested when needed
- Confirm `SCHEDULE_EXACT_ALARM` flow works if required
- Verify scheduled prayer notifications fire at the expected time
- Reboot the device or emulator and confirm future notifications still schedule
- Confirm there is no duplicate notification spam after reopening the app

## Pass Criteria
- No crashes
- No ANR or freeze during navigation
- No layout overflow on tested screens
- Notification scheduling works after app restart and reboot
- Permission prompts are understandable and recoverable
