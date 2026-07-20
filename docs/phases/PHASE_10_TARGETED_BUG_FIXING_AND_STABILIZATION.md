# Phase 10 — Targeted Bug Fixing and Prototype Stabilization

## Objective

Resolve or explicitly disposition the concrete defects discovered during Phase 09, complete high-value skipped checks where practical, and establish a stable gameplay baseline before visual redesign.

## Player-facing result

The Eras 1–3 prototype remains functionally unchanged but behaves reliably and is comfortably usable on the tested Android phone.

## Required reading

`CURRENT_HANDOFF.md`, `KNOWN_ISSUES.md`, `ANDROID_DEVICE_TEST.md`, `PLAYTEST_CHECKLIST.md`, `UI_UX_SPEC.md`, `SAVE_AND_OFFLINE_SPEC.md`, and `ROADMAP_V2.md`.

## Included

- Reproduce every sufficiently described open prototype defect
- Ask for missing reproduction details instead of guessing
- Diagnose ISSUE-004 as a UI-scale/layout problem
- Compare viewport, stretch, content scale, anchors, font sizes, theme overrides, and actual device dimensions
- Fix confirmed blocker, critical, major, and approved minor defects
- Run regression after each related fix group
- Rebuild APK and conduct targeted manual device verification
- Record unverified items honestly

## Excluded

- Broad art-direction changes
- Full reskinning
- Era 4 content
- New mechanics
- Unrelated refactors
- Blindly setting a 720p resolution without diagnosing the cause

## ISSUE-004 handling

The authoritative symptom is: **UI/presentation appeared too small on the tested Moto phone.** “Use 720p” is a tester suggestion, not yet the diagnosed fix.

The investigation must record:

- Actual Moto model and screenshot/resolution when the tester can provide them
- Project viewport and stretch settings
- Effective logical viewport on device
- Font and control minimum sizes
- Whether the problem is global scale, local component sizing, density, or excessive information density
- Comparison at the four existing portrait layouts plus a 720 × 1280 reference

## Automated tests

- Full preexisting suite before edits
- Targeted regression for each repaired bug
- Four established portrait layouts plus 720 × 1280
- Larger-text and reduced-motion layout checks
- Content/save/reachability regression
- Android configuration and APK inspection

## Manual verification

- Install revised APK on the test phone
- Recheck onboarding, Build, and Upgrades
- Confirm comfortable size, not merely technical readability
- Exercise each fixed bug from its reproduction steps
- Where practical, test background/resume, force-close, Android Back, brownout, and sound/haptics

## Acceptance criteria

- [ ] Every specified bug is reproduced or marked Needs Information
- [ ] ISSUE-004 has a root-cause finding and targeted fix or explicit disposition
- [ ] No blocker/critical defect remains
- [ ] Fixed issues include real verification evidence
- [ ] Core gameplay/balance/save tests remain passing
- [ ] Revised APK is built and statically inspected
- [ ] Targeted phone retest is recorded
- [ ] No visual direction was invented prematurely
- [ ] Living documents updated

## Stop condition

Stop after the functional prototype is stable. Do not begin theme exploration.
