# Release Readiness Evidence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refresh release readiness evidence for the current branch and document remaining manual-device blockers honestly.

**Architecture:** Keep automated command evidence separate from manual device evidence. `docs/qa/release-signoff.md` remains the release gate, while README summarizes latest automated status.

**Tech Stack:** Flutter CLI, Android/iOS build tooling, Markdown QA docs.

---

### Task 1: Automated Evidence

**Files:**
- Modify: `docs/qa/release-signoff.md`

- [ ] **Step 1: Record current commit**

Run `git branch --show-current` and `git rev-parse --short HEAD`.

- [ ] **Step 2: Run analyzer and tests**

Run `flutter analyze` and `flutter test` and record pass/fail.

- [ ] **Step 3: List devices**

Run `flutter devices` and record available devices without requiring physical-device QA.

### Task 2: Build Evidence

**Files:**
- Modify: `docs/qa/release-signoff.md`

- [ ] **Step 1: Build Android debug APK**

Run `flutter build apk --debug` and record artifact path on success.

- [ ] **Step 2: Build iOS no-codesign**

Run `flutter build ios --no-codesign` and record artifact path on success.

### Task 3: Signoff Docs

**Files:**
- Modify: `docs/qa/release-signoff.md`
- Modify: `README.md` if status text needs updating

- [ ] **Step 1: Update release signoff**

Replace stale 2026-06-16 evidence with current Phase 16 evidence and remaining blockers.

- [ ] **Step 2: Validate docs**

Run `git diff --check` and inspect `git diff --stat`.

- [ ] **Step 3: Commit and push**

Commit as `Update release readiness evidence` and push current branch.
