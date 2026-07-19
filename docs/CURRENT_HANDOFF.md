# Current Handoff

Updated: 2026-07-19  
Active phase: Phase 00 — Project Foundation

## Current state

Phase 00 is implemented and validated in the working tree. The Godot project launches to a responsive, portrait-first development shell; gameplay is intentionally absent.

## Completed

- Initialized a Git repository on branch `main`.
- Recorded Godot 4.6.2, GL Compatibility, Java 21, and local Android SDK findings.
- Added the documented repository layout and generated-output/secret ignore rules.
- Added `project.godot`, the base theme and audio bus layout, application bootstrap, safe-area container, and `scenes/app/Main.tscn`.
- Established `app_back`, `app_confirm`, and `app_toggle_debug` input actions.
- Added a foundation validator, three-size portrait integration test, smoke-test path, and one-command validation runner.
- Rendered and visually inspected the shell at 360 × 640, 393 × 873, and 480 × 800.

## Next action

Review the Phase 00 evidence and commit the foundation if desired. Advance `docs/ACTIVE_PHASE.md` only with explicit user authorization; do not begin Phase 01 yet.

## Known blockers

- Android package identifier and publisher identity are not yet supplied.
- The local Android SDK has tools but no installed platform package, so Android export is not supportable yet.
- GitHub SSH remote is configured; Phase commits go directly to `main`.
- Physical Android safe-area and device behavior remain unverified.

## Test evidence

- `./tools/validate.sh` — passed: clean import, 51 foundation checks, three portrait layout sizes, and headless main-scene smoke launch.
- `xvfb-run -a godot4 --path . --script res://tests/integration/test_portrait_layout.gd -- --capture-layouts` — passed; all three rendered captures inspected with no clipping or missing resources. Xvfb reported expected host V-Sync/audio-device warnings.
- Graphical runtime capture — passed under Xvfb/llvmpipe with the development shell visibly rendered.
- `xvfb-run -a godot4 --editor --path . --quit-after 2` — editor started and exited successfully; the VPS reported host audio/V-Sync and unavailable Vulkan-device scan warnings, with no project parser or resource errors.
- Android export/device test — not run; prerequisites are unavailable.

## Files changed

- Project configuration: `.gitignore`, `project.godot`, `default_bus_layout.tres`
- Shell: `scenes/app/Main.tscn`, `scripts/core/app_bootstrap.gd`, `scripts/ui/safe_area_root.gd`, `assets/themes/base_theme.tres`
- Validation: `tools/validate.sh`, `tests/validate_foundation.gd`, `tests/integration/test_portrait_layout.gd`, `tests/README.md`
- Structure markers under `assets/`, `data/`, `scenes/`, `scripts/`, and `tests/`
- Documentation: `README.md`, `docs/PROJECT_SETUP_CHECKLIST.md`, `docs/CURRENT_HANDOFF.md`, `docs/PROGRESS.md`, `docs/KNOWN_ISSUES.md`, `docs/PLAYTEST_CHECKLIST.md`, `docs/DECISION_LOG.md`

## Remaining acceptance criteria

All locally supportable Phase 00 acceptance criteria pass. Android export and physical-device verification belong to later work after the missing publisher identity and SDK platform are supplied.
