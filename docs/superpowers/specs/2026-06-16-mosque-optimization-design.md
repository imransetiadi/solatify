# Mosque Optimization Design

## Goal
Optimize the Masjid Terdekat feature on iOS and Android for more reliable location/search behavior, smoother UI responsiveness, and safer map/route launching.

## Current Context
The feature currently lives mostly in `lib/features/mosque/presentation/screens/nearby_mosque_screen.dart`. It already supports GPS lookup, fallback to saved location, Overpass API mosque search across multiple endpoints, distance sorting, a lightweight area preview, and map/route buttons through external Google Maps URLs. Android has coarse/fine location and internet permissions. iOS has location usage descriptions.

## Architecture
Keep the feature in the existing feature-first structure, but move pure, reusable logic out of the screen where practical. The screen remains responsible for UI state and orchestration. Helper functions handle Overpass query building, response parsing, distance sorting, cache-key construction, and map/route URI construction. This keeps the UI smaller and makes cross-platform behavior testable without device access.

## Reliability Plan
Use GPS when available. If GPS is disabled, denied, or times out, use the saved prayer-location fallback and show a clear status message. Add a simple in-memory/session cache keyed by rounded coordinates and radius so the screen can show the last successful mosque list quickly while a fresh network request is attempted. Keep the Overpass endpoint fallback strategy and retain broad mosque tags.

## Search and Data Handling
Normalize parsed mosque results by validating coordinates, extracting the best available name/address fields, calculating distance from the active origin, sorting by nearest first, and deduplicating repeated Overpass elements by stable ID/source. Limit preview markers in the area map so the screen does not render too much work when many mosques are returned.

## Map and Route Launching
Build map and route URIs through a pure helper. On iOS, prefer Apple Maps web URLs through `maps.apple.com`. On Android, prefer Google Maps web URLs already supported by the current code. Keep browser/external-application fallback behavior and show a SnackBar if launch fails.

## Responsiveness Plan
Avoid expensive work in `build()`. Keep list rendering lazy through `ListView.builder`. Keep the area preview marker count capped. Preserve the current visual style, but rely on the existing shared `GlassContainer` performance tuning so mosque cards benefit from the lighter blur defaults.

## Testing Plan
Add or extend unit tests in `test/mosque_search_test.dart` for:

- Overpass query output remains valid and broad enough for mosque data.
- Parser accepts node/way/relation center coordinates.
- Parser sorts by distance and deduplicates repeated entries.
- Cache key is stable for nearby coordinates rounded to a practical precision.
- Map and route URI builders produce correct iOS and Android URLs.

## QA Plan
Run:

- `flutter test --no-pub test/mosque_search_test.dart`
- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build apk --debug`
- `flutter build ios --no-codesign`

Manual QA still needs device evidence for actual GPS permission prompts, real Overpass network behavior, and native map app launching on both Android and iOS.

## Non-Goals
Do not add a full interactive map SDK. Do not add server-side mosque APIs. Do not redesign the whole Mosque UI. Do not change unrelated features.
