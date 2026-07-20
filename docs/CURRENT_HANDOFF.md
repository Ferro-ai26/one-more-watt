# Current Handoff

Updated: 2026-07-20

Active phase: Phase 13 — Eras 1–3 Production Skin

Status: Device Retest In Progress — Touch Fix Implemented

## Exact result achieved

Phase 12 commit `ae61a94` was pushed to `origin/main` and remote synchronization was confirmed before Phase 13 began. Phase 13 then manually reconstructed a complete project-original, code-native presentation layer for the existing Eras 1–3 vertical slice while preserving the locked Phase 11 phone-board direction and Phase 12 technical contracts:

- distinct Desk, Room, and House/Home Server Closet dioramas with nested scale continuity, ordinary-life remnants, representative infrastructure clusters, authored cyan routes, warm-to-charcoal escalation, and visible brownout/reserve states;
- one persistent asymmetric scratched WATT core with curious, thinking, pleased, concerned, and completion expressions; WATT remains cyan during brownouts and never becomes evil or monstrous;
- contextual Build/Upgrade drawers that preserve 39% of portrait height for the live world at routine phone sizes, replacing the Phase 12 card-heavy full-screen fallback as composition authority;
- compact semantic infrastructure glyphs, installation pulses, restrained drawer audio, safe overload/blackout/cyan-reboot/scale-reveal transition states, operator-framed completion reports, larger-text sizing, and reduced-motion substitution;
- 12 final host-rendered evidence images covering Eras 1–3, Main, Build, report, brownout, pullback, 130% text, and 320 × 568;
- a 44-check headless Phase 13 suite and 68-check graphical capture run integrated into UI/full validation.

No generated Phase 11 raster is integrated. No gameplay formula, balance value, save schema, content progression, Android foundation, request order, or era number changed. Era 4 and Phase 14 were not started. Under `DEC-030`, this reusable code-native layer is production-functional but not approval of final painted art; `ISSUE-007` remains open for the later gold-standard visual-production pass.

A first external Phase 13 pass installed and cold-launched the clean commit-`1dcb9cf` APK on a Motorola Moto G (2025), reported at 720 × 1604 / 280 dpi with app version `v0.10.0-dev`. It found that Build and Upgrades could not scroll by touch and that a cost-threshold purchase confirmation appeared only for some purchases. The Phase 13 follow-up now:

- routes both shared scroll instances—main screens and modals—through an explicit reusable touch-drag implementation, with an 8-pixel deadzone, vertical-only movement, drag-safe card/control filtering, and correct input ownership while a modal is open;
- covers Build, Upgrades, Reports, Settings, and every other screen/modal using those shared containers, with synthetic Android drag regression on overflowing Build and Settings content;
- removes the conditional purchase-confirmation modal and Settings toggle so every affordable purchase applies on its first tap; the legacy setting stays serialized only for save compatibility (`DEC-031`).

`ISSUE-009` is fix-implemented and awaiting device retest. Phase 13 remains open; the remainder of the physical checklist is not claimed.

## Files changed

- Runtime: `era_environment_view.gd`, `era_skin_registry.gd`, `skin_tokens.gd`, `main_ui.gd`, `main_view_model.gd`, `shop_item_card.gd`, `vital_card.gd`, `feedback_audio.gd`, and `ShopItemCard.tscn`.
- Added: `infrastructure_glyph.gd`, `touch_scroll_container.gd`, `test_phase13_production_skin.gd`, and `test_phase13_skin.sh`.
- Validation/inventory: `test_main_ui_systems.gd`, `test_ui.sh`, `validate.sh`, `asset_inventory.json`, and setup/test documentation.
- Evidence/docs: `docs/phase_13/`, Phase 13 contract status, `ACTIVE_PHASE.md`, `PROGRESS.md`, `PLAYTEST_CHECKLIST.md`, `KNOWN_ISSUES.md`, `DECISION_LOG.md`, and this handoff.

## Commands/tests run and results

- Phase 12 push confirmation: local HEAD and `origin/main` both resolved to `ae61a9462ea21bdd0e1bf588e5348f7da04617ca` before Phase 13 work.
- Baseline `./tools/validate.sh`: all functional suites passed; the unchanged 500-refresh host guard missed twice at 1,050.8 ms and 1,130.5 ms, matching documented VPS variance.
- `GODOT_BIN=godot4 ./tools/test_ui.sh`: passed 48 UI-system, 296 Main-UI, 81 Phase 12 skin, and 44 Phase 13 skin checks.
- `GODOT_BIN=godot4 ./tools/test_vertical_slice.sh`: passed 908 balance/reachability and 111 UI/performance checks after removing redundant presentation churn; 25 Build rebuilds 1,428.2 ms, 500 refreshes 489.2 ms, 294 nodes.
- Final `./tools/validate.sh`: passed every repository suite and headless smoke launch. Accepted endpoint: 25 Build rebuilds 1,342.7 ms, 500 refreshes 487.4 ms, 294 nodes; five portrait layouts passed from 320 × 568 through 720 × 1280.
- Graphical Phase 13 capture: passed 68 checks and wrote 12 inspected screenshots under `docs/phase_13/evidence/`.
- Measurement-only dirty-tree Android export: 55,939,440 bytes, SHA-256 `c82bb39f8f854a90f6c5368fe93fd10436388e97e6e075ec25bc616943f24458`; +16,565 bytes / +0.030% over Phase 12. Package, API 24/35, `VIBRATE`-only permission, and v2/v3 signatures passed static inspection. This is not a clean provenance build or device-tested artifact.
- `adb devices -l`: no attached device.
- First device-pass report: install/cold launch passed on Motorola Moto G (2025), 720 × 1604 at 280 dpi; app version `v0.10.0-dev`; exact build suffix/effective UI line not supplied; Build/Upgrade touch scrolling failed on the first APK.
- Follow-up `./tools/test_ui.sh`: passed 48 UI-system, 426 Main-UI, 81 Phase 12 skin, and 51 Phase 13 checks, including real synthetic touch drags on overflowing screen and modal content and immediate purchase behavior with a legacy confirmation preference enabled.
- Follow-up `./tools/validate.sh`: passed every repository suite and headless smoke launch; 908 balance/reachability and 111 UI/performance checks remain green. Performance measured 1,396.6 ms for 25 Build rebuilds, 489.2 ms for 500 refreshes, and 294 nodes.
- Follow-up graphical layout capture: passed 461 checks across 35 states at five portrait sizes. Manually inspected the changed 320 × 568 Build/Settings and 393 × 873 Settings captures; scrolling affordance, removed confirmation toggle, world-first drawer, and horizontal fit remain correct.

## Manual verification

- Inspected all 12 final captures at original resolution against the locked phone board.
- Corrected clipped operator/brownout copy, prohibited red WATT eyes during brownout, retained pullback state after modal close, redundant Build description density, maximum-text card height, and narrow navigation copy before accepting the final set.
- Confirmed WATT remains the scene focal point, environment consequences remain visible, the Build/Upgrade drawer keeps the world live, categories/states remain redundant, and no generated concept raster or baked essential text is present.
- The first physical pass confirmed install/cold launch and supplied the exact model/display/density, then stopped for the concrete scroll defect. The fix is host-verified but has not yet run on that phone. No screenshots, full playthrough, audible speaker/headphone mix review, or safe-area/touch/haptic/GPU/heat/battery result is claimed.
- Manually inspected the follow-up host Build and Settings captures at 320 × 568 and Settings at 393 × 873 after removing the toggle; no horizontal clipping or new placeholder direction was introduced.

## Remaining acceptance criteria

- Replacement-APK retest of Build, Upgrades, Reports, and Settings scrolling plus immediate purchasing.
- Exact Settings build suffix and `EFFECTIVE UI` line, Android/API, screenshots, and the remaining Phase 13 phone playtest: full Eras 1–3 route, required states, touch comfort, physical font rasterization, safe areas, sound repetition/audio focus, haptics, GPU behavior, heat, and battery.

## Known blockers

- No Android device or emulator is attached to the current ARM64 VPS; replacement-build results depend on the external Moto tester.
- `ISSUE-007` deliberately remains open: the current project-original code-native layer is reusable and directionally faithful, but final tactile painted environment/WATT/infrastructure art belongs to the later gold-standard visual-production pass.

## Recommended next action inside Phase 13

Build and install a clean commit-tied replacement APK. First verify touch scrolling in Build, Upgrades, Reports, and Settings and confirm purchases no longer open a modal. Then continue the preserved Phase 13 physical-phone checklist and record the exact Settings build/EFFECTIVE UI lines plus screenshots and qualitative audio/haptic/heat/battery notes. Only then close Phase 13. Do not begin Phase 14 without separate authorization.
