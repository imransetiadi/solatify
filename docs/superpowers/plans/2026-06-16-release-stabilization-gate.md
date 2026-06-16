# Release Stabilization Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stabilize Solatify for Android and iOS release by making the working tree clear, validating tests/analyzer, checking Adhan assets, and producing Android/iOS build evidence.

**Architecture:** Treat release readiness as a sequence of gates: inventory, quality, Android, iOS, and reporting. Do not add features or perform broad refactors; only fix issues that block analyzer, tests, packaging, or release builds. Keep all changes minimal and report external blockers such as Apple signing separately from application bugs.

**Tech Stack:** Flutter, Dart, Riverpod, flutter_local_notifications, Android Gradle, Xcode/iOS project resources, Hive, Flutter test/analyzer.

---

## File Structure

- `docs/superpowers/specs/2026-06-16-release-stabilization-gate-design.md` — approved design source for this plan.
- `docs/superpowers/plans/2026-06-16-release-stabilization-gate.md` — this implementation plan.
- `lib/features/notifications/data/services/notification_service.dart` — notification channel, custom Adhan sound, exact scheduling mode.
- `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart` — scheduler request creation for today and tomorrow Subuh.
- `test/notification_scheduler_test.dart` — regression test for tomorrow Subuh scheduling after all current-day prayers have passed.
- `android/app/src/main/AndroidManifest.xml` — Android permissions and foreground service declarations.
- `android/app/src/main/res/raw/adhan.mp3` — Android bundled Adhan notification sound resource.
- `ios/Runner/adhan.mp3` — iOS bundled Adhan notification sound resource.
- `ios/Runner.xcodeproj/project.pbxproj` — Xcode project resource registration for `adhan.mp3`.
- `.superpowers/brainstorm/` — empty workflow folder; remove only after verifying it has no files.

---

### Task 1: Release Inventory

**Files:**
- Read: `docs/superpowers/specs/2026-06-16-release-stabilization-gate-design.md`
- Read: `lib/features/notifications/data/services/notification_service.dart`
- Read: `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart`
- Read: `android/app/src/main/AndroidManifest.xml`
- Read: `ios/Runner.xcodeproj/project.pbxproj`
- Read: `android/app/src/main/res/raw/adhan.mp3`
- Read: `ios/Runner/adhan.mp3`

- [ ] **Step 1: Check current Git status**

Run:
```bash
git status --short
```

Expected: Shows the current release-related modified/untracked files, including notification changes, Adhan assets, spec/plan docs, and `test/notification_scheduler_test.dart`.

- [ ] **Step 2: Confirm Adhan Android asset exists**

Run:
```bash
ls -lh android/app/src/main/res/raw/adhan.mp3
```

Expected: The file exists and is non-empty. If the file is missing, recreate the dummy audio file with:
```bash
mkdir -p android/app/src/main/res/raw
echo "fffbe06400000000000000000000000000000000000000000000000000000000" | xxd -r -p > android/app/src/main/res/raw/adhan.mp3
```

- [ ] **Step 3: Confirm Adhan iOS asset exists**

Run:
```bash
ls -lh ios/Runner/adhan.mp3
```

Expected: The file exists and is non-empty. If the file is missing, recreate the dummy audio file with:
```bash
echo "fffbe06400000000000000000000000000000000000000000000000000000000" | xxd -r -p > ios/Runner/adhan.mp3
```

- [ ] **Step 4: Confirm iOS resource is registered**

Run:
```bash
rg -n "adhan.mp3" ios/Runner.xcodeproj/project.pbxproj
```

Expected: At least one `PBXFileReference` entry and one `PBXBuildFile` or Resources build phase entry for `adhan.mp3`.

- [ ] **Step 5: Confirm Android notification permissions**

Run:
```bash
rg -n "SCHEDULE_EXACT_ALARM|USE_EXACT_ALARM|POST_NOTIFICATIONS|RECEIVE_BOOT_COMPLETED|WAKE_LOCK|FOREGROUND_SERVICE" android/app/src/main/AndroidManifest.xml
```

Expected: All listed permissions appear in the manifest.

- [ ] **Step 6: Confirm empty workflow folder is safe to remove**

Run:
```bash
find .superpowers -maxdepth 5 -type f -print
```

Expected: No files are printed. If no files are printed, remove the empty folder:
```bash
rmdir .superpowers/brainstorm .superpowers
```

If `rmdir` fails because the directories are not empty, do not remove anything; include the folder in the final report instead.

---

### Task 2: Quality Gate

**Files:**
- Read: `analysis_options.yaml`
- Read: `test/notification_scheduler_test.dart`
- Modify only if needed: files named by analyzer or failing tests.

- [ ] **Step 1: Run analyzer**

Run:
```bash
flutter analyze --no-pub
```

Expected: `No issues found!`

- [ ] **Step 2: Fix analyzer issues only if present**

If analyzer reports issues, fix only the exact files and lines reported. Examples of acceptable fixes:

```dart
await Hive.openBox<dynamic>(name);
```

```dart
showModalBottomSheet<void>(
  context: context,
  builder: (context) => const SizedBox.shrink(),
);
```

```dart
showDialog<void>(
  context: context,
  builder: (context) => const SizedBox.shrink(),
);
```

Do not perform unrelated refactors.

- [ ] **Step 3: Run full tests**

Run:
```bash
flutter test --no-pub
```

Expected: All tests pass, including `test/notification_scheduler_test.dart`.

- [ ] **Step 4: Fix failing tests only if present**

If `test/notification_scheduler_test.dart` fails, inspect the helper in `lib/features/notifications/presentation/providers/notification_scheduler_provider.dart` and ensure this behavior is present:

```dart
final tomorrowSubuh = tomorrow['subuh'];
if (tomorrowSubuh != null && tomorrowSubuh.isAfter(now)) {
  requests.add(
    PrayerNotificationRequest(
      prayerKey: 'subuh',
      prayerTime: tomorrowSubuh,
      notificationId: 2001,
    ),
  );
}
```

Run the failing test again after any fix:
```bash
flutter test --no-pub test/notification_scheduler_test.dart
```

Expected: The targeted test passes.

---

### Task 3: Android Gate

**Files:**
- Read: `android/app/src/main/AndroidManifest.xml`
- Read: `android/app/src/main/res/raw/adhan.mp3`
- Read: `lib/features/notifications/data/services/notification_service.dart`
- Output: `build/app/outputs/flutter-apk/app-release.apk` or the build artifact path printed by Flutter.

- [ ] **Step 1: Confirm Android Adhan notification code**

Run:
```bash
rg -n "prayer_times_adhan_channel_v1|RawResourceAndroidNotificationSound\('adhan'\)|AndroidScheduleMode.exactAllowWhileIdle" lib/features/notifications/data/services/notification_service.dart
```

Expected: All three patterns are found.

- [ ] **Step 2: Build release APK smoke artifact**

Run:
```bash
flutter build apk --release
```

Expected: Build succeeds and prints an APK output path.

- [ ] **Step 3: Record APK artifact size**

Run:
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

Expected: APK exists and has a non-zero size.

- [ ] **Step 4: If Play Store artifact is needed, build AAB**

Run:
```bash
flutter build appbundle --release
```

Expected: Build succeeds and prints an AAB output path. If signing configuration blocks release output, record the exact signing error in the final report.

---

### Task 4: iOS Gate

**Files:**
- Read: `ios/Runner/adhan.mp3`
- Read: `ios/Runner.xcodeproj/project.pbxproj`
- Output: iOS build output generated by Flutter/Xcode.

- [ ] **Step 1: Confirm iOS Adhan resource registration**

Run:
```bash
rg -n "adhan.mp3" ios/Runner.xcodeproj/project.pbxproj ios/Runner
```

Expected: `ios/Runner/adhan.mp3` exists and `project.pbxproj` contains resource references.

- [ ] **Step 2: Run CocoaPods install if needed**

Run:
```bash
cd ios && pod install
```

Expected: Pods install succeeds. If the command reports repositories are stale, run:
```bash
cd ios && pod install --repo-update
```

- [ ] **Step 3: Build iOS without codesign**

Run:
```bash
flutter build ios --release --no-codesign
```

Expected: Build succeeds without requiring Apple signing credentials.

- [ ] **Step 4: If device signing is required, record manual requirement**

If a signed device or App Store build is required, do not guess signing settings. Record this exact manual requirement in the final report:

```text
iOS signed release still requires Apple Developer provisioning, valid signing certificate, and Xcode archive/export configuration on the release machine.
```

---

### Task 5: Release Report and Final Verification

**Files:**
- Read: `git status --short`
- Read: build artifact paths from Android/iOS commands.
- Modify: none unless the final report is saved separately by user request.

- [ ] **Step 1: Run final analyzer**

Run:
```bash
flutter analyze --no-pub
```

Expected: `No issues found!`

- [ ] **Step 2: Run final tests**

Run:
```bash
flutter test --no-pub
```

Expected: All tests pass.

- [ ] **Step 3: Capture final status**

Run:
```bash
git status --short
```

Expected: Only intended release stabilization files remain modified/untracked.

- [ ] **Step 4: Prepare final user report**

Include these exact sections in the final response:

```text
**Release Gate Result**
- Analyzer: <pass/fail with command evidence>
- Tests: <pass/fail with command evidence>
- Android APK: <path or blocker>
- Android AAB: <path, skipped, or blocker>
- iOS no-codesign build: <pass/fail or blocker>

**Included Changes**
- Notification scheduler includes tomorrow Subuh.
- Android Adhan sound resource is bundled.
- iOS Adhan sound resource is bundled and registered in Xcode.
- Analyzer warnings are cleaned.

**Remaining Manual Steps**
- Replace dummy `adhan.mp3` files with real Adhan audio before public release if still dummy.
- Configure Apple signing manually for App Store/TestFlight release if not already configured.
- Configure Google Play signing/AAB upload manually if needed.
```

- [ ] **Step 5: Do not commit unless user explicitly asks**

Do not run `git commit` unless the user explicitly requests a commit. If the user asks for a commit, use:

```bash
git add docs/superpowers/specs/2026-06-16-release-stabilization-gate-design.md docs/superpowers/plans/2026-06-16-release-stabilization-gate.md lib/core/database/hive_service.dart lib/core/navigation/router.dart lib/features/onboarding/presentation/screens/onboarding_screen.dart lib/features/notifications/data/services/notification_service.dart lib/features/notifications/presentation/providers/notification_scheduler_provider.dart test/notification_scheduler_test.dart android/app/src/main/res/raw/adhan.mp3 ios/Runner/adhan.mp3 ios/Runner.xcodeproj/project.pbxproj
git commit -m "chore: stabilize android and ios release gates"
```
