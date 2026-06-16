# Adhan Alarm Notification Design Spec

**Goal:** Modify the existing prayer notification system to play a custom Adhan audio instead of the default system sound.

**Approach:** Option 1 (Standard Notification with Custom Sound). The notification operates as a standard OS banner but plays a custom `.mp3` file.

## 1. Audio Assets
- **File Name**: `adhan.mp3`
- **Location Android**: `android/app/src/main/res/raw/adhan.mp3`
- **Location iOS**: Needs to be bundled directly into Xcode project (`ios/Runner/adhan.mp3`).

## 2. Notification Channel Handling (Android)
- **Constraint**: Android prevents modifying the sound of an existing notification channel once it's created.
- **Solution**: We will create a completely new channel ID: `prayer_times_adhan_channel_v1`.
- **Channel Properties**:
  - `sound`: `RawResourceAndroidNotificationSound('adhan')`
  - `importance`: `Importance.max`

## 3. iOS Handling
- **Property**: `DarwinNotificationDetails(sound: 'adhan.mp3')`
- **Constraint**: iOS limits notification sounds to 30 seconds.

## 4. Code Modifications
Target File: `lib/features/notifications/data/services/notification_service.dart`

- Update `_createNotificationChannel` with the new ID and sound configuration.
- Update `showPrayerNotification` and `schedulePrayerNotification` with the correct `AndroidNotificationDetails` and `DarwinNotificationDetails`.
