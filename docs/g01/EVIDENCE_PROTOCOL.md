# G01 Evidence Protocol

## Recorder boundary

The recorder is enabled only by the `g01_playtest` export feature, `--g01-playtest`, or the isolated test override. Normal debug launch behavior is unchanged. It observes the central `GameSession.mutation_committed` signal, session snapshots, one low-frequency classification sample, and centralized report/maintenance/lifecycle UI boundaries.

It writes only under `user://g01_playtests/<session_id>/`:

- `save/` — isolated format-2 playtest save and backups
- `g01_record.json` — complete local ordered record
- `g01_compact.json` — clipboard-safe summary, at most 8 KiB
- `g01_summary.txt` — human-readable factual summary

No account, player name, IP address, free-form observation, normal save payload, remote transmission, Internet permission, or production analytics service is added.

## Objective events

Purchases, upgrades, authorizations, allocation changes, maintenance choices/deferrals, report views, relevant automation configuration, request completions, brownouts/recoveries, Reserve-support episodes, and 10/30/60-minute snapshots are recorded. Counts are objective actions, never “meaningful decisions.”

## Timing categories

- **Foreground interaction gap:** the span between objective actions; it carries a breakdown and is not a behavioral judgment.
- **System-imposed forced stall:** foreground time with no authorization/report/maintenance decision and no affordable unlocked purchase or upgrade.
- **Report/dialogue viewing:** identified request-detail, performance-report, or offline-report foreground time.
- **Background/offline:** time outside active foreground play, separate from simulated rewards.
- **Unknown inactivity:** remaining foreground time whose intent cannot be established.

No category infers boredom, confusion, attention, strategy, or perceived agency.

## Evidence sequence

1. Run the deterministic audit separately from observed play.
2. User starts a fresh isolated Android G01 session and plays toward 60 minutes, stopping honestly if desired.
3. User completes structured observations at 10, 30, and 60 minutes or early stop. A first-10–15-minute screen recording is recommended, not required.
4. Retain the full record locally; paste the compact JSON and provide the human summary plus worksheet.
5. Review the baseline and produce exactly five prioritized gameplay problems, evidence, proposed revisions, and the next controlled tuning checkpoint.
6. Later target at least three unfamiliar-player sessions across more than one device where practical. If unavailable, obtain an explicit evidence-limitation disposition before the final G01 decision.
