# Current Handoff

Updated: 2026-07-19
Active phase: Phase 02 — Core Power Simulation

## Current state

Phase 02 is implemented and validated in the working tree. The request-agnostic grid core deterministically simulates Generation, Transmission, Reserve, allocation, Stored Energy, stability, and brownout transitions at a fixed 0.25-second step. A scrollable debug panel exposes controlled scenarios and time advancement. Authored request lifecycle behavior remains absent.

## Completed

- Added invariant-safe `GridState`, pure step calculations, typed step results, domain events, and a fixed-step `GridSimulation` coordinator.
- Added infrastructure aggregate rebuilding from stable IDs and immutable content definitions.
- Added balance-driven Expand Grid, Balanced, and Feed WATT shares plus Reserve charge/discharge rates; content version is now `0.2.0`.
- Added edge-triggered `brownout_started` and `brownout_ended` events without currency or infrastructure loss.
- Added cumulative 0–100 Grid Stability using served-demand ratio, brownout duration, and Reserve margin.
- Added debug scenarios for Generation, Transmission, Reserve protection, brownout, recovery, allocation changes, and exact time advancement.
- Added 178 equation/invariant checks and 18 headless debug-panel checks.

## Next action

Review the Phase 02 evidence and proposed `DEC-012`. Do not begin Phase 03 until the user explicitly advances `docs/ACTIVE_PHASE.md`.

## Known blockers

- Android package identifier and publisher identity are not yet supplied.
- The local Android SDK has tools but no installed platform package, so Android export is not supportable yet.
- Physical Android safe-area and device behavior remain unverified.
- No Phase 02 implementation blocker remains.

## Test evidence

- `./tools/validate.sh` — passed: clean import, 51 foundation checks, 29 content/API checks, 12 invalid content fixtures, 178 simulation checks, three portrait layout checks, 18 debug-panel checks, and headless smoke launch.
- `./tools/test_simulation.sh` — passed independently with 178 checks covering every required equation, seeded repeatability, fixed-step equivalence, aggregation, and negative/non-finite invariants.
- `xvfb-run -a godot4 --audio-driver Dummy --path . --script res://tests/integration/test_grid_debug_panel.gd -- --capture-layouts` — passed with 23 checks including capture creation.
- Generation-limited, Transmission-limited, Reserve-protected, and brownout captures at 393 × 873 were visually inspected; labels and values matched calculations. Recovery was also exercised and verified by the panel integration test.
- Android export/device test — not run; prerequisites remain unavailable and are outside Phase 02.

## Files changed

- Simulation: `scripts/simulation/grid_state.gd`, `grid_calculator.gd`, `grid_step_result.gd`, `grid_event.gd`, `grid_simulation.gd`, and `infrastructure_aggregator.gd`
- Balance/content: `data/balance/constants.json`, `data/manifest.json`, content validation updates, and the negative-balance fixture
- Debug presentation: `scenes/debug/GridDebugPanel.tscn`, `scripts/ui/grid_debug_panel.gd`, and `scenes/app/Main.tscn`
- Tests/tools: `tests/unit/test_grid_simulation.gd`, `tests/integration/test_grid_debug_panel.gd`, `tools/test_simulation.sh`, and the repository validation runner
- Documentation: gameplay/content/architecture specifications, `README.md`, `docs/ACTIVE_PHASE.md`, and all required living documents

## Remaining acceptance criteria

All Phase 02 acceptance criteria pass locally. Authored request states, request progression, demand-profile playback, incident behavior, purchases, saves, and offline simulation remain intentionally out of scope.
