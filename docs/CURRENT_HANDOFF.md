# Current Handoff

Updated: 2026-07-20
Active phase: Phase 09 — Android Prototype

## Current state

All host-executable Phase 09 work is complete. The permanent package `com.ferroai.onemorewatt` is approved, Android lifecycle/build-provenance gaps are addressed, and a debug APK from recorded commit `e165b2b7ace78a848b1eed4431f919804a8b8e6f` passed export and static inspection. Phase 09 remains blocked—not complete—because no physical Android device or executable emulator is available. Phase 10 has not started and is not authorized.

## Completed

- Activated Phase 09 without opening Phase 10 scope.
- Located Android Platform 35, build-tools 35.0.1, platform-tools 37.0.0, a local debug keystore, and matching Godot 4.6.2 Android templates.
- Recorded `com.ferroai.onemorewatt` in a validated debug preset with arm64-v8a/x86_64, version code/name 9/`0.9.0-dev`, no Internet/network-state permission, and `VIBRATE` for optional haptics.
- Added version/commit diagnostics, app-controlled Android Back behavior, explicit pause/resume feedback-audio handling, a project launcher icon, and four-size regression coverage.
- Added a clean-tree export tool that injects the exact source commit, rejects Godot export errors, and verifies package, version, permissions, architectures, embedded build ID, signature, and checksum.
- Built `build/android/one_more_watt_phase09_debug.apk` from `e165b2b`; the 55,797,809-byte artifact has SHA-256 `8402cde8c980c6f226dc7ac88df977692ba0822bd332d1e246055afd66c1785a`.
- Verified API 24/35, portrait/resizeable manifest, no backup, debug flag, only `VIBRATE`, arm64-v8a/x86_64 native payloads, v2/v3 debug signature, four-byte ZIP alignment, embedded build `e165b2b7ace7`, and the rendered WATT launcher icon.
- Added `docs/ANDROID_BUILD_RECORD.md`, `docs/ANDROID_DEVICE_TEST.md`, and a guarded non-destructive device install/launch script.

## Next action

Make one physical Android device available through ADB, verify the artifact checksum, run `./tools/android_device_smoke.sh`, then complete `docs/ANDROID_DEVICE_TEST.md`. Record device model/API, launch/resume time, memory/FPS, 30-minute battery/heat notes, two-hour offline return, touch/safe-area/audio/haptic behavior, force-close save recovery, and the Eras 1–3 endpoint. Only then can Phase 09 receive a final expand/revise/stop decision.

## Known blockers

- `adb devices -l` returns no device; `adb install -r` reports `no devices/emulators found`.
- This ARM64 VPS has no Android emulator binary or `/dev/kvm`. Listed ARM64 system images cannot run without an executable runtime and do not satisfy the contract's physical-device requirement.

## Test evidence

- `./tools/validate.sh` — passed after the final export/icon changes: clean import, 55 foundation, 24 Android config, content/invalid fixtures, 178 grid, 187 request, 93 economy, 42 UI/domain, 225 main-interface, 81 persistence/offline, 14 offline UI, 908 balance/reachability, 111 UI/performance, four portrait layouts, all diagnostic panels, and headless smoke launch.
- Final host performance: 25 full Build rebuilds in 985.1 ms, 500 live refreshes in 955.6 ms, 217 nodes.
- `./tools/build_android_debug.sh` — passed from clean `e165b2b`; build record and full SHA-256 generated.
- Native `aapt`, `apksigner`, `zipalign`, archive, and embedded-project checks — passed.
- Extracted xxxhdpi launcher icon — visually inspected and correct.
- `./tools/android_device_smoke.sh` — safely stopped with status 2 before mutation because no device is attached.
- A prior full-suite host timing run narrowly missed the 1000 ms synthetic refresh budget at 1016.8 ms; immediate isolated rerun passed at 969.3 ms and final full regression passed at 955.6 ms. No functional defect was observed.

## Files changed

- Android/runtime: `export_presets.cfg`, `project.godot`, `assets/icons/app_icon.svg`, `scripts/ui/main_ui.gd`, `scripts/ui/feedback_audio.gd`
- Tests/tools: `tests/validate_android_config.gd`, `tests/validate_foundation.gd`, `tests/integration/test_main_ui.gd`, `tools/build_android_debug.sh`, `tools/android_device_smoke.sh`, `tools/validate.sh`
- Documentation: `docs/ANDROID_BUILD_RECORD.md`, `docs/ANDROID_DEVICE_TEST.md`, and all required living control documents

## Remaining acceptance criteria

The recorded-commit APK/checksum and host setup/evidence criteria pass. Physical install/launch, on-device core-loop endpoint, force-close save recovery, background/offline report, unobstructed touch/safe-area behavior, device performance, and a final expand/revise/stop decision remain open. Because these are explicit Phase 09 acceptance criteria, the phase is blocked rather than complete.
