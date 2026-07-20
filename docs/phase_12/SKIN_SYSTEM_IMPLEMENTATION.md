# Phase 12 Skin System Implementation

Status: implemented reusable architecture; Phase 13 not started.

## Authority and boundaries

`scripts/ui/theme/skin_tokens.gd` is the single code authority for semantic color, typography, spacing, radius, border, icon, touch-target, motion, and reduced-motion values. `assets/themes/one_more_watt_theme.tres` packages those decisions into the live Godot Theme and embeds the licensed Atkinson font resources.

The Phase 11 phone board remains the composition authority. The live Phase 12 sample manually reconstructs its hierarchy with Godot controls and code-native drawing; no generated Phase 11 concept raster is loaded by the runtime.

## Reusable contracts

| Contract | Runtime implementation | Proof |
| --- | --- | --- |
| Semantic tokens | `SkinTokens` constants and style factories | Exact-token and unauthorized-literal tests |
| Base Theme | `one_more_watt_theme.tres` | Theme/font load tests and live Main inheritance |
| Grid metric | `VitalCard` | Default and limiting state in Main; full state API test |
| Infrastructure/upgrade card | `ShopItemCard` | Locked, affordable, and unaffordable Build states; full state API test |
| Era environment | `EraSkinDefinition`, `EraSkinRegistry`, `EraEnvironmentView` | Base, Desk, and Room variants validate and swap without game-state mutation |
| Asset completeness | `asset_inventory.json`, `AssetInventoryValidator` | Development fallbacks warn; release-required fallbacks fail release audit |
| Scene regression | `test_skin_system.gd` plus two 393 × 873 baselines | Baseline load/dimension checks and opt-in graphical recapture |

## Component states

Reusable cards accept: default, focused, selected, pressed, disabled, locked, affordable, unaffordable, warning, limiting, loading, and progress. Reduced motion and 130% text are orthogonal settings rather than mutually exclusive visual states. Important status remains reinforced by text and border treatment rather than color alone.

The live sample exercises default/limiting vital cards and unaffordable Build cards on a clean start. The automated state harness instantiates every remaining state without adding a production route or changing gameplay.

## Environment contract

An `EraSkinDefinition` supplies background/wall/surface/ambient colors, the mandatory scratched-core WATT variant, named infrastructure slots, authored power-flow paths, ambient and lighting treatment identifiers, transition hooks, a memory estimate, and a release-completeness flag. It receives infrastructure counts and online/authorization state from the game but owns no progression, balance, or save data.

The live code-native Desk sample contains warm practical surfaces, aged equipment, an outlet, fasteners, a small fan/battery cluster, authored dark rubber/cyan cable paths, the scratched WATT core, and a persistent operator-handshake plate. The Room variant darkens the practical environment and adds a spreading cyan path. Both are development proofs, not final painted environment art.

## Font packaging and provenance

Atkinson Hyperlegible Next and Atkinson Hyperlegible Mono were fetched from Google Fonts repository commit `389b770410cc0b7c21c85673bfa2077420fe7f65` under OFL 1.1.

| File | Bytes | SHA-256 | Role |
| --- | ---: | --- | --- |
| `AtkinsonHyperlegibleNext-Variable.ttf` | 114,552 | `5a455d1cfa099b601ab70751bb9673e8fe1854dc4500c80e1a220d0d75e31745` | UI, dialogue, headings, buttons |
| `AtkinsonHyperlegibleMono-Variable.ttf` | 53,960 | `5ce8b1698d1ded7dff2178c1a3ad159470085a58ea239e8b2cb88f4fb4a6f646` | numeric/status role |

Both OFL texts are packaged beside the font files. No external art asset was integrated.

## Regression command

Run `GODOT_BIN=godot4 ./tools/test_skin_system.sh`. On a graphical Linux host, regenerate review captures with `xvfb-run -a godot4 --path . --script res://tests/integration/test_skin_system.gd -- --capture-skin` and compare them with the approved Phase 11 phone board before updating baselines.
