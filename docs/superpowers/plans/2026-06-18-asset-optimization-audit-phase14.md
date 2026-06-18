# Asset Optimization Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add asset size guardrails and document current asset usage without changing visual assets.

**Architecture:** Keep asset budgets in tests so regressions fail fast. Keep audit details in QA docs so future asset compression/removal can be reviewed with evidence.

**Tech Stack:** Dart tests, Flutter asset manifest conventions, Markdown QA docs.

---

### Task 1: Asset Budget Test

**Files:**
- Create: `test/asset_budget_test.dart`

- [ ] **Step 1: Assert runtime asset sizes**

Check `assets/images/masjid_nabawi.svg` and `assets/icon.jpg` stay below compact runtime budgets.

- [ ] **Step 2: Assert launcher asset size**

Check `assets/best_logo.png` stays below launcher source budget.

- [ ] **Step 3: Flag oversized review candidates**

Check `assets/icon_white.png` remains documented as a review candidate and does not exceed a temporary cap.

### Task 2: QA Documentation

**Files:**
- Create: `docs/qa/asset-optimization-audit.md`
- Modify: `README.md`

- [ ] **Step 1: Document asset inventory**

List file size, usage, and action for each asset.

- [ ] **Step 2: Update README**

Mention asset budget guardrails and update test count.

### Task 3: Validation And Publish

**Files:**
- All changed files

- [ ] **Step 1: Format tests**

Run `dart format test/asset_budget_test.dart`.

- [ ] **Step 2: Verify**

Run `flutter analyze` and `flutter test`.

- [ ] **Step 3: Commit and push**

Commit as `Add asset optimization guardrails` and push current branch.
