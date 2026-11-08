# Solatify full app audit — 8 November 2026

Scope: every feature and menu, Android and iOS. Four parallel code reviews (prayer times and
notifications; Quran and content; tracker, Qibla, mosques, home and navigation; performance and
platform configuration) plus runtime checks on a Pixel 7 emulator (Android 16, API 37) and an
iPhone 16 Pro. Each finding below was checked in the code before it was changed.

Verification: `flutter analyze` clean, 241 tests pass (new regression tests are noted below),
`flutter build apk --release` and `flutter build ios --release` succeed.

## Fixed

### Critical / high
| Area | Problem | Fix |
|---|---|---|
| Android navigation | With targetSdk 36, predictive back on Android 16+ bypassed the shell `PopScope`: back from Mosques, Schedule etc. closed the app instead of returning Home (confirmed A/B on the emulator). | `android:enableOnBackInvokedCallback="false"` so back goes through Flutter. Manifest test. |
| Prayer times | In-memory cache keyed by the device date but storing the city date: wrong day's times and a tight recalculation loop (Hive write + notification resync per pass) around midnight when the phone and city timezones differ. | Cache keyed by the city date; refresh timer never re-arms at 0 s. Test fails without the fix. |
| Notifications | Reminders (5–15 min before) played the adhan sound and said "Telah masuk waktu salat…". | Reminders use the short sound on both platforms and their own copy ("Dzuhur 10 menit lagi"). |
| Security (Android) | `flutter_local_notifications` receivers exported: any app could post notifications as Solatify. | `exported="false"`. Manifest test. |
| Quran performance | The surah reader rebuilt the whole screen on every audio position tick (up to 60/s). | Screen watches only playing surah/verse/state; the progress bar is its own widget. |
| Qibla (iOS) | Compass always fell back to magnetic north (true heading needs location updates). | Kilometre-accuracy location updates run alongside the heading while the screen is open. |
| Qibla (Android) | Phones without a gyroscope had no compass. | Falls back to the geomagnetic rotation vector, then accelerometer + magnetometer. |
| Layout | Phones in landscape: the 8-item navigation rail overflowed and cut off Tracker/Settings. | Rail scrolls on short screens (labels hidden). Widget test fails without the fix. |

### Medium
- Notifications that had already fired were removed from the tray by the next sync (≤15 min), on Android with their "Stop adhan" action.
- Home-screen widgets froze after tomorrow's Subuh; they now get 6 days of prayers and localised names.
- Android adhan now takes audio focus (pauses Quran/music); native notification text is localised.
- Timezone: unknown (device-language) country names use the device IANA zone when it matches the location (`flutter_timezone`), instead of a DST-less fixed offset.
- DST-safe day stepping (`cityNoon`) for tomorrow, later days, the widget and the tracker.
- Adhan toggle no longer sends users to system settings when turning it off, and asks for permission only when it is missing.
- Turning adhan off during a sync stops the rest of the sync.
- Quran: tapping a verse during "Play all" jumps within the playlist (previously replaced it with one verse).
- Quran: a connection drop mid-surah now shows "Retry" (continues from the failed verse) on any tab.
- Quran: English users get English translations (the API had them; only Indonesian was parsed).
- Quran: typed, bilingual load errors instead of raw exceptions; partial/empty caches are refreshed; large surahs decode off the UI isolate; offline falls back to older caches.
- Dhikr counters persist for the day (were lost when switching tabs).
- Tracker: rolls to the new day on resume; streak no longer capped at 14 days; renaming a habit keeps its history; target habits count as done only at the target; a failed save keeps the checklist (SnackBar) instead of an error screen; insights and share text are bilingual; heatmap refreshes after habit changes.
- Mosques: no longer silently replaces the saved prayer-times city with the GPS fix; bilingual status/errors; "offline" is told apart from "server busy".
- Onboarding: localised GPS error; finishing handles a failed save.
- Undo SnackBars (tracker, dhikr, onboarding) dismiss themselves.
- Text scale cap raised from 1.25 to 1.5 (checked on device at 1.5).
- Global content search keeps the field and the query in sync; prayer-guide labels localised.

### Low / housekeeping
- Timezone database initialised once instead of twice at startup.
- Countdown timer pauses while the app is in the background.
- `prayer_schedules` box pruned to 14 days; splash `CurvedAnimation` disposed; redundant clip removed from every `GlassContainer`.
- Removed unused dependencies (`cupertino_icons`, `shared_preferences`, `freezed`, `json_serializable`, `build_runner`), the unused bundled `assets/icon.jpg` and the stray `update_settings.dart`.
- Dependencies updated within their ranges (flutter_local_notifications 22.3.3, geolocator 14.1.2, just_audio 0.10.6, audio_session 0.2.4, share_plus 13.3.1, package_info_plus 10.2.2, …); the "plugins that apply Kotlin Gradle Plugin" build warning is gone.
- Google Play: removed the restricted `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission (the app's battery settings page is opened instead; alarms use `setAlarmClock`).
- iOS: bilingual location permission text (`en.lproj` / `id.lproj` `InfoPlist.strings`), `CFBundleLocalizations`, `ITSAppUsesNonExemptEncryption = false`.

## Not changed (needs a decision or more work)
- **Kemenag ihtiyat (+2 min)**: official Kemenag tables add a safety margin; the app does not. Confirm against bimasislam.kemenag.go.id before changing prayer times.
- **Content translations**: many duas, tips, Asmaul Husna meanings, dhikr notes and prayer-guide texts exist only in Indonesian. Needs translated content.
- **Auto-saving "last read"** on leaving a surah would overwrite the reader's manual marker; product decision.
- ~~**Public Overpass servers** are slow (29–35 s measured)~~ — resolved in PR #73: mosque search now uses Photon (about 1 s), with Overpass only as a fallback.
- **Lints**: `analysis_options.yaml` was deliberately deleted; a temporary run found no correctness issues (only style and fire-and-forget settings writes).
- **AGP 9 opt-out flags** (`android.newDsl=false`, `android.builtInKotlin=false`) and the variant-API APK rename will need migrating before the next AGP major.
- **Crash reporting / CI**: none yet; release errors only go to `debugPrint`.
- `assets/icon_white.png` remains an unreferenced review candidate.
