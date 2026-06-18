# Performance Profiling Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deterministic performance budget guards and repeatable profile-mode documentation for Solatify's golden path.

**Architecture:** Keep performance thresholds centralized in `PerformanceTuning`. QA docs describe evidence collection separately from automated unit/widget tests so device-only performance claims remain honest.

**Tech Stack:** Flutter, Dart unit tests, existing QA Markdown docs.

---

### Task 1: Performance Budget Constants

**Files:**
- Modify: `lib/core/performance/performance_tuning.dart`
- Modify: `test/performance_tuning_test.dart`

- [ ] **Step 1: Add budget constants**

Add cold start, warm resume, frame build, frame raster, and compact smoke target constants.

- [ ] **Step 2: Add unit tests**

Assert budgets stay within the QA thresholds and compact test target count remains explicit.

### Task 2: Golden Path QA Docs

**Files:**
- Modify: `docs/qa/performance-checklist.md`
- Modify: `docs/qa/runbook.md`
- Create: `docs/qa/performance-baseline-template.md`

- [ ] **Step 1: Document golden paths**

List cold start, Home scroll, Quran list, Schedule, and menu switching scenarios with expected evidence.

- [ ] **Step 2: Add baseline template**

Create a reusable table for platform/device/build/timing/frame/memory evidence.

### Task 3: README And Validation

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update performance notes**

Mention centralized budgets and profile-mode baseline workflow.

- [ ] **Step 2: Format and verify**

Run `dart format`, `flutter analyze`, and `flutter test`.

- [ ] **Step 3: Commit and push**

Commit as `Add performance profiling baseline` and push current branch.
