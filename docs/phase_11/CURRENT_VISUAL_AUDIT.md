# Phase 11 Current Visual Audit

Date: 2026-07-20

Scope: Phase 10 functional prototype at commit `4c77a30`, before any Phase 11 runtime change.

## Evidence reviewed

- First-run Grid screen captured from Godot at 360 × 640 logical pixels with fresh user data.
- Runtime UI construction in `scripts/ui/main_ui.gd`, `scripts/ui/main_view_model.gd`, `scripts/ui/vital_card.gd`, and `scripts/ui/shop_item_card.gd`.
- Scene and theme resources in `scenes/app/Main.tscn`, `scenes/components/`, and `assets/themes/base_theme.tres`.
- Current app icon and all populated visual-asset directories.
- Responsive coverage at 320 × 568, 360 × 640, 393 × 873, 480 × 800, and 720 × 1280.
- Complete clean baseline run of `./tools/validate.sh`.

Baseline capture: [`concepts/current_prototype_360x640.png`](concepts/current_prototype_360x640.png)

## Reusable strengths

- The screen hierarchy already matches the mobile specification: status, WATT/request focus, three grid vitals, allocation, contextual content, and thumb-reachable navigation.
- WATT remains present on Grid and in the compact header on Build, Upgrades, and Reports.
- Generation, Transmission, and Reserve are equal peers, and the limiting state has text reinforcement instead of relying on color.
- Controls retain 48-pixel minimum targets, text scales functionally, reduced motion preserves semantic feedback, and the layout is proven down to 320 × 568.
- Dynamic text, values, and state remain code-native. No baked UI image blocks localization or live data.
- The compact card/modular structure is a strong substrate for a later semantic theme system.
- The current app icon has a crisp power motif and readable silhouette, although it does not yet establish WATT as the character.

## Visual problems

### Character and world

- WATT is a three-character text glyph rather than a designed protagonist. It has no durable silhouette, face system, model sheet, or animation rig.
- Environment progression is communicated by badges and prose, not by visible desk, room, or house transformation.
- Purchases update numbers and summaries but do not yet create the promised visual accumulation gag.
- The app icon reads as a generic electricity utility mark rather than a character-driven comedy game.

### UI language

- The nearly uniform dark-blue panel stack resembles a competent developer dashboard. It does not yet feel domestic, improvised, tactile, or comically overbuilt.
- Colors are repeated inline across scripts and scenes rather than expressed as exact semantic roles. Generation, Transmission, and Reserve do not have a complete, persistent visual grammar.
- Similar one-pixel outlines, dark fills, and corner radii flatten hierarchy. Focal panel, shop cards, modals, and ordinary surfaces feel closely related in depth and importance.
- Small all-caps telemetry is dense at 360 × 640. Dialogue, request metadata, forecast, tutorial, and recommendation compete instead of forming a relaxed reading sequence.
- Icons are mostly absent. Category, status, navigation, affordability, lock, and milestone states rely heavily on labels.

### Motion and finish

- Current motion is primarily a short color modulation on WATT and the focal panel. It proves semantic hooks but not a character or environmental animation language.
- There is no visible power-flow path, contained Reserve motion, construction settle, or scale-reveal transition art.
- No production illustration, texture, shader, ambience, or music asset is present. The synthesized semantic cues are functional placeholders for later direction-aligned sound work.

## Production constraints

- Android portrait is primary; every routine state must survive 320 logical pixels of width and larger text.
- WATT, dialogue, bottleneck, progress, and one useful action must win the first glance.
- Category meaning must be reinforced by icon, label, pattern, or motion. Palette alone is insufficient.
- Generated raster UI and baked text are unsuitable. Reusable UI geometry and icons should remain vector or Godot-native.
- Environments must scale across 16 eras without requiring unique full-screen high-resolution art for every minor purchase.
- Early domestic warmth must transition to cosmic scale without replacing WATT or abandoning recognizable earlier equipment.
- Phase 11 concepts are direction evidence only. They must not become an accidental full reskin or a substitute for the Phase 12 skin architecture.

## Audit conclusion

Preserve the existing information architecture, touch sizing, semantic state hooks, and responsive behavior. Replace the gray-box presentation with a character-first visual system that gives WATT a stable silhouette, makes infrastructure accumulation visible, reduces telemetry competition, and establishes repeatable category and motion languages.
