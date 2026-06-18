# Performance Baseline Template

Use this file as the repeatable evidence sheet for profile-mode performance runs.

## Build Context
| Field | Value |
|-------|-------|
| Date | 2026-06-18 |
| Tester | Codex Phase 17 |
| Branch | `fix-android-adhan-playback` |
| Commit | `0f09718` plus Phase 17 evidence docs |
| Build number / artifact | `build/app/outputs/flutter-apk/app-profile.apk` built successfully, 89.3 MB |
| Flutter version | |
| Device | Android physical `2602BPC18G`, Android emulator `emulator-5554`, cabled iOS `Satelit88` detected |
| OS version | Android 16/API 36 physical, Android 17/API 37 emulator, iOS 18.5 cabled |
| Mode | `profile` artifact built; DevTools observation pending |

## Golden Path Measurements
| Path | Steps | Budget | Result | Evidence |
|------|-------|--------|--------|----------|
| Cold start | Force stop app, launch, measure until Home is usable | <= 5s | | |
| Warm resume | Background app, wait 30s, resume until interactive | <= 2s | | |
| Home scroll | Scroll Home prayer and quick-action content for 20s | No repeated jank | | |
| Quran list | Open Quran, search/scroll surah list for 20s | No repeated jank | | |
| Schedule | Open Jadwal, change date/location sheet, scroll cards | No repeated jank | | |
| Menu switching | Switch Home/Schedule/Quran/Content/More rapidly 3 rounds | No visible hitching | | |

## Integration Evidence
| Target | Command | Result | Notes |
|--------|---------|--------|-------|
| Android physical `2602BPC18G` | `flutter test -d GMFYIJQKVOM7AIYP integration_test/app_test.dart` | Pass, 2/2 | Native Android prayer alarms scheduled in logs |
| Android emulator `emulator-5554` | `flutter test -d emulator-5554 integration_test/app_test.dart` | Pass, 2/2 | Navigation and tablet layout passed |
| iOS cabled `Satelit88` | `flutter test -d 00008140-000518E42EB8401C integration_test/app_test.dart` | Pass, 2/2 | Prayer notifications scheduled in logs |

## Frame Evidence
| Path | Avg build | Worst build | Avg raster | Worst raster | Notes |
|------|-----------|-------------|------------|--------------|-------|
| Home scroll | | | | | |
| Quran list | | | | | |
| Schedule | | | | | |
| Menu switching | | | | | |

## Memory Evidence
| Scenario | Start memory | End memory | Result | Notes |
|----------|--------------|------------|--------|-------|
| 5 navigation loops | Not captured | Not captured | Pending | Requires DevTools/profile observation |
| Background/resume x5 | Not captured | Not captured | Pending | Requires manual device observation |
| Notification settings + reschedule | Not captured | Not captured | Pending | Requires manual permission/settings flow |

## Failure Notes
| Issue | Repro steps | Log / screenshot | Owner | Next action |
|-------|-------------|------------------|-------|-------------|
| | | | | |
