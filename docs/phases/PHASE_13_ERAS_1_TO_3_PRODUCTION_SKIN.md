# Phase 13 — Eras 1–3 Production Skin

## Objective

Apply the approved design system and production-quality visual/audio treatment to the complete existing Eras 1–3 prototype.

## Player-facing result

The prototype looks and feels like a coherent commercial game rather than a development build, while retaining the proven gameplay and progression.

## Required reading

All visual specifications, the approved workbook, asset inventory, `WATT_CHARACTER_BIBLE.md`, `UI_UX_SPEC.md`, and the complete Phase 09/10 regression evidence.

## Included

- Main Grid, Build, Upgrades, Reports, settings, confirmations, offline return, and diagnostics presentation
- WATT production presentation and expressions for Eras 1–3
- Desk, Bedroom, and Home Server Closet environments
- Visual infrastructure appearance/upgrade states
- Power-flow, Reserve, brownout, purchase, unlock, completion, and era-transition effects
- Production-ready prototype icons
- Essential UI/WATT sound set and haptic tuning
- Accessibility variants
- Asset provenance and licensing records
- Screenshot evidence for required states

## Excluded

- Era 4
- New gameplay systems
- Final full-game art pass
- Store screenshots/listing
- Cosmetic systems unrelated to the prototype

## Implementation sequence

Skin one screen family at a time. For each family: preserve behavior, apply components/tokens, integrate approved assets, render key states, run regression, inspect phone output, and update the asset inventory.

## Automated tests

- Full functional suite after each screen family
- Theme/component and asset completeness
- Layout matrix including 720 × 1280
- Large-number and larger-text stress
- Reduced motion
- Screenshot baselines
- Performance, memory, and APK-size comparison

## Manual verification

- Complete a clean-save Eras 1–3 playthrough
- Review every required visual state on phone
- Verify WATT remains focal and dialogue remains readable
- Verify purchase results visibly affect the environment
- Check sound repetition, audio focus, haptics, heat, and battery qualitatively

## Acceptance criteria

- [ ] All release-intended prototype screens use the approved design system
- [ ] Eras 1–3 have distinct coherent environments
- [ ] WATT evolves while remaining recognizable
- [ ] No unintended placeholder remains in scoped content
- [ ] All important system states have clear visual feedback
- [ ] Accessibility variants work
- [ ] Functional progression and saves are unchanged except approved fixes
- [ ] Asset rights and provenance are recorded
- [ ] Phone screenshots and playtest evidence exist

## Stop condition

Do not add Era 4. Stop after the complete three-era production skin is integrated.
