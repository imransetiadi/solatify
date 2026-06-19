# Qibla Heading Adapter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Decouple `QiblaScreen` from `flutter_compass_v2` behind an internal heading adapter/provider without changing Qibla UI behavior.

**Architecture:** Add a small Clean Architecture slice inside `lib/features/qibla`: a domain entity, domain repository contract, data implementation backed by `flutter_compass_v2`, and a Riverpod stream provider. The presentation layer reads `qiblaHeadingProvider` and keeps its current simulated-heading fallback when sensor heading is unavailable.

**Tech Stack:** Flutter, Dart null safety, Riverpod, `flutter_compass_v2`, existing Solatify Clean Architecture conventions.

---

## File Structure

- Create `lib/features/qibla/domain/entities/qibla_heading.dart` — immutable heading value with nullable degrees.
- Create `lib/features/qibla/domain/repositories/qibla_heading_repository.dart` — abstraction for heading stream.
- Create `lib/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart` — adapter from `FlutterCompass.events` to `QiblaHeading`.
- Create `lib/features/qibla/presentation/providers/qibla_heading_provider.dart` — Riverpod providers for repository and stream.
- Modify `lib/features/qibla/presentation/screens/qibla_screen.dart` — remove direct plugin import and consume provider.
- Modify `test/routed_screen_smoke_test.dart` — add regression test proving the plugin import is isolated from presentation.

---

### Task 1: Add Regression Test For Adapter Boundary

**Files:**
- Modify: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Write the failing source-level regression test**

Add this test near the existing Qibla tests in `test/routed_screen_smoke_test.dart`:

```dart
test('Qibla heading source is isolated behind adapter', () {
  final qiblaScreen = File(
    'lib/features/qibla/presentation/screens/qibla_screen.dart',
  ).readAsStringSync();
  final qiblaProvider = File(
    'lib/features/qibla/presentation/providers/qibla_heading_provider.dart',
  ).readAsStringSync();
  final qiblaAdapter = File(
    'lib/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart',
  ).readAsStringSync();

  expect(qiblaScreen, isNot(contains('flutter_compass_v2')));
  expect(qiblaScreen, contains('qiblaHeadingProvider'));
  expect(qiblaProvider, contains('qiblaHeadingRepositoryProvider'));
  expect(qiblaAdapter, contains('flutter_compass_v2'));
  expect(qiblaAdapter, contains('FlutterCompass.events'));
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test --no-pub test/routed_screen_smoke_test.dart --plain-name "Qibla heading source is isolated behind adapter"
```

Expected: FAIL because `qibla_heading_provider.dart` and `flutter_compass_qibla_heading_repository.dart` do not exist yet, or because `QiblaScreen` still imports `flutter_compass_v2`.

- [ ] **Step 3: Commit failing test only**

```bash
git add test/routed_screen_smoke_test.dart
git commit -m "test: cover qibla heading adapter boundary"
```

---

### Task 2: Add Qibla Heading Domain Contract

**Files:**
- Create: `lib/features/qibla/domain/entities/qibla_heading.dart`
- Create: `lib/features/qibla/domain/repositories/qibla_heading_repository.dart`

- [ ] **Step 1: Create heading entity**

Create `lib/features/qibla/domain/entities/qibla_heading.dart`:

```dart
class QiblaHeading {
  const QiblaHeading({required this.degrees});

  final double? degrees;

  bool get hasSensorHeading => degrees != null;
}
```

- [ ] **Step 2: Create repository contract**

Create `lib/features/qibla/domain/repositories/qibla_heading_repository.dart`:

```dart
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';

abstract class QiblaHeadingRepository {
  Stream<QiblaHeading> watchHeading();
}
```

- [ ] **Step 3: Run analyzer for new domain files**

Run:

```bash
flutter analyze --no-pub
```

Expected: analyzer may still fail until adapter/provider files are added in later tasks if Task 1 references missing files. There should be no syntax errors in the two new domain files.

- [ ] **Step 4: Commit domain contract**

```bash
git add lib/features/qibla/domain/entities/qibla_heading.dart lib/features/qibla/domain/repositories/qibla_heading_repository.dart
git commit -m "feat: add qibla heading contract"
```

---

### Task 3: Add Flutter Compass Adapter And Provider

**Files:**
- Create: `lib/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart`
- Create: `lib/features/qibla/presentation/providers/qibla_heading_provider.dart`

- [ ] **Step 1: Create plugin-backed adapter**

Create `lib/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart`:

```dart
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';
import 'package:solatify/features/qibla/domain/repositories/qibla_heading_repository.dart';

class FlutterCompassQiblaHeadingRepository implements QiblaHeadingRepository {
  const FlutterCompassQiblaHeadingRepository();

  @override
  Stream<QiblaHeading> watchHeading() {
    return FlutterCompass.events.map(
      (event) => QiblaHeading(degrees: event.heading),
    );
  }
}
```

- [ ] **Step 2: Create Riverpod providers**

Create `lib/features/qibla/presentation/providers/qibla_heading_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart';
import 'package:solatify/features/qibla/domain/entities/qibla_heading.dart';
import 'package:solatify/features/qibla/domain/repositories/qibla_heading_repository.dart';

final qiblaHeadingRepositoryProvider = Provider<QiblaHeadingRepository>(
  (ref) => const FlutterCompassQiblaHeadingRepository(),
);

final qiblaHeadingProvider = StreamProvider<QiblaHeading>((ref) {
  return ref.watch(qiblaHeadingRepositoryProvider).watchHeading();
});
```

- [ ] **Step 3: Run focused boundary test**

Run:

```bash
flutter test --no-pub test/routed_screen_smoke_test.dart --plain-name "Qibla heading source is isolated behind adapter"
```

Expected: still FAIL because `QiblaScreen` still imports `flutter_compass_v2` and does not yet use `qiblaHeadingProvider`.

- [ ] **Step 4: Commit adapter and provider**

```bash
git add lib/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart lib/features/qibla/presentation/providers/qibla_heading_provider.dart
git commit -m "feat: add qibla heading adapter"
```

---

### Task 4: Refactor Qibla Screen To Use Provider

**Files:**
- Modify: `lib/features/qibla/presentation/screens/qibla_screen.dart`

- [ ] **Step 1: Replace direct plugin import**

Remove:

```dart
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
```

Add:

```dart
import 'package:solatify/features/qibla/presentation/providers/qibla_heading_provider.dart';
```

- [ ] **Step 2: Replace StreamBuilder with provider watch**

Inside `build`, after calculating theme variables, add:

```dart
final headingState = ref.watch(qiblaHeadingProvider);
final sensorHeading = headingState.valueOrNull?.degrees;
final hasSensor = sensorHeading != null;
final heading = sensorHeading ?? _simulatedHeading;
```

Then replace:

```dart
child: StreamBuilder<CompassEvent>(
  stream: FlutterCompass.events,
  builder: (context, snapshot) {
    final hasSensor =
        snapshot.hasData && snapshot.data?.heading != null;
    final heading = hasSensor
        ? snapshot.data!.heading!
        : _simulatedHeading;

    final qiblaRelativeAngle = (qiblaAngle - heading + 360) % 360;
```

with:

```dart
child: Builder(
  builder: (context) {
    final qiblaRelativeAngle = (qiblaAngle - heading + 360) % 360;
```

Keep the rest of the builder body unchanged and close it as `Builder` instead of `StreamBuilder`.

- [ ] **Step 3: Run formatter**

Run:

```bash
dart format lib/features/qibla/presentation/screens/qibla_screen.dart
```

Expected: file formatted.

- [ ] **Step 4: Run focused Qibla tests**

Run:

```bash
flutter test --no-pub test/routed_screen_smoke_test.dart --plain-name "Qibla screen renders"
flutter test --no-pub test/routed_screen_smoke_test.dart --plain-name "Qibla heading source is isolated behind adapter"
```

Expected: both PASS.

- [ ] **Step 5: Commit Qibla screen refactor**

```bash
git add lib/features/qibla/presentation/screens/qibla_screen.dart
git commit -m "refactor: consume qibla heading provider"
```

---

### Task 5: Full Verification And PR

**Files:**
- Verify all changed files.

- [ ] **Step 1: Run analyzer**

```bash
flutter analyze --no-pub
```

Expected: `No issues found!`

- [ ] **Step 2: Run full tests**

```bash
flutter test --no-pub
```

Expected: all tests pass.

- [ ] **Step 3: Run debug APK build**

```bash
flutter build apk --debug --no-pub
```

Expected: build succeeds. Existing KGP warnings may still appear.

- [ ] **Step 4: Optional Android Qibla smoke test**

If Android device is connected, run:

```bash
flutter run -d GMFYIJQKVOM7AIYP --debug --no-pub
```

Expected: Qibla screen opens without crash and logs show compass sensor activity when the device is rotated.

- [ ] **Step 5: Create PR**

```bash
git push -u origin spike/qibla-heading-adapter
gh pr create --base main --head spike/qibla-heading-adapter --title "refactor: isolate qibla heading source" --body "## Summary
- Add Qibla heading domain contract and plugin-backed adapter
- Move flutter_compass_v2 usage out of QiblaScreen
- Add regression coverage for the adapter boundary

## Test Plan
- flutter analyze --no-pub
- flutter test --no-pub
- flutter build apk --debug --no-pub"
```
