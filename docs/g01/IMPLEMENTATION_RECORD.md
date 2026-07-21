# G01 Baseline Evidence Implementation Record

Date: 2026-07-21
Status: Host implementation complete; Android artifact and informed session pending

## Implemented

- Minimal debug-only recorder driven primarily by `GameSession.mutation_committed`, factual session snapshots, and centralized report/maintenance/lifecycle boundaries
- Isolated `user://g01_playtests/<session_id>/` profile with explicit begin/resume and no normal-save initialization
- Complete atomic JSON record, compact clipboard JSON capped at 8 KiB, and human-readable factual summary
- Objective action counts and separate foreground-gap, forced-stall, report/dialogue, unknown-inactivity, and background/offline durations
- Automatic mechanical snapshots at 10, 30, and 60 foreground minutes
- Separately flagged `Android G01 Debug` export while preserving the normal runnable debug preset
- Deterministic audit, category matrix, evidence protocol, and observation worksheet

## Explicitly unchanged

Content remains `0.10.0`, normal saves remain format 2, and no balance, request formula, dialogue, mechanic, production art, Era 6, or Prestige content changed. The recorder never calls remote services and the APK presets continue excluding Internet and network-state permissions.

## Host validation

- `./tools/test_g01.sh`: 32 recorder/profile plus 10 G01 UI checks passed.
- `./tools/validate.sh`: complete repository regression and headless launch passed through Phase 16 plus G01. Android configuration now passes 36 checks; all previous gameplay, persistence, layout, skin, and era suites remain green.
- Deterministic route remains 115.4 mechanical / 135.5 structured minutes through Era 4, with Era 2 at 11.7 minutes, Era 3 at 37.0 minutes, 22.3 idle minutes, a 300-second longest modeled purchase gap, and 1,625.2 brownout seconds.

No physical Android run, visual screen inspection, or player-experience observation occurred in this host implementation record.
