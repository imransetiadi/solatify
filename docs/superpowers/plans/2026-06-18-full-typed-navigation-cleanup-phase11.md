# Full Typed Navigation Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace remaining internal hardcoded navigation strings with `AppRoutes` while preserving app behavior.

**Architecture:** Keep `AppRoutes` as the single source of truth for internal paths. Feature screens import `package:solatify/core/navigation/app_routes.dart` only where they navigate to internal routes.

**Tech Stack:** Flutter, Dart, GoRouter, existing AppRoutes.

---

### Task 1: Internal Route Literal Audit

**Files:**
- Modify: feature screens with remaining internal `context.go('/...')` or `context.push('/...')`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Search route literals**

Run `rg -n "context\.(go|push|replace)\('/|context\.(go|push|replace)\(\"/|goRouter\.go\('/|goRouter\.go\(\"/" lib test` and classify internal vs external paths.

- [ ] **Step 2: Replace internal literals**

Use `AppRoutes` constants/helpers for app-owned paths only.

### Task 2: Regression Guard

**Files:**
- Modify: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add source guard test**

Assert priority feature sources do not contain direct `context.go('/` or `context.push('/` internal literals.

- [ ] **Step 2: Preserve dynamic route tests**

Keep existing `AppRoutes.quranSurah` assertions.

### Task 3: Docs And Validation

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update README**

Mention internal navigation cleanup uses `AppRoutes` as route source of truth.

- [ ] **Step 2: Format**

Run `dart format` on changed Dart/test files.

- [ ] **Step 3: Verify**

Run `flutter analyze` and `flutter test`.

- [ ] **Step 4: Commit and push**

Commit as `Clean up typed navigation usage` and push current branch.
