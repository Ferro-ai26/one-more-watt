# Phase 13 Asset Provenance

Date: 2026-07-20

## Integrated assets

| Asset/system | Source | License/status | Release boundary |
| --- | --- | --- | --- |
| Domestic Eras 1–3 diorama kit | Manually authored GDScript drawing primitives in this repository | Project-original | Integrated provisional presentation; not final painted-art approval |
| Semantic infrastructure glyphs | Manually authored GDScript geometry in this repository | Project-original | Integrated provisional icon layer |
| WATT expressions/core | Manually authored GDScript geometry derived from the locked project character rules | Project-original | Integrated provisional character presentation |
| Procedural feedback cues | Deterministic PCM synthesis authored in this repository | Project-original | Integrated; no external samples |
| Atkinson Hyperlegible Next/Mono | Preserved Phase 12 Google Fonts/OFL package and hashes | OFL-1.1 | Unchanged and integrated |
| Base Theme/tokens/app icon | Preserved Phase 12 project resources | Project-original except OFL fonts | Unchanged and integrated |

No external image, generated image, external sound, trademarked logo, or copied production asset was added in Phase 13. Essential text remains live Godot UI. The Phase 11 generated backgrounds remain under `docs/phase_11/` as internal direction reference only and are not loaded by the runtime.

## Explicit unresolved release assets

`assets/asset_inventory.json` retains five `release_required` fallback entries: Eras 1–3 painted environments, painted WATT core, and painted infrastructure icon set. Their paths do not exist by design, development validation warns, and release-scope validation fails. `ISSUE-007` owns later manual reconstruction, provenance, contextual phone review, and release-audit clearance.

Approval of Phase 13's reusable code-native layer must not change those entries to integrated or imply gold-standard art approval.
