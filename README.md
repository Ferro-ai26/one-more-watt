# ONE MORE WATT — Development Document Pack

Version: 2.0
Target: Android-first Godot incremental/idle game  
Prototype scope: Eras 1–3  
First major product checkpoint: Era 6 and first prestige

## Purpose

This pack converts the original game plan into build-facing specifications for Codex. The files are intended to be placed at the root of the game repository and committed to version control before development begins.

The documents use three levels of authority:

1. **Permanent specifications** define the product, systems, content, presentation, and technical rules.
2. **Phase contracts** define exactly what Codex may build during a particular phase.
3. **Living control documents** record the active phase, current state, decisions, defects, and test results.

If documents conflict, use this order:

1. `docs/DECISION_LOG.md` entries marked Accepted, newest first
2. The active phase contract
3. Permanent specifications
4. `docs/GAME_VISION.md`
5. The original concept document

## Starting development

1. Copy this pack into the repository root.
2. Open `docs/PROJECT_SETUP_CHECKLIST.md` and fill in the repository-specific values.
3. Set `docs/ACTIVE_PHASE.md` to Phase 00.
4. Start Codex from the repository root.
5. Tell Codex: `Read AGENTS.md and execute only the active phase.`
6. Review the phase evidence before advancing `ACTIVE_PHASE.md`.

## Current repository

Phases 00–10 are closed. Phase 10 added Android density-aware canvas scaling while preserving the verified minimum layout and repaired the larger-text path. Its revised APK and complete host regression passed; the user accepted deferral of the remaining Moto verification to Phase 14. Phase 11 is awaiting explicit authorization and has not begun. With Godot 4.6.2 available as `godot4`, run the complete repository check from this directory:

```bash
./tools/validate.sh
```

Run content validation alone with `./tools/validate_content.sh`, grid tests with `./tools/test_simulation.sh`, request-domain tests with `./tools/test_requests.sh`, economy tests with `./tools/test_economy.sh`, main-interface tests with `./tools/test_ui.sh`, persistence/offline tests with `./tools/test_persistence.sh`, and the balance/reachability/performance path with `./tools/test_vertical_slice.sh`. `./tools/build_android_debug.sh` produces and verifies the debug APK from a clean commit; `./tools/android_device_smoke.sh` installs and cold-launches it when a device is attached. Era 4, prestige, cloud accounts, final production art/music, store rollout, and release signing remain deferred.

## Scope policy

Phases 00–10 are completed history. `docs/ROADMAP_V2.md` and the revised Phase 10–26 contracts govern post-prototype work. The superseded, unstarted v1 Phase 10–16 contracts are retained under `docs/phases/legacy_v1/` for history only and must not be executed.

The numerical values in `PROGRESSION_AND_BALANCE.md` are initial tuning values, not promises. Change them through recorded balance decisions and data files, never by scattering constants through scripts.

## Pack contents

- `AGENTS.md`: mandatory operating rules for Codex
- `docs/GAME_VISION.md`: concise product authority
- `docs/GAMEPLAY_SYSTEMS.md`: simulation and mechanic rules
- `docs/PROGRESSION_AND_BALANCE.md`: economy formulas and initial numbers
- `docs/WATT_CHARACTER_BIBLE.md`: character and comedy rules
- `docs/CONTENT_DATABASE.md`: content schemas and prototype catalog
- `docs/UI_UX_SPEC.md`: mobile screens and interaction behavior
- `docs/TECHNICAL_ARCHITECTURE.md`: Godot implementation boundaries
- `docs/SAVE_AND_OFFLINE_SPEC.md`: persistence and offline rules
- `docs/ART_AND_AUDIO_DIRECTION.md`: audiovisual direction
- `docs/ANDROID_RELEASE_SPEC.md`: Android requirements
- `docs/ROADMAP_V2.md`: accepted post-prototype phase sequence and release policy
- `docs/THEME_AND_ART_DIRECTION_SPEC.md`: visual identity approval contract
- `docs/ART_DIRECTION_WORKBOOK.md`: Phase 11 visual exploration and approval record
- `docs/SKIN_ARCHITECTURE_SPEC.md`: reusable production skin system
- `docs/ASSET_PIPELINE_AND_INVENTORY.md`: asset ownership and production pipeline
- `docs/VISUAL_QA_CHECKLIST.md`: visual, mobile, and accessibility verification
- `docs/RELEASE_READINESS_DEFINITION.md`: production release evidence bar
- `docs/phases/`: build contracts
- `docs/templates/`: reusable content and phase templates

## Definition of a completed phase

A phase is complete only when its acceptance criteria pass, its automated checks pass, its manual test results are recorded, and all living documents are updated. Producing code without evidence does not complete a phase.

<!-- ONE_MORE_WATT_README_V2 -->
## Post-prototype roadmap v2

Phase 09 closed with “continue with targeted revisions.” `docs/ROADMAP_V2.md` and the revised Phase 10–26 contracts supersede the archived v1 Phase 10–16 plan. The new roadmap adds targeted stabilization, approved art direction, reusable skin architecture, production skinning, era-integrated art, content lock, final audiovisual production, release-candidate stabilization, closed testing, and separately authorized production release.
<!-- END_ONE_MORE_WATT_README_V2 -->
