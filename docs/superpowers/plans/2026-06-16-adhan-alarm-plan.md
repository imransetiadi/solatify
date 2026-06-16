# Adhan Alarm Notification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modify the local notification service to play a custom Adhan sound instead of the default beep.

**Architecture:** Modifying `flutter_local_notifications` payload to target raw assets and bumping the Android channel ID to bypass cache.

**Tech Stack:** `flutter_local_notifications`, native raw resources.

---

### Task 1: Generate Mock Audio Asset

**Files:**
- Create: `android/app/src/main/res/raw/adhan.mp3`

- [ ] **Step 1: Create raw directory and place a dummy mp3**
*(Note: A silent 1KB dummy mp3 is sufficient for compiling. The user will replace it with the real adhan later).*

```bash
mkdir -p android/app/src/main/res/raw
# Using hex representation of a tiny 1-frame MP3
echo "fffbe06400000000000000000000000000000000000000000000000000000000" | xxd -r -p > android/app/src/main/res/raw/adhan.mp3
```

### Task 2: Modify Notification Service Code

**Files:**
- Modify: `lib/features/notifications/data/services/notification_service.dart`

- [ ] **Step 1: Update Android Channel Creation**
Change the channel ID to `prayer_times_adhan_channel_v1` and attach the raw sound.

```dart
// Modify _createNotificationChannel()
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'prayer_times_adhan_channel_v1',
  'Prayer Times Adhan',
  description: 'Adhan notifications for prayer times',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('adhan'),
  enableVibration: true,
  enableLights: true,
);
```

- [ ] **Step 2: Update Notification Details Config**
Apply the new sound configurations in both `showPrayerNotification` and `schedulePrayerNotification`.

```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'prayer_times_adhan_channel_v1',
  'Prayer Times Adhan',
  channelDescription: 'Adhan notifications for prayer times',
  importance: Importance.max,
  priority: Priority.high,
  enableVibration: true,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('adhan'),
  enableLights: true,
  icon: '@mipmap/ic_launcher',
);

const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  sound: 'adhan.mp3', // Requires manual Xcode import by the user
);
```

- [ ] **Step 3: Run Flutter Analyzer**
```bash
flutter analyze lib/features/notifications
```
