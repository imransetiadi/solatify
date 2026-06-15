# 🚀 Panduan Deployment Solatify

Dokumen ini menjelaskan cara mem-build dan mendeploy aplikasi Solatify ke App Store dan Google Play.

---

## 📋 Prerequisites

### Android
- Android SDK 21 (Android 5.0) atau lebih tinggi
- Android Studio atau Command Line Tools
- Keystore untuk signing (lihat bagian Signing)

### iOS
- Xcode 14.0 atau lebih tinggi
- Apple Developer Account
- Provisioning Profiles
- Code Signing Certificates

---

## 🔑 Signing Configuration

### Android Keystore

```bash
# Generate keystore (jalankan sekali saja)
keytool -genkey -v -keystore ~/solatify.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias solatify-key

# Jangan pernah share keystore file!
# Store password dengan aman
```

### iOS Code Signing

1. Buka Xcode project
2. Select Runner > Signing & Capabilities
3. Configure Development Team
4. Configure Provisioning Profiles

---

## 📦 Build APK (Android)

### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (untuk Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🍎 Build IPA (iOS)

### Debug IPA
```bash
flutter build ipa --debug
```

### Release IPA
```bash
flutter build ipa --release
# Output: build/ios/ipa/solatify.ipa
```

---

## 📤 Upload ke Google Play

### Setup Play Console Account
1. Buat developer account di [Google Play Console](https://play.google.com/console)
2. Buat aplikasi baru
3. Fill in app details (nama, icon, screenshot, dll)

### Upload APK/AAB
1. Navigate ke Release Management > App Releases
2. Create new release
3. Upload App Bundle (.aab)
4. Fill in release notes
5. Review dan publish

### Langkah Detail
```
1. Google Play Console > Solatify
2. Go to Release Management > Production
3. Create Release
4. Upload solatify.aab (dari build/)
5. Add release notes
6. Review app content
7. Click Publish
```

---

## 🍎 Upload ke App Store

### Setup App Store Connect Account
1. Buat developer account di [Apple Developer](https://developer.apple.com)
2. Create app di App Store Connect
3. Configure certificates dan provisioning profiles

### Upload IPA
```bash
# Verify build
xcrun altool --validate-app -f solatify.ipa \
  -t ios -u [apple_id] -p [password]

# Upload
xcrun altool --upload-app -f solatify.ipa \
  -t ios -u [apple_id] -p [password]
```

### Atau via Xcode
1. Select Generic iOS Device di Xcode
2. Product > Archive
3. Distribute App
4. Upload to App Store

---

## ✅ Pre-Release Checklist

### Versioning
```
pubspec.yaml:
version: 1.0.0+1
  - 1.0.0 = version name
  - +1 = build number
```

### Update Version
```yaml
# pubspec.yaml
version: 1.1.0+2
```

### Pre-Release Tasks
- [ ] Update version number
- [ ] Update CHANGELOG
- [ ] Test di real device (Android & iOS)
- [ ] Verify all features work
- [ ] Check app permissions
- [ ] Test offline functionality
- [ ] Performance testing
- [ ] Security review

---

## 🐛 Testing Sebelum Release

### Functional Testing
```bash
# Run app
flutter run -v

# Test all features:
- [ ] Prayer times calculation
- [ ] Notifications
- [ ] Qur'an viewer
- [ ] Settings
- [ ] Dark mode
- [ ] Localization
```

### Performance Testing
- Check startup time
- Monitor memory usage
- Test battery consumption
- Verify smooth animations

### Device Testing
- [ ] Test di minimal 2 Android devices
- [ ] Test di minimal 2 iOS devices
- [ ] Different screen sizes
- [ ] Different OS versions

---

## 📋 Release Checklist

**1 Week Before Release**
- [ ] Code freeze - stop new features
- [ ] Run full test suite
- [ ] Performance profiling
- [ ] Security audit

**Release Day**
- [ ] Update version
- [ ] Update CHANGELOG
- [ ] Build release binaries
- [ ] Test release builds
- [ ] Upload to stores
- [ ] Tag git release

**After Release**
- [ ] Monitor crash reports
- [ ] Monitor user feedback
- [ ] Be ready for hotfixes
- [ ] Plan next release

---

## 🔄 Hotfix Process

If critical bug found:

```bash
# Create hotfix branch
git checkout -b hotfix/bug-name

# Fix bug
# Test thoroughly
# Update version: 1.0.1+2

# Build and release
flutter build apk --release
flutter build ipa --release

# Commit and tag
git commit -am "chore: hotfix version 1.0.1"
git tag v1.0.1
git push origin hotfix/bug-name
```

---

## 📊 Release Notes Template

```
## Version 1.1.0

### ✨ New Features
- Prayer time notifications dengan pesan Bahasa Indonesia
- Asmaul Husna (99 Nama Allah)
- Dark mode support

### 🐛 Bug Fixes
- Fixed prayer time calculation for certain locations
- Improved notification timing

### 🚀 Improvements
- Better performance
- Improved UI/UX
- Updated translations

### 📦 Dependencies
- Updated Flutter to 3.44.1
- Updated Riverpod to 2.5.1

### 🙏 Thank You
Thanks to all contributors and testers!
```

---

## 🆘 Troubleshooting

### APK/AAB Build Fails
```bash
flutter clean
flutter pub get
flutter build appbundle --release -v
```

### IPA Build Fails
```bash
flutter clean
flutter pub get
cd ios
rm -rf Pods
cd ..
flutter build ipa --release -v
```

### Upload Fails
- Check credentials
- Check file format
- Check file size
- Check network connection
- Check store requirements

---

## 📈 Post-Release Monitoring

- Monitor crash reports daily
- Track user ratings
- Monitor performance metrics
- Respond to user feedback
- Plan next features

---

**Happy deploying! 🚀**

