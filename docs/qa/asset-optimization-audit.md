# Asset Optimization Audit

**Date:** 2026-06-18, updated 2026-11-08 after the logo refresh (#71) and asset cleanup.
**Scope:** `assets/` runtime and launcher source assets.

## Inventory
| Asset | Size | Type | Usage | Guard (`test/asset_budget_test.dart`) |
|-------|------|------|-------|--------|
| `assets/images/solatify_logo.svg` | ~4 KB | SVG | In-app logo (`SolatifyLogo`: splash, home header, onboarding) | Under 4 KB |
| `assets/brand/solatify_icon.svg` / `.png` | ~4 KB / ~92 KB | SVG master + 1024 px render | `flutter_launcher_icons` source (iOS and legacy Android) | SVG under 4 KB, PNG under 128 KB |
| `assets/brand/android_foreground.svg` / `.png` | ~4 KB / ~32 KB | SVG master + render | Android adaptive icon foreground | Same |
| `assets/brand/android_background.svg` / `.png` | ~4 KB / ~68 KB | SVG master + render | Android adaptive icon background | Same |
| `assets/brand/android_monochrome.svg` / `.png` | ~4 KB / ~24 KB | SVG master + render | Android 13+ themed icon | Same |

## Removed
| Asset | Reason |
|-------|--------|
| `assets/images/masjid_nabawi.svg` | Old mosque illustration, replaced by `solatify_logo.svg` (#71) |
| `assets/best_logo.png` | Old launcher source, replaced by `assets/brand` (#71) |
| `assets/icon.jpg` | Unused bundled image (#72) |
| `assets/icon_white.png` | Old Masjid Nabawi artwork with no references, superseded by `assets/brand` |

The tests assert that the removed files stay gone.

## Guardrails
- Runtime SVG assets should stay small enough to avoid startup and scroll regressions.
- Launcher sources can be larger than runtime assets but should stay compact because they live in the repository and are processed during builds. Regenerate the PNGs from the SVG masters rather than editing them by hand.
- Document an unused asset before deleting it, so brand or source material is not removed by accident.
