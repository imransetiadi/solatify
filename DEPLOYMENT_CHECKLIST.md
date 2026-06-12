# ✅ Pre-Deployment Checklist - Solatify iOS

## System Requirements
- [ ] Xcode 15+ installed on Mac
- [ ] iPhone 16 Pro connected via USB
- [ ] iPhone unlocked and "Trust" selected
- [ ] CocoaPods installed (`sudo gem install cocoapods`)
- [ ] Flutter SDK installed and in PATH

## Project Verification
- [ ] All dart files compile without errors
- [ ] No critical warnings in build output
- [ ] pubspec.yaml dependencies are correct
- [ ] iOS build configuration is valid

## Code Changes Verified
- [ ] ✅ Notification scheduling bug fixed (prayer_times_provider.dart)
- [ ] ✅ Improved countdown provider created (improved_countdown_provider.dart)
- [ ] ✅ Prayer time validator created (prayer_time_validator.dart)
- [ ] ✅ Prayer time utilities created (prayer_time_utilities.dart)
- [ ] ✅ Error handler & logging created (prayer_time_error_handler.dart)
- [ ] ✅ Prayer display widget created (prayer_time_display_widget.dart)
- [ ] ✅ Azan audio service created (azan_audio_service.dart)
- [ ] ✅ Notification scheduler provider created
- [ ] ✅ Settings provider updated with azanSoundEnabled
- [ ] ✅ pubspec.yaml updated with audio assets path

## Pre-Deployment Steps (Run on Your Mac)

### 1. Navigate to Project
```bash
cd /Users/imboyy/Documents/imboyy/aplikasi/Solatify
```

### 2. Clean & Prepare
```bash
flutter clean
flutter pub get
```

### 3. Verify iOS Dependencies
```bash
cd ios
pod install --repo-update
cd ..
```

### 4. Check Connected Devices
```bash
flutter devices
```
Note the device ID for your iPhone 16 Pro.

### 5. Build Release
```bash
flutter build ios --release
```

### 6. Deploy to Device
```bash
flutter run --release -d <YOUR_DEVICE_ID>
```

## Post-Deployment Testing

### On iPhone 16 Pro, verify:
- [ ] ✅ App launches without crashes
- [ ] ✅ Home screen displays correctly
- [ ] ✅ Prayer countdown updates smoothly every 500ms
- [ ] ✅ All 5 prayer times display in correct order
- [ ] ✅ Countdown accuracy (check against system clock)
- [ ] ✅ Settings screen opens and toggles work
- [ ] ✅ Notification permissions can be granted
- [ ] ✅ Azan sound toggle appears in settings
- [ ] ✅ Prayer reminders toggle appears in settings

### Advanced Testing:
- [ ] Navigate through all screens
- [ ] Change calculation method in settings
- [ ] Verify prayer time offsets work
- [ ] Test with different locations (if location feature available)
- [ ] Monitor console output for warnings/errors

## Troubleshooting

### If Build Fails:
```bash
# Complete clean rebuild
flutter clean
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod deintegrate && pod install --repo-update
cd ..
flutter pub get
flutter build ios --release
```

### If Device Not Detected:
1. Unlock iPhone 16 Pro
2. Select "Trust" when prompted
3. Restart Xcode
4. Unplug and replug USB cable
5. Run `flutter devices` again

### If Pods Install Fails:
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

### If Build Succeeds but Run Fails:
1. Check Xcode signing: Xcode → Signing & Capabilities
2. Ensure development team is selected
3. Check provisioning profile is valid
4. Try: `flutter run --release -d <DEVICE_ID> -v` for verbose output

## Important Notes

- First build may take 5-10 minutes (normal)
- Subsequent builds are faster
- Release build is optimized for production
- All refactoring improvements are included
- Azan audio file requirement: Place MP3 at `assets/audio/azan.mp3`

## Version Info
- **App Version:** 1.0.0+1
- **Deployment Date:** 2026-06-12
- **Target Device:** iPhone 16 Pro
- **Minimum iOS:** Check Runner project settings

## Success Criteria
✅ App installs on iPhone 16 Pro
✅ All UI renders correctly
✅ Countdown updates smoothly (500ms refresh)
✅ No console errors or crashes
✅ Prayer times display accurately
✅ Settings work properly
✅ Notifications can be enabled

---

After successful deployment, the Solatify app is ready for use on your iPhone 16 Pro!
