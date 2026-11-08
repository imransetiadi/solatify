# Prayer time corrections (koreksi waktu salat)

Audit and rules for how Solatify turns astronomical prayer times into the
times users see, hear (adhan) and get on the widget. Last audited
2026-11-08.

## Two layers, kept separate

| Layer | Who sets it | Where | Purpose |
|---|---|---|---|
| **Method standard** | The app, per calculation method | `PrayerMethodStandard` in `prayer_calculation_service.dart` | Reproduce the official schedule: ihtiyat (safety margin) and rounding |
| **Manual correction** | The user, per prayer | Settings > Koreksi Waktu Salat (`prayer_offsets` setting) | Match a local mosque's adhan |

"0 minutes" always means the method's official time. A correction only moves
away from it. Never use corrections to emulate a method standard; if an
official schedule needs a margin, add it to the standard.

Order of operations (adhan applies all of them before rounding):

```
astronomical time + method ihtiyat + user correction, then rounded
```

## Kemenag RI standard

| | Subuh | Dzuhur | Ashar | Magrib | Isya |
|---|---|---|---|---|---|
| Ihtiyat (minutes) | 2 | 3 | 2 | 3 | 2 |

Times are **rounded up** to the next minute, so a published minute is never
earlier than the computed instant. Angles: Subuh -20°, Isya -18°, Ashar Shafi'i.

### Evidence

Calibrated on 2026-11-08 against Kemenag's published schedules (Bimas Islam
data via `api.myquran.com`) for Banda Aceh, Medan, Jakarta, Surabaya,
Denpasar, Makassar and Jayapura on 15 Jan, 15 Apr, 15 Jul and 8 Nov 2026
(140 times):

| | Before | After |
|---|---|---|
| Same minute as Kemenag | 0 / 140 | 121 / 140 (86%) |
| Earlier than Kemenag | 140 / 140 (2 to 4 min) | 3 / 140 (1 min) |
| Largest difference | 4 min | 1 min |
| Magrib earlier than Kemenag | 28 / 28 | 0 / 28 |

The remaining one-minute differences come from the reference coordinates
(Kemenag uses one point per regency/city; the app uses the user's GPS or the
city centre in `location_service.dart`). The fixtures live in
`test/prayer_method_standard_test.dart` and fail if accuracy drops below 85%
or more than a minute off.

Secondary sources disagree on Kemenag's Dzuhur margin (2 or 3 minutes) and do
not state the rounding rule, which is why the values were fitted to the
published schedules rather than copied from an article. Magrib fits 3 minutes;
Kemenag's sunset includes refinements (such as elevation) that the app does
not model, so the extra minute keeps Magrib from ever being early.

**Re-calibrate** when Kemenag changes its criteria, or yearly: fetch a few
cities and dates, update the fixture, run the test.

### Other methods

MWL, ISNA, Egypt, Umm al-Qura and MUIS keep adhan's output (nearest minute,
no extra margin). Unknown stored method names fall back to Kemenag parameters
**and** the Kemenag standard, so the two never disagree.

## Manual corrections: rules

- Whole minutes, **-60 to +60**, per prayer. Values are sanitised on every
  read and write (`sanitizePrayerOffsets`): missing keys become 0, decimals
  are rounded, out-of-range values are clamped, junk is dropped. A corrupt or
  old backup can never push the adhan hours away.
- **Prayer order is preserved.** The dialog refuses a value that would put a
  prayer at or past its neighbour (with the neighbour's own correction),
  because the countdown, notifications and widget all assume Subuh < Dzuhur <
  Ashar < Magrib < Isya.
- **Subuh and Magrib earlier than standard** show a warning: the adhan would
  sound before the official time, and these two also mark the start and the
  end of the fast.
- The dialog shows **today's standard time and the resulting time**, so users
  do not have to do the arithmetic.
- A failed save shows a SnackBar and leaves the schedule unchanged; the state
  only changes after the value is stored.
- **Reset all** returns every prayer to the standard time.
- The schedule screen says when times include Kemenag's ihtiyat and lists any
  active manual corrections.

## Propagation

Every consumer calls `PrayerCalculationService.calculatePrayerTimes` with
`settings.calculationMethod` and `settings.prayerOffsets`: the home countdown
(`prayerTimesProvider`), the schedule screen, notifications (6 days ahead) and
the home screen widgets. A change to a correction recalculates
`prayerTimesProvider`, which reschedules notifications; the widget provider
watches settings directly. The calculation cache key includes the method and
the sanitised corrections.

## Migration (first release after v1.0.0-rc4)

Kemenag times move 2 to 4 minutes later. Users who had added minutes by hand
to match Kemenag would now be late by that much, so Settings shows a one-time
notice when the method is Kemenag and any correction is non-zero, with
"Reset all corrections" and "Keep my corrections". The choice is stored as
`ihtiyat_notice_dismissed`.

## Checklist for future changes

- [ ] Does the change alter what "0 minutes" means? Then it belongs in the
      method standard, with fixtures, not in user corrections.
- [ ] Are all five consumers still going through `calculatePrayerTimes`?
- [ ] Do Subuh and Magrib stay at or after the official time by default?
- [ ] Are both locales (id, en) updated for any new copy?
- [ ] `flutter test test/prayer_method_standard_test.dart test/prayer_offset_rules_test.dart`
