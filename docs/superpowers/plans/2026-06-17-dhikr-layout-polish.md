# Dhikr Layout Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Dzikir Pagi & Petang card layout so Arabic, latin, meaning, and count badge remain readable without overflow on compact iOS/Android screens.

**Architecture:** Keep `DhikrScreen` as the only UI surface touched. Add a compact-width widget regression test, then replace fragile horizontal header layout with wrapping content and theme-aware text blocks.

**Tech Stack:** Flutter, Riverpod, widget tests, existing `GlassContainer`, `ResponsiveCenter`, and theme tokens.

---

### Task 1: Compact Layout Regression

**Files:**
- Modify: `test/islamic_content_smoke_test.dart`
- Modify: `lib/features/dhikr/presentation/screens/dhikr_screen.dart`

- [ ] **Step 1: Add failing compact-width test**

Add a widget test that renders `DhikrScreen` at Android compact width, scrolls the Dzikir list, switches to Dzikir Petang, and asserts `tester.takeException()` stays null.

- [ ] **Step 2: Verify RED**

Run `flutter test --no-pub test/islamic_content_smoke_test.dart` and confirm the compact layout test fails if the current layout overflows.

- [ ] **Step 3: Patch card layout**

Use `Wrap` for title/count badge, add padded Arabic text block with right alignment and RTL direction, use consistent spacing, and make note styling theme-aware.

- [ ] **Step 4: Verify GREEN**

Run `flutter test --no-pub test/islamic_content_smoke_test.dart`, `flutter test --no-pub`, and `flutter analyze --no-pub`.
