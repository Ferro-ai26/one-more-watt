# Phase 04 — Infrastructure and Upgrades

## Objective

Implement purchasing, cost scaling, milestones, unlocks, upgrades, and early automation using the data architecture.

## Player-facing result

The player can spend Stored Energy on meaningful improvements, see the grid respond immediately, and understand why an item helps.

## Required reading

`GAMEPLAY_SYSTEMS.md`, `PROGRESSION_AND_BALANCE.md`, `CONTENT_DATABASE.md`, and `UI_UX_SPEC.md`.

## Included

- Infrastructure ownership and purchasing commands
- Buy-one and exact bulk-cost calculations
- One-time and leveled upgrades
- Effect stacking rules
- Count milestones
- Content unlock evaluation
- Affordability and predicted-effect data for UI
- Prototype automation: Reserve threshold and safe throttling
- Debug/simple shop presentation

## Excluded

Production art, final responsive shop, prestige purchases, Eras 4+, monetized boosts, and automated spending unless separately approved.

## Implementation requirements

- Purchase commands are atomic.
- Cost calculations use documented rounding.
- UI preview calls the same calculators used by purchase.
- Locked items explain unmet conditions.
- Effect operations are enumerated, not arbitrary expressions.
- Rebuilding derived state after load produces the same grid values.
- Early infrastructure supports later category multipliers without code replacement.

## Automated tests

- Single and bulk cost
- Insufficient funds makes no mutation
- Purchase subtracts correct currency and increments ownership
- Milestones apply at exact thresholds
- Multiplier group stacking
- Upgrade max level
- Unlock dependency evaluation
- Derived-grid rebuild equivalence
- Automation respects enabled state and threshold

## Manual verification

Purchase one item in each core category, cross a milestone, buy an upgrade, and confirm pre-purchase predictions match the resulting grid.

## Acceptance criteria

- [ ] All Eras 1–3 infrastructure definitions can be interpreted
- [ ] Purchase previews are truthful
- [ ] No balance constants are embedded in shop scenes
- [ ] Locked and unaffordable states are distinct
- [ ] Milestone event and effect occur once
- [ ] Automated tests and headless smoke pass
- [ ] Living documents updated

## Stop condition

Do not build the final main navigation or fill all content. Stop after the economy commands are reliable.

