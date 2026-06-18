# Asset Optimization Audit

**Date:** 2026-06-18  
**Scope:** `assets/` runtime and launcher source assets.

## Inventory
| Asset | Size | Dimensions / Type | Usage | Action |
|-------|------|-------------------|-------|--------|
| `assets/images/masjid_nabawi.svg` | ~2 KB | SVG | Runtime logo in Home, Splash, Onboarding, README | Keep. Guard under 8 KB. |
| `assets/icon.jpg` | ~26 KB | 310x349 JPEG | Declared in `pubspec.yaml` asset list | Keep. Guard under 64 KB; review if still needed after launcher icon flow is finalized. |
| `assets/best_logo.png` | ~7 KB | 1024x1024 PNG | `flutter_launcher_icons` source/adaptive foreground | Keep. Guard under 32 KB. |
| `assets/icon_white.png` | ~153 KB | 1024x1024 PNG | No current runtime/pubspec reference found | Review candidate. Keep for now under temporary 192 KB cap until visual approval to remove or compress. |

## Guardrails
- Runtime SVG/JPEG assets should stay small enough to avoid startup and scroll regressions.
- Launcher source assets can be larger than runtime assets, but should stay compact because they live in the repository and may be processed during builds.
- Unused large assets must be documented before deletion to avoid accidentally removing brand/source material.

## Follow-Up Candidates
1. Confirm whether `assets/icon_white.png` is still needed as a brand source file.
2. If not needed, remove it in a dedicated cleanup phase with visual/brand approval.
3. If needed, generate a compressed source variant and compare visual quality before replacing.
