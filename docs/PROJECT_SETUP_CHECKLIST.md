# Project Setup Checklist

Complete this file before or during Phase 00. Do not guess publisher-controlled identifiers.

## Repository

- Project root: `/home/ubuntu/projects/one_more_watt/one-more-watt-document-pack`
- Git remote: `origin` → `git@github.com:Ferro-ai26/one-more-watt.git`
- Default branch: `main`
- Development branch policy: Direct phase commits to `main`; no force-push
- CI available: No

## Godot

- Exact Godot version: 4.6.2.stable.official.71f334935
- Headless executable command/path: `/home/ubuntu/.local/bin/godot4 --headless`
- Renderer: GL Compatibility
- Project display name: ONE MORE WATT
- Base orientation: Portrait
- Base logical resolution: 720 × 1280, `canvas_items` stretch with `expand` aspect

## Android

- Package identifier: `com.ferroai.onemorewatt` — permanently approved by the publisher on 2026-07-20
- Minimum Android SDK: API 24, inherited from the Godot 4.6.2 prebuilt Android template
- Target Android SDK: API 35, inherited from the Godot 4.6.2 prebuilt Android template
- Java/JDK version: OpenJDK 21.0.11 at `/usr/lib/jvm/java-21-openjdk-arm64`
- Android SDK path/tool versions: `/home/ubuntu/.local/share/android-sdk`; command-line tools latest package 19.0; build-tools 35.0.1; platform-tools/adb 37.0.0; Android Platform 35 installed
- Debug keystore policy: Local development keystore only; never commit
- Release keystore location policy: External secret; never commit
- Version name: `0.10.0-dev`, sourced from `application/config/version` in `project.godot`
- Version code: 10 for the Phase 10 stabilization build

## Build commands

- Content validation: `./tools/validate_content.sh`
- Unit tests: `godot4 --headless --path . --script res://tests/content/test_invalid_content.gd`
- Simulation tests: `./tools/test_simulation.sh`
- Request lifecycle tests: `./tools/test_requests.sh`
- Economy tests: `./tools/test_economy.sh`
- Main UI tests: `./tools/test_ui.sh`
- Phase 13 production-skin tests: `./tools/test_phase13_skin.sh`
- Persistence/offline tests: `./tools/test_persistence.sh`
- Eras 1–3 vertical-slice tests: `./tools/test_vertical_slice.sh`
- Integration tests: `godot4 --headless --path . --script res://tests/integration/test_portrait_layout.gd`
- Headless smoke test: `godot4 --headless --path . -- --smoke-test`
- Full repository validation: `./tools/validate.sh`
- Debug APK export: `./tools/build_android_debug.sh` from a clean committed tree
- Physical-device install/launch smoke: `./tools/android_device_smoke.sh` after confirming the intended ADB device
- Release AAB export: Phase 16; not configured

## Ownership and publishing

- Publisher/developer name: Unknown — publisher decision required
- Copyright holder: Unknown — publisher decision required
- Support email/site: Unknown — publisher decision required
- Privacy policy location when needed: Unknown; no prototype network or sensitive-data features are planned

## Environment findings

Phase 09 reinspection found a separate current SDK at `/home/ubuntu/.local/share/android-sdk` with the required Android 35 platform and build tools; the earlier `/usr/lib/android-sdk` finding was stale and incomplete. Godot 4.6.2 and matching Android export templates are installed. The permanent package identifier and a debug-only prebuilt-template export preset are recorded. The host-verified artifact/build record is in `docs/ANDROID_BUILD_RECORD.md`. Kevin supplied a partial manual Moto phone pass because direct ADB access was unavailable; exact device/API details and the remaining device matrix were skipped.
