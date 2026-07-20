# Known Issues

## Severity definitions

- Blocker: Prevents active-phase completion or produces unsafe data loss.
- Critical: Major feature failure, crash, or unrecoverable progress problem.
- Major: Important behavior is incorrect but a workaround exists.
- Minor: Limited defect that does not prevent normal progress.
- Polish: Presentation, tuning, or quality issue.

## Open issues

Phase 04 validation found no new economy, unlock, milestone, upgrade, automation, or shop-preview defects. The existing Android setup dependency remains open.

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
