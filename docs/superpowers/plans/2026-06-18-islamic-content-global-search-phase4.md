# Islamic Content Global Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an offline global search to the Islamic Content hub across duas, dhikr, Asmaul Husna, Islamic tips, and prayer guide content.

**Architecture:** A presentation-layer search provider builds lightweight `IslamicContentSearchItem` entries from existing local/domain data. `IslamicContentScreen` owns the search field and renders matched results that navigate to existing routes.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, existing static/local content data.

---

### Task 1: Search Index Provider

**Files:**
- Create: `lib/features/islamic_content/presentation/providers/islamic_content_search_provider.dart`
- Test: `test/islamic_content_smoke_test.dart`

- [ ] **Step 1: Add search item model**

Create `IslamicContentSearchItem` with `category`, `title`, `subtitle`, `route`, `keywords`, and `icon`.

- [ ] **Step 2: Build offline index**

Use existing providers/local data for duas, dhikr, Asmaul Husna, tips, and prayer guide summaries/steps.

- [ ] **Step 3: Add query matcher**

Normalize lowercase text and match against category, title, subtitle, and keywords.

- [ ] **Step 4: Test search matching**

Assert queries like `qunut`, `dzikir`, `rahman`, and `dhuha` return expected categories/routes.

### Task 2: Hub UI Integration

**Files:**
- Modify: `lib/features/islamic_content/presentation/screens/islamic_content_screen.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add search field**

Add a controller/listener or Riverpod state query near the top of the hub.

- [ ] **Step 2: Render results**

When query is non-empty, render compact result cards with category, title, subtitle, and chevron.

- [ ] **Step 3: Navigate result tap**

Use `context.push(item.route)` for existing routes.

- [ ] **Step 4: Add empty result state**

Show friendly text when no content matches.

### Task 3: Docs And Validation

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1: Update README**

Mention global Islamic Content search in feature notes.

- [ ] **Step 2: Format code**

Run `dart format` on changed Dart and test files.

- [ ] **Step 3: Run analyzer and tests**

Run `flutter analyze && flutter test` and require clean output.

- [ ] **Step 4: Commit and push**

Commit as `Add Islamic content global search` and push the current branch.
