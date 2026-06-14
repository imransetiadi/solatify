# 🏗️ Solatify - Arsitektur Aplikasi

Dokumen ini menjelaskan arsitektur dan design pattern yang digunakan di Solatify.

---

## 📐 Architecture Pattern

Solatify menggunakan **Clean Architecture** dengan pola **MVVM + Riverpod**.

```
┌─────────────────────────────────────┐
│      PRESENTATION LAYER             │
│  (Screens, Widgets, Providers)      │
└─────────────────────────────────────┘
              ↕️ (Dependencies)
┌─────────────────────────────────────┐
│       DATA LAYER                    │
│  (Repositories, Services, Models)   │
└─────────────────────────────────────┘
              ↕️ (Dependencies)
┌─────────────────────────────────────┐
│      DOMAIN LAYER                   │
│  (Entities, Use Cases)              │
└─────────────────────────────────────┘
```

---

## 📦 Core Modules

### Database (Hive)
```
core/database/
└── hive_service.dart
    - Mengelola local storage
    - Caching system
    - Data persistence
```

### Navigation (GoRouter)
```
core/navigation/
└── router.dart
    - App routing
    - Deep linking
    - Navigation state
```

### Theme
```
core/theme/
└── theme.dart
    - Light/Dark theme
    - Color palette
    - Typography
```

### Localization (intl)
```
core/localization/
└── app_localizations.dart
    - Multi-language support
    - Indonesian & English
    - Easy to extend
```

### Widgets
```
core/widgets/
├── glass_container.dart
├── responsive_layout.dart
└── islamic/
    └── islamic_decorations.dart
```

---

## 🎯 Feature Architecture

Setiap feature mengikuti struktur yang konsisten:

```
features/[feature_name]/
├── data/
│   ├── models/
│   │   └── model.dart         # JSON serialization
│   ├── services/
│   │   └── service.dart       # API/local calls
│   └── repositories/
│       └── repository.dart    # Data abstraction
│
├── domain/
│   └── models/
│       └── entity.dart        # Business entities
│
└── presentation/
    ├── screens/
    │   └── screen.dart        # Full screens
    ├── widgets/
    │   └── widget.dart        # Reusable widgets
    └── providers/
        └── provider.dart      # State management
```

---

## 🔄 State Management (Riverpod)

Menggunakan **Riverpod** untuk state management.

### Provider Types

**StateNotifierProvider** - Mutable state
```dart
final countdownProvider = StateNotifierProvider<CountdownNotifier, CountdownState>(
  (ref) => CountdownNotifier(ref),
);
```

**Provider** - Immutable computed value
```dart
final totalUsersProvider = Provider((ref) {
  return ref.watch(usersProvider).length;
});
```

**FutureProvider** - Async data
```dart
final prayerTimesProvider = FutureProvider((ref) async {
  return await getPrayerTimes();
});
```

---

## 🏛️ Feature: Prayer Schedule

### Data Flow
```
PrayerTimesProvider (state)
    ↓
PrayerCalculationService (business logic)
    ↓
Hive Database (persistence)
    ↓
LocationProvider (dependency)
```

### Notification System
```
NotificationSchedulerProvider
    ↓
NotificationService
    ↓
flutter_local_notifications
    ↓
Device OS (Android/iOS)
```

---

## 🔐 Dependency Injection

Menggunakan **Riverpod** untuk DI:

```dart
// Inject provider
final serviceProvider = Provider((ref) {
  return MyService();
});

// Use in another provider
final useCaseProvider = Provider((ref) {
  final service = ref.watch(serviceProvider);
  return MyUseCase(service);
});
```

---

## 🧠 Design Patterns

### 1. **Provider Pattern**
```dart
final myDataProvider = StateNotifierProvider<Notifier, State>(...);
```

### 2. **Repository Pattern**
```dart
class UserRepository {
  Future<List<User>> getUsers() async { ... }
}
```

### 3. **Singleton Pattern**
```dart
class NotificationService {
  static final _instance = NotificationService._internal();
  factory NotificationService() => _instance;
}
```

### 4. **Builder Pattern**
```dart
class QueryBuilder {
  QueryBuilder where(String field) { ... }
  QueryBuilder orderBy(String field) { ... }
  Query build() { ... }
}
```

---

## 📊 Data Models

### JSON Serialization
```dart
class Prayer extends Equatable {
  final String name;
  final DateTime time;
  
  const Prayer({required this.name, required this.time});
  
  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      name: json['name'],
      time: DateTime.parse(json['time']),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time.toIso8601String(),
  };
}
```

---

## 🔄 Data Flow Example

### Getting Prayer Times
```
UI (PrayerScheduleScreen)
    ↓
Watch (prayerTimesProvider)
    ↓
StateNotifier (reads settings, location)
    ↓
PrayerCalculationService (calculates times)
    ↓
Hive Database (caches result)
    ↓
UI Updates
```

---

## 🧪 Testing Architecture

### Unit Tests
```dart
test('prayer calculation is accurate', () {
  final result = calculatePrayerTimes(...);
  expect(result.subuh, DateTime(...));
});
```

### Widget Tests
```dart
testWidgets('prayer display shows time', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('04:30'), findsOneWidget);
});
```

---

## 🚀 Performance Considerations

### 1. Lazy Loading
Providers diinisialisasi hanya ketika digunakan

### 2. Caching
Data disimpan di Hive untuk akses cepat

### 3. Async Operations
Menggunakan FutureProvider untuk operasi async

### 4. Memory Management
Proper cleanup di dispose methods

---

## 🔄 Error Handling

### Centralized Error Handler
```dart
class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is SocketException) {
      return 'Network error';
    }
    return 'Unknown error';
  }
}
```

---

## 📈 Scalability

### Adding New Feature
1. Create `features/[name]/` folder
2. Implement data layer
3. Implement domain layer
4. Implement presentation layer
5. Add routes di router.dart

### Extending Existing Feature
1. Add new provider
2. Add new widget/screen
3. Update navigation if needed

---

## 📚 Best Practices

✅ Keep layers separated
✅ Use providers consistently
✅ Proper error handling
✅ Meaningful variable names
✅ Document complex logic
✅ Test business logic
✅ Cache appropriate data
✅ Lazy load when possible

---

**Keep the architecture clean and maintainable!** 🏗️

