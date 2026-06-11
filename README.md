# Solatify

Solatify is a Flutter-based Islamic companion app focused on daily worship, prayer time awareness, Quran reading, and lightweight Islamic content. The app is built with an offline-first approach for core content, responsive layouts, and configurable settings for different user preferences.

## Features

- Prayer schedule with location-based calculation.
- Countdown to the next prayer on the home dashboard.
- Prayer time offset settings for Subuh, Dzuhur, Ashar, Magrib, and Isya.
- Qibla direction screen using device compass support.
- Digital Quran with surah list and surah detail pages.
- Daily prayer tracker for marking worship completion.
- Nearby mosque screen with map integration.
- Islamic content hub with Asmaul Husna, daily duas, Hijri calendar events, and Islamic tips.
- Dhikr feature for daily remembrance.
- Reminder and adhan notification settings.
- Light, dark, and system theme support.
- Responsive UI for mobile and tablet layouts.

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- GoRouter for navigation
- Hive and SharedPreferences for local persistence
- Adhan package for prayer time calculation
- Geolocator and Geocoding for location support
- Flutter Compass for qibla direction
- Google Maps Flutter for mosque discovery
- Flutter Local Notifications and Workmanager for reminders
- HTTP for remote Quran data with local fallback behavior

## Project Structure

```text
lib/
+-- core/
|   +-- database/          # Local storage services
|   +-- navigation/        # App router and navigation layout
|   +-- theme/             # Theme configuration
|   +-- utils/             # Location and utility services
|   +-- widgets/           # Shared UI components
+-- features/
    +-- asmaul_husna/      # 99 names of Allah
    +-- dhikr/             # Dhikr feature
    +-- duas/              # Daily duas
    +-- hijri_calendar/    # Islamic calendar events
    +-- home/              # Dashboard and prayer countdown
    +-- islamic_content/   # Islamic content hub
    +-- islamic_tips/      # Daily Islamic tips
    +-- mosque/            # Nearby mosque screen
    +-- onboarding/        # Splash and onboarding flow
    +-- prayer_schedule/   # Prayer calculation and schedule UI
    +-- qibla/             # Qibla compass
    +-- quran/             # Quran repository, models, and screens
    +-- reminder/          # Notification service
    +-- settings/          # User preferences
    +-- tracker/           # Prayer tracker
```

## Requirements

- Flutter SDK compatible with Dart `^3.12.1`
- Android Studio or Xcode for mobile builds
- A physical device or emulator for location, compass, notification, and map features

Check your local setup with:

```bash
flutter doctor
```

## Getting Started

Clone the repository:

```bash
git clone https://github.com/imransetiadi/solatify.git
cd solatify
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

Analyze the project:

```bash
flutter analyze
```

## Platform Notes

Some features require platform permissions and real device hardware:

- Prayer schedule needs location permission for accurate calculation.
- Qibla direction needs compass and sensor support.
- Nearby mosque discovery uses maps and location services.
- Prayer reminders need notification permission.
- Background reminder behavior can differ between Android and iOS depending on platform restrictions.

## Main Screens

- Home: daily dashboard, next prayer countdown, and daily Islamic tip.
- Jadwal: complete prayer schedule.
- Quran: surah list and reading screen.
- Konten: Asmaul Husna, daily duas, Hijri events, and Islamic tips.
- Kiblat: compass-based qibla direction.
- Jurnal: prayer completion tracker.
- Masjid: nearby mosque discovery.
- Pengaturan: calculation method, adhan, theme, language, and prayer offsets.

## Testing

The project includes focused Flutter tests for prayer calculation, prayer schedule behavior, Quran data, and widget behavior.

```bash
flutter test
```

## Repository

GitHub: [imransetiadi/solatify](https://github.com/imransetiadi/solatify)

## License

No license file has been added yet.
