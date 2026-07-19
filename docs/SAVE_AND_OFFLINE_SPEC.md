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

