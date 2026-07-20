# Save and Offline Progress Specification

## Goals

- Never intentionally lose valid player progress
- Resume predictably after Android suspension or termination
- Keep offline outcomes consistent with online rules
- Support future schema migrations
- Prevent duplicate rewards

## Storage

Use Godot's writable user-data location. Maintain:

- `save_main.json` or an equivalent stable binary format
- `save_backup_1`
- `save_backup_2`
- `save_meta` containing lightweight version/checksum information when needed

JSON is preferred during the prototype for inspectability. If a binary format is later chosen, retain a debug export path.

## Save envelope

The save contains:

- Format/schema version
- Game build version
- Content version
- Save sequence number
- Created and updated timestamps in UTC
- Last trusted wall-clock timestamp
- Checksum or integrity field
- Player/runtime state payload

## Write procedure

1. Serialize a complete snapshot to a temporary file.
2. Validate the serialized snapshot can be parsed.
3. Flush/close the file.
4. Rotate known-good backups.
5. Atomically replace the main save where the platform permits.
6. Record success without blocking the player longer than necessary.

Never overwrite all known-good copies before validating the new snapshot.

## Save triggers

- After completing or acknowledging a request report
- After a significant purchase or unlock, with debouncing
- On era transition
- Before and after prestige
- When the app moves to the background
- Periodically during active play, initially every 30 seconds if state changed
- On clean quit

## Load and recovery

Load the newest valid save by sequence number, beginning with the main file. If it is corrupt or incompatible:

1. Attempt Backup 1.
2. Attempt Backup 2.
3. Explain which backup was restored.
4. Preserve corrupt files for diagnostics rather than overwriting them immediately.
5. Start a new game only after all recovery paths fail and the player confirms when practical.

## Schema migrations

- Migrations are sequential: version N to N+1.
- Each migration is deterministic and testable.
- Unknown future versions fail safely rather than being loaded partially.
- Removed stable IDs map through explicit compatibility tables.
- Migration makes a backup before replacing the original.

## Offline timing

When backgrounding or saving, record UTC wall time. On return:

```text
raw_elapsed = current_utc - last_saved_utc
recognized_elapsed = clamp(raw_elapsed, 0, offline_cap)
effective_elapsed = recognized_elapsed × offline_efficiency
```

If the clock moves backward, grant zero negative progress, retain the last trusted timestamp, and show no accusatory message. If time jumps implausibly far forward, apply only the normal cap and record a diagnostic flag.

## Offline simulation order

1. Load and migrate state.
2. Determine recognized elapsed duration.
3. Rebuild derived grid values.
4. Simulate active request to the next event boundary.
5. Apply Reserve, demand peaks, progress, and Stored Energy using normal rules.
6. If a request completes, grant its rewards exactly once.
7. Start another request only when queue automation is unlocked and enabled.
8. Continue until elapsed time is consumed or no system can progress.
9. Produce a summarized offline report.
10. Save the resulting state before dismissing the report.

## Fairness rules

- No random destructive incidents occur offline.
- The player does not lose infrastructure, Stored Energy, or completed progress while away.
- Known deterministic demand events may cause brownouts exactly as they would online.
- Request progress never exceeds 100%.
- A completed request cannot award twice if the app closes before its report is viewed.
- Offline generation cannot bypass locked mechanics.
- The displayed result must disclose the cap and efficiency applied.

## Test matrix

- Save/load with a new game
- Save/load at every request state
- Close during a purchase
- Close immediately after request completion
- Close while a report is open
- Offline duration of 0, 1 second, 10 minutes, exact cap, and beyond cap
- Clock moved backward
- Clock moved far forward
- Corrupt main with valid backup
- Corrupt all saves
- Migration from every supported schema version
- Stable IDs removed or renamed through migration
- Offline request completes with queue disabled
- Multiple offline completions with queue enabled

## Phase 06 implementation baseline

Prototype saves use format version 2 and inspectable checksummed JSON. `save_main.json`, `save_backup_1.json`, and `save_backup_2.json` live under `user://`; a complete snapshot is restored into a throwaway domain session before the validated temporary file can rotate known-good backups and replace main. Corrupt main files are copied to timestamped diagnostic evidence before recovery or replacement.

The envelope stores build/content versions, sequence, UTC epoch timestamps, last trusted UTC, trigger, checksum, and a session payload. Session state includes stable-ID ownership and upgrades, milestone/unlock state, full request lifecycle/statistics/reports, fixed-step accumulator and grid state, deterministic seed/incident position, dialogue repetition state, runtime settings, and extensible prestige/lifetime/tutorial sections. Derived grid values are always rebuilt after restore.

Format migrations run sequentially before domain restore. The version 1 fixture adds the prestige namespace and maps the retired fixture ID `starter_outlet` to `wall_outlet`; unknown future formats fail closed. A migrated main is preserved as Backup 1 when the new current-format save is written.

Offline policy is authored in balance data: a 7,200-second cap, 80% efficiency, and a seven-day far-forward diagnostic threshold. Simulation uses the normal fixed-step request/grid rules in bounded chunks, stops at request completion before consuming remaining idle time, disables incidents not explicitly allowed offline, never auto-starts the next request without queue automation, and pauses an announced tutorial requiring input. The post-offline state is saved before its return report is dismissed.

Phase 07 adds era/feature progression, best Stability service, pending transition, and prototype-completion fields to the economy payload with safe defaults under format version 2. Additive content version `0.7.0` explicitly accepts `0.6.0` saves, rebuilds new request states, and reconciles existing reports into feature/era state before the next write upgrades the envelope content version. Offline progress grants zero before its Era 2 feature unlock.

Phase 08 keeps save format 2 and stable IDs. Content version `0.8.0` explicitly accepts `0.7.0` and `0.6.0` because the phase changes balance, localization, feedback, and presentation without removing saved fields or content IDs. Restore rebuilds the current tuned aggregates and request definitions; the next successful write upgrades the envelope content version.

Phase 15 keeps save format 2 and advances canonical content to `0.9.0`. Additive economy fields record Predictive Reserve Guard configuration, stable-ID maintenance choices/pending input, one-request temporary effects and their bound request ID, and completed eras. Missing fields migrate to safe empty/disabled defaults. `0.9.0` accepts `0.8.0`, `0.7.0`, and `0.6.0`; restored Era 3 endpoints expose an explicit Era 4 authorization without currency loss or ownership mutation.

Offline simulation stops before consuming elapsed time whenever an unresolved maintenance review requires operator input. It never selects Repair, Replace, or Overclock. A bound one-request Overclock survives save/load and clears exactly once after that request completes. Phase 15 also normalizes typed Godot collections through JSON before checksum calculation so a just-encoded envelope validates identically to its parsed representation; self-validation errors report their concrete validation reason.
