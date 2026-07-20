# Known Issues

## Severity definitions

- Blocker: Prevents active-phase completion or produces unsafe data loss.
- Critical: Major feature failure, crash, or unrecoverable progress problem.
- Major: Important behavior is incorrect but a workaround exists.
- Minor: Limited defect that does not prevent normal progress.
- Polish: Presentation, tuning, or quality issue.

## Open issues

Phase 09 is closed with the decision “continue with targeted revisions.” Manual Moto testing verified install, cold launch, build identity, onboarding, and touch purchases. No blocker or critical defect was reported. The remaining device matrix was skipped at the tester's request and is not claimed as passed.

### ISSUE-004 — Phone presentation appears too small

- Status: Open
- Severity: Minor
- First seen build/commit: APK from `e165b2b`, manual Moto phone test, 2026-07-20
- Affected phase: Phase 09 device evidence; Phase 10 targeted stabilization
- Reproduction:
  1. Install and launch the Phase 09 APK on the tester's Moto phone.
  2. Review the early onboarding presentation.
- Expected: The mobile presentation uses a comfortable phone-scale resolution; tester requested a 720p target.
- Actual: Onboarding remained readable and authorizable, but the overall presentation appeared too small.
- Evidence/log: Manual report from Kevin. Exact Moto model, Android/API, display size, and screenshot were not provided.
- Workaround: None required to continue the tested core flow.
- Fix verification: Pending a targeted resolution/scale revision and repeat device review.

### ISSUE-003 — Physical Android verification unavailable on current host

- Status: Fixed
- Severity: Blocker
- First seen build/commit: `d588ba3`, 2026-07-20
- Affected phase: Phase 09 completion gate
- Reproduction:
  1. Run `/home/ubuntu/.local/share/android-sdk/platform-tools/adb devices -l`.
  2. Observe no attached device; inspect the ARM64 VPS and observe no emulator package, system image, or `/dev/kvm` device.
- Expected: At least one physical Android device is available for install, cold launch, touch, safe-area, lifecycle, save/offline, sound, haptic, storage, performance, battery, and heat checks.
- Actual: No device is attached to the VPS, but the user supplied truthful manual evidence from a Moto phone.
- Evidence/log: Kevin reported successful install/cold launch, correct Settings version/build, readable and authorizable onboarding, and working Build/Upgrade touch purchases. Remaining device checks were explicitly skipped.
- Workaround: Manual device reporting was used because direct ADB access to the VPS was unavailable.
- Fix verification: The Phase 09 physical-evidence blocker is resolved for the recorded partial pass; unexecuted checks remain documented limitations rather than passed results.

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

- Status: Fixed
- Severity: Major
- First seen build/commit: Phase 00 working tree, 2026-07-19
- Affected phase: Phase 00 foundation and Phase 09 export; resolved during Phase 09
- Reproduction:
  1. Inspect `docs/PROJECT_SETUP_CHECKLIST.md`.
  2. Observe that no publisher-controlled package identifier has been approved.
- Expected: A valid Android export preset can target an installed SDK platform with the approved package identifier.
- Actual: Resolved in source. The publisher approved `com.ferroai.onemorewatt`; Android Platform 35, build-tools 35.0.1, platform-tools 37.0.0, matching export templates, and a validated export preset are available.
- Evidence/log: `tests/validate_android_config.gd` passes 24 checks over the recorded preset.
- Workaround: None required.
- Fix verification: APK from `e165b2b` statically verifies package `com.ferroai.onemorewatt`, version code/name 9/`0.9.0-dev`, API 24/35, arm64-v8a/x86_64, only `VIBRATE`, v2/v3 signature, four-byte alignment, and embedded build ID. SHA-256 is recorded in `docs/ANDROID_BUILD_RECORD.md`.

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
