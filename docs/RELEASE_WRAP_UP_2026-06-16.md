# Release Wrap-up — 2026-06-16

## Summary

Release stabilization is grouped in the `release-wrap-up` worktree. The Android app bundle build, analyzer, and test gates pass, and remaining store-publish blockers are documented below.

## Verification Status

| Gate | Command | Status | Notes |
| --- | --- | --- | --- |
| Flutter doctor | `flutter doctor -v` | Pass | `No issues found!`; local wireless device discovery warning is non-blocking. |
| Analyzer | `flutter analyze --no-pub` | Pass | `No issues found!` |
| Tests | `flutter test --no-pub` | Pass | `All tests passed!` with 25 passing tests. |
| Android AAB | `flutter build appbundle --release` | Pass | Fresh AAB emitted at `build/app/outputs/bundle/release/app-release.aab`. |

## Release Changes Grouped

- Adhan notification channel uses `prayer_times_adhan_channel_v1`, bundled raw sound `adhan`, and `AndroidScheduleMode.exactAllowWhileIdle`.
- Notification scheduling includes future same-day prayers and tomorrow `Subuh` so the next dawn alarm remains scheduled after all current-day prayer times have passed.
- Analyzer cleanup keeps modified release files package-import safe and removes duplicate type identities in the worktree.
- Regression coverage includes `test/notification_scheduler_test.dart` for tomorrow `Subuh` scheduling.
- Android asset exists at `android/app/src/main/res/raw/adhan.mp3` and is 32 bytes.
- iOS asset exists at `ios/Runner/adhan.mp3`, is registered in `ios/Runner.xcodeproj/project.pbxproj`, and is bundled into `Runner.app`.
- Superpowers workflow artifact `.superpowers/brainstorm/.../server.pid` was checked; PID `39359` was not active, so the untracked folder was removed from the main checkout.

## Build Artifacts

- AAB: `build/app/outputs/bundle/release/app-release.aab` — modified `2026-06-16 07:42:38 WIB`, size `61,359,029 bytes`.

## Known Blockers And Risks

- Adhan audio: the bundled `adhan.mp3` is a 32-byte placeholder and must be replaced with the approved production audio before public release.
- Plugin maintenance warning: Flutter warns that `audio_session`, `flutter_compass_v2`, and `package_info_plus` still apply Kotlin Gradle Plugin; future Flutter versions may require upgrades.
- iOS signing: no-codesign build succeeds, but TestFlight/App Store upload still requires Apple Developer team, provisioning profiles, certificates, and archive signing.

## Google Play Checklist

1. Replace placeholder `android/app/src/main/res/raw/adhan.mp3` with the approved production Adhan audio.
2. Run `flutter doctor -v`, `flutter analyze --no-pub`, and `flutter test --no-pub`.
3. Run `flutter build appbundle --release` and require exit `0` plus a fresh `build/app/outputs/bundle/release/app-release.aab`.
4. Upload the validated AAB in Google Play Console, complete release notes, app content declarations, review, and publish.

## TestFlight / App Store Checklist

1. Replace placeholder `ios/Runner/adhan.mp3` with the approved production Adhan audio and confirm it remains registered in Xcode resources.
2. Configure Apple Developer team, signing certificate, bundle identifier, and provisioning profile.
3. Run `flutter analyze --no-pub` and `flutter test --no-pub`.
4. Create a signed archive via Xcode Organizer or `flutter build ipa --release` with valid signing.
5. Upload to App Store Connect, assign the build to TestFlight or App Store release, complete compliance/privacy metadata, and submit for review.

## Commit Readiness

Suggested commit message when ready:

```text
chore: stabilize release app bundle build
```

Do not commit generated build outputs. Review and stage only source, test, asset, and documentation changes intended for the release stabilization patch.
