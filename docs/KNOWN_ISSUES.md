# Known Issues

## Severity definitions

- Blocker: Prevents active-phase completion or produces unsafe data loss.
- Critical: Major feature failure, crash, or unrecoverable progress problem.
- Major: Important behavior is incorrect but a workaround exists.
- Minor: Limited defect that does not prevent normal progress.
- Polish: Presentation, tuning, or quality issue.

## Open issues

Phase 07 validation found no blocker, critical, progression, reachability, localization, save-boundary, or endpoint defect. One pacing/polish issue and the existing Android setup dependency remain open.

### ISSUE-002 — Optimized prototype path is shorter than the first-run target

- Status: Open
- Severity: Polish
- First seen build/commit: Phase 07 working tree, 2026-07-20
- Affected phase: Phase 07 baseline; tune during Phase 08
- Reproduction:
  1. Run `./tools/test_vertical_slice.sh`.
  2. Observe the deterministic no-debug balance report.
- Expected: A representative first run reaches the endpoint in 75–120 minutes without a tedious wait.
- Actual: The optimized accelerated route reaches it in 46.8 simulated minutes, while still accumulating 31.5 idle minutes and one 660-second Era 3 purchase gap.
- Evidence/log: Two clean runs produce identical Era 2 at 4.6 minutes, Era 3 at 22.8 minutes, endpoint at 46.8 minutes, 408.5 brownout seconds, and 21 earned purchases.
- Workaround: Offline progress is available before the long Era 3 gap; ordinary human reading and purchase decisions lengthen the route, but have not been used to claim the target is met.
- Fix verification: Pending Phase 08 pacing and idle-gap tuning plus another clean first-player playtest.

### ISSUE-001 — Android export configuration unavailable

- Status: Deferred
- Severity: Major
- First seen build/commit: Phase 00 working tree, 2026-07-19
- Affected phase: Phase 00 foundation; must be resolved before Phase 09 Android gate
- Reproduction:
  1. Inspect `docs/PROJECT_SETUP_CHECKLIST.md` and the local Android SDK.
  2. Observe that no publisher-controlled package identifier or Android SDK platform is available.
- Expected: A valid Android export preset can target an installed SDK platform with the approved package identifier.
- Actual: Creating a truthful, usable Android export preset is not currently possible.
- Evidence/log: Android command-line tools 19.0, build-tools 29.0.3, and adb 34.0.4 are present under `/usr/lib/android-sdk`; no `android.jar` was found.
- Workaround: Desktop/headless Godot development and tests are available.
- Fix verification: Pending package identifier, SDK platform installation, preset creation, export, and device test.

## Issue template

```markdown
### ISSUE-XXX — Title

- Status: Open | Investigating | Fixed | Deferred
- Severity:
- First seen build/commit:
- Affected phase:
- Reproduction:
  1.
  2.
- Expected:
- Actual:
- Evidence/log:
- Workaround:
- Fix verification:
```

Do not delete fixed issues. Mark them Fixed and include verification evidence.
