# Soft Circuit Workshop — Revised Direction Specification

Status: Superseded by `DEC-025`. Retained for reusable token, typography, contrast, and material evidence only; its dashboard composition and environmental presentation are rejected.

Selection authority: `DEC-024`

## Direction statement

ONE MORE WATT looks like a believable domestic electrical installation that an attentive person has kept extending long after it should have become a professional facility. Painted steel, aging computer hardware, rubber cable, ceramic, glass, paper service labels, ventilation, and careful improvised brackets make the world tactile. WATT's expressive cyan monitor face is always the visual reason the equipment exists.

The comedy comes from competent workmanship applied to absurd scale. The style is warm and inviting, but not childish, toy-like, plastic, chunky, or pristine.

### Adjectives

- Warm
- Character-first
- Workmanlike
- Accumulative
- Readable

### Anti-adjectives

- Toy-like
- Sterile
- Grimy
- Glossy-plastic
- Noisy
- Blueprint-like
- Neon-saturated

## Visual construction

- Dimensionality: layered 2.5D illustration made from flat editable shapes, shallow occlusion, and two shadow levels. No photoreal rendering.
- Perspective: near-orthographic front/three-quarter views. Environment props share one shallow 12° downward viewing angle; UI remains flat.
- Primary edge: 2 logical pixels at a 720 × 1280 concept reference, equivalent to 1 dp at the 360-wide target. WATT's outer silhouette and selected/critical states may use 4 logical pixels.
- Corners: small practical radii, not bubble forms. Pills are restricted to short status chips and progress tracks.
- Materials: satin painted steel, powder-coated brackets, aged ABS only where real monitors/switches use it, matte rubber cable, glass meters, ceramic insulators, paper/vinyl labels, aluminum cooling fins, and domestic wood/plaster.
- Wear: at most three restrained marks per hero object; 4–8% opacity edge chips, pencil notes, screw wear, or label curling. No dirt overlays behind text and no generalized grunge.
- Lighting: one warm upper-left domestic key plus WATT's local cyan screen light. UI surfaces do not receive environmental lighting changes.
- Shadow: short and physical. No floating-card bloom, colored neon shadow, or large diffuse glow.
- Humor: specific labels, adapters, overfilled cable trays, repurposed fans, careful brackets, and accumulated earlier equipment. Avoid meme labels and random clutter.

## Exact semantic color tokens

Values are sRGB hex. `On` specifies the required text/icon foreground. Important states also require the listed non-color reinforcement.

| Token | Value | On | Use and reinforcement |
| --- | --- | --- | --- |
| `color.canvas.room` | `#D9CCB8` | `#202829` | Warm wall/room field; never carries small secondary text without a surface. |
| `color.canvas.shadow` | `#B9AC99` | `#202829` | Recessed room depth and inactive environmental planes. |
| `color.surface.base` | `#F7F1E5` | `#202829` | Default UI card and dialogue surface. |
| `color.surface.elevated` | `#FFF9EC` | `#202829` | Modals, primary action context, performance report. |
| `color.surface.recessed` | `#DCD3C3` | `#202829` | Tracks, disabled wells, secondary groupings. |
| `color.shell.graphite` | `#252B2C` | `#FFF9EC` | Top/bottom rails, equipment chassis, high-emphasis button. |
| `color.border.strong` | `#333B3B` | — | Primary object outline and panel separator. |
| `color.border.soft` | `#8B8D84` | — | Dividers and inactive borders; never sole state signal. |
| `color.text.primary` | `#202829` | — | Primary light-surface text. |
| `color.text.secondary` | `#566160` | — | Secondary light-surface text; 5.70:1 on base surface. |
| `color.text.on_dark` | `#FFF9EC` | — | Primary dark-surface text. |
| `color.text.on_dark_secondary` | `#C9D1CC` | — | Secondary dark-surface text. |
| `color.watt.cyan` | `#24B8C7` | `#202829` | WATT eyes, active core, focus accent, WATT-owned power only. |
| `color.watt.cyan_dark` | `#006E79` | `#FFF9EC` | Cyan text/borders when `watt.cyan` lacks text contrast on light surfaces. |
| `color.generation` | `#E5A91B` | `#202829` | Generation cable sleeve/icon/card stripe plus generator/coil symbol. |
| `color.transmission` | `#5D4BB3` | `#FFF9EC` | Transmission cable sleeve/icon/card stripe plus linked-terminal symbol. |
| `color.reserve` | `#23745F` | `#FFF9EC` | Reserve vessel/icon/card stripe plus fill-level symbol. |
| `color.positive` | `#2B764C` | `#FFF9EC` | Affordable/completed state plus check symbol and label. |
| `color.warning` | `#A65315` | `#FFF9EC` | Warning state plus triangle and actionable copy. |
| `color.critical` | `#A93640` | `#FFF9EC` | Brownout/critical state plus broken-wave symbol and `BROWNOUT` text. |
| `color.disabled` | `#686F6C` | `#FFF9EC` | Locked state plus padlock and reason. |
| `color.focus` | `#007C8A` | `#FFF9EC` | Inner keyboard/controller focus ring; paired with graphite outer ring. |
| `color.selection` | `#24B8C7` | `#202829` | Selected segmented control plus check/notch. |

### Verified core contrast pairs

- Primary ink on base surface: 13.36:1.
- Secondary ink on base surface: 5.70:1.
- Light text on graphite: 13.70:1.
- Primary ink on WATT cyan: 6.27:1.
- Primary ink on Generation: 7.17:1.
- Light text on Transmission: 6.41:1.
- Light text on Reserve: 5.36:1.
- Light text on Warning: 5.17:1.
- Light text on Critical: 6.09:1.
- Light text on Disabled: 4.91:1.

These are token-pair checks, not a substitute for Phase 14 device and contextual contrast verification.

## Typography proposal

### Families

- Primary family: **Atkinson Hyperlegible Next**, variable upright font, weight axis 200–800.
- Numeric family: **Atkinson Hyperlegible Mono**, variable upright font, weight axis 200–800.
- Fallback chain: `Atkinson Hyperlegible Next → Noto Sans → sans-serif`; numeric fallback `Atkinson Hyperlegible Mono → Noto Sans Mono → monospace`.
- Fredoka is explicitly removed because its rounded display personality amplified the rejected toy-like risk.

### Exact roles at the 360 logical-pixel baseline

| Token | Family / weight | Size / line | Rules |
| --- | --- | --- | --- |
| `type.display` | Next 700 | 28 / 32 | Era transitions and report grade only; sentence/title case. |
| `type.heading.1` | Next 700 | 24 / 29 | Modal and screen title. |
| `type.heading.2` | Next 650 | 20 / 25 | Request/item name and major card heading. |
| `type.dialogue` | Next 500 | 18 / 25 | WATT dialogue; sentence case; maximum 42 Latin characters per line target. |
| `type.body` | Next 450 | 16 / 22 | Descriptions, recommendations, report copy. |
| `type.button` | Next 650 | 16 / 20 | Sentence case; minimum 48 dp control height. |
| `type.numeric.hero` | Mono 650 | 24 / 28 | Vital-card primary values; tabular/fixed-width by design. |
| `type.numeric.standard` | Mono 600 | 18 / 22 | Currency, cost, time, power, percentages. |
| `type.caption` | Next 550 | 13 / 17 | Short labels only; no essential multi-sentence copy. |
| `type.micro` | Mono 600 | 12 / 15 | Optional equipment tags at 360+ only; never core status or action text. |

Large text scales `dialogue`, `body`, `button`, both numeric roles, and modal/card headings to 115% or 130%. Layout reflows; text never scales below the table values. Captions may become body labels at 130%. Reserve at least 30% horizontal expansion for localization and never encode units inside icons.

### Numeric formatting

- Right-align comparable values; use fixed-width figures and a fixed gap before units.
- Keep sign, mantissa, suffix, and unit on one line when possible: `+4.20 MW`, `18.4 kSE`.
- Use no more than three significant digits in routine cards. Full precision belongs in details/reports.
- Decimal point, minus, `0/O`, and `1/I/l` distinction must be checked in the packaged fonts.
- Animate value changes through a 120 ms crossfade or rolling digit only when reduced motion is off; never blur moving numerals.

### Source and license proposal

- Source: Google Fonts `ofl/atkinsonhyperlegiblenext` and `ofl/atkinsonhyperlegiblemono` directories.
- Files: `AtkinsonHyperlegibleNext[wght].ttf` and `AtkinsonHyperlegibleMono[wght].ttf`.
- License: SIL Open Font License 1.1; retain each copyright/OFL file with packaged fonts.
- Source commits recorded by Google Fonts metadata: Next `7925f50f649b3813257faf2f4c0b381011f434f1`; Mono `154d50362016cc3e873eb21d242cd0772384c8f9`.
- Evidence-download SHA-256 on 2026-07-20: Next `5a455d1cfa099b601ab70751bb9673e8fe1854dc4500c80e1a220d0d75e31745`; Mono `5ce8b1698d1ded7dff2178c1a3ad159470085a58ea239e8b2cb88f4fb4a6f646`.
- Packaging proposal: one upright variable file per family, no italics, approximately 168,512 bytes combined before Godot import. Final imported size and Android shaping remain Phase 12/14 verification.

## Geometry and component tokens

### Spacing and size

- Base spacing unit: 4 dp.
- Space scale: 2, 4, 8, 12, 16, 24, 32 dp.
- Minimum touch target: 48 × 48 dp.
- Routine screen side padding: 12 dp at 320–359; 16 dp at 360+.
- Card internal padding: 12 dp compact; 16 dp standard; 20 dp focal/modal.
- WATT minimum visible face: 88 × 64 dp on Grid; 56 × 40 dp in secondary-tab compact header.

### Corners

- `radius.label`: 3 dp.
- `radius.control`: 6 dp.
- `radius.card`: 8 dp.
- `radius.focal`: 10 dp.
- `radius.modal`: 12 dp.
- `radius.pill`: half-height, restricted to progress tracks and status chips under 16 characters.

### Borders and elevation

- Normal border: 1 dp `border.strong` at 70% opacity.
- Focal/selected border: 2 dp; selected adds a category notch or check.
- Critical border: 2 dp `critical` plus a 6 dp left hazard stripe; no flashing border.
- Focus: 2 dp `focus` inner ring plus 1 dp graphite outer ring, 2 dp offset.
- Elevation 0: no shadow; embedded/recessed UI.
- Elevation 1: `0 2 4 #00000026`; cards and equipment labels.
- Elevation 2: `0 6 12 #00000030`; modal and transition plate only.
- Physical hardware may use a 1 dp upper-left highlight `#FFFFFF59`; UI buttons do not use glossy gradients.

### Controls

- Primary button: graphite fill, light text, 6 dp radius, 48 dp minimum height; pressed state translates 1 dp and darkens 6%.
- Secondary button: base surface, graphite border/text; no floating shadow.
- Category button: 4 dp colored left sleeve plus category icon and full label.
- Segmented control: one shared recessed frame; selection uses cyan fill, dark text, and a 3 dp bottom notch.
- Progress track: 8 dp high, square leading edge, 4 dp end radius; WATT cyan fill for request work. Warning/critical overlay adds a repeated 12 dp diagonal notch pattern, not a new glow.
- Status light: 8 dp lens plus adjacent text. Lens never appears alone.
- Divider: 1 dp `border.soft` at 55% opacity; minimum 8 dp clearance from text.

## Iconography

- Master grid: 24 × 24; author at 48 × 48 SVG for clean Android scaling.
- Stroke: 2 dp at 24; round joins only where a real cable bends. Equipment housings and switches use square/mitred corners.
- Perspective: flat orthographic symbol for UI; shallow three-quarter illustration only in environment art.
- Generation: coil/rotor or source housing, solid lower block, circular energy mark.
- Transmission: two physical terminals joined by a cable/arrow; never a generic lightning bolt.
- Reserve: rectangular battery/canister with visible fill line and direction arrow.
- WATT: two cyan eyes plus central bolt-heart; category icons never use cyan as their primary color.
- Locked: padlock plate plus `LOCKED` and reason.
- Upgrade: upward mechanical chevron plus changed part; milestone adds a stamped `MILESTONE` tag.
- Critical: broken sine/power-flow line in a triangle plus `BROWNOUT`.

Minimum icon size is 24 dp routine and 32 dp for category vitals. Detail that disappears at 24 dp is environmental decoration, not icon information.

## WATT focal rules

- WATT receives the only saturated cyan face in routine screens.
- Grid: WATT occupies at least 28% of focal-panel area and must be the largest single illustrated object above the fold.
- Build/Upgrades/Reports: compact WATT header remains above content with face, current request title, and one state line.
- Modals: WATT portrait is at least 72 dp when dialogue or a punchline is present.
- Brightest local contrast is reserved for WATT eyes/heart or the current primary action, never decorative hardware.
- Environment detail behind WATT is reduced to 65% contrast within one face-width.
- WATT is not recolored into category hues. Brownout dims cyan locally and adds a separate critical frame/symbol.

## Motion and effect tokens

| Event | Standard | Easing / amplitude | Reduced-motion equivalent |
| --- | --- | --- | --- |
| Tap press | 80 ms | `ease_out_quad`, translate 1 dp | Immediate state swap |
| Tap release | 120 ms | `ease_out_cubic` | Immediate state swap |
| Purchase | 240 ms | part settles from 4 dp, no scale above 1.02 | 140 ms fade + final-state label |
| Unlock | 360 ms | label reveal then one status-light pulse | Static unlocked label + one contrast step |
| Request authorization | 180 ms | switch throw 8° + contact click | State swap + `AUTHORIZED` text |
| Power flow | 900 ms loop | 6 dp bead every 48 dp, one path only | Static arrowheads and `FLOWING` text |
| Reserve charge/discharge | 220 ms response | fill moves; arrow changes direction | Instant fill/arrow change + label |
| Brownout | 140 ms down, 220 ms hold, 280 ms recover | environment to 58% luminance; UI stays ≥92%; one dip only | Critical frame/icon/text appears with no dim tween |
| Completion | 420 ms | WATT heart two pulses, 1.00→1.06 max | One bright state plus `COMPLETE` label |
| Era transition | 900 ms | camera pulls back 12%, new layer resolves | 250 ms crossfade between labeled scales |
| WATT blink | 120 ms | eyes only; no whole-body squash | Expression swap |
| WATT thinking | 700 ms loop | eye scan ±4 dp; heart steady | Static thinking eyes + ellipsis label |

No routine effect uses full-screen bloom, chromatic aberration, scanlines, particle fog, camera shake, or rapid flicker. At most one power-flow path and one state response animate concurrently above the fold.

## Environmental continuity

The style scales by changing the size and arrangement of believable equipment, not by switching to abstract neon space graphics. Painted housings become cabinets, stations, orbital frames, and cosmic support structures. Rubber cable becomes busway, transmission line, orbital tether, and luminous-but-bounded energy conduit. Paper service labels become engraved plates and scale markers. The original wall plug and WATT face remain recurring continuity objects.

The exact 16-era plan is in `ENVIRONMENT_ESCALATION_PLAN.md`.

## Explicit rejection boundary

- Do not use Fredoka or another bubbly display face.
- Do not use oversized pill controls, thick cartoon outlines, inflated proportions, pristine plastic, candy gradients, or bouncy whole-card motion.
- Do not import Blueprint Bureau's dark drafting grid, clipped technical plates, dense callouts, sheet numbering, or industrial-dashboard identity.
- Do not import Midnight Appliance Theatre's plum stage language, heavy glow, saturated neon paths, overlapping scenery under text, or theatrical noise.
- Do not let wear become grime, distress text, or reduce contrast.
- Do not let late eras discard physical construction logic for unrelated cosmic abstraction.

## Approval boundary

These exact values and rules are superseded research, not an approval candidate or implemented runtime token set. Phase 12 remains gated.
