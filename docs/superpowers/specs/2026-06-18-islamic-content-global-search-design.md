# Islamic Content Global Search Design

## Goal
Add one offline search entry point in the Islamic Content hub so users can quickly find duas, dhikr, Asmaul Husna, Islamic tips, and prayer guide content.

## Scope
Phase 4 focuses on search discovery in the hub screen. It does not deep-link to a specific item detail yet; tapping a result opens the relevant feature page.

## User Experience
- The Islamic Content hub shows a compact search field near the top.
- When the query is empty, the existing feature cards remain primary.
- When the query has text, a result list appears with category, title, subtitle, and a route target.
- Empty results show a friendly no-match state.
- Search runs offline from existing static/local providers and avoids loading heavy UI screens.

## Architecture
- Add a small presentation search model and provider under `features/islamic_content/presentation`.
- Build a normalized index from lightweight local data sources/providers.
- Keep the index route-level: result taps navigate to existing feature routes.
- Avoid new storage and avoid adding another screen in this phase.

## Validation
- Add unit tests for query normalization, matching title/body/category, and route metadata.
- Add smoke/source tests for search labels and result rendering hooks.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Deep-link to exact dua/dhikr/tip/step item.
- Search result highlighting.
- Recent searches and persisted search history.
