# Phase 02 — Core Power Simulation

## Objective

Implement the deterministic Generation, Transmission, Reserve, Stored Energy, allocation, and brownout simulation independently of finished UI.

## Player-facing result

A debug panel can advance time and clearly demonstrate each bottleneck, Reserve behavior, allocation changes, and a harmless brownout.

## Required reading

`GAMEPLAY_SYSTEMS.md`, `PROGRESSION_AND_BALANCE.md`, `TECHNICAL_ARCHITECTURE.md`, and `DECISION_LOG.md`.

## Included

- Runtime grid state
- Aggregate infrastructure effects from test fixtures
- Delivered-power calculation
- Reserve charge/discharge limits
- Stored Energy accumulation
- Three allocation modes
- Fixed-step active simulation
- Brownout and recovery events
- Grid Stability calculation
- Debug controls and readouts

## Excluded

Authored request lifecycle, shop UI, save/offline, production visual effects, prestige, and Eras 4+.

## Implementation requirements

- Simulation code has no dependency on scene-tree presentation.
- Grid invariants are enforced after each command/tick.
- Allocation values come from balance data.
- Time advancement supports deterministic test calls.
- Brownouts produce events without losing currency or infrastructure.
- Derived aggregates can be rebuilt from owned definitions.

## Automated tests

- Generation below Transmission
- Transmission below Generation
- Reserve charges only from eligible surplus
- Reserve discharge covers a peak up to limits
- Remaining deficit creates brownout
- Stored Energy respects allocation and conversion efficiency
- Allocation change affects expected rates
- Stability stays in 0–100
- Large delta and equivalent small deltas match within tolerance
- Negative/overflow invariants hold

## Manual verification

Use debug controls to create generation-limited, transmission-limited, reserve-protected, and brownout scenarios. Confirm labels and values agree with calculations.

## Acceptance criteria

- [ ] Every core equation has unit coverage
- [ ] Repeated seeded runs match
- [ ] Debug panel identifies the limiting constraint
- [ ] Brownout starts and ends correctly
- [ ] No request-specific assumptions exist in the grid calculator
- [ ] Headless smoke test passes
- [ ] Living documents updated

## Stop condition

Do not build the authored request state machine. Stop after the standalone grid simulation is reliable.

