# Phase 16 Neighborhood Microgrid Implementation Record

Date: 2026-07-21

Status: Complete — implementation and host acceptance passed; physical Android gate closed by accepted limitation under `DEC-039`

## Delivered boundary

- Added authoritative Era 5 `era_05_neighborhood_microgrid`; City Data Center/Era 6 remains absent and noninteractive.
- Added six required requests and one optional vanity request. Every required request has a concrete operator payoff, and all current dialogue remains data-driven and tagged `provisional_copy`.
- Added seven infrastructure definitions and project-original SVG icons: Neighborhood Substation, Community Solar Farm, Municipal Generator, Battery Warehouse, Small Hydroelectric Plant, Underground Distribution, and Borrowed Utility Connection.
- Added deterministic `Limited` / `Modeled` / `Verified` forecasts with disclosed reason, bounded duration, next peak, minimum Reserve, service, and bottleneck data.
- Added operator-owned Reserve presets plus advanced floor/start ratios. Safe throttle preserves Reserve without changing the selected allocation mode and records start/stop actions.
- Added policy-bounded automation for records explicitly authored `routine` and `automation_eligible`; strategic Era 4 Repair/Replace/Overclock remains manual. Resolved and blocked actions record stable ID, reason, order, cost, and simulation time.
- Added exactly-one-request preauthorization with Reserve-target or next-safe-return start rules, cancellation without duplicate research cost, stable save/restore, offline start, and a hard report boundary with no request chaining or offline purchases.
- Advanced canonical content to `0.10.0` while retaining additive save format 2 compatibility with `0.9.0`, `0.8.0`, `0.7.0`, and `0.6.0`.
- Added a project-original blue-hour Neighborhood diorama, nested Building node, persistent scratched core, civic WATT display, dim-home/bright-substation contradiction, authored lateral/underground cyan paths, contextual operator drawer, procedural policy cues, takeover report, and locked City pullback.

## Tuning result

The prepared six-request route completes every request within 600–1,500 seconds and the full required route within 5,700–8,100 seconds (95–135 minutes). Two deterministic runs are covered by the Phase 16 suite. Existing Eras 1–4 formulas and the established two-hour/80% offline policy remain unchanged.

## Validation entry points

- `./tools/test_phase16_neighborhood.sh`: 110 domain checks plus 23 headless contextual-UI checks.
- `xvfb-run -a godot4 --path . --script res://tests/integration/test_phase16_neighborhood_ui.gd -- --capture-phase16`: 39 graphical checks and eight reviewed phone captures.
- `./tools/validate.sh`: complete repository regression through Phase 16 and headless launch.
- Final observed host guard: 824.0 ms for 25 full Build rebuilds, 595.5 ms for 500 live refreshes, 463 UI nodes, and approximately 12.65 MiB isolated skin-harness memory delta.

## Provenance and limitations

All seven new icons, environment forms, paths, state graphics, motion, and procedural cue definitions are project-original/code-authored. Generated Phase 11 concept imagery is not integrated. This is the required production-functional Era 5 presentation, not closure of the later tactile painted gold-standard pass; `ISSUE-007` remains explicit.

Clean source commit `cc51fbf883e6` exported `build/android/one_more_watt_phase16_debug.apk`: 56,025,572 bytes, SHA-256 `1a934d52355bfaa758f2fb6b0076215145e0cb097f330fa9cb53bf438ac85f37`. Package/API/architectures/VIBRATE-only permission/embedded-ID/v2-v3 signature inspection passed. No physical Android device was attached to the host, so physical install, safe-area, touch, lifecycle, audible mix, haptics, FPS, heat, and battery were not observed. Under `DEC-039`, the user accepted this disclosed limitation and closed Phase 16 by disposition. The unchecked matrix is deferred to later full Android QA; no device pass is claimed.
