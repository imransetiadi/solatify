# Weekly QA Checklist

**Purpose:** Lightweight regression pass for the most important Solatify flows.

## Required Evidence
- Tester name, date, build number, and device used
- Screenshot or log excerpt for any failed step
- Short note for any area that needed retest

## Automated Baseline
- [ ] `flutter test`
- [ ] `flutter analyze`
- [ ] `flutter test integration_test/app_test.dart`

## Navigation Smoke Test
- [ ] Open the app from a cold start
- [ ] Confirm splash screen transitions correctly
- [ ] Verify Home, Schedule, Quran, Content, and More open
- [ ] Open Qibla, Mosque, and Settings from More
- [ ] Return to the main shell without getting stuck

## Responsive Smoke Test
- [ ] Check one small phone and one large phone
- [ ] Rotate portrait and landscape
- [ ] Confirm text and buttons are not clipped
- [ ] Confirm dialogs fit on screen

## Notification Smoke Test
- [ ] Confirm notification permissions still work
- [ ] Schedule a near-future notification
- [ ] Verify the notification appears
- [ ] Reopen the app and confirm no duplicate setup issues

## Performance Smoke Test
- [ ] Launch in `profile` mode
- [ ] Scroll Home, Quran, and Schedule
- [ ] Switch tabs rapidly
- [ ] Watch for stutters or frame drops

## Weekly Log
| Date | Device | Build | Result | Evidence | Notes |
|------|--------|-------|--------|----------|-------|
|      |        |       |        |          |       |
