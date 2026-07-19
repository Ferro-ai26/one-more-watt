# Codex Build Runbook

## Purpose

This is the human operator's guide for using the document pack with Codex on the VPS. Codex's binding instructions remain in `AGENTS.md`.

## One-time setup

1. Extract the pack into the game repository root so `AGENTS.md` is beside `docs/`.
2. Commit the documents before implementation begins.
3. Complete the known values in `docs/PROJECT_SETUP_CHECKLIST.md`.
4. Confirm `docs/ACTIVE_PHASE.md` points to Phase 00.
5. Start Codex from the repository root, preferably on a development branch.

## Recommended first prompt

```text
Read AGENTS.md, docs/ACTIVE_PHASE.md, the active phase contract, and
docs/CURRENT_HANDOFF.md. Inspect the repository before editing. Execute only
the active phase. Run every available required test, update the living project
documents, and stop at the phase stop condition. Do not advance ACTIVE_PHASE.md.
```

## Reviewing a completed phase

Ask Codex for evidence rather than a general assurance:

```text
Review the active phase without changing the project. Check every acceptance
criterion against the repository, test output, and manual evidence. Report each
criterion as PASS, FAIL, or NOT VERIFIED. Do not advance the phase.
```

Manually review:

- Git diff and status
- Test commands and real output
- `CURRENT_HANDOFF.md`
- `KNOWN_ISSUES.md`
- The phase's manual verification evidence
- Whether the player-facing result actually works

## Advancing a phase

Advance only after review. Edit `ACTIVE_PHASE.md` to the next phase, set its status, and commit the completed phase documents/code. Then begin a new Codex session using the standard prompt.

Do not tell Codex to “continue until the whole game is done.” The phase gates exist to limit compounding design errors and false completion claims.

## Daily autonomous cadence

If using scheduled sessions:

- Planning session: inspect the active phase and write a bounded task plan; no phase advancement.
- Build session: implement the highest-priority incomplete acceptance criteria.
- Verification session: run tests, inspect changes, repair in-scope defects, and update the handoff.

Every scheduled session reads the repository documents fresh. Chat history is not project state.

## When Codex is blocked

Codex should exhaust safe in-scope diagnostics, document the blocker, and stop. Common legitimate blockers include:

- Missing publisher-owned package identifier
- Android SDK/tool incompatible with VPS architecture
- Physical-device test required
- Design choice with materially different player outcomes
- Missing licensed production asset

Do not allow a workaround to be reported as full verification. For example, a generated APK is not a physical-device pass.

## Changing the design

1. Add a Proposed entry to `DECISION_LOG.md`.
2. Review the player and technical consequences.
3. Mark it Accepted or Rejected.
4. Update every affected permanent specification.
5. Update active or future phase acceptance criteria.
6. Commit the document change separately or clearly within the implementation commit.

## Backups and permanence

Keep the extracted pack in Git. The ZIP is a transfer artifact; the repository copy is the operational source. Commits preserve history and make accidental Codex edits reviewable and reversible.

