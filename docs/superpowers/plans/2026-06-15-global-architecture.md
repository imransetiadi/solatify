# Global Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a strict Clean Architecture standard for Solatify using a feature-first structure, Riverpod for state management, and Hive for local storage.

**Architecture:** A three-layered approach (Data, Domain, Presentation) encapsulated within modular features. Global utilities live in `lib/core/`.

**Tech Stack:** Flutter, Riverpod, Hive

---

### Task 1: Reorganize Core Directory Structure

**Files:**
- Create: `lib/core/config/app_config.dart`
- Create: `lib/core/error/failures.dart`
- Create: `lib/core/network/api_client.dart`
- Delete: unused directories if they exist (we will leave existing ones to prevent breaking changes, but create the new required ones).

- [ ] **Step 1: Create missing core directories and stub files**

```bash
mkdir -p lib/core/config lib/core/error lib/core/network
```

- [ ] **Step 2: Add failure classes**

```dart
// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}
```

- [ ] **Step 3: Commit Core directory setup**

```bash
git add lib/core/
git commit -m "chore(core): scaffold strict core architecture directories"
```

### Task 2: Standardize Hive Service

**Files:**
- Modify: `lib/core/database/hive_service.dart`
- Create: `lib/core/database/hive_constants.dart`

- [ ] **Step 1: Define Hive constants**

```dart
// lib/core/database/hive_constants.dart
class HiveConstants {
  static const String settingsBox = 'settings_box';
}
```

- [ ] **Step 2: Standardize Hive Initialization in HiveService**

```dart
// lib/core/database/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(HiveConstants.settingsBox);
  }
}
```

- [ ] **Step 3: Commit Hive standardization**

```bash
git add lib/core/database/
git commit -m "chore(database): standardize hive service and constants"
```

### Task 3: Ensure Riverpod ProviderScope in Main

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Ensure main.dart wraps app in ProviderScope and calls HiveService.init**

```dart
// lib/main.dart (update existing to ensure this structure)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/database/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Solatify Architecture'))),
    );
  }
}
```

- [ ] **Step 2: Commit main.dart updates**

```bash
git add lib/main.dart
git commit -m "chore(main): add ProviderScope and Hive initialization"
```

### Task 4: Scaffold Feature Template

**Files:**
- Create: `lib/features/template_feature/` and subdirectories

- [ ] **Step 1: Scaffold Data Layer**

```bash
mkdir -p lib/features/template_feature/data/datasources
mkdir -p lib/features/template_feature/data/models
mkdir -p lib/features/template_feature/data/repositories
```

- [ ] **Step 2: Scaffold Domain Layer**

```bash
mkdir -p lib/features/template_feature/domain/entities
mkdir -p lib/features/template_feature/domain/repositories
mkdir -p lib/features/template_feature/domain/usecases
```

- [ ] **Step 3: Scaffold Presentation Layer**

```bash
mkdir -p lib/features/template_feature/presentation/providers
mkdir -p lib/features/template_feature/presentation/screens
mkdir -p lib/features/template_feature/presentation/widgets
```

- [ ] **Step 4: Commit Feature template**

```bash
git add lib/features/template_feature/
git commit -m "chore(features): scaffold 3-layer architecture template feature"
```
