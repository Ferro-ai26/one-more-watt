# Skin Architecture and Godot Design System

## Goal

Separate presentation from gameplay so the complete game can share a coherent visual system and future eras can be added without restyling every scene independently.

## Principles

- Gameplay state and balance never depend on a skin.
- Components consume semantic tokens rather than isolated literal values.
- Era variation is layered on the base theme rather than duplicating entire screens.
- Runtime skin changes cannot corrupt saves or request state.
- UI remains functional with development fallback assets.
- Android memory and draw-call costs are measured.

## Suggested structure

```text
assets/
  art/watt/
  art/environments/era_01/
  art/environments/era_02/
  art/environments/era_03/
  audio/ui/
  audio/watt/
  fonts/
  icons/actions/
  icons/grid/
  icons/infrastructure/
ui/
  themes/one_more_watt_theme.tres
  tokens/color_tokens.gd
  tokens/type_tokens.gd
  tokens/spacing_tokens.gd
  tokens/motion_tokens.gd
  components/WattPanel.tscn
  components/GridMetricCard.tscn
  components/InfrastructureCard.tscn
  components/RequestCard.tscn
  components/SegmentedControl.tscn
  components/ReportPanel.tscn
  components/StandardModal.tscn
  skins/base/
  skins/eras/era_01/
  skins/eras/era_02/
  skins/eras/era_03/
```

Adapt paths to the real repository rather than creating duplicates of established directories.

## Semantic tokens

At minimum:

- Surface/background/elevation colors
- Primary/secondary/muted text
- WATT, Generation, Transmission, and Reserve accents
- Success, warning, critical, locked, focus
- Display/heading/body/numeric/caption type roles
- Spacing scale
- Corner and border scale
- Standard icon sizes
- Touch-target minimums
- Motion duration/easing categories
- Reduced-motion substitutions

Scenes must not copy raw color or font-size literals when a semantic token exists.

## Component states

Every reusable component documents and demonstrates:

- Default
- Focused/selected
- Pressed
- Disabled
- Locked
- Affordable/unaffordable where applicable
- Warning/limiting
- Loading/progress
- Reduced motion
- Larger text

## Environment skin contract

An era environment supplies:

- Background layers
- WATT presentation variant
- Infrastructure display slots or aggregation rules
- Power-flow paths
- Ambient animation set
- Lighting/overlay treatment
- Transition-in/out hooks
- Memory-cost metadata

It does not own progression rules or infrastructure counts.

## Asset fallback

Missing noncritical production art uses an explicit development fallback with a visible debug warning. Release builds fail the asset-completeness audit for missing release-scope assets.

## Skin regression tests

- All required component states instantiate
- Theme resources load with no missing dependencies
- Semantic token audit detects unauthorized literals in scoped UI files
- All supported aspect ratios remain unclipped
- Text-size and reduced-motion settings work
- Era skin swap does not change gameplay state
- Skin assets stay within memory budget
- Screenshot baselines cover representative screens and states

## Sol skinning workflow

For each screen:

1. Inventory current nodes, behavior, and tests.
2. Map controls to reusable components.
3. Apply semantic tokens.
4. Integrate approved assets.
5. Preserve signals, accessibility, and automation hooks.
6. Render representative states.
7. Compare with approved direction.
8. Run functional and visual regression.
9. Record remaining placeholder assets.

Sol must not rewrite proven gameplay logic merely to simplify skinning.

## Phase 12 implementation authority

The reusable implementation is recorded in `docs/phase_12/SKIN_SYSTEM_IMPLEMENTATION.md`. `scripts/ui/theme/skin_tokens.gd` is the authoritative runtime token source; `assets/themes/one_more_watt_theme.tres` is the live base Theme; and `assets/asset_inventory.json` is the machine-validated asset inventory. The base/Desk/Room environment contract is proven without integrating generated concept imagery. Remaining production migration is explicitly routed in `docs/phase_12/UI_OVERRIDE_AND_MIGRATION_INVENTORY.md` rather than silently treated as complete.
