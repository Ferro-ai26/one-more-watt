# Known Issues

## Severity definitions

- Blocker: Prevents active-phase completion or produces unsafe data loss.
- Critical: Major feature failure, crash, or unrecoverable progress problem.
- Major: Important behavior is incorrect but a workaround exists.
- Minor: Limited defect that does not prevent normal progress.
- Polish: Presentation, tuning, or quality issue.

## Open issues

Phase 10 is closed with the user's explicit acceptance of the remaining physical-device verification limitation. The earlier Moto pass verified install, cold launch, build identity, onboarding, and touch purchases; no blocker or critical defect was reported. The density-aware Phase 10 build passed host regression and static APK inspection but was not run on that phone. Those checks remain unverified and are deferred to Phase 14 rather than claimed as passed.

Phase 13's first Moto G (2025) pass confirmed install/cold launch and found one concrete interaction defect: Build and Upgrades could not be scrolled by touch. `ISSUE-009` has a host-verified fix and awaits replacement-APK retest. The tester also directed removal of the conditional large-purchase confirmation; that accepted interaction change is recorded in `DEC-031`. Final tactile painted environment/WATT/infrastructure art remains deliberately absent: generated Phase 11 backgrounds are reference-only and the gold-standard replacement remains tracked as `ISSUE-007`, not silently claimed complete.

### ISSUE-009 — Build and Upgrades do not scroll by touch on Moto G (2025)

- Status: Fix Implemented — Device Retest Required
- Severity: Major
- First seen build/commit: Phase 13 APK from `1dcb9cf`, Motorola Moto G (2025), 2026-07-20
- Affected phase: Phase 13 physical-phone verification
- Reproduction:
  1. Install and cold-launch the Phase 13 debug APK on the Moto G (2025), reported at 720 × 1604 and 280 dpi.
  2. Open Build or Upgrades.
  3. Drag upward over the connection/upgrade cards to reach content below the fold.
- Expected: Every player-facing list and modal scrolls vertically by touch while its buttons remain tappable.
- Actual: Build and Upgrades remain at the top and content below the fold cannot be reached.
- Evidence/log: Direct tester report; `docs/ANDROID_DEVICE_TEST.md`. Source inspection found scroll containers but no explicit shared touch path, while card/control surfaces could intercept the gesture.
- Workaround: None practical on the affected APK.
- Fix verification: Added `TouchScrollContainer` for the shared screen and modal paths, explicit vertical/deadzone/pass settings, drag-safe card/control filters, and synthetic touch-drag tests for an overflowing Build drawer and Settings modal. Host UI/Phase 13 tests pass. Install the replacement commit-tied APK and repeat Build, Upgrades, Reports, and Settings scrolling before marking fixed.

### ISSUE-007 — Production environment and WATT art remain explicit fallbacks

- Status: Deferred — Later Gold-Standard Visual Production
- Severity: Polish
- First seen build/commit: Phase 12 working tree, 2026-07-20
- Affected phase: Phase 12 architecture proof and Phase 13 provisional production skin; final replacement owned by a later authorized visual-production pass
- Reproduction:
  1. Launch any Phase 13 Era 1–3 Main or Build state.
  2. Observe the project-original code-native diorama, scratched core, and semantic glyph presentation.
- Expected: Phase 13 provides a coherent, reusable, directionally faithful Eras 1–3 presentation without integrating generated concepts; a later gold-standard pass manually reconstructs final tactile painted environment, WATT, and infrastructure assets.
- Actual: The current layer is functional, responsive, authored, and compositionally faithful, but intentionally schematic rather than approval of final painted production art. This is an intended fallback, not an accidental placeholder.
- Evidence/log: `assets/asset_inventory.json` retains five release-required fallbacks and fails release scope while separately recording the integrated project-original Phase 13 diorama/glyph/audio layer. Final evidence is under `docs/phase_13/evidence/`.
- Workaround: Continue using the explicit code-native presentation layer for development and verification.
- Fix verification: A later explicitly authorized gold-standard visual-production pass must replace the five required fallback entries with provenance-recorded production assets, pass release-scope inventory validation, and receive contextual phone review. Phase 13 must not silently close this issue.

### ISSUE-008 — Phase 13 physical-phone playtest requires external completion

- Status: Partial External Pass — Retest In Progress
- Severity: Blocker for Phase 13 closure; not a known runtime defect
- First seen build/commit: Phase 13 working tree, 2026-07-20
- Affected phase: Phase 13 manual verification gate
- Reproduction:
  1. Run `adb devices -l` on the current ARM64 VPS.
  2. Observe that no device or emulator is attached.
- Expected: Run the complete Phase 13 Eras 1–3 skin on a physical Android phone and record screenshots, touch comfort, font rasterization, sound repetition/audio focus, haptics, GPU behavior, heat, and battery.
- Actual: The user confirmed install/cold launch on a Motorola Moto G (2025), app version `v0.10.0-dev`, and a 720 × 1604 / 280 dpi display. The pass found `ISSUE-009` before the full route was completed. Android/API, exact Settings build suffix, effective UI line, screenshots, safe areas, font comfort, lifecycle, audio, haptics, GPU, heat, battery, and the rest of the playthrough remain unverified.
- Evidence/log: `docs/phase_13/VISUAL_QA_RECORD.md`, `docs/PLAYTEST_CHECKLIST.md`, and `docs/CURRENT_HANDOFF.md`.
- Workaround: Host 320 × 568 and 393 × 873 evidence validates composition/layout only; it does not substitute for physical-device behavior.
- Fix verification: Retest the replacement clean commit-tied APK on the same phone, then complete and record the preserved checklist before closing Phase 13. Phase 14 remains separately gated.

### ISSUE-004 — Phone presentation appears too small

- Status: Fix Implemented — Device Verification Deferred
- Severity: Minor
- First seen build/commit: APK from `e165b2b`, manual Moto phone test, 2026-07-20
- Affected phase: Phase 09 device evidence; Phase 10 targeted stabilization; device verification deferred to Phase 14
- Reproduction:
  1. Install and launch the Phase 09 APK on the tester's Moto phone.
  2. Review the early onboarding presentation.
- Expected: The mobile presentation uses a comfortable phone-scale resolution; tester requested a 720p target.
- Actual: Onboarding remained readable and authorizable, but the overall presentation appeared too small. Repository diagnosis found that the requested 720 × 1280 base was already configured. Godot's canvas stretch scaled from pixel resolution while the UI treated its 48 logical-pixel target as 48 Android dp, so dense displays could render the interface physically smaller than intended.
- Evidence/log: Manual report from Kevin. Exact Moto model, Android/API, display size, and screenshot were not provided. Phase 10 source inspection confirmed 720 × 1280, `canvas_items`, `expand`, anchored full-rect controls, 12–22 logical-pixel type, and 48 logical-pixel controls. Density reference tests resolve 1080 × 2400 at 480 dpi and 720 × 1600 at 320 dpi to 360 × 800 effective logical units.
- Workaround: None required to continue the tested core flow.
- Fix verification: Host-side implementation and regression pass. Density-aware scaling preserves at least 320 × 568, Settings reports physical/density/effective values, and UI/layout checks pass at 320 × 568, 360 × 640, 393 × 873, 480 × 800, and 720 × 1280 with maximum text and reduced motion. Revised APK from `0c4f44e` passed static inspection with SHA-256 `c5ab857ef877284a8c09e84bdf136c06b8789be6effdf3d8b6ff931f95e8c5c4`. The user accepted closure without a repeat Moto run; physical comfort and device-detail verification are explicitly deferred to Phase 14 and are not claimed as passing.

### ISSUE-006 — Larger-text setting did not scale explicit UI fonts

- Status: Fixed
- Severity: Minor
- First seen build/commit: Phase 05 UI baseline; diagnosed during Phase 10 ISSUE-004 investigation
- Affected phase: Phase 10 targeted stabilization
- Reproduction:
  1. Open Settings in the Phase 09 prototype.
  2. Change Text size while observing request titles, dialogue, numeric vitals, modal copy, and shop text that use local font overrides.
- Expected: The documented text-size setting enlarges important dialogue, numeric, modal, and scrollable screen text and remains usable at the smallest layout.
- Actual: The setting updated runtime state and only changed the theme default; most player-facing labels had explicit font-size overrides and did not change. A restored non-default setting was likewise not applied during UI bootstrap.
- Evidence/log: Source inspection of `_cycle_text_size`, `_label`, component scenes, and the persistence bootstrap path.
- Workaround: None; reduced or default text remained readable in host layouts.
- Fix verification: Important dialogue/numeric text and labels inside scrollable screen/modal regions now scale semantically after bootstrap and after dynamic rebuilds. The integration suite verifies 130% text with reduced motion at five portrait sizes, including a 25-pixel scaled request title and no horizontal shell overflow.

### ISSUE-005 — Additional reported small bugs lack reproduction details

- Status: Withdrawn — No Actionable Reproduction Details
- Severity: Not assessed
- First seen build/commit: Phase 09 manual Moto report, 2026-07-20
- Affected phase: Phase 10 targeted stabilization — closed without action
- Reproduction: Not provided.
- Expected: Not provided.
- Actual: Kevin mentioned additional small bugs but skipped details; no behavior is inferred or fabricated.
- Evidence/log: `ANDROID_DEVICE_TEST.md` Phase 09 report.
- Workaround: Unknown.
- Fix verification: The user explicitly withdrew the remaining investigation at Phase 10 closure. No reproduction, expected behavior, or actual behavior was supplied, so no bug was inferred, invented, or changed.

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
