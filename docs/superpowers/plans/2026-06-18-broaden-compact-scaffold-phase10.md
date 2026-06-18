# Broaden Compact Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `SolatifyScreenScaffold` adoption to additional compatible detail/content screens while preserving behavior.

**Architecture:** Keep the scaffold in `lib/core/widgets` as the single shared chrome component. Feature screens keep their existing child content and providers, only replacing repeated Scaffold/AppBar/IslamicBackground/ResponsiveCenter wrappers.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, existing Solatify widgets.

---

### Task 1: Content Detail Scaffold Migration

**Files:**
- Modify: `lib/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart`
- Modify: `lib/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart`
- Modify: `lib/features/prayer_guide/presentation/screens/prayer_guide_screen.dart`

- [ ] **Step 1: Replace repeated wrappers**

Use `SolatifyScreenScaffold` with `backRoute: AppRoutes.islamicContent` and preserve each screen's existing child widget tree.

- [ ] **Step 2: Remove unused imports and variables**

Remove `go_router`, `IslamicBackground`, and `ResponsiveCenter` imports when no longer needed.

### Task 2: Settings Detail Scaffold Migration

**Files:**
- Modify: `lib/features/settings/presentation/screens/notification_health_screen.dart`

- [ ] **Step 1: Replace notification health wrapper**

Use `SolatifyScreenScaffold` with `backRoute: AppRoutes.settings`, preserving actions and scroll body.

- [ ] **Step 2: Preserve diagnostics behavior**

Keep provider watches, refresh/reschedule actions, and all state cards unchanged.

### Task 3: Tests And Docs

**Files:**
- Modify: `test/routed_screen_smoke_test.dart`
- Modify: `README.md`

- [ ] **Step 1: Update scaffold adoption smoke test**

Assert all Phase 9 and Phase 10 target screens import/use `SolatifyScreenScaffold` and `AppRoutes`.

- [ ] **Step 2: Update README architecture note**

Mention broader scaffold adoption for content/detail screens.

### Task 4: Validation And Publish

**Files:**
- All changed Dart files

- [ ] **Step 1: Format Dart files**

Run `dart format` on changed Dart/test files.

- [ ] **Step 2: Analyze and test**

Run `flutter analyze` and `flutter test`; both must pass.

- [ ] **Step 3: Commit and push**

Commit as `Broaden compact scaffold adoption` and push the current branch.
