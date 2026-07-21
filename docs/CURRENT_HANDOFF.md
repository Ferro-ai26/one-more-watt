# Current Handoff

Updated: 2026-07-21

Active gate: Gameplay Gate G01 — Core Gameplay and Fun Validation

Status: Active — Awaiting Informed Android Baseline

## Exact result achieved

- The user authorized G01 and the reduced baseline-evidence checkpoint under `DEC-041` over the implemented Eras 1–5 baseline.
- Added a minimal debug-only local recorder, isolated playtest profile, complete/compact/human summaries, factual timing categories, and automatic 10/30/60-minute mechanical snapshots.
- Normal debug launch behavior and normal format-2 saves remain unchanged. G01 initializes only `user://g01_playtests/<session_id>/`; the isolation suite keeps an ordinary-save sentinel byte-for-byte unchanged.
- Added the deterministic baseline audit, request-category matrix, evidence protocol, and structured observation worksheet.
- Corrected the G01 evidence gate: informed self-play may support the next tuning proposal but is never fresh-player evidence; final confidence targets three unfamiliar-player sessions across more than one device where practical, or an explicit accepted limitation.
- Committed the implementation at `1f7a5231e062847d6b182f56e5ec1e7b87154798` and produced a verified G01 APK from that exact clean commit.
- Pushed the G01 implementation and artifact-handoff commits to `origin/main`; local `main` and `origin/main` were confirmed synchronized.
- No balance, dialogue, request mechanic, content data, production art, normal save field, Era 6, or Prestige behavior changed. Phase 17 did not begin.

## Files changed

- Runtime/test tooling: `scripts/playtest/`, the G01-only integration points in `scripts/ui/main_ui.gd`, dedicated export preset/build wrapper, and 42 proportional G01 checks.
- Gate/evidence documentation: `docs/phases/GATE_G01_CORE_GAMEPLAY_AND_FUN_VALIDATION.md`, `docs/g01/`, `docs/ACTIVE_PHASE.md`, and `docs/DECISION_LOG.md`.
- Living records: `docs/PROGRESS.md`, `docs/KNOWN_ISSUES.md`, `docs/PLAYTEST_CHECKLIST.md`, `docs/ANDROID_BUILD_RECORD.md`, and this handoff.
- The untracked user file `temp instructions.txt` remains untouched and uncommitted.

## Commands/tests run and results

- `./tools/test_g01.sh`: passed 32 recorder/profile and 10 isolated G01 UI checks.
- `./tools/validate.sh`: passed the complete repository regression and final headless launch. This includes 55 foundation, 36 Android configuration, 32 content plus 12 invalid fixtures, 178 grid, 187 request, 93 economy, 48 UI-system, 426 Main-UI, 85 skin-system, 51 production-skin, 81 persistence plus 14 offline-UI, 1,393 balance/reachability plus 113 UI/performance, 89+24 Phase 15, 110+23 Phase 16, the new 32+10 G01 checks, five portrait layouts, and 18/59/42 debug-panel checks.
- Final host performance sample: 893.5 ms for 25 full Build rebuilds, 590.5 ms for 500 live refreshes, and 463 UI nodes.
- `./tools/build_g01_android_debug.sh` from clean detached commit `1f7a5231e062`: passed export and static verification. The copied APK is 56,046,438 bytes with SHA-256 `c598fa084d53bc570fed2f4e884e803e48840ab2a1c2480672a8b88d26e2934f`; API 24/35, arm64/x86_64, G01 feature, build ID, VIBRATE-only permissions, and v2/v3 signatures pass.
- `./tools/android_device_smoke.sh build/android/one_more_watt_g01_debug.apk`: exited 2 because no ready device is attached; no install was attempted.
- One outer worktree-cleanup command returned nonzero only after attempting to remove an already removed temporary directory. The export script itself passed, the artifact had already been copied, no worktree remains, and independent checksum/signature checks passed.
- `git push origin main`: pushed the G01 checkpoint and confirmed local/remote synchronization.

## Manual verification

No physical Android install, gameplay session, screen recording, device screenshot, audible-speaker review, haptic check, heat/battery observation, or player-experience assessment occurred. No such pass is claimed.

## Remaining acceptance criteria

- The user must run the G01 APK for 60 foreground minutes or an honest early stop, complete observations at 10/30/60 minutes, and return the compact plus human-readable summaries. A screen recording of the first 10–15 minutes is recommended but optional.
- After evidence returns, identify exactly five highest-priority gameplay problems, supporting evidence, proposed changes, and the next controlled tuning checkpoint before changing gameplay.
- Later G01 work owns evidence-supported tuning, distinct request decisions, multiple viable approaches, feedback/report/dialogue revisions, and the final proceed/revise/stop decision.
- Seek three unfamiliar-player sessions across more than one device where reasonably obtainable; otherwise obtain an explicit accepted evidence limitation. Never relabel the informed user session.
- Phase 17 remains unauthorized regardless of G01 progress until a separate user instruction.

## Known blockers

- `ISSUE-012`: no player session has occurred, so fun, comprehension, perceived agency, and continuation intent remain unknown.
- `ISSUE-007` remains outside this baseline checkpoint as the later gold-standard production-art pass.
- Deferred Phase 15/16 phone matrices remain historical verification debt for later full Android QA, not G01 passes.

## Recommended next action inside the current gate

Install `build/android/one_more_watt_g01_debug.apk`, choose **Begin fresh isolated G01 session**, play toward 60 minutes without coaching/debug intervention, complete `docs/g01/OBSERVATION_WORKSHEET.md` at 10/30/60 minutes, then use Settings → Diagnostics to finalize and copy the compact summary. Return the compact JSON, human-readable summary, and worksheet for the five-problem evidence review. Do not begin Phase 17.
