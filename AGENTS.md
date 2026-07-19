# Codex Operating Contract — ONE MORE WATT

These instructions apply to every autonomous or interactive Codex session in this repository.

## Required reading order

Before editing anything:

1. Read `docs/ACTIVE_PHASE.md`.
2. Read the referenced phase contract in full.
3. Read `docs/CURRENT_HANDOFF.md`.
4. Read the permanent specifications named by the phase.
5. Inspect repository status and existing tests.

Do not assume a previous chat contains the current project state.

## Scope control

- Work only on the active phase.
- Do not begin the next phase, even if time remains.
- Respect every Included, Excluded, and Stop Condition section.
- Do not redesign a documented mechanic silently.
- If a necessary decision is missing, record it as a proposed entry in `docs/DECISION_LOG.md` and choose the smallest reversible implementation.
- Stop and report when a missing decision would materially alter the product.
- Preserve user changes and unrelated working systems.

## Implementation rules

- Target the Godot version recorded in `docs/PROJECT_SETUP_CHECKLIST.md`.
- Keep simulation logic independent of scenes and presentation.
- Store balance and authored content in data files or typed resources, not UI scripts.
- Use stable string identifiers in saves and content references.
- Avoid hardcoded node paths across unrelated scenes.
- Prefer signals or explicit service interfaces for cross-system communication.
- Use deterministic simulation. Random outcomes must use a controlled seed when they affect tests or offline progress.
- Do not add live generative AI, remote accounts, analytics, advertisements, purchases, or network services unless a later approved specification explicitly requires them.
- Do not add punitive progress loss.
- Do not add detailed wire-by-wire grid placement.
- Keep Android touch use and small screens in mind from the first UI phase.

## Quality requirements

For every change:

- Add or update tests proportional to the risk.
- Run existing validation and smoke tests.
- Treat parser errors, missing resources, invalid data references, and save failures as blockers.
- Do not suppress errors merely to obtain a passing command.
- Keep warnings at zero when reasonably controllable.
- Confirm the project launches headlessly before reporting completion.
- For UI phases, complete the specified manual playtest in addition to headless checks.

## Documentation requirements

Before ending a session, update:

- `docs/CURRENT_HANDOFF.md`
- `docs/PROGRESS.md`
- `docs/KNOWN_ISSUES.md`
- `docs/PLAYTEST_CHECKLIST.md` when player-facing behavior changed
- `docs/DECISION_LOG.md` when a design or technical decision was made

The handoff must state:

- Exact result achieved
- Files changed
- Commands/tests run and their results
- Remaining acceptance criteria
- Known blockers
- Recommended next action inside the current phase

## Git policy

- Inspect status before and after work.
- Do not discard unrecognized changes.
- Keep commits limited to the active phase.
- Use descriptive commit messages such as `Phase 03: implement request lifecycle`.
- Do not rewrite shared history or force-push.
- Do not create or publish a release unless explicitly directed.

## Phase completion procedure

1. Verify every acceptance criterion with evidence.
2. Run the phase's automated test list.
3. Execute and record the manual playtest.
4. Update living documents.
5. Commit the completed phase when repository policy allows it.
6. Stop. Do not modify `ACTIVE_PHASE.md` unless the user explicitly authorizes advancement.

## Reporting style

Use concise reports with these labels:

- Phase
- Changed
- Tests
- Manual verification
- Known issues
- Next action

Never claim a device test, export, visual inspection, or playtest occurred unless it actually occurred.

