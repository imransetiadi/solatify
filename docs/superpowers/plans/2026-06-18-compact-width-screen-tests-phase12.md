# Compact Width Screen Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add compact-width widget smoke tests for core user-facing screens.

**Architecture:** Use Flutter widget tests with a fixed compact `tester.view.physicalSize` and existing Riverpod/Hive setup. Keep tests deterministic by checking render anchors and `tester.takeException()` instead of committing fragile image baselines.

**Tech Stack:** Flutter test, Riverpod, Hive, existing screen widgets.

---

### Task 1: Compact Test Harness

**Files:**
- Create: `test/compact_width_smoke_test.dart`

- [ ] **Step 1: Add Hive setup**

Initialize temporary Hive boxes used by Home, Schedule, Quran, Settings, and Content screens.

- [ ] **Step 2: Add compact surface helper**

Set `tester.view.physicalSize = const Size(360, 780)` and reset it in teardown.

### Task 2: Core Screen Coverage

**Files:**
- Create: `test/compact_width_smoke_test.dart`

- [ ] **Step 1: Test Home compact render**

Pump `HomeScreen` and assert `Solatify` renders with no exception.

- [ ] **Step 2: Test Schedule compact render**

Pump `PrayerScheduleScreen` and assert `Jadwal Salat` renders with no exception.

- [ ] **Step 3: Test Quran compact render**

Pump `QuranHomeScreen` and assert search UI renders with no exception.

- [ ] **Step 4: Test Settings compact render**

Pump `SettingsScreen` and assert settings text renders with no exception.

- [ ] **Step 5: Test Islamic Content compact render**

Pump `IslamicContentScreen` and assert content/search anchors render with no exception.

### Task 3: Docs And Verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update QA notes**

Mention compact-width smoke tests and update test count.

- [ ] **Step 2: Format and validate**

Run `dart format`, `flutter analyze`, and `flutter test`.

- [ ] **Step 3: Commit and push**

Commit as `Add compact width screen tests` and push current branch.
