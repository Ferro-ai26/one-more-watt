# Phase 07 — Eras 1–3 Vertical Slice

## Objective

Populate and integrate the complete Cold Boot, Bedroom Assistant, and Home Server Closet experience using the proven systems.

## Player-facing result

A new player can progress from WATT's first boot through the Home Server Closet capstone in a coherent 75–120 minute first run, including save and offline play.

## Required reading

All permanent design documents, especially `CONTENT_DATABASE.md`, `WATT_CHARACTER_BIBLE.md`, `PROGRESSION_AND_BALANCE.md`, and `PLAYTEST_CHECKLIST.md`.

## Included

- All 18 cataloged prototype requests or an approved 12–18 subset
- Complete Eras 1–3 infrastructure and upgrades
- Embedded tutorial progression
- Four required request types
- Three optional vanity requests when scope permits
- WATT behavioral evolution across three eras
- One visible environment transformation per era, using polished placeholders where necessary
- Early automation and forecast unlocks
- Era transitions and prototype completion state
- Reviewed English localization strings

## Excluded

Era 4 content, prestige, live services, monetization, final store art, large localization effort, and unapproved new mechanics.

## Implementation requirements

- Every request advances a mechanic, tests the grid, unlocks meaningful content, or provides a strong character beat.
- Tutorial prompts occur immediately before the system matters.
- Automation arrives before waiting/repetition becomes tedious.
- WATT dialogue passes the character review checklist.
- Main progression remains reachable without completing vanity requests or earning top grades.
- The prototype endpoint produces a clear “more coming” state without pretending Era 4 exists.

## Automated tests

- Content validation for all prototype data
- Reachability simulation from new game to prototype endpoint
- Every required unlock condition reachable
- No circular dependency
- Request/reward ID uniqueness
- Localization completeness
- Save/load at each era boundary
- Deterministic balance simulation report
- Headless full-path smoke run using accelerated time

## Manual verification

Perform a clean-save playthrough without debug currency. Record milestone times, purchase choices, brownouts, confusion points, repeated dialogue, and idle gaps in `PLAYTEST_CHECKLIST.md`.

## Acceptance criteria

- [ ] WATT's role is clear within 30 seconds
- [ ] First five minutes contain multiple requests and visible changes
- [ ] Generation, Transmission, and Reserve each become meaningfully limiting
- [ ] 12–18 requests are complete and reviewed
- [ ] Era transitions work and persist
- [ ] Prototype endpoint is reachable without debug tools
- [ ] Full clean-save playtest evidence recorded
- [ ] No blocker/critical known issue
- [ ] Living documents updated

## Stop condition

Do not add Era 4. Stop at a complete, testable three-era vertical slice.

