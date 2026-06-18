# Haptic Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add subtle haptic feedback to high-priority Solatify interactions.

**Architecture:** A core `SolatifyHaptics` helper wraps Flutter `HapticFeedback`. Feature screens call the helper inside existing tap/toggle handlers without changing business logic.

**Tech Stack:** Flutter, Dart, `services.dart` HapticFeedback, existing navigation and feature screens.

---

### Task 1: Core Haptics Helper

**Files:**
- Create: `lib/core/services/solatify_haptics.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add helper class**

Create `SolatifyHaptics` with static `selection`, `light`, and `success` methods.

- [ ] **Step 2: Keep calls safe**

Wrap haptic calls in `try-catch` and use `debugPrint` for failures.

### Task 2: Priority Interactions

**Files:**
- Modify: `lib/core/navigation/router.dart`
- Modify: `lib/features/tracker/presentation/screens/tracker_screen.dart`
- Modify: `lib/features/quran/presentation/screens/surah_detail_screen.dart`
- Modify: `lib/features/quran/presentation/screens/quran_home_screen.dart`
- Modify: `lib/features/islamic_content/presentation/screens/islamic_content_screen.dart`
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add navigation haptics**

Call `SolatifyHaptics.selection()` for bottom nav and navigation rail destination changes.

- [ ] **Step 2: Add content/menu haptics**

Call selection feedback before Islamic Content menu/result navigation.

- [ ] **Step 3: Add Quran haptics**

Call light feedback for bookmarks and reader switches; success feedback for last-read marking.

- [ ] **Step 4: Add tracker/settings haptics**

Call light/selection feedback for tracker checklist and Settings toggle/menu taps.

### Task 3: Docs And Validation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention subtle haptic feedback in UX notes.

- [ ] **Step 2: Format code**

Run `dart format` on changed Dart and test files.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Add subtle haptic feedback` and push the current branch.
