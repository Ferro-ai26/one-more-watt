# Phase 05 — Main UI and Feedback

## Objective

Build the responsive portrait interface that makes WATT, the active request, grid bottlenecks, allocation, purchasing, upgrades, and reports readable on a phone.

## Player-facing result

The prototype systems can be played through the intended main interface without debug controls.

## Required reading

`UI_UX_SPEC.md`, `ART_AND_AUDIO_DIRECTION.md`, `WATT_CHARACTER_BIBLE.md`, and `GAMEPLAY_SYSTEMS.md`.

## Included

- Responsive main-screen hierarchy
- WATT/request focal panel
- Generation, Transmission, and Reserve vital cards
- Allocation segmented control
- Grid, Build, Upgrades, and Reports navigation
- Request authorization screen
- Performance report screen
- Reusable infrastructure and upgrade cards
- Number formatting and unit promotion
- Placeholder environmental visualization
- Accessibility settings required by the UI spec
- Essential sound and haptic hooks with safe fallbacks

## Excluded

Final art, final music, full content population, offline report logic, production store assets, and landscape-specific design.

## Implementation requirements

- UI observes state and issues commands; it does not own economy rules.
- Limiting state uses icon/text plus color.
- WATT remains visible during routine play.
- Touch targets meet minimum size.
- Layout handles smallest and tallest test sizes.
- Reduced motion disables nonessential large animation.
- Number notation is centralized.
- Modals preserve clear back-navigation order.

## Automated tests

- Number formatting at unit boundaries
- View-model predictions match calculators
- Navigation state
- Modal/back-stack behavior where testable
- Accessibility setting persistence in runtime state
- Scene instantiation and missing-node smoke tests

## Manual verification

At three portrait resolutions, play a sample request from announcement through report, buy infrastructure, change allocation, trigger a brownout, and inspect every specified UI state.

## Acceptance criteria

- [ ] Core loop requires no debug panel
- [ ] Bottleneck is identifiable at a glance
- [ ] Purchase effect is visible before buying
- [ ] WATT and request remain the visual focus
- [ ] Small-screen text and controls are usable
- [ ] Reduced-motion and text-size options work
- [ ] No clipping, overlap, or inaccessible modal state
- [ ] Living documents updated

## Stop condition

Do not begin save/offline work or polish final art. Stop after the complete online loop is usable through production-structured UI.

