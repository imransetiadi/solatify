# Performance Baseline Template

Use this file as the repeatable evidence sheet for profile-mode performance runs.

## Build Context
| Field | Value |
|-------|-------|
| Date | |
| Tester | |
| Branch | |
| Commit | |
| Build number / artifact | |
| Flutter version | |
| Device | |
| OS version | |
| Mode | `profile` |

## Golden Path Measurements
| Path | Steps | Budget | Result | Evidence |
|------|-------|--------|--------|----------|
| Cold start | Force stop app, launch, measure until Home is usable | <= 5s | | |
| Warm resume | Background app, wait 30s, resume until interactive | <= 2s | | |
| Home scroll | Scroll Home prayer and quick-action content for 20s | No repeated jank | | |
| Quran list | Open Quran, search/scroll surah list for 20s | No repeated jank | | |
| Schedule | Open Jadwal, change date/location sheet, scroll cards | No repeated jank | | |
| Menu switching | Switch Home/Schedule/Quran/Content/More rapidly 3 rounds | No visible hitching | | |

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
| 5 navigation loops | | | Stable / Growth / Leak suspected | |
| Background/resume x5 | | | Stable / Growth / Leak suspected | |
| Notification settings + reschedule | | | Stable / Growth / Leak suspected | |

## Failure Notes
| Issue | Repro steps | Log / screenshot | Owner | Next action |
|-------|-------------|------------------|-------|-------------|
| | | | | |
