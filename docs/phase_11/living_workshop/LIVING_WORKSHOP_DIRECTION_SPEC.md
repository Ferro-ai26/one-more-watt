# Living Animated Workshop Diorama — Direction Specification

Status: Superseded exploration under `DEC-026`; not selected or awaiting approval. Retained for possible technical reference only.

Historical authority: `DEC-025`, superseded by `DEC-026`.

## Superseded hierarchy study

1. **World first:** WATT and the physical grid occupy the primary view.
2. **Character second:** WATT's request, eyes, posture, cable behavior, and reactions explain why the world is changing.
3. **Numbers third:** routine values remain crisp but compact; detailed statistics live in drawers, contextual trays, and reports.

The main screen is a cutaway workshop scene with interface rails attached around it. It is not a dashboard with an illustration card.

## Exact portrait composition

Reference canvas: 720 × 1280, representing a 360 × 640 logical viewport at 2×.

| Region | Reference bounds | Portrait share | Rule |
| --- | --- | ---: | --- |
| Status rail | `y 0–140` | 10.94% | Era, Stored Energy, aggregate power, warnings, settings only. |
| Living diorama | `y 140–950` | 63.28% | Unbroken cutaway world; no enclosing UI card. |
| Context shelf | `y 950–1170` | 17.19% | One bottleneck/action summary attached to the scene; not three statistic cards. |
| Bottom navigation | `y 1170–1280` | 8.59% | Four compact 48 dp targets. |

The request plate overlaps the lower diorama between approximately `y 770–930` and is physically hung from WATT's desk rail. WATT's body occupies 20–30% of the diorama's intended focal mass and roughly 28–36% of its width. WATT cannot be moved into a portrait card.

Build and Upgrade use drawers from approximately `y 625–1170`: 42.6% of the full screen and about half of the usable content height. The upper scene and WATT remain visible. The drawer may list item rows because it is a secondary tool surface.

## Retained semantic tokens

The tested accessible token pairs remain unchanged:

| Role | Color | Required foreground/reinforcement |
| --- | --- | --- |
| UI graphite | `#252B2C` | `#FFF9EC` text; 13.70:1 |
| Light plate | `#F7F1E5` | `#202829` text; 13.36:1 |
| Secondary light text | `#566160` | on `#F7F1E5`; 5.70:1 |
| WATT cyan | `#24B8C7` | cyan belongs to WATT/active electricity; dark ink gives 6.27:1 |
| Generation | `#E5A91B` | plug/rotor shape and `GENERATION`; dark ink gives 7.17:1 |
| Transmission | `#5D4BB3` | cable/terminal shape and `TRANSMISSION`; light text gives 6.41:1 |
| Reserve | `#23745F` | battery/fill shape and `RESERVE`; light text gives 5.36:1 |
| Warning | `#A65315` | triangle, plain-language action; light text gives 5.17:1 |
| Critical | `#A93640` | broken-flow mark, `BROWNOUT`, recovery action; light text gives 6.09:1 |
| Disabled | `#686F6C` | lock plate and reason; light text gives 4.91:1 |

### Environmental palette

| Token | Value | Use |
| --- | --- | --- |
| `scene.shadow.deep` | `#171D1D` | cutaway void, deep equipment shadow |
| `scene.wall.warm` | `#806A52` | painted/plaster wall midtone |
| `scene.wall.light` | `#B69B73` | amber-lit plaster planes |
| `scene.wood` | `#6B4932` | dusty desk and shelves |
| `scene.wood.light` | `#A4774E` | worn front edges |
| `scene.steel` | `#4B5958` | WATT and equipment housings |
| `scene.steel.dark` | `#2D3737` | vents, brackets, unlit chassis |
| `scene.smoked_glass` | `#102829` | WATT face and meter glass |
| `scene.aged_plastic` | `#9A8C74` | real switch/battery parts only |
| `scene.amber_light` | `#D98B36` | lamp pools and active domestic light |
| `scene.cyan_light` | `#48D7DF` | bounded WATT spill and powered cable accents |

Environmental color never carries small essential text. Text sits on graphite or light plates using the tested pairs above.

## Typography

Retain Atkinson Hyperlegible Next for UI/body and Atkinson Hyperlegible Mono for numeric/status roles. Exact files, commits, SHA-256 hashes, OFL 1.1 records, 360-wide type scale, fallbacks, and later packaging requirements remain in the superseded specification and `../CONCEPT_ASSET_RECORD.md`; they are preserved without runtime integration.

Avoid abbreviations when a complete word fits. The status rail may use `W`, `SE`, time notation, and `GEN / TRANS / RES` only at 320 width; the 360 baseline spells out the active bottleneck in the attached request and contextual shelf.

## Painted diorama language

- Layered stylized 2D with near-orthographic cutaway perspective and shallow 10–12° top visibility.
- Four depth bands: room shell, fixed furniture, installed grid equipment/cables, WATT/interactive foreground.
- Painted edges use value variation and a restrained dry-brush mask; silhouettes remain cleaner than internal texture.
- Warm amber light establishes the room. WATT and live electricity add a bounded cyan counter-light; cyan never fills the whole scene.
- Deep charcoal negative spaces separate objects and make wires legible.
- Materials: painted steel, smoked glass, matte rubber, dusty wood, aged plastic where plausible, ceramic, paper/vinyl labels, aluminum fins, screws, clamps, vents, and service brackets.
- Wear: maximum three readable marks per hero object; no texture under UI copy; no generalized grime overlay.
- Dry comedy lives in a crooked `TEMPORARY` bracket that persists for eras, a lamp aimed at WATT rather than the desk, the battery bay labeled `OPTIMISTIC`, and hardware reacting with unjustified professionalism.

## WATT physical design

WATT is a salvaged desktop terminal mounted in a low steel service cradle, not a freestanding rounded mascot.

- Overall body: asymmetric 1.35:1 silhouette, smoked face inset, steel side cheeks, exposed rear vent, bolted lower cradle, one fixed foot and one improvised shim.
- Face window: 1.58:1; two cyan apertures remain the recognition anchor.
- Bolt-heart: a small physical cyan status meter below the face window, not a mouth or logo floating inside it.
- No permanent mouth. Pleased/completion uses eye arcs, chassis lift, cable release, and heart response.
- Cable tail: exits rear-left through a strain relief and follows authored scene paths. It coils, tightens, sags, or pulls gently to communicate state; it never behaves as a limb through freeform physics.
- Gestures: 2–4° chassis lean on its cradle, face tracking, cable-tension change, a small vent flap, and nearby lamp/fan reactions.
- Brownout: body drops 3–4 dp, eyes narrow and fall to 58% cyan, fan coasts, cable pulse breaks, red physical lamp illuminates. No rapid flicker.

## Environmental behavior

- Purchases claim named anchors such as `desk_left_wall`, `desk_rear_rail`, `floor_battery_bay`, `window_service`, and `room_right_rack`.
- Cable routes are authored Bézier paths with occupied/unoccupied states and direction markers. The player never places individual wires.
- Installation sequence: anchor highlight → object seats into brackets → cable traces from source to object → connector closes → status lamp and environmental response activate.
- Ownership milestones choose visual states: one unit, small cluster, consolidated bank, facility. Counts remain numeric; the scene does not render every unit.
- WATT looks toward the active anchor, leans toward the bottleneck path, and reacts when the new connection changes request service.

## Motion and parallax tokens

| Event | Normal execution | Reduced motion |
| --- | --- | --- |
| Idle parallax | room ±1 dp, furniture ±2 dp, cables ±3 dp, foreground ±4 dp over 6 s | Static depth bands |
| Eye tracking | 180 ms lead, 120 ms settle; max ±8 dp | Immediate eye pose |
| Cable idle | 2–3 dp slow sag/breath over 2.4 s | Static authored curve |
| Purchase anchor | 180 ms amber outline + label | Static highlighted anchor |
| Object installation | 320 ms, translate 12 dp, no overshoot | 140 ms opacity swap |
| Cable connection | 420 ms authored path trace + connector click | Complete path appears with `CONNECTED` |
| Activation | 260 ms status lamp + one bounded power pulse | Lamp and `ACTIVE` state swap |
| Bottleneck gesture | WATT leans 3°, eyes and nearby cable point for 500 ms | Static eyes + arrow/label |
| Brownout | 140 ms scene dim, fan coast 500 ms, cable break state; UI ≥92% | Immediate critical state; no dim tween |
| Completion | 420 ms chassis lift 3 dp, cable relax, two heart pulses | Bright eyes + `COMPLETE` label |
| Era pullback | 1200 ms across four depth bands, desk scale 1.0→0.42 | 300 ms crossfade between labeled scales |
| Drawer open | 220 ms vertical reveal; scene remains fixed | Immediate drawer state |

At most one cable trace, one WATT reaction, and one local machine response run concurrently. No bloom, camera shake, scanlines, particle fog, rapid flashing, or continuous high-energy neon.

## Main-screen information policy

- Rail: `COLD BOOT`, Stored Energy, total delivered power, settings, and at most one active warning.
- Diorama: physical category evidence via colored cable sleeves/endpoints, motion, WATT state, and installed objects.
- Attached request: WATT line, full request name, progress, remaining time, and plain-language bottleneck. It is the primary text surface.
- Context shelf: one recommended action plus compact Generation/Transmission/Reserve values on a single line. Detailed trends, forecasts, and ownership open contextually.
- Build/Upgrade drawers: costs, owned counts, predicted change, lock reason, and milestones.
- Reports: cards permitted because they are secondary and comparative.

## Explicit rejection boundary

No full-screen equipment-card gameplay, flat beige infographic scenes, dashboard-first Main Grid, static WATT portrait cards, sterile engineering dashboards, dense abbreviations, generic minimalist iconography, neon sci-fi fields, toy-like mascot proportions, freeform cable physics, or one-object-per-unit clutter.

## Approval boundary

These rules are no longer an approval candidate. A substantial visual and narrative pivot is pending. They are not runtime tokens, imported assets, or Phase 12 authorization.
