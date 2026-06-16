# Release Signoff Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Execute release-grade QA for Solatify, document evidence, and update the release signoff status.

**Architecture:** This is a verification/documentation task. Automated checks establish code health first, platform build checks verify Android/iOS compile readiness, and `docs/qa/release-signoff.md` records evidence-backed pass/fail status without claiming unobserved device results.

**Tech Stack:** Flutter, Dart test, Flutter integration_test, Android Gradle build, Xcode iOS no-codesign build, Solatify QA docs.

---

### Task 1: Automated QA Baseline

**Files:**
- Read: `docs/qa/runbook.md`
- Read: `docs/qa/release-signoff.md`
- No production code changes expected

- [ ] **Step 1: Check working tree**

Run: `git status -sb`

Expected: current branch and changed files are visible before QA begins.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze --no-pub`

Expected: exit code 0 and `No issues found!`.

- [ ] **Step 3: Run full unit/widget tests**

Run: `flutter test --no-pub`

Expected: exit code 0 and all tests pass.

- [ ] **Step 4: Run integration audit test**

Run: `flutter test integration_test/app_test.dart`

Expected: exit code 0 and all integration tests pass. If the command requires unavailable device support, record the exact blocker in `docs/qa/release-signoff.md`.

### Task 2: Platform Build Checks

**Files:**
- Read: `docs/qa/android-checklist.md`
- Read: `docs/qa/ios-checklist.md`
- No production code changes expected

- [ ] **Step 1: Build Android debug APK**

Run: `flutter build apk --debug`

Expected: exit code 0 and `build/app/outputs/flutter-apk/app-debug.apk` created.

- [ ] **Step 2: Build iOS without codesign**

Run: `flutter build ios --no-codesign`

Expected: exit code 0 and `build/ios/iphoneos/Runner.app` created.

- [ ] **Step 3: Remove transient build-only changes**

Run: `git status --porcelain=v1`

Expected: if `ios/Podfile.lock` changed only by `integration_test`, revert it with `git checkout -- ios/Podfile.lock`; do not revert intentional source/test/doc changes.

### Task 3: Release Signoff Documentation

**Files:**
- Modify: `docs/qa/release-signoff.md`
- Read: `docs/qa/performance-checklist.md`

- [ ] **Step 1: Record command evidence**

Update `docs/qa/release-signoff.md` Release Info and Signoff Notes with branch, commit, date, and each command result from Tasks 1-2.

- [ ] **Step 2: Record feature/menu audit status**

Update `docs/qa/release-signoff.md` with status for Beranda, Jadwal, Qur’an, Konten, More, Kiblat, Masjid, Tracker, Pengaturan, and Notifikasi based on automated coverage and build evidence.

- [ ] **Step 3: Record platform limitations**

If physical device/profile evidence is not collected, mark device-only checks and performance profiling as pending manual evidence rather than passed.

- [ ] **Step 4: Record open issues and risks**

Add blockers for failed commands. If all commands pass but device profiling is not run, list manual device QA and profile performance as follow-up evidence, not a blocker to automated readiness.

### Task 4: Final Verification

**Files:**
- Read: `docs/qa/release-signoff.md`
- Read: current git diff

- [ ] **Step 1: Re-run analyzer after docs update if source changed**

Run: `flutter analyze --no-pub` if any Dart source changed during this QA task.

Expected: exit code 0.

- [ ] **Step 2: Check final diff**

Run: `git diff --stat` and `git status -sb`

Expected: only intentional source/test/doc changes remain.

- [ ] **Step 3: Summarize evidence**

Report commands run, pass/fail outcomes, changed files, and any manual device QA follow-up needed.
