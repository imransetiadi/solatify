# Typed Routes And Compact Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add route constants/helpers and a shared compact screen scaffold, then migrate priority route usages.

**Architecture:** `AppRoutes` centralizes route strings and dynamic route builders. `SolatifyScreenScaffold` centralizes common screen chrome while leaving feature content unchanged.

**Tech Stack:** Flutter, Dart, GoRouter, existing IslamicBackground and ResponsiveCenter widgets.

---

### Task 1: Route Constants

**Files:**
- Create: `lib/core/navigation/app_routes.dart`
- Modify: `lib/core/navigation/router.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add AppRoutes constants**

Define static constants for splash, onboarding, home, schedule, quran, Islamic Content routes, qibla, mosque, tracker, settings, and notification health.

- [ ] **Step 2: Add dynamic Quran helper**

Add `quranSurah(int surahId, {int? scrollTo})` with proper query string output.

- [ ] **Step 3: Migrate router.dart**

Replace hardcoded route paths in GoRoute and navigation destination definitions with `AppRoutes`.

### Task 2: Compact Scaffold

**Files:**
- Create: `lib/core/widgets/solatify_screen_scaffold.dart`
- Modify: `lib/features/duas/presentation/screens/duas_screen.dart`
- Modify: `lib/features/dhikr/presentation/screens/dhikr_screen.dart`
- Modify: `lib/features/islamic_tips/presentation/screens/islamic_tips_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Create scaffold widget**

Implement a reusable scaffold with title, optional back route, app bar, Islamic background, responsive center, and child.

- [ ] **Step 2: Migrate three content screens**

Use the scaffold in Duas, Dhikr, and Islamic Tips without changing their content widgets.

### Task 3: Priority Route Migrations

**Files:**
- Modify: `lib/features/islamic_content/presentation/screens/islamic_content_screen.dart`
- Modify: `lib/features/quran/presentation/screens/quran_home_screen.dart`
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`
- Modify: `lib/features/notifications/data/services/notification_service.dart`
- Test: `test/routed_screen_smoke_test.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 1: Migrate content routes**

Use `AppRoutes` in menu items, search result routes, and back buttons.

- [ ] **Step 2: Migrate Quran dynamic routes**

Use `AppRoutes.quranSurah` for last-read/bookmark/surah navigation.

- [ ] **Step 3: Migrate notification/settings routes**

Use `AppRoutes.schedule` and `AppRoutes.notificationHealth`.

### Task 4: Docs And Validation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention typed route constants and compact scaffold in architecture notes.

- [ ] **Step 2: Format code**

Run `dart format` on changed Dart/test files.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Add typed routes and compact scaffold` and push current branch.
