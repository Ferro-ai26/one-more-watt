# Decision Log

Accepted decisions are authoritative. New entries must not silently overwrite old ones; mark a superseded decision and link its replacement.

## DEC-001 — WATT is the main character

- Status: Accepted
- Decision: Requests, dialogue, unlocks, and progression are framed through WATT. The grid is the managed system, not the game's personality.
- Reason: Character-driven escalation differentiates the game from generic power incremental titles.

## DEC-002 — Three-variable grid model

- Status: Accepted
- Decision: The core grid consists of Generation, Transmission, and Reserve. No wire-by-wire simulation is planned.
- Reason: These constraints create legible decisions on a phone without engineering-simulator complexity.

## DEC-003 — City Data Center is Era 6

- Status: Accepted
- Decision: Era 6 is City Data Center and marks the deliberate transition from fast active requests to 20–60 minute idle requests.
- Reason: The game must spend enough time at human scale for escalation to feel earned.

## DEC-004 — Brownouts never erase request progress

- Status: Accepted
- Decision: Insufficient power reduces progress rate and report quality but never reverses accumulated progress or destroys ordinary infrastructure.
- Reason: Failure should inform and amuse rather than punish time investment.

## DEC-005 — Offline simulation is deterministic and safe

- Status: Accepted
- Decision: Offline progress uses known state and deterministic demand. Random destructive offline events are prohibited.
- Reason: Players cannot respond while away and should not be punished by unpreventable randomness.

## DEC-006 — Authored WATT dialogue

- Status: Accepted
- Decision: Shipped WATT dialogue is authored content. Live generative AI is not required.
- Reason: Authored lines provide consistent comedy, safety, localization, and offline operation.

## DEC-007 — Prototype contains Eras 1–3

- Status: Accepted
- Decision: The first vertical slice ends after Home Server Closet and includes 12–18 requests, full core grid mechanics, save, and conservative offline progress.
- Reason: It proves the relationship between WATT, requests, and grid management before expensive content expansion.

## DEC-008 — Data-driven content

- Status: Accepted
- Decision: Authored content and balance values live outside presentation and simulation scripts, initially in validated JSON.
- Reason: The game requires large content expansion and frequent balancing without repeated code changes.

## DEC-009 — No monetization in the prototype

- Status: Accepted
- Decision: Phases 00–09 contain no advertising, purchases, premium currency, or monetization pressure.
- Reason: The first milestone is proving fun, clarity, retention potential, and technical reliability.

## DEC-010 — Godot 4.6.2 foundation baseline

- Status: Proposed
- Date: 2026-07-19
- Decision: Target Godot 4.6.2 stable with the GL Compatibility renderer for the project foundation. Store the development version in `application/config/version` as its single source.
- Reason: This stable engine and matching export templates are installed and operational on the ARM64 development host, and GL Compatibility is the conservative mobile baseline.
- Consequences: Keep the project on this exact engine line during an active phase. Any upgrade requires an accepted decision and full regression pass; Android export still requires an approved package identifier and complete SDK.

## DEC-011 — Manifest-driven JSON schema version 1

- Status: Proposed
- Date: 2026-07-19
- Decision: Use `data/manifest.json` as the single content entry point, JSON as source of truth, schema version 1, exact placeholder-asset exceptions, typed immutable runtime definitions, and only enumerated effect/unlock vocabularies.
- Reason: The Phase 01 contract requires deterministic validation, stable cross-file IDs, safe effects, and a content version without committing later phases to generated Godot resources.
- Consequences: Schema changes require a manifest/schema version decision; unknown content operations and undeclared missing assets fail closed. Full prototype population remains separate from the schema exercise records.

## DEC-012 — Load-first standalone grid boundary

- Status: Proposed
- Date: 2026-07-19
- Decision: Keep Phase 02 request-agnostic. Deliverable power and Reserve serve a generic external load first; remaining surplus is split by the selected allocation mode. Eligible grid share charges Reserve before conversion to Stored Energy, while the WATT share is exposed for the Phase 03 request layer.
- Reason: This preserves the documented Reserve equations, prevents simultaneous Reserve charge/discharge, and avoids embedding request lifecycle assumptions in `GridCalculator`.
- Consequences: Phase 03 owns the mapping from authored continuous demand and useful WATT power to request progress, but it must consume the existing grid outputs rather than rewriting the core flow equations.

## DEC-013 — Served request load contributes useful WATT power

- Status: Proposed
- Date: 2026-07-20
- Decision: During an active request, power that serves its authored demand contributes to useful WATT power. WATT's share of surplus may add acceleration up to `max_useful_power`; only the remaining grid share may charge Reserve or convert to Stored Energy.
- Reason: This connects the load-first Phase 02 boundary to the documented first request, which must complete from the starting 5 W grid even when its continuous demand is also 5 W, without double-counting request-serving energy as currency.
- Consequences: Allocation affects acceleration when surplus exists, underpowered requests still advance from actually served demand, and preview/runtime use the same demand and cap definitions. A future balance change can alter authored values without changing this boundary.

## Proposed decision template

```markdown
## DEC-XXX — Short title

- Status: Proposed | Accepted | Rejected | Superseded by DEC-XXX
- Date:
- Decision:
- Reason:
- Consequences:
```
