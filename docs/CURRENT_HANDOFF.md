# Current Handoff

Updated: 2026-07-20

Active phase: Phase 10 — Targeted Bug Fixing and Prototype Stabilization

Status: In Progress — Host Fix and APK Verified; Phone Retest Pending

## Exact result achieved

The user explicitly authorized Phase 10. Repository-side diagnosis of `ISSUE-004` is complete: the project already used the suggested 720 × 1280 base with `canvas_items`/`expand`, so blindly changing to 720p would not address the report. The scale mismatch came from treating 48 logical pixels as 48 Android dp while Godot's automatic canvas stretch followed physical pixel resolution.

A bounded mobile density scaler now adjusts the root window's content scale from the Android-reported dpi and physical window size. It targets density-independent logical sizing but never reduces the effective viewport below the verified 320 × 568 layout. Settings exposes display pixels, dpi, effective logical dimensions, and applied scale for the targeted phone retest.

The investigation also confirmed and fixed `ISSUE-006`: Text size changed stored state but explicit per-control font sizes did not scale, and restored text size was not applied at bootstrap. Important dialogue/numeric text plus labels inside scrollable screens and modals now apply the saved 100%/115%/130% scale. Compact metadata and controls remain stable so the smallest layout does not overflow horizontally.

The additional “small bugs” mentioned during Phase 09 remain `ISSUE-005 — Needs Information`; no unspecified behavior was inferred.

The implementation/evidence checkpoint is committed as `0c4f44e`. Its clean-tree Phase 10 APK passed scripted export and static inspection: `build/android/one_more_watt_phase10_debug.apk`, 55,802,078 bytes, SHA-256 `c5ab857ef877284a8c09e84bdf136c06b8789be6effdf3d8b6ff931f95e8c5c4`, version code/name 10/`0.10.0-dev`, API 24–35, arm64-v8a/x86_64, VIBRATE-only, v2/v3 signature, four-byte alignment, portrait manifest, and embedded build `0c4f44e259c9`.

## Files changed

- Added `scripts/ui/mobile_ui_scaler.gd` and its imported UID.
- Updated `scripts/ui/main_ui.gd` and `scripts/ui/vital_card.gd` for scale application, display diagnostics, semantic text scaling, and compact vital headings.
- Advanced project/export identity to `0.10.0-dev`, version code 10, and `one_more_watt_phase10_debug.apk` in `project.godot`, `export_presets.cfg`, and Android scripts.
- Expanded UI and portrait tests to five layouts including 720 × 1280, density reference calculations, maximum text, and reduced motion.
- Updated active-phase, progress, playtest, issue, decision, setup, release, README, and test documentation.

## Commands/tests run

- `./tools/validate.sh` before edits: passed the complete Phase 09 baseline.
- `./tools/test_ui.sh` after the final UI changes: 48 UI-system and 296 integration checks passed.
- `xvfb-run -a godot4 --path . --script res://tests/integration/test_main_ui.gd -- --capture-layouts`: 331 checks passed with 35 captures generated.
- Representative 320 × 568 authorization/settings, 360 × 640 Build, and 720 × 1280 authorization/settings captures were visually inspected.
- `./tools/validate.sh` after implementation: full repository suite passed, including 908 balance/reachability, 111 UI/performance, 81 persistence/offline, five portrait layouts, Android configuration, and headless smoke launch.
- `./tools/build_android_debug.sh`: exported and verified the Phase 10 APK from clean commit `0c4f44e`.
- Additional `aapt`, `zipalign`, and SHA-256 inspection confirmed version/API, portrait/resizeable manifest, disabled backup, VIBRATE-only permissions, alignment, size, and hash.
- `./tools/android_device_smoke.sh`: exited 2 because no ready device was attached; no install was attempted.
- `git diff --check`: passed before the implementation commit; rerun for the final evidence update.

## Remaining acceptance criteria

- Install the APK on the Moto phone and confirm physical comfort, not only technical readability.
- Record the exact Moto/display details and exercise the high-value skipped checks where practical.
- Update the living evidence with APK identity and phone results.

## Known blockers

The VPS has no attached Android device or emulator/KVM path. The exact Moto model, Android/API, display dimensions/density, screenshot, and the reproduction details for the unspecified small bugs are unavailable. These do not block host implementation or APK construction, but physical-device acceptance cannot be claimed without tester evidence.

## Recommended next action

Hand the exact recorded APK to Kevin and complete the Phase 10 section of `ANDROID_DEVICE_TEST.md`. Do not begin Phase 11.
