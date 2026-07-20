# Current Handoff

Updated: 2026-07-20
Active phase: Phase 04 — Infrastructure and Upgrades

## Current state

Phase 04 is implemented and validated in the working tree. A deterministic economy coordinator now turns Stored Energy, stable-ID ownership, upgrade levels, milestones, and automation settings into grid values through one shared preview/purchase/rebuild path. Canonical content version `0.4.0` includes all 18 Eras 1–3 infrastructure definitions and three representative upgrades. The active phase is complete; Phase 05 remains gated on explicit user authorization.

## Completed

- Added exact floored next and bulk pricing with atomic infrastructure and upgrade purchase commands.
- Added locked, unaffordable, affordable, and maxed previews with missing currency, unmet conditions, exact costs, and predicted derived-grid deltas.
- Added explicit starting ownership, milestone threshold tracking/events, one-time and leveled upgrades, and direct/category/tag/global multiplier groups.
- Added a rebuild boundary that derives grid values from baseline hardware, ownership, passive effects, milestones, and upgrades without double-counting the starting Wall Outlet.
- Added disabled-by-default low-Reserve throttling with an explicit normalized threshold and no automated spending.
- Expanded canonical content to version `0.4.0` with three eras, all 18 specified infrastructure definitions, and three representative upgrades.
- Added a portrait diagnostic shop exercising core categories, unlocks, affordability, milestone crossing, upgrades, and automation through domain previews rather than UI balance constants.

## Next action

Review the Phase 04 evidence and proposed `DEC-014`. Do not begin Phase 05 until the user explicitly advances `docs/ACTIVE_PHASE.md`.

## Known blockers

- Android package identifier and publisher identity are not yet supplied.
- The local Android SDK has tools but no installed platform package, so Android export is not supportable yet.
- Physical Android safe-area, touch, and device behavior remain unverified.
- No Phase 04 implementation blocker remains.

## Test evidence

- `./tools/validate.sh` — passed: clean import, 51 foundation checks, 30 content/API checks, 12 invalid fixtures, 178 grid checks, 143 request-domain checks, 93 economy checks, three portrait layouts, 18 grid-panel checks, 58 request-panel checks, 42 economy-panel checks, and headless smoke launch.
- `./tools/test_economy.sh` — passed independently with 93 checks covering every Era 1–3 infrastructure interpretation, exact costs, atomicity, unlocks, milestones, stacking, max levels, rebuild equivalence, and automation boundaries.
- `xvfb-run -a godot4 --audio-driver Dummy --path . --script res://tests/integration/test_economy_debug_panel.gd -- --capture-layouts` — passed with 46 checks and four captures.
- Core-category purchases, the tenth-item milestone, an upgrade, and low-Reserve automation at 393 × 873 were visually inspected. Each purchase reported that its preview matched the resulting grid; milestone and purchase events were distinct and readable.
- Android export/device test — not run; prerequisites remain unavailable and are outside Phase 04.

## Files changed

- Economy domain: state, preview, event, unlock evaluator, calculator, coordinator, and generalized infrastructure aggregator under `scripts/simulation/`
- Content: all Eras 1–3 infrastructure, three upgrades, era membership, localization, milestone/starting-ownership balance, validator extensions, and manifest content version `0.4.0`
- Debug presentation: `scenes/debug/EconomyDebugPanel.tscn`, `scripts/ui/economy_debug_panel.gd`, and the Phase 04 main development shell
- Tests/tools: economy unit and panel integration suites, `tools/test_economy.sh`, responsive/prior-panel regression adjustments, and the full validator
- Documentation: economy/rebuild boundaries, content schema, proposed decision, README, active phase, and all required living documents

## Remaining acceptance criteria

All Phase 04 acceptance criteria pass locally. Production main navigation, finished shop presentation, persistence, offline progress, full Era 1–3 request population, automated spending, Eras 4+, monetization, and physical Android verification remain intentionally out of scope.
