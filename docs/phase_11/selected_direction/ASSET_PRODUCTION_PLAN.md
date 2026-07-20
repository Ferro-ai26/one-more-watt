# Soft Circuit Workshop — Asset Production Plan

Status: Superseded by `../living_workshop/ASSET_PRODUCTION_PLAN.md`. Reusable rights/font research is preserved; prior screen-composition and effort assumptions are not current.

Machine-readable initial inventory: `asset_production_inventory.csv`

## Production approach

### Code-native and vector-first

- Godot Theme resources own semantic colors, type sizes, spacing, borders, radii, focus, and state styles.
- UI icons, WATT face parts, equipment labels, cable paths, and status patterns remain editable SVG or Godot-drawn geometry.
- Dynamic text and values remain Godot controls. No concept PNG becomes a full-screen runtime UI.
- Environment art uses layered vector masters or layered raster sources exported by depth band; no single flattened export is the only source.
- Common electrical props use one master silhouette with era-appropriate detail variants rather than unrelated redraws.

### Human-authored production art

The preferred production path is controlled vector/manual illustration based on the approved model sheet and material rules. AI generation is not required for the selected system. If later used for mood or prop ideation, its prompt, tool/version, source references, and output review must be recorded; generated UI, icons, labels, WATT faces, or final environment geometry remain prohibited without manual reconstruction and explicit approval.

## Initial production inventory

| Group | Planned quantity | Source / export | Owner phase | Status now |
| --- | ---: | --- | --- | --- |
| Font families | 2 variable upright files | TTF + OFL → Godot font resources | 12 | Proposed; exact source commits/hashes recorded |
| Semantic theme/token resource | 1 system | `.tres` / GDScript-safe constants | 12 | Specified, not implemented |
| Reusable panel/control styles | 12–16 | Godot StyleBox/theme resources | 12 | Specified, not implemented |
| Core category icons | 3 | Editable SVG, 48 master → 24/32 dp | 12 | Direction sketches in concepts |
| Navigation icons | 5 | Editable SVG | 12 | Not produced |
| State icons/patterns | 8–10 | Editable SVG / code pattern | 12 | Direction sketches in concepts |
| Infrastructure icons | 18 | Editable SVG with category sleeves | 13 | Not produced |
| Upgrade icons | 3 | Editable SVG | 13 | Not produced |
| WATT base rig | 1 | Layered SVG/2D rig | 13 | Model-sheet proposal only |
| WATT expression states | 6 required + blink | Rig poses/shape keys | 13 | Model-sheet proposal only |
| WATT era housings | Eras 1, 2, 3, 6 target | Layered vector/2.5D assemblies | 13, 17 | Model-sheet proposal only |
| Environment masters | 3 prototype eras | Layered vector or lossless layered raster | 13 | Direction concepts only |
| Environment depth exports | 3–4 bands per era | SVG/PNG/WebP by opacity need | 13 | Not produced |
| Purchase-visible prop variants | 18, grouped from infrastructure masters | SVG/layered prop instances | 13 | Not produced |
| Era transitions | 1→2 and 2→3 | Reuse environment bands + transition masks | 13 | 1→2 concept only |
| UI state effects | 7 semantic hooks | Godot tween/shader/code paths | 12–13 | Timing tokens specified |
| App/store icon redesign | 1 family, later sizes | WATT-based vector master | 23/25 | Existing lightning icon remains prototype |

## Effort estimate

The estimates are person-days after final Phase 11 approval. They are planning ranges, not calendar promises.

| Workstream | Art/animation days | Godot/UI days | Notes |
| --- | ---: | ---: | --- |
| Font packaging and type proof | 1–2 | 1–2 | Includes fallback and large-text samples; device QA later. |
| Theme/component visual implementation | 2–3 | 7–10 | Phase 12 token/component proof, not full skin. |
| WATT base rig + six expressions | 6–8 | 2–4 | Includes compact-header and modal variants. |
| Core/navigation/state icon system | 6–8 | 2–3 | Includes 24 dp cleanup and state reinforcement. |
| Eighteen infrastructure + three upgrade icons/props | 9–13 | 2–4 | Reuses equipment masters between shop and environment. |
| Era 1 environment and visible accumulation | 5–7 | 3–4 | Desk, monitor, outlet/cable/battery/fan layers. |
| Era 2 environment and accumulation | 6–8 | 3–4 | Bedroom, outside generator, solar/battery/ventilation. |
| Era 3 environment and accumulation | 7–10 | 3–5 | House/closet, racks, cooling, wiring, transformer. |
| Motion/effect production | 4–6 | 5–7 | Restrained paths, Reserve, WATT, brownout, transitions. |
| Art cleanup, accessibility variants, revision reserve | 6–8 | 3–5 | Includes smallest-layout simplification; device work remains Phase 14. |
| **Total** | **52–73** | **31–48** | Spread across Phases 12–14; audio and later eras excluded. |

Candidate A's earlier 25–35 art-day estimate covered a simpler stylized Eras 1–3 skin. The selected believable-hardware revision raises the credible range because it adds reusable equipment masters, controlled wear, more exact WATT rigging, and phone-scale cleanup.

## Android and memory budget proposals

- Prefer vector/Godot-native UI assets; do not allocate full-screen textures for routine screens.
- Environment source may exceed target size, but runtime opaque backgrounds export as WebP at no more than 1440 × 2560 per full-depth composite reference; actual layers should be cropped to content bounds.
- Target total concurrently resident Era environment textures: ≤24 MiB uncompressed estimate on the 720 × 1280 reference, subject to Phase 12 measurement.
- WATT + current environment + UI icon atlas target: ≤8 MiB additional uncompressed estimate.
- Keep no more than the current and next transition environment resident during routine play.
- SVG import or rasterization must be reviewed for edge consistency at 320, 360, 393, 480, and 720 logical widths.

## Rights and sourcing

### Fonts

- Source only the two recorded Google Fonts OFL family directories.
- Retain each original `OFL.txt`, copyright line, source commit, filename, and SHA-256.
- Do not modify or rename the font in Phase 12 unless the license/reserved-name implications are reviewed.

### Original assets

- Code-authored Phase 11 SVG concepts are internal original work and retain their editable source.
- Production WATT, icons, equipment, labels, and environments should be original to the project.
- If commissioned, the contract must grant commercial game/store/marketing use, modification, source-file delivery, and sublicensing necessary for distribution. Creator credit requirements must be recorded.
- Do not use unlicensed web photos, traced manufacturer marks, real utility logos, copied warning labels, or third-party textures.
- Generic hardware may be referenced for functional plausibility, but distinctive branding and exact proprietary product dress must be removed.

### Audio boundary

Existing procedural cues remain the functional baseline. Direction-specific ambience/music production is not required to approve Phase 11 and remains owned by later audiovisual phases. Any later recording/library asset needs its own license and source record.

## Principal risks and mitigation

| Risk | Impact | Mitigation / gate |
| --- | --- | --- |
| Warm/tactile becomes childish | Undermines tone and long-game credibility | Atkinson type, small radii, mature proportions, satin metal/rubber/ceramic, no inflated controls or bounce. Review every hero asset against anti-adjectives. |
| Believable hardware becomes grim or overtechnical | Loses invitation and comprehension | Warm room field, WATT cyan focal light, simplified silhouettes, plain-language labels; no fault diagrams or dense SCADA callouts. |
| Environment detail competes with values | Bottleneck/request clarity falls | Three density tiers, opaque text surfaces, contrast quiet zone around WATT/numbers, ≤5 background silhouettes at 320 width. |
| Category hues drift between props/UI/effects | Player cannot scan the grid | One semantic token source; category sleeves at endpoints; shape/icon/text reinforcement in every state. |
| WATT disappears at later scale | Violates character-first pillar | Fixed eye/heart ratios, focal-size rules, single cyan face, every era transition lands on WATT before revealing infrastructure. |
| Late eras become unrelated cosmic neon | Breaks identity | Physical housings, bounded conduits, labels, fasteners, original plug relic, and continuous camera/scale grammar through all 16 eras. |
| Wear becomes visual noise | Android readability and polish suffer | 4–8% opacity cap, max three wear marks per hero, omit wear at icon scale and behind all text. |
| Font source/license drift | Release rights or rendering inconsistency | Pin exact files/commits/hashes and ship OFL texts; no web-served runtime fonts. |
| Production estimate expands | Schedule pressure encourages one-offs | Reuse shop/environment equipment masters; prove WATT, category icons, one card, and one environment band in Phase 12 before full production. |
| Concept art mistaken for runtime architecture | Brittle reskin | Concepts remain `.gdignore` documentation; Phase 12 owns semantic resources and reusable implementation. |

## Approval and production gate

All inventory items are retired-plan or superseded-exploration records under `DEC-026`. A future direction must explicitly replace or re-adopt them. Runtime integration remains prohibited.
