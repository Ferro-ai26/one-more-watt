# Phase 01 — Data Architecture

## Objective

Implement validated, indexed, data-driven definitions for eras, infrastructure, upgrades, requests, dialogue, demand profiles, and balance constants.

## Player-facing result

The development shell can display loaded content counts and a sample request definition. No full gameplay is required.

## Required reading

`CONTENT_DATABASE.md`, `PROGRESSION_AND_BALANCE.md`, `WATT_CHARACTER_BIBLE.md`, and `TECHNICAL_ARCHITECTURE.md`.

## Included

- Data directory and manifest
- Parser and typed in-memory definitions
- Cross-reference index
- Localization-key loading
- Deterministic validation command
- Prototype records sufficient to exercise every schema
- Clear validation errors with file and record ID

## Excluded

Runtime purchases, timers, request completion, full prototype content population, save files, and final UI.

## Implementation requirements

- Definitions are immutable during normal play.
- Stable IDs are the only cross-file reference.
- Validation covers every rule in `CONTENT_DATABASE.md`.
- Unsupported effect operations fail safely.
- Debug placeholder-asset exceptions are explicit rather than globally ignoring missing files.
- Manifest or content version is available to save systems later.

## Automated tests

- Valid fixture loads
- Invalid JSON fails
- Duplicate ID fails
- Broken reference fails
- Missing localization key fails
- Negative balance value fails
- Circular required unlock fails
- Unsupported effect operation fails
- Project headless smoke test

## Manual verification

Launch the development shell and confirm content counts and one sample record match source JSON.

## Acceptance criteria

- [ ] All schema families load through one content repository
- [ ] Bad fixtures fail for the correct reason
- [ ] No authored prose or economy constants are required in UI/simulation scripts
- [ ] Content version is exposed
- [ ] Validation command is documented
- [ ] Living documents updated

## Stop condition

Do not implement economy or request progression. Stop when content definitions can be trusted by later phases.

