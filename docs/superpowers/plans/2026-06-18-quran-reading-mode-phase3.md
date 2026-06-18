# Quran Reading Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Quran reading mode controls to Surah Detail with persisted font and visibility preferences.

**Architecture:** A small Quran presentation preference state stores reader settings in Hive. `SurahDetailScreen` consumes those settings to adjust Arabic text size, hide/show transliteration and translation, show progress, and present a bottom sheet control panel.

**Tech Stack:** Flutter, Dart, Riverpod, Hive, existing Quran repository/provider, existing responsive UI tokens.

---

### Task 1: Quran Reader Preferences

**Files:**
- Modify: `lib/features/quran/presentation/quran_provider.dart`
- Test: `test/quran_test.dart`

- [ ] **Step 1: Add preference state**

Add `QuranReaderPreferences` with `arabicFontSize`, `showTransliteration`, `showTranslation`, and `focusMode` defaults.

- [ ] **Step 2: Add notifier persistence**

Add a Riverpod notifier that reads/writes preferences through `HiveService.getSetting` and `HiveService.saveSetting`.

- [ ] **Step 3: Test defaults and updates**

Add tests that assert default font size is readable, toggles update state, and font size clamps to safe bounds.

### Task 2: Surah Detail Controls

**Files:**
- Modify: `lib/features/quran/presentation/screens/surah_detail_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add progress label**

Show `Ayat 1 / total` near the header and update from `initialScrollVerse` when available.

- [ ] **Step 2: Add `Aa` control**

Add a compact action button in the header that opens a bottom sheet.

- [ ] **Step 3: Add bottom sheet controls**

Provide slider for Arabic font size plus switches for transliteration, translation, and focus mode.

- [ ] **Step 4: Apply preferences to verse cards**

Use selected font size for Arabic text and conditionally render transliteration/translation blocks.

### Task 3: Docs And Validation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention Quran Reading Mode and font controls in feature notes.

- [ ] **Step 2: Format code**

Run `dart format` on changed Dart and test files.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Add Quran reading mode controls` and push the current branch.
