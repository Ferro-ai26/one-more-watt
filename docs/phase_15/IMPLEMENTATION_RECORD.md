# Phase 15 Building Network Implementation Record

Date: 2026-07-20

Status: Implementation, host acceptance, and clean APK/static inspection complete; physical Android verification pending

## Delivered boundary

- Added `era_04_building_network` after the unchanged Eras 1–3 route. Era 5/Neighborhood remains absent and locked.
- Added six required Building requests and one optional lobby-directory vanity request. Every required request declares a concrete human-operator payoff. All current Era 4 request dialogue is tagged `provisional_copy` and remains subject to a later dedicated writing pass.
- Added Building Transformer, Commercial Battery Room, Parking-Lot Solar, Diesel Backup Array, Central Cooling, Medium-Voltage Connection, and Emergency Extension-Cord Stairwell with integrated project-original SVG icons.
- Added two deterministic, non-recurring maintenance reviews. Repair, Replace, and Overclock are explicit one-time operator choices; offline simulation stops rather than choosing, and no choice removes completed progress or owned infrastructure.
- Added operator-controlled Predictive Reserve Guard using a transient pre-peak allocation override that preserves the player's selected allocation mode.
- Added additive format-2 save fields and content `0.9.0` migration from supported `0.8.0`, `0.7.0`, and `0.6.0` payloads.
- Added the Building cutaway, scratched-core service console, lobby face, ordinary-life remnant, authored cyan/amber routes, brownout state, takeover report, and locked Neighborhood pullback through the reusable Phase 12/13 presentation system.
- Kept gameplay formulas, Android package/version foundation, stable prior IDs, the authoritative 16-era numbering, and City Data Center as Era 6 unchanged.

## Tuning result

The deterministic mechanical/structured route reports 115.4 / 135.5 minutes through Era 4. Required Building request completion times are 392.75, 475.75, 338.5, 412.0, 500.0, and 625.0 seconds—each within the approved four-to-12-minute window. The longest modeled purchase/research idle gap is 300 seconds. Two identical runs passed 1,354 balance/reachability checks.

## Provenance and art status

The seven new SVG silhouettes, environment drawing, animation states, and procedural maintenance cue are project-original/code-authored. Generated Phase 11 imagery is not loaded by the project and remains composition reference only. The new layer is production-functional and contextually reviewed, but it is not a claim that final tactile painted art is complete; `ISSUE-007` remains open for the later gold-standard pass.

## Validation entry points

- `./tools/test_phase15_building.sh`: 89 domain checks plus 24 headless graphical checks.
- `xvfb-run -a godot4 --path . --script res://tests/integration/test_phase15_building_ui.gd -- --capture-phase15`: 38 capture checks and seven reviewed PNGs.
- `./tools/test_vertical_slice.sh`: deterministic fresh route, migration-era path, UI route, and unchanged host performance guards.
- `./tools/validate.sh`: complete repository gate including the Phase 15 suites and headless launch.

The clean Android export from source commit `14b577fc8045e4de1b70692745f86591b3c38960` is `build/android/one_more_watt_phase15_debug.apk`, 55,982,701 bytes, SHA-256 `c82563de4bc3fdfb1c07f39cd626dc9f11d0b3f9dd28166453844718a58063e6`. Package/API/architectures/permission/embedded-ID/v2-v3 signature inspection passed. Physical execution remains unavailable under `ISSUE-010`.
