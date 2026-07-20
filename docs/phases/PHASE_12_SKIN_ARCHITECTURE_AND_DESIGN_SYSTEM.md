# Phase 12 — Skin Architecture and Design System

## Objective

Translate the approved visual direction into reusable Godot tokens, theme resources, components, environment contracts, and regression tooling.

## Player-facing result

A limited vertical sample demonstrates the approved skin functioning in the real game, including important states and accessibility settings.

## Required reading

`SKIN_ARCHITECTURE_SPEC.md`, approved `ART_DIRECTION_WORKBOOK.md`, `THEME_AND_ART_DIRECTION_SPEC.md`, `UI_UX_SPEC.md`, and `TECHNICAL_ARCHITECTURE.md`.

## Included

- Inventory current UI scenes and style overrides
- Define semantic token implementation
- Create base Godot Theme and font resources
- Build/refactor reusable components
- Create an era-skin/environment interface
- Integrate approved WATT base presentation
- Skin one representative Main Grid path and one Build card set
- Implement all component states
- Add screenshot/scene regression hooks
- Add asset inventory and missing-asset validation
- Measure initial memory, APK-size, and rendering impact

## Excluded

- Skinning every screen
- Full Eras 1–3 environment production
- Era 4 content
- Gameplay redesign
- One-off styles bypassing the token system

## Preservation rules

- Existing signals, commands, automation identifiers, and accessibility hooks remain functional.
- Skin changes do not alter save schemas or balance.
- Refactoring a component requires behavior parity tests before removing the previous implementation.
- Fallback assets keep development builds usable.

## Automated tests

- Theme and resource load
- Required semantic tokens exist
- Reusable component states instantiate
- Unauthorized literal-style audit in migrated UI scope
- Layout at supported aspect ratios and text sizes
- Reduced-motion state
- Era skin swap preserves gameplay state
- Main functional suite
- Performance and memory comparison

## Acceptance criteria

- [x] Approved tokens exist in one authoritative system
- [x] Representative live sample matches the approved direction
- [x] Components expose all required states
- [x] No gameplay/save regression
- [x] Environment-skin contract is proven with at least two early-era variants or a base plus variant
- [x] Asset inventory validation works
- [x] Performance cost is measured and acceptable
- [x] Remaining screens/assets have a migration inventory

## Stop condition

Stop after the reusable system is proven. Do not skin all Eras 1–3 screens.

Closure evidence is recorded in `docs/phase_12/`. The complete repository suite, graphical baseline review, dirty-tree measurement APK, asset audit, and headless launch passed on 2026-07-20. Phase 13 was not started.
