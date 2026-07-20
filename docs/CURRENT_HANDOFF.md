# Current Handoff

Updated: 2026-07-20
Active phase: Phase 09 — Android Prototype

## Current state

Phase 09 is in progress by explicit user authorization. The permanent package identifier `com.ferroai.onemorewatt` is approved and captured in a validated debug export preset. Host-side Android preparation is implemented: the correct Android 35 SDK was located, the app version is `0.9.0-dev`, build provenance is visible in Settings/diagnostics, Android Back is app-controlled, pause/resume audio behavior is explicit, and a clean-tree export/inspection script is ready. Physical-device acceptance is waiting for an attached Android device.

## Completed

- Activated Phase 09 without opening Phase 10 scope.
- Reinspected the local toolchain and found Android Platform 35, build-tools 35.0.1, platform-tools 37.0.0, a local debug keystore, and matching Godot 4.6.2 Android templates.
- Set the Phase 09 development version and added build provenance to Settings and the diagnostic summary.
- Disabled automatic Android Back exit; Back now closes the top modal, returns secondary navigation to Grid, then saves and exits only from the root screen.
- Stopped feedback audio on application pause and restored playback eligibility on resume; the existing background save and offline-return path remains authoritative.
- Added `tools/build_android_debug.sh`, which requires a clean tree, injects the exact source commit into the exported build, exports with Godot, verifies the APK signature/package, and records SHA-256 provenance.
- Added regression coverage for version/build diagnostics and Android Back notifications across all four portrait sizes.
- Recorded the approved permanent package identifier and a debug-only preset with arm64-v8a/x86_64, no Internet/network-state permission, and vibration permission for optional haptics.

## Next action

Commit the validated export configuration and run `./tools/build_android_debug.sh`. Then attach a physical Android device for install, lifecycle, touch, safe-area, audio, haptic, storage, performance, and full-loop verification.

## Known blockers

- No Android device is attached to ADB, and this ARM64 VPS has no emulator/system image or KVM device. Phase 09 cannot meet its physical-device acceptance criteria on the current host alone.

## Test evidence

- `godot4 --headless --path . --script res://tests/validate_foundation.gd` — passed 53 checks.
- `godot4 --headless --path . --script res://tests/unit/test_main_ui_systems.gd` — passed 42 checks.
- `godot4 --headless --path . --script res://tests/integration/test_main_ui.gd` — passed 225 checks across 320 × 568, 360 × 640, 393 × 873, and 480 × 800.
- `./tools/validate.sh` — passed the complete repository suite: clean import, 53 foundation, content/invalid fixtures, grid, request, economy, 42 UI/domain, 225 main-interface, persistence/offline, 908 balance/reachability, 111 progression-UI/performance, four portrait layouts, all diagnostic panels, and headless smoke launch.
- `bash -n tools/build_android_debug.sh` — passed.
- `godot4 --headless --path . --script res://tests/validate_android_config.gd` — passed 21 package/version/architecture/permission/export-boundary checks.
- `adb devices -l` — no attached devices.
- One full-suite run hit 1016.8 ms against the 1000 ms host-only live-refresh budget; immediate isolated rerun passed at 969.3 ms with all 111 UI/performance checks. No functional failure occurred.
- First export attempt from `54781a1` failed before artifact creation because the preset mixed an empty debug-keystore path with explicit credentials. The preset was corrected to keep all debug signing configuration in uncommitted editor settings.
- Second export attempt from `3dffe01` produced a correctly packaged and signed APK, exposing the approved package, API 24/35, arm64-v8a/x86_64 libraries, and only `VIBRATE`; it was not accepted because Godot logged a missing-project-icon error and the API-35 inspection binaries were not executable on the ARM64 host. A project icon and native inspection-tool fallback were added for the next clean build.
- APK export remains to be run from the committed preset.

## Files changed

- Phase control/setup: `docs/ACTIVE_PHASE.md`, `docs/PROJECT_SETUP_CHECKLIST.md`
- Runtime: `project.godot`, `scripts/ui/main_ui.gd`, `scripts/ui/feedback_audio.gd`
- Tests/tooling: `tests/validate_foundation.gd`, `tests/integration/test_main_ui.gd`, `tools/build_android_debug.sh`
- Living documentation: `README.md`, `docs/CURRENT_HANDOFF.md`, `docs/PROGRESS.md`, `docs/KNOWN_ISSUES.md`, `docs/PLAYTEST_CHECKLIST.md`, `docs/DECISION_LOG.md`

## Remaining acceptance criteria

All Phase 09 acceptance criteria involving physical Android hardware remain open. Host-side lifecycle behavior, export configuration, and build provenance are implemented and covered, but an APK checksum/package/signature inspection is still pending the clean commit, and device install/launch, complete core loop, force-close save recovery, background offline report, touch/safe-area review, and device performance evidence have not yet occurred.
