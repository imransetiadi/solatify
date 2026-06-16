# Islamic Content Compact Grid Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix excessive spacing between menu items in the Islamic Content screen by implementing a compact grid layout.

**Architecture:** We will modify the `GridView.builder` constraints (`mainAxisExtent`, `crossAxisSpacing`, `mainAxisSpacing`) and the internal padding of `_ContentMenuCard` inside `IslamicContentScreen`.

**Tech Stack:** Flutter, Riverpod, Dart

---

### Task 1: Update GridView Spacing and Heights

**Files:**
- Modify: `lib/features/islamic_content/presentation/screens/islamic_content_screen.dart`

- [ ] **Step 1: Modify crossAxisSpacing and mainAxisSpacing**
Locate the `SliverGridDelegateWithFixedCrossAxisCount` and change both spacings from `12` to `10`.

```dart
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: cardHeight,
                    ),
```

- [ ] **Step 2: Update cardHeight Calculation**
Locate the `cardHeight` calculation. Change the fixed heights to be much more compact (e.g., `120.0` for small screens, `110.0` for larger screens).

```dart
                  final cardHeight = constraints.maxWidth < 380
                      ? 120.0
                      : 110.0;
```

- [ ] **Step 3: Modify Padding inside _ContentMenuCard**
Locate the `_ContentMenuCard` widget and change the `Padding` from `EdgeInsets.all(16)` to `EdgeInsets.all(12)`.

```dart
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
```

- [ ] **Step 4: Reduce icon background size**
Inside `_ContentMenuCard`, change the icon container dimensions from `42` to `36`, and border radius to `10`.

```dart
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: primaryColor, size: 20),
              ),
```

- [ ] **Step 5: Run Analyzer and Tests**
Run: `flutter analyze` and `flutter test --no-pub`
Expected: PASS

- [ ] **Step 6: Commit**
```bash
git add lib/features/islamic_content/presentation/screens/islamic_content_screen.dart
git commit -m "style: implement compact grid layout for islamic content menu"
```
