# 📁 Solatify Project Structure Documentation

**Last Updated**: 14 Juni 2026  
**Version**: 2.0 (Reorganized)

---

## 🎯 Overview

Solatify uses **Clean Architecture** with clear separation of concerns. The project is organized into:
- **Core**: Shared infrastructure and cross-cutting concerns
- **Features**: Independent business logic modules

---

## 📊 Complete Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/                              # Shared infrastructure
│   ├── database/
│   │   └── hive_service.dart          # Local database management
│   │
│   ├── navigation/
│   │   └── router.dart                # App routing configuration
│   │
│   ├── theme/
│   │   └── theme.dart                 # Light/Dark theme definitions
│   │
│   ├── localization/
│   │   └── app_localizations.dart     # Multi-language support
│   │
│   ├── utils/
│   │   └── location_service.dart      # Location utilities & city data
│   │
│   ├── services/
│   │   └── (Device-level services)
│   │
│   └── widgets/
│       ├── glass_container.dart       # Glass morphism component
│       ├── responsive_layout.dart     # Responsive UI layout
│       └── islamic/
│           └── islamic_decorations.dart # Islamic design elements
│
├── features/                          # Feature modules
│   │
│   ├── home/                          # Dashboard & Main Screen
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       ├── widgets/
│   │       │   └── prayer_time_display_widget.dart
│   │       └── providers/              # ✨ NEW
│   │           ├── countdown_provider.dart
│   │           └── improved_countdown_provider.dart
│   │
│   ├── notifications/                 # ✨ NEW - Notification System
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── notification_service.dart
│   │   └── presentation/
│   │       └── providers/
│   │           └── notification_scheduler_provider.dart
│   │
│   ├── prayer_schedule/               # Prayer Times Management
│   │   ├── data/
│   │   │   ├── prayer_calculation_service.dart
│   │   │   ├── prayer_time_validator.dart
│   │   │   ├── prayer_time_utilities.dart
│   │   │   ├── prayer_time_error_handler.dart
│   │   │   └── prayer_timezone_service.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── prayer_schedule_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── manual_location_dialog.dart
│   │   │   ├── prayer_times_provider.dart
│   │   │   └── location_provider.dart
│   │   └── domain/
│   │
│   ├── settings/                      # User Preferences
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── settings_provider.dart
│   │
│   ├── quran/                         # Qur'an Viewer
│   │   ├── data/
│   │   │   └── quran_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── quran_home_screen.dart
│   │   │   │   └── surah_detail_screen.dart
│   │   │   └── quran_provider.dart
│   │   └── domain/
│   │       └── models/
│   │           └── quran_models.dart
│   │
│   ├── prayer_schedule/               # (See above)
│   │
│   ├── asmaul_husna/                  # 99 Names of Allah
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── asmaul_husna_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── asmaul_husna_screen.dart
│   │       └── providers/
│   │           └── asmaul_husna_provider.dart
│   │
│   ├── duas/                          # Daily Prayers & Duas
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── dua_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── duas_screen.dart
│   │       └── providers/
│   │           └── duas_provider.dart
│   │
│   ├── dhikr/                         # Islamic Remembrance
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── dhikr_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── dhikr_screen.dart
│   │       └── providers/
│   │           └── dhikr_provider.dart
│   │
│   ├── hijri_calendar/                # Islamic Calendar & Events
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── hijri_event_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── hijri_calendar_screen.dart
│   │       └── providers/
│   │           └── hijri_calendar_provider.dart
│   │
│   ├── islamic_tips/                  # Daily Islamic Tips & Hadith
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── tip_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── islamic_tips_screen.dart
│   │       └── providers/
│   │           └── tips_provider.dart
│   │
│   ├── islamic_content/               # Islamic Content Hub
│   │   └── presentation/
│   │       └── screens/
│   │           └── islamic_content_screen.dart
│   │
│   ├── qibla/                         # Qibla Direction Compass
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── qibla_screen.dart
│   │       └── providers/             # ✨ NEW
│   │
│   ├── mosque/                        # Nearby Mosques
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── nearby_mosque_screen.dart
│   │       └── providers/             # ✨ NEW
│   │
│   ├── onboarding/                    # Onboarding Flow
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── onboarding_screen.dart
│   │       │   └── get_started_screen.dart
│   │       └── providers/             # ✨ NEW
│   │
│   └── reminder/                      # (Reserved for future use)
```

---

## 🔄 Layer Responsibilities

### Core Layer
Provides infrastructure and utilities used across multiple features:
- **database**: Persistent storage (Hive)
- **navigation**: App routing and navigation
- **theme**: UI theming (light/dark mode)
- **localization**: Multi-language support
- **utils**: Utility functions and helpers
- **services**: Device-level services
- **widgets**: Reusable UI components

### Feature Layers

#### Presentation Layer
- **screens/**: Full-screen UI components
- **widgets/**: Feature-specific reusable components
- **providers/**: Riverpod state management (NEW - organized)

#### Data Layer
- **services/**: Data fetching and transformation
- **repositories/**: Data access abstraction

#### Domain Layer
- **models/**: Business logic models

---

## ✨ Recent Changes (v2.0)

### Moved Files
1. ✅ `notification_service.dart`
   - From: `core/services/`
   - To: `features/notifications/data/services/`
   - Reason: Feature-specific, not device-level

2. ✅ `notification_scheduler_provider.dart`
   - From: `prayer_schedule/presentation/`
   - To: `notifications/presentation/providers/`
   - Reason: Cleaner feature separation

3. ✅ `countdown_provider.dart`
   - From: `home/presentation/`
   - To: `home/presentation/providers/`
   - Reason: Provider files in dedicated folder

4. ✅ `improved_countdown_provider.dart`
   - From: `home/presentation/`
   - To: `home/presentation/providers/`
   - Reason: Provider files in dedicated folder

### New Folders Created
- ✅ `features/notifications/` - Dedicated notification feature
- ✅ `features/home/presentation/providers/` - Organized providers
- ✅ `features/qibla/presentation/providers/`
- ✅ `features/mosque/presentation/providers/`
- ✅ `features/onboarding/presentation/providers/`

### Import Updates
- ✅ `main.dart` - Updated notification scheduler import
- ✅ `home_screen.dart` - Updated countdown provider imports
- ✅ `notification_scheduler_provider.dart` - Fixed relative imports

---

## 📋 File Organization Rules

### Do's ✅
- Place feature-specific code in `features/`
- Use `domain/`, `data/`, `presentation/` layers
- Organize providers in `presentation/providers/`
- Keep core infrastructure in `core/`
- Use relative imports within features
- One feature per folder

### Don'ts ❌
- Don't put feature code in `core/`
- Don't mix layers (domain code in presentation)
- Don't scatter providers across folders
- Don't cross-reference features directly
- Don't use absolute imports unnecessarily

---

## 🎯 Architecture Benefits

✅ **Clear Separation of Concerns**
- Each feature has its own domain, data, and presentation

✅ **Scalability**
- Easy to add new features
- Easy to modify existing features without affecting others

✅ **Maintainability**
- Consistent structure across all features
- Easy to find files
- Clear responsibilities

✅ **Testability**
- Each layer can be tested independently
- Easy to mock dependencies

✅ **Reusability**
- Core components shared across features
- No code duplication

---

## 📊 Statistics

**Total Features**: 13
**Organized Providers**: 6
**Core Infrastructure Components**: 9
**Files Reorganized**: 4
**Import Updates**: 3

---

## 🚀 Next Steps

1. Continue organizing remaining features
2. Add domain layers where appropriate
3. Implement proper data repositories
4. Add unit and integration tests
5. Document feature-specific APIs

---

## 📞 Quick Reference

### Finding Features
- UI Features: `lib/features/[feature]/presentation/screens/`
- Business Logic: `lib/features/[feature]/domain/models/`
- Data Layer: `lib/features/[feature]/data/`
- State Management: `lib/features/[feature]/presentation/providers/`

### Adding a New Feature
1. Create `lib/features/[new_feature]/`
2. Add `data/`, `presentation/`, `domain/` folders
3. Create `presentation/screens/` and `presentation/providers/`
4. Implement domain models if needed
5. Update imports in related files

---

**Project Status**: ✅ Clean Architecture Implemented  
**Last Reorganized**: 14 Juni 2026  
**Maintainability**: ⭐⭐⭐⭐⭐

