# Current Handoff

Updated: 2026-07-20
Active phase: Phase 03 — Request and WATT System

## Current state

Phase 03 is implemented and validated in the working tree. A request-domain coordinator connects immutable authored definitions to the Phase 02 grid and supports the complete locked, available, announced, authorized, running, completed, and reported lifecycle. Four focused samples exercise Capacity, Stability, Burst, and Research without adding Phase 04 purchases or the full prototype catalog.

## Completed

- Added deterministic demand-profile sampling, seeded non-destructive incidents, preview/runtime parity, underprepared warnings, and permissive authorization.
- Added monotonic progress from served request demand plus capped WATT surplus allocation at fixed 0.25-second steps.
- Added one-time research costs, idempotent completion rewards, stable-ID unlock events, and next-available request selection.
- Added authored announcement/completion dialogue, unseen-priority selection, ten-event repetition history, and 60-second brownout cooldown.
- Added aggregate performance reports with grades, demand/service, peak, brownout, Reserve, allocation changes, incidents, currency, rewards, unlocks, and actionable suggestions.
- Added a responsive request debug panel covering lifecycle commands, four types, allocation, intentional brownout, recovery, report, and acknowledgement.
- Expanded canonical content to version `0.3.0` with four phase samples and one deterministic runtime incident.

## Next action

Review the Phase 03 evidence and proposed `DEC-013`. Do not begin Phase 04 until the user explicitly advances `docs/ACTIVE_PHASE.md`.

## Known blockers

- Android package identifier and publisher identity are not yet supplied.
- The local Android SDK has tools but no installed platform package, so Android export is not supportable yet.
- Physical Android safe-area, touch, and device behavior remain unverified.
- No Phase 03 implementation blocker remains.

## Test evidence

- `./tools/validate.sh` — passed: clean import, 51 foundation checks, 29 content/API checks, 12 invalid fixtures, 178 grid checks, 143 request-domain checks, three portrait layouts, 18 grid-panel checks, 58 request-panel checks, and headless smoke launch.
- `./tools/test_requests.sh` — passed independently with 143 checks covering every required lifecycle, behavior, boundary, invariant, reward, dialogue, report, unlock, incident, and fixed-step case.
- `xvfb-run -a godot4 --audio-driver Dummy --path . --script res://tests/integration/test_request_debug_panel.gd -- --capture-layouts` — passed with 62 checks and four captures.
- Capacity, Stability, Burst, and Research reports at 393 × 873 were visually inspected. Stability recorded the intentional allocation change, 1.00-second brownout, recovery, 93.7% service, and grade A; the other samples recorded full service and no brownout.
- Android export/device test — not run; prerequisites remain unavailable and are outside Phase 03.

## Files changed

- Request domain: state, preview, event, profile sampler, incident timeline, dialogue selector, coordinator, and aggregate report classes under `scripts/simulation/`
- Content: four request/demand-profile samples, WATT dialogue, incident, localization, validator extensions, and manifest content version `0.3.0`
- Debug presentation: `scenes/debug/RequestDebugPanel.tscn`, `scripts/ui/request_debug_panel.gd`, and the Phase 03 main development shell
- Tests/tools: request unit and panel integration suites, `tools/test_requests.sh`, prior-panel regression adjustment, and the full validator
- Documentation: request/grid boundary, content schema, architecture, proposed decision, README, active phase, and all required living documents

## Remaining acceptance criteria

All Phase 03 acceptance criteria pass locally. Full Era 1–3 request population, vanity cosmetics, request queues, Build shop/purchases, finished main UI, persistence, offline progress, and physical Android verification remain intentionally out of scope.
