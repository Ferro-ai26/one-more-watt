# Phase 03 — Request and WATT System

## Objective

Connect authored WATT requests to the grid simulation and implement the complete announcement-to-report lifecycle.

## Player-facing result

The player can receive, inspect, authorize, run, brown out, complete, and acknowledge sample requests while WATT reacts appropriately.

## Required reading

`GAMEPLAY_SYSTEMS.md`, `WATT_CHARACTER_BIBLE.md`, `CONTENT_DATABASE.md`, `UI_UX_SPEC.md`, and `TECHNICAL_ARCHITECTURE.md`.

## Included

- Request state machine
- Capacity, stability, burst, and research behavior
- Demand profiles and seeded incidents
- Authorization preview and underprepared warning
- WATT dialogue selection and repetition controls
- Completion reward transaction
- Performance report generation
- Unlock event emission
- Debug/simple presentation sufficient to test the lifecycle

## Excluded

Full Build shop, finished main UI, all prototype content, persistence, vanity-request cosmetics, and request queues.

## Implementation requirements

- Progress is monotonic.
- Rewards are idempotent and granted once.
- Preview and runtime use the same demand/balance definitions.
- A request can complete during a brownout at reduced speed.
- Dialogue selection cannot replace required tutorial or completion lines.
- Performance reports store summaries, not raw simulation frames.
- Unlock effects occur through stable IDs.

## Automated tests

- Every request state transition
- Invalid authorization rejected
- Underprepared authorization allowed with warning state
- Four request types progress correctly
- Demand peak uses Reserve
- Brownout reduces rate but not accumulated progress
- Completion reward granted once across repeated calls
- Dialogue cooldown and unseen-priority behavior
- Performance grade boundaries
- Unlock event follows completion

## Manual verification

Run one sample of each request type. Change allocation mid-request, intentionally cause a brownout, recover, and confirm the report truthfully describes the run.

## Acceptance criteria

- [ ] Full lifecycle works for four request types
- [ ] WATT announcement and completion lines are data-driven
- [ ] Underprepared request remains playable
- [ ] Report data matches observed behavior
- [ ] Reward duplication test passes
- [ ] The next available request is identified after report acknowledgement
- [ ] Living documents updated

## Stop condition

Do not populate all Eras 1–3 requests or construct the finished screen hierarchy.

