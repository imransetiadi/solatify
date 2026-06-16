# QA Device Commands

**Purpose:** Fast reference for running Solatify on iOS and Android during QA.

## Single Integration-Test Path
- Use `flutter test integration_test/app_test.dart` for the authoritative integration test run.
- Do not create alternate command variants in other QA docs.

## Flutter Run
- iOS simulator: `flutter run -d ios`
- Android emulator or device: `flutter run -d android`
- Profile mode: `flutter run --profile`
- Release smoke test: `flutter run --release`

## Tests
- Full suite: `flutter test`
- Integration test: `flutter test integration_test/app_test.dart`
- Static analysis: `flutter analyze`

## Logs
- iOS logs: Xcode Console
- Android logs: `adb logcat`
- Flutter logs: terminal output from `flutter run`

## Log Capture Examples
- Android: `adb logcat > qa-android-log.txt`
- iOS: save the Xcode Console output or copy the relevant excerpt into the QA note
- For both platforms, include the build number and timestamp with every log excerpt

## Build / Install
- Android debug APK: `flutter build apk`
- Android install: `flutter install`
- iOS build without code signing: `flutter build ios --no-codesign`

## Performance Profiling
- Start in profile mode: `flutter run --profile`
- Open DevTools from the terminal or Flutter menu
- Inspect CPU, memory, and frame rendering while navigating the app

## Useful Device Checks
- Rotate the device or simulator between portrait and landscape
- Test notification permission prompts after a fresh install
- Reboot Android device or emulator to confirm scheduled notifications survive
