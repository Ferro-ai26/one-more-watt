# ONE MORE WATT — Development Document Pack

Version: 1.0  
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

Phase 01 has established the Godot project foundation and validated content architecture. With Godot 4.6.2 available as `godot4`, run the complete repository check from this directory:

```bash
./tools/validate.sh
```

Run content validation alone with `./tools/validate_content.sh`. The project currently launches a responsive development shell that reports loaded content; gameplay remains intentionally out of scope until its later phase contracts are activated.

## Scope policy

Phases 00–09 are the committed prototype plan. Phases 10–16 are expansion contracts and should not begin until the Android prototype passes the Phase 09 gate.

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
- `docs/phases/`: build contracts
- `docs/templates/`: reusable content and phase templates

## Definition of a completed phase

A phase is complete only when its acceptance criteria pass, its automated checks pass, its manual test results are recorded, and all living documents are updated. Producing code without evidence does not complete a phase.
