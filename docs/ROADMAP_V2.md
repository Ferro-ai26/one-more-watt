# ONE MORE WATT — Development Roadmap v2

Status: Accepted post-Phase-09 roadmap; base-v1 scope revised under `DEC-040`
Effective after: Phase 09 Android Prototype closure
Phase 09 decision: Continue with targeted revisions

## Base game v1.0 scope decision

City Data Center/Era 6 is the final content era of base game v1.0. The base release must include the City idle transition and the first complete Model Retraining/Prestige loop. The authoritative 16-era ladder is preserved, but Eras 7–16 are post-launch expansion-sized updates rather than base-v1 release requirements.

Gameplay Gate G01 is inserted after Phase 16 and before Phase 17. It validates and improves the completed Eras 1–5 first 30–60 minutes before any City implementation. The gate does not renumber, delete, overwrite, authorize, or begin an existing numbered phase.

## Why the roadmap changed

The original roadmap proved the Eras 1–3 prototype but moved too quickly from content expansion to release. It mentioned art direction and polish without defining a production-quality theming and skinning pipeline.

Version 2 separates five different kinds of work:

1. Functional stabilization
2. Visual identity design
3. Reusable skin-system construction
4. Era-by-era content production
5. Release-candidate validation and publishing

This prevents the game from accumulating many gray-box eras and leaving an unmanageable art conversion for the end.

## Revised phases

| Phase | Name | Primary gate |
| ---: | --- | --- |
| 10 | Targeted Bug Fixing and Prototype Stabilization | Known prototype defects resolved or dispositioned |
| 11 | Theme and Art Direction | Visual direction approved from representative concepts |
| 12 | Skin Architecture and Design System | Reusable Godot skin system proven |
| 13 | Eras 1–3 Production Skin | Existing prototype fully skinned without gameplay regression |
| 14 | Visual, Mobile, and Accessibility QA | Production-skinned prototype passes device review |
| 15 | Building Network — Era 4 | Era 4 complete in established visual system |
| 16 | Neighborhood Microgrid — Era 5 | All pre-idle automation complete |
| G01 | Core Gameplay and Fun Validation | Eras 1–5 first 30–60 minutes earn explicit proceed/revise/stop decision |
| 17 | City Data Center and First Prestige — Era 6 | Base-v1 content capstone, idle transition, and first retraining loop proven |
| 18 | Era 6 Android and Retention Checkpoint | Base-v1 active-to-idle arc receives device/retention go/revise/stop evidence |
| 19 | Metro through Continent — Eras 7–10 | Preserved post-launch expansion-sized regional arc |
| 20 | Planet through Solar System — Eras 11–13 | Preserved post-launch expansion-sized day-scale arc |
| 21 | Galactic through Multiverse — Eras 14–16 | Preserved post-launch expansion-sized cosmic/endless arc |
| 22 | Full-Game Content and Balance Pass | Applicable release-version scope content-locked |
| 23 | Final Production Art, Animation, and Audio | All applicable release-scope presentation complete |
| 24 | Release-Candidate Stabilization | RC quality bar passed for the applicable release scope |
| 25 | Closed Testing and Store Preparation | External release evidence and store package complete |
| 26 | Production Release | Explicit publisher authorization required |

## Scheduling after the scope decision

The numbered contracts remain preserved at their existing paths and numbers. Their scheduling is now interpreted as follows:

1. Complete G01 and record an explicit proceed/revise/stop decision.
2. If separately authorized, Phase 17 implements the final base-v1 content era and first complete Prestige loop.
3. Phase 18 validates the Eras 1–6 active-to-idle product and supplies the deferred full Android/retention checkpoint.
4. Base-v1 content lock, final production, release-candidate, closed-test/store, and publication gates use the approved Eras 1–6 release scope. Existing Phase 22–26 contract wording is release-version scoped; it does not pull Eras 7–16 back into base v1.0.
5. Phases 19–21 remain intact as post-launch expansion-sized scope. They require a separately approved post-launch schedule and explicit authorization; they are not prerequisites for base-v1 release readiness.

This scheduling note supersedes the former assumption that Eras 7–16 had to be produced before the first production release. It does not silently authorize, execute, or edit any Phase 17–26 contract.

## Visual-production cadence

Visual work happens at three levels:

### Direction lock — Phase 11

Decide the rules: visual premise, WATT design, palette, typography, shape language, icon style, animation, environmental escalation, and comedy.

### System and prototype skin — Phases 12–14

Build reusable Godot theme/components, apply them to Eras 1–3, and verify the result on a phone.

### Continuous era production — Phases 15–17 and post-launch Phases 19–21

Every new era ships with its environment, WATT evolution, infrastructure presentation, icons, effects, and audio additions. No phase may claim completion with permanent gray-box presentation.

For base v1.0, this cadence ends with City Data Center/Era 6 in Phase 17. The same production rule remains attached to the preserved Eras 7–16 post-launch expansion contracts.

Phase 23 is a final consistency and quality pass, not the first time art is applied.

## Release policy

“Feature complete” is not “release ready.” Release requires separate evidence for:

- Complete approved content scope
- Production skin and audiovisual consistency
- Balance and save compatibility
- Accessibility and device coverage
- Defect stabilization
- Closed-test feedback
- Store disclosures and assets
- Signed, reproducible artifact
- Explicit publisher approval

For base v1.0, “complete approved content scope” means Eras 1–6 plus the City idle transition and first complete Model Retraining/Prestige loop. G01 must reach an explicit proceed decision before Era 6 work can be authorized.

## Phase advancement

Codex never advances phases automatically. Each phase requires evidence, updated living documents, a reviewed commit, and explicit user authorization for the next phase.
