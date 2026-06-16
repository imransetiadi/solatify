# iOS QA Checklist

**Goal:** Verify Solatify core flows, responsiveness, permissions, and notification behavior on iPhone and iPad.

## Device Matrix
- One small iPhone model
- One large iPhone model
- One iPad in landscape-capable use
- Recommended minimum OS: iOS 17 or newer

## Required Evidence
- Device model and iOS version
- Screenshot or recording for every visual defect
- Console log excerpt for crashes, permission failures, or scheduling failures

## Pre-flight
- Install a profile or release build on the device
- Open Xcode Console before starting the test run
- Confirm location access is available or can be requested
- Confirm notification permission prompts appear after a fresh install
- Confirm exact alarm or notification scheduling permissions can be reviewed if surfaced by the OS

## Core Flows
- Launch the app from a cold start
- Complete onboarding if it appears
- Open each bottom tab: Home, Schedule, Quran, Content, More
- From More, open Qibla, Mosque, and Settings
- Return to the expected tab or screen after each back navigation action

## Screen Checks
- Home: prayer cards render, location text is visible, no clipped text
- Schedule: prayer list renders, date strip is usable, selection updates content
- Quran: surah list renders, search or filters do not break layout
- Content: cards or menu items render without overflow
- Qibla: compass view renders, alignment UI is visible, no sensor crash
- Mosque: loading state and list state render cleanly
- Settings: language and calculation method dialogs open and close correctly

## Responsiveness
- Rotate between portrait and landscape on phone and tablet
- Verify no overflow warnings or clipped controls
- Verify tap targets remain usable on smaller screens
- Verify tablet layout uses wider spacing appropriately

## Notification Checks
- Grant notification permission, then confirm the app continues normally after accept or deny
- If prompted, grant exact alarm or scheduling permission
- Schedule a near-future prayer notification
- Confirm the notification appears in foreground and background states
- Reopen the app and confirm notification setup does not duplicate

## Pass Criteria
- No crashes
- No blank screens
- No clipped critical content
- No broken navigation paths
- No failed permission loops
- Notifications appear when scheduled
