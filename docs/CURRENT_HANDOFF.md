# Current Handoff

Updated: 2026-07-20
Active phase: Phase 05 — Main UI and Feedback

## Current state

Phase 05 is implemented, validated, committed as `6ae86ac`, and pushed to `origin/main`. The former development shell is now a responsive production-structured online interface connecting WATT requests, the deterministic grid, purchases/upgrades, allocation, and reports without exposing debug controls. Content version is `0.5.0`. The active phase is complete; Phase 06 persistence/offline work remains gated on explicit user authorization.

## Completed

- Committed and pushed the Phase 05 implementation as `6ae86ac` to `origin/main`.
- Added a thin `GameSession` that synchronizes shared Stored Energy and economy-derived grid values across the existing request and economy domains at explicit command boundaries.
- Added `MainViewModel` snapshots whose request forecasts, costs, effects, and reports come directly from domain calculators.
- Built the fixed portrait hierarchy: top status, persistent WATT/request focal panel, Generation/Transmission/Reserve vital cards, allocation control, lower screen region, and Grid/Build/Upgrades/Reports navigation.
- Added reusable shop and vital cards, request authorization, large-purchase confirmation, performance reports, report archive, modal/back handling, explicit bottleneck text, and placeholder environmental state.
- Added centralized engineering/scientific number and W/kW/MW unit formatting.
- Added runtime reduced-motion, three text sizes, notation, haptics, large-purchase confirmation, named audio-bus controls, diagnostics, credits/version, and safe feedback hooks.
- Increased the first request reward from 10 to 12 Stored Energy so it funds the exact next Wall Outlet cost, and bumped canonical content to `0.5.0`.
- Kept all three diagnostic panels independently testable after removing them from the main scene.

## Next action

Review the Phase 05 evidence and proposed `DEC-015`. Do not begin Phase 06 until the user explicitly advances `docs/ACTIVE_PHASE.md`.

## Known blockers

- Android package identifier and publisher identity are not yet supplied.
- The local Android SDK has tools but no installed platform package, so Android export is not supportable yet.
- Physical Android safe-area, touch, haptic, and audio-device behavior remain unverified.
- No Phase 05 implementation blocker remains.

## Test evidence

- `./tools/validate.sh` — passed: clean import, 51 foundation checks, 30 content/API checks, 12 invalid fixtures, 178 grid checks, 143 request-domain checks, 93 economy checks, 40 UI/domain checks, 154 headless main-interface checks, three portrait layouts, 18 grid-panel checks, 58 request-panel checks, 42 economy-panel checks, and headless smoke launch.
- `./tools/test_ui.sh` — passed independently with 40 number-formatting/navigation/settings/session/view-model checks and 154 main-interface checks covering the online loop at all three portrait sizes.
- `xvfb-run -a godot4 --audio-driver Dummy --path . --script res://tests/integration/test_main_ui.gd -- --capture-layouts` — passed with 175 checks and 21 captures.
- Authorization, report, brownout, Build, Upgrades, Reports archive, and Settings states at 360 × 640, 393 × 873, and 480 × 800 were visually inspected. One detected 360-pixel report-row overflow was fixed, guarded with per-tab width assertions, recaptured, and re-inspected.
- Android export/device test — not run; prerequisites remain unavailable and are outside Phase 05.

## Files changed

- Online/UI state: `scripts/core/game_session.gd`, `scripts/ui/main_view_model.gd`, navigation, runtime settings, number formatter, and feedback hooks
- Main presentation: `scenes/app/Main.tscn`, `scripts/ui/main_ui.gd`, and reusable ShopItemCard/VitalCard scenes and scripts
- Content: manifest `0.5.0` and first-request reward tuning
- Tests/tools: Phase 05 unit/integration suites, `tools/test_ui.sh`, responsive/prior-panel regression adjustments, and the full validator
- Documentation: UI/architecture/art-feedback/balance baselines, proposed decision, README, active phase, and all required living documents

## Remaining acceptance criteria

All Phase 05 acceptance criteria pass locally. Save serialization, settings persistence across launches, offline progress/reports, final art/music, full Eras 1–3 content population, landscape-specific layout, production store assets, and physical Android verification remain intentionally out of scope.
