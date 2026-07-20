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

- Package identifier: Unknown — publisher-controlled value required before creating an export preset
- Minimum Android SDK: Unknown — not selected
- Target Android SDK: Unknown — not selected
- Java/JDK version: OpenJDK 21.0.11 at `/usr/lib/jvm/java-21-openjdk-arm64`
- Android SDK path/tool versions: `/usr/lib/android-sdk`; command-line tools 19.0; build-tools 29.0.3; adb 34.0.4; no installed Android platform (`android.jar`) detected
- Debug keystore policy: Local development keystore only; never commit
- Release keystore location policy: External secret; never commit
- Version name: `0.0.1-dev`, sourced from `application/config/version` in `project.godot`
- Version code: Not configured; requires Android export preset

## Build commands

- Content validation: `./tools/validate_content.sh`
- Unit tests: `godot4 --headless --path . --script res://tests/content/test_invalid_content.gd`
- Simulation tests: `./tools/test_simulation.sh`
- Request lifecycle tests: `./tools/test_requests.sh`
- Economy tests: `./tools/test_economy.sh`
- Main UI tests: `./tools/test_ui.sh`
- Integration tests: `godot4 --headless --path . --script res://tests/integration/test_portrait_layout.gd`
- Headless smoke test: `godot4 --headless --path . -- --smoke-test`
- Full repository validation: `./tools/validate.sh`
- Debug APK export: Pending package identifier, SDK platform installation, and export preset
- Release AAB export: Phase 16; not configured

## Ownership and publishing

- Publisher/developer name: Unknown — publisher decision required
- Copyright holder: Unknown — publisher decision required
- Support email/site: Unknown — publisher decision required
- Privacy policy location when needed: Unknown; no prototype network or sensitive-data features are planned

## Environment findings

Phase 00 was executed on Ubuntu 24.04 ARM64 (`aarch64`). Godot 4.6.2 and matching ARM64 desktop export templates run locally. Android export templates are installed, but the SDK has no installed Android platform and the package identifier is undecided, so no Android preset or APK was produced. No physical-device test has occurred.
