# Phase 06 — Save and Offline Progress

## Objective

Make player state durable and implement bounded deterministic offline simulation with recovery and truthful reporting.

## Player-facing result

The player can close the game, return later, recover progress, and understand exactly what happened while away.

## Required reading

`SAVE_AND_OFFLINE_SPEC.md`, `GAMEPLAY_SYSTEMS.md`, `TECHNICAL_ARCHITECTURE.md`, and `UI_UX_SPEC.md`.

## Included

- Versioned save envelope
- Atomic write and two known-good backups
- Autosave triggers and debounce
- Save/load round trip for all implemented state
- Sequential migration framework
- Offline elapsed-time calculation
- Event-boundary offline simulation
- Offline return report
- Clock anomaly handling
- Debug save diagnostics and recovery exercise

## Excluded

Cloud save, accounts, cross-device sync, leaderboards, device-specific backup promises, and punitive anti-cheat.

## Implementation requirements

- Save snapshots are complete and validated before replacing a known-good file.
- Derived grid caches rebuild after load.
- Request rewards remain idempotent across close/reopen.
- Active tutorial interactions that require input pause offline chaining.
- Offline cap and efficiency come from data/upgrades.
- A corrupt main save can recover from backup without destroying evidence.
- Prestige fields may be empty but schema space must remain extensible.

## Automated tests

- New-game round trip
- Mid-request round trip
- Post-completion/pre-report round trip
- Reward idempotency after reload
- Main corruption with Backup 1 recovery
- All-save failure safe path
- Migration fixture
- Offline durations: zero, short, cap, over cap
- Clock backward and far-forward behavior
- Equivalent online/offline seeded simulation within tolerance
- Queue disabled after offline completion

## Manual verification

Start a request, background or close the app, wait or use a controlled debug timestamp, return, inspect the offline report, and verify state. Repeat around request completion and with a deliberately invalid main save in a development environment.

## Acceptance criteria

- [ ] All player progress fields survive round trip
- [ ] No duplicated completion reward
- [ ] Offline report reconciles with state changes
- [ ] Cap and efficiency are disclosed
- [ ] Backup recovery works and is explained
- [ ] Save/migration tests pass
- [ ] Living documents updated

## Stop condition

Do not populate final prototype content. Stop after persistence and offline behavior are dependable.

