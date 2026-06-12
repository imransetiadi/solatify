# Azan Audio Setup Guide

## Features Added
This update adds automatic prayer time notifications and azan (call to prayer) sound playback to Solatify.

### Features:
1. **Prayer Time Notifications** - Automatic notifications when each of the 5 prayer times arrives
2. **Azan Auto-Play** - Automatic azan sound playback when prayer time is triggered
3. **Notification Toggle** - Enable/disable all prayer time notifications from settings
4. **Azan Sound Toggle** - Enable/disable automatic azan playback from settings

## Setup Instructions

### Step 1: Azan Audio File
The app includes an azan audio file at `assets/audio/azan.mp3` and native notification sounds for Android/iOS.

Audio source: `Beautiful adhan.ogg` from Wikimedia Commons, public domain/CC0.

**To add the azan audio:**
1. Get an azan audio file in MP3 format (recommended duration: 30-60 seconds)
2. Place it at: `assets/audio/azan.mp3`

**Popular azan sources:**
- Use any high-quality azan recording from Islamic audio libraries
- Ensure the file is in MP3 format
- File size should be reasonable (<5MB)

### Step 2: Settings Integration
The following settings are now available in the Settings screen:

1. **Prayer Reminder** - Enable/disable all prayer time notifications
2. **Putar Azan Otomatis** - Enable/disable automatic azan sound playback when prayer time arrives

### Step 3: Permission Requirements
The app will request the following permissions:
- **Notifications**: To show prayer time reminders
- **Audio**: To play azan sound

Make sure to grant these permissions when prompted.

## Implementation Details

### New Files Created:
- `lib/features/reminder/data/services/azan_audio_service.dart` - Audio playback service
- `lib/features/reminder/presentation/providers/notification_scheduler_provider.dart` - Notification scheduling
- `lib/features/reminder/presentation/providers/azan_audio_provider.dart` - Azan audio initialization

### Modified Files:
- `lib/features/settings/presentation/settings_provider.dart` - Added azanSoundEnabled setting
- `lib/features/settings/presentation/screens/settings_screen.dart` - Added azan toggle UI
- `lib/features/reminder/data/services/notification_service.dart` - Enhanced with azan playback
- `pubspec.yaml` - Added audio assets path

## Usage

### For Users:
1. Go to Settings
2. Toggle "Prayer Reminder" to enable/disable all notifications
3. Toggle "Putar Azan Otomatis" to enable/disable azan sound playback
4. The app will automatically notify and play azan at each prayer time

### For Developers:
The notification scheduler is automatically triggered whenever prayer times change. You can watch the `notificationSchedulerProvider` in your UI to ensure notifications are always up-to-date.

## Testing
To test the notification and azan features:
1. Ensure the azan.mp3 file is in assets/audio/
2. Build the app: `flutter build`
3. Open settings and enable both toggles
4. Wait for the next prayer time or manually adjust system time to test

## Troubleshooting

**Azan not playing:**
- Ensure `assets/audio/azan.mp3` exists
- Check that "Putar Azan Otomatis" is enabled in settings
- Check device volume is not muted
- Ensure notification permissions are granted

**Notifications not showing:**
- Ensure "Prayer Reminder" is enabled in settings
- Check notification permissions are granted
- For Android: Check notification settings for the app

**Audio not found error:**
- Make sure the azan audio file is properly placed at `assets/audio/azan.mp3`
- Run `flutter clean && flutter pub get` to rebuild assets

## Future Enhancements
- Support for multiple azan sounds
- Customizable azan duration
- Volume control for azan
- Snooze functionality
