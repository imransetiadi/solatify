# Performance Checklist

**Goal:** Measure startup, navigation smoothness, scrolling performance, and memory stability on iOS and Android.

## Test Mode
- Run in `profile` mode for real performance numbers
- Use a physical device when possible
- Open Flutter DevTools for CPU, memory, and frame analysis
- Keep logs visible while testing so exception spam is captured

## Required Evidence
- Device model, OS version, build number, and test date
- Screenshot of DevTools frames or memory view for any threshold breach
- Log excerpt for jank-related exceptions, crashes, or repeated background errors

## Thresholds
- Cold start to first usable screen: under 5 seconds on a modern flagship device
- Warm resume to interactive screen: under 2 seconds
- Sustained frame drops: no repeated jank during normal navigation or scrolling
- Memory growth: no obvious monotonic leak during repeated navigation and background/resume loops
- Logs: no repeated background exception spam or scheduling loops

These thresholds are mirrored by `PerformanceTuning` constants so automated tests catch accidental budget drift. Device-specific timing still requires profile-mode evidence.

## Golden Path Scenarios
Capture each path in `docs/qa/performance-baseline-template.md`:

1. **Cold start** — force stop the app, launch from icon, measure until Home is usable.
2. **Home scroll** — scroll Home prayer cards and quick actions for at least 20 seconds.
3. **Quran list** — open Qur'an, search or scroll the surah list for at least 20 seconds.
4. **Schedule** — open Jadwal, move between dates, open location sheet, and scroll prayer cards.
5. **Menu switching** — switch Home, Schedule, Quran, Content, and More quickly for three rounds.

## Startup
- Measure cold start time from app launch to the first usable screen
- Measure warm start after background resume
- Verify splash and boot flow do not stall on Hive or notification initialization

## Navigation
- Rapidly switch between Home, Schedule, Quran, Content, and More
- Open and close Qibla, Mosque, and Settings repeatedly
- Confirm transitions remain smooth without visible hitching

## Scrolling
- Scroll Home prayer cards
- Scroll Quran lists and detail pages
- Scroll long content lists where available
- Verify large images or SVG assets do not cause visible jank

## Memory
- Watch memory before and after repeated navigation
- Reopen the app from background several times
- Confirm memory growth is stable and there is no obvious leak

## Notification Stress
- Schedule a near-future notification
- Background the app, reopen it, and repeat
- Confirm notification setup does not repeatedly re-register or spike memory

## Tools
- `flutter run --profile`
- Flutter DevTools CPU profile
- Flutter DevTools memory view
- `adb logcat` or Xcode Console
- `docs/qa/performance-baseline-template.md` for evidence capture

## Pass Criteria
- Startup is consistent across repeated launches
- Scrolling stays smooth on primary screens
- No sustained frame drops during normal use
- Memory remains stable during repeated navigation
- No background crashes or exception spam in logs
