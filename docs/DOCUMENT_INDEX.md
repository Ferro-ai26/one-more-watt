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

## Phase contracts

- Phases 00–09: approved development sequence for the Android vertical slice
- Phases 10–12: expansion from Building Network through City and first prestige
- Phases 13–15: grouped long-game production contracts requiring approved era appendices
- Phase 16: release preparation, still requiring explicit authorization to publish

## Authority reminder

If two documents conflict, use the hierarchy in the root `README.md`. Fix the contradiction in documentation before building behavior that depends on it.
