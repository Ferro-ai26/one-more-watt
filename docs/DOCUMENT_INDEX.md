# Document Index and Ownership

## Permanent specifications

| Document | Owns | Update trigger |
| --- | --- | --- |
| `GAME_VISION.md` | Product identity, pillars, scope, era ladder | Major product decision |
| `GAMEPLAY_SYSTEMS.md` | Mechanic behavior and invariants | Accepted mechanic change |
| `PROGRESSION_AND_BALANCE.md` | Formulas, targets, starting values | Balance decision or playtest result |
| `WATT_CHARACTER_BIBLE.md` | Character voice and comedy | Narrative direction change |
| `CONTENT_DATABASE.md` | Schemas, IDs, prototype catalog | Schema/content policy change |
| `UI_UX_SPEC.md` | Screens, flows, mobile interaction | UX decision or accessibility finding |
| `TECHNICAL_ARCHITECTURE.md` | Code boundaries and test strategy | Architecture decision |
| `SAVE_AND_OFFLINE_SPEC.md` | Persistence and offline rules | Save/lifecycle decision |
| `ART_AND_AUDIO_DIRECTION.md` | Visual/audio language and assets | Creative direction decision |
| `ANDROID_RELEASE_SPEC.md` | Android/export/release requirements | Toolchain or publishing decision |
| `ROADMAP_V2.md` | Accepted post-prototype phase sequence and release policy | Roadmap or release-gate decision |
| `THEME_AND_ART_DIRECTION_SPEC.md` | Visual premise, palette, WATT design, typography, motion, and approval rules | Accepted creative-direction change |
| `SKIN_ARCHITECTURE_SPEC.md` | Reusable Godot theme, component, token, and skin boundaries | Skin-system architecture decision |
| `ASSET_PIPELINE_AND_INVENTORY.md` | Asset ownership, states, formats, naming, and production tracking | Asset-pipeline or inventory change |
| `VISUAL_QA_CHECKLIST.md` | Visual, mobile, skin, and accessibility verification | QA-scope or device-policy change |
| `RELEASE_READINESS_DEFINITION.md` | Evidence required before production release | Release policy or publisher decision |

## Living control documents

| Document | Update frequency |
| --- | --- |
| `ACTIVE_PHASE.md` | Only when the user authorizes a phase change |
| `CURRENT_HANDOFF.md` | End of every work session |
| `PROGRESS.md` | Every material completed outcome |
| `DECISION_LOG.md` | Every material design/technical choice |
| `KNOWN_ISSUES.md` | When a defect is found, changed, or verified fixed |
| `PLAYTEST_CHECKLIST.md` | Every formal player-facing verification |
| `PROJECT_SETUP_CHECKLIST.md` | Toolchain/repository environment change |
| `ANDROID_BUILD_RECORD.md` | Every recorded Android artifact and static inspection |
| `ANDROID_DEVICE_TEST.md` | Physical Android install/lifecycle/performance pass |
| `CODEX_RUNBOOK.md` | Operator workflow change |
| `ART_DIRECTION_WORKBOOK.md` | During Phase 11 exploration and whenever an approved visual direction changes |

## Phase contracts

- Phases 00–09: completed development sequence and evidence for the Android vertical slice
- Phase 10: targeted prototype stabilization; Complete — accepted device-verification limitation transferred to Phase 14
- Phase 11: theme and art direction; In Progress — no selected direction; major visual/narrative pivot pending under DEC-026
- Phases 12–14: reusable skin architecture, production skinning, and visual/mobile QA
- Phases 15–21: era-integrated game and art production through the Multiverse
- Phases 22–26: content lock, final audiovisual production, stabilization, closed testing/store preparation, and separately authorized production release
- `phases/legacy_v1/`: superseded, unstarted v1 Phase 10–16 contracts retained for history only

## Authority reminder

If two documents conflict, use the hierarchy in the root `README.md`. Fix the contradiction in documentation before building behavior that depends on it.
