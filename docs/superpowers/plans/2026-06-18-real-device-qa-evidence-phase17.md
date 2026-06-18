# Real Device QA Evidence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refresh device-level QA evidence for Android and iOS targets detected by Flutter.

**Architecture:** Use existing `integration_test/app_test.dart` for navigation/device smoke. Keep manual notification/profile observations separate from automated integration evidence.

**Tech Stack:** Flutter integration_test, Android/iOS device tooling, Markdown QA docs.

---

### Task 1: Device Integration Evidence

**Files:**
- Modify: `docs/qa/release-signoff.md`

- [ ] **Step 1: Run Android physical integration test**

Run `flutter test -d GMFYIJQKVOM7AIYP integration_test/app_test.dart`.

- [ ] **Step 2: Run iOS wireless integration test**

Run `flutter test -d 00008140-000518E42EB8401C integration_test/app_test.dart`.

### Task 2: Performance Evidence Starter

**Files:**
- Modify: `docs/qa/performance-baseline-template.md`

- [ ] **Step 1: Record available device context**

Use detected device list and current commit as baseline context.

- [ ] **Step 2: Mark visual/profile observations pending**

Do not mark frame/memory paths passed without DevTools/profile observation.

### Task 3: Signoff Update

**Files:**
- Modify: `docs/qa/release-signoff.md`

- [ ] **Step 1: Update signoff evidence**

Record integration command results and remaining manual blockers.

- [ ] **Step 2: Commit and push**

Run `git diff --check`, commit as `Add real device QA evidence`, and push.
