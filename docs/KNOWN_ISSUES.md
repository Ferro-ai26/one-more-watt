# Known Issues

## Severity definitions

- Blocker: Prevents active-phase completion or produces unsafe data loss.
- Critical: Major feature failure, crash, or unrecoverable progress problem.
- Major: Important behavior is incorrect but a workaround exists.
- Minor: Limited defect that does not prevent normal progress.
- Polish: Presentation, tuning, or quality issue.

## Open issues

Phase 09 is active. No critical, progression, reachability, localization, save-boundary, endpoint, accessibility, or available-host performance defect is known. The package identifier is approved and export configuration is ready; Phase 09 completion remains blocked on physical Android hardware.

### ISSUE-003 — Physical Android verification unavailable on current host

- Status: Open
- Severity: Blocker
- First seen build/commit: Phase 09 working tree, 2026-07-20
- Affected phase: Phase 09 completion gate
- Reproduction:
  1. Run `/home/ubuntu/.local/share/android-sdk/platform-tools/adb devices -l`.
  2. Observe no attached device; inspect the ARM64 VPS and observe no emulator package, system image, or `/dev/kvm` device.
- Expected: At least one physical Android device is available for install, cold launch, touch, safe-area, lifecycle, save/offline, sound, haptic, storage, performance, battery, and heat checks.
- Actual: No device is attached, and the current host cannot provide truthful physical-device evidence.
- Evidence/log: ADB returned an empty device list on 2026-07-20. No device test is claimed.
- Workaround: Build and inspect the APK locally, then transfer it and the Phase 09 checklist to a physical Android device or a suitable PC/device test environment.
- Fix verification: Pending recorded physical-device pass.

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

- Status: Investigating
- Severity: Major
- First seen build/commit: Phase 00 working tree, 2026-07-19
- Affected phase: Phase 00 foundation; must be resolved before Phase 09 Android gate
- Reproduction:
  1. Inspect `docs/PROJECT_SETUP_CHECKLIST.md`.
  2. Observe that no publisher-controlled package identifier has been approved.
- Expected: A valid Android export preset can target an installed SDK platform with the approved package identifier.
- Actual: Resolved in source. The publisher approved `com.ferroai.onemorewatt`; Android Platform 35, build-tools 35.0.1, platform-tools 37.0.0, matching export templates, and a validated export preset are available.
- Evidence/log: `tests/validate_android_config.gd` passes 21 checks over the recorded preset.
- Workaround: None required.
- Fix verification: Pending inspected APK package metadata; then mark Fixed.

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
