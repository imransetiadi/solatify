# Mosque Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Masjid Terdekat reliability, responsiveness, and cross-platform map/route behavior on iOS and Android.

**Architecture:** Extract pure mosque helpers from the screen into a focused data utility so parsing, cache keys, and map URI behavior are unit-testable. Keep `NearbyMosqueScreen` as the UI orchestrator for location, fetch, cache, state, and external launch behavior.

**Tech Stack:** Flutter, Riverpod, Geolocator, Overpass API via `http`, `url_launcher`, existing Clean Architecture feature layout.

---

### Task 1: Pure Mosque Helpers

**Files:**
- Create: `lib/features/mosque/data/mosque_search_utils.dart`
- Modify: `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart`
- Test: `test/mosque_search_test.dart`

- [ ] **Step 1: Add failing tests for parser, cache key, and URI builders**

Add tests to `test/mosque_search_test.dart` for:

```dart
test('parseMosqueOverpassElements deduplicates and sorts by distance', () {
  final data = jsonDecode('''
{
  "elements": [
    {"type":"node","id":1,"lat":-6.20,"lon":106.80,"tags":{"name":"Far Mosque"}},
    {"type":"node","id":2,"lat":-6.2087,"lon":106.8455,"tags":{"name":"Near Mosque"}},
    {"type":"node","id":2,"lat":-6.2087,"lon":106.8455,"tags":{"name":"Duplicate Mosque"}}
  ]
}
''') as Map<String, dynamic>;

  final mosques = parseMosqueOverpassElements(
    data: data,
    originLatitude: -6.2088,
    originLongitude: 106.8456,
  );

  expect(mosques, hasLength(2));
  expect(mosques.first.name, 'Near Mosque');
});

test('buildMosqueCacheKey rounds coordinates to stable precision', () {
  expect(
    buildMosqueCacheKey(latitude: -6.2088123, longitude: 106.8456123, radiusMeters: 5000),
    buildMosqueCacheKey(latitude: -6.2088499, longitude: 106.8456499, radiusMeters: 5000),
  );
});

test('buildMosqueMapUri prefers Apple Maps for iOS', () {
  final uri = buildMosqueMapUri(latitude: -6.2, longitude: 106.8, platform: MosqueMapPlatform.ios);
  expect(uri.host, 'maps.apple.com');
  expect(uri.queryParameters['q'], '-6.2,106.8');
});

test('buildMosqueRouteUri uses Google Maps destination for Android', () {
  final uri = buildMosqueRouteUri(latitude: -6.2, longitude: 106.8, platform: MosqueMapPlatform.android);
  expect(uri.host, 'www.google.com');
  expect(uri.path, '/maps/dir/');
  expect(uri.queryParameters['destination'], '-6.2,106.8');
});
```

- [ ] **Step 2: Run tests and confirm they fail**

Run: `flutter test --no-pub test/mosque_search_test.dart`

Expected: fail because new helper file/functions do not exist or parser does not deduplicate.

- [ ] **Step 3: Move pure helpers into data utility**

Create `lib/features/mosque/data/mosque_search_utils.dart` with:

- `MosqueItem`
- `MosqueMapPlatform`
- `buildMosqueOverpassQuery`
- `parseMosqueOverpassElements`
- `calculateMosqueDistance`
- `buildMosqueCacheKey`
- `buildMosqueMapUri`
- `buildMosqueRouteUri`

Parser behavior must validate coordinates, use center coordinates for ways/relations, sort nearest first, and deduplicate by `type:id`.

- [ ] **Step 4: Update screen imports**

Remove duplicated model/helper code from `nearby_mosque_screen.dart` and import `package:solatify/features/mosque/data/mosque_search_utils.dart`.

- [ ] **Step 5: Run focused tests**

Run: `flutter test --no-pub test/mosque_search_test.dart`

Expected: all mosque search tests pass.

### Task 2: Cache and Platform-Aware Launching

**Files:**
- Modify: `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart`
- Test: `test/mosque_search_test.dart`

- [ ] **Step 1: Add in-memory cache in the screen**

Add a static map cache keyed by `buildMosqueCacheKey(...)`. When a cached list exists, show it immediately before network fetch completes. After successful network fetch, update the cache.

- [ ] **Step 2: Use platform-aware URI builders**

Update `_openInMap` and `_openRoute` to call `buildMosqueMapUri` / `buildMosqueRouteUri` with iOS or Android based on `defaultTargetPlatform`. Use Android as fallback for other platforms.

- [ ] **Step 3: Keep launch fallback behavior**

Preserve `_launchMapUri` SnackBar behavior when `launchUrl` returns false or throws.

- [ ] **Step 4: Run focused tests**

Run: `flutter test --no-pub test/mosque_search_test.dart test/routed_screen_smoke_test.dart`

Expected: all tests pass.

### Task 3: Responsiveness Cleanup

**Files:**
- Modify: `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart`

- [ ] **Step 1: Reduce build-time list work**

Avoid repeated `toList()` where not needed and keep area-preview marker count capped to 12.

- [ ] **Step 2: Improve loading status without blocking cached results**

If cached mosques are visible and a fresh fetch is running, keep the list visible and show status text/loading indicator only in the header area.

- [ ] **Step 3: Ensure mounted checks around async UI updates**

Keep `if (!mounted) return;` before every `setState` after awaited calls.

### Task 4: Verification

**Files:**
- Read: modified files and current diff

- [ ] **Step 1: Run focused tests**

Run: `flutter test --no-pub test/mosque_search_test.dart test/routed_screen_smoke_test.dart`

Expected: pass.

- [ ] **Step 2: Run full test suite**

Run: `flutter test --no-pub`

Expected: pass.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze --no-pub`

Expected: no issues.

- [ ] **Step 4: Run Android build**

Run: `flutter build apk --debug`

Expected: debug APK builds.

- [ ] **Step 5: Run iOS build**

Run: `flutter build ios --no-codesign`

Expected: iOS app builds without codesign.

- [ ] **Step 6: Clean transient build changes**

Run: `git status --short`

Expected: if `ios/Podfile.lock` changed only due to build/integration plugin, revert it.
