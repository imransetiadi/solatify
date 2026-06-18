# Unified State Views Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable Solatify state view and apply it to key loading, empty, and error states.

**Architecture:** A core widget renders consistent GlassContainer-based state cards. Feature screens keep their existing async logic and swap inline `CircularProgressIndicator`/plain `Text` states for the shared component.

**Tech Stack:** Flutter, Dart, existing GlassContainer, responsive tokens, Riverpod async screens.

---

### Task 1: Shared State Widget

**Files:**
- Create: `lib/core/widgets/solatify_state_view.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Create enum and widget**

Add `SolatifyStateVariant` and `SolatifyStateView` with icon, title, description, optional action label/callback, and loading progress support.

- [ ] **Step 2: Theme from tokens**

Use `GlassContainer`, `SolatifyType`, `SolatifyIconSize`, and theme colors instead of hardcoded screen-specific colors.

- [ ] **Step 3: Add smoke test**

Render loading/error/empty variants in a simple widget test or source smoke assertion.

### Task 2: Apply To Priority Screens

**Files:**
- Modify: `lib/features/islamic_content/presentation/screens/islamic_content_screen.dart`
- Modify: `lib/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart`
- Modify: `lib/features/islamic_tips/presentation/screens/islamic_tips_screen.dart`
- Modify: `lib/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart`
- Modify: `lib/features/tracker/presentation/screens/tracker_screen.dart`
- Modify: `lib/features/quran/presentation/screens/surah_detail_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Replace loading states**

Use `SolatifyStateView.loading(...)` or equivalent constructor for key async loading branches.

- [ ] **Step 2: Replace empty states**

Use `SolatifyStateView.empty(...)` for no data/search result states.

- [ ] **Step 3: Replace error states**

Use `SolatifyStateView.error(...)` with retry actions where existing retry exists.

- [ ] **Step 4: Add adoption assertions**

Assert selected screen sources import or reference `SolatifyStateView`.

### Task 3: Docs And Validation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention unified empty/loading/error state patterns in UX/performance notes.

- [ ] **Step 2: Format code**

Run `dart format` on changed Dart and test files.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Add unified state views` and push the current branch.
