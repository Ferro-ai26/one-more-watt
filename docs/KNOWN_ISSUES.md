# Known Issues

## Severity definitions

- Blocker: Prevents active-phase completion or produces unsafe data loss.
- Critical: Major feature failure, crash, or unrecoverable progress problem.
- Major: Important behavior is incorrect but a workaround exists.
- Minor: Limited defect that does not prevent normal progress.
- Polish: Presentation, tuning, or quality issue.

## Open issues

Phase 08 validation found no blocker, critical, progression, reachability, localization, save-boundary, endpoint, accessibility, or available-host performance defect. The Phase 07 pacing issue is fixed. The Android setup dependency remains deferred with explicit disposition, and outside-player/audible-device validation is recorded as a playtest limitation rather than a product defect.

### ISSUE-002 — Optimized prototype path is shorter than the first-run target

- Status: Fixed
- Severity: Polish
- First seen build/commit: `abbf967`, 2026-07-20
- Fixed in build/commit: `2cffcd1`, 2026-07-20
- Affected phase: Phase 07 baseline; tune during Phase 08
- Reproduction:
  1. Run `./tools/test_vertical_slice.sh`.
  2. Observe the deterministic no-debug balance report.
- Expected: A representative first run reaches the endpoint in 75–120 minutes without a tedious wait.
- Actual: Fixed in Phase 08. The deterministic mechanical route is 65.8 minutes; the documented structured newcomer self-test is 79.8 minutes. Era 2 arrives at 11.7, Era 3 at 37.0, and no individual purchase gap exceeds 300 seconds.
- Evidence/log: Two clean no-debug runs produce identical milestones, 21 earned purchases, 18.5 idle minutes, a 300-second maximum gap, 1,143.2 recoverable brownout seconds, and the persistent endpoint. External-player timing remains unclaimed.
- Workaround: None required for the fixed pacing cliff. Offline progress remains available before both five-minute gaps.
- Fix verification: `./tools/test_vertical_slice.sh`, structured Phase 08 rounds, and visually inspected clean-path captures pass.

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
- Fix verification: Pending package identifier, SDK platform installation, preset creation, export, and device test. Disposition: Phase 08 may recommend GO, but Phase 09 cannot complete until these prerequisites and physical-device checks exist.

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
