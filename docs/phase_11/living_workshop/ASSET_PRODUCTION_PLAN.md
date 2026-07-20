# Living Animated Workshop Diorama — Asset Production Plan

Status: Superseded planning exploration under `DEC-026`; estimates and architecture are not approved inputs to production.

Machine-readable plan: `asset_production_inventory.csv`

## Production architecture assumptions

- Each era uses four composited depth bands, named installation anchors, authored cable paths, and milestone state sets.
- Environment masters are layered vector or layered raster sources; UI and dynamic text remain Godot-native.
- WATT uses one reusable physical rig: body/cradle, face apertures, bolt-heart meter, cable segments, vent flap, status lamps, and shadow/light masks.
- Purchase animation reuses three families: place/bolt, route/connect, activate/respond.
- Infrastructure uses `single → cluster → bank → facility` states. Counts do not produce one sprite per unit.
- Build/Upgrade drawers reuse one component system over the live scene. Reports remain the only card-dense screen family.
- No freeform cable physics is planned. Authored curves make screenshots deterministic and avoid unstable overlaps.

## Initial inventory

| Group | Planned quantity | Source/export | Owner phase | Status |
| --- | ---: | --- | --- | --- |
| Fonts | 2 variable upright TTF + OFL files | pinned Google Fonts sources | 12 | Preserved proposal; not integrated |
| Diorama compositor | 1 reusable four-band system | Godot nodes/shader-safe materials | 12 | Planned |
| Anchor/cable authoring schema | 1 system | typed resources + editor-safe paths | 12 | Planned |
| Drawer/context components | 6–8 | Godot Theme/Control scenes | 12 | Concepted, not implemented |
| WATT physical rig | 1 base + compact/large presentations | layered SVG/raster rig | 13 | Model-sheet concept only |
| WATT expression/body states | 6 expressions + blink and 5 body/cable reactions | rig poses/timelines | 13 | Concepted |
| Reusable purchase animations | 3 families + reduced-motion swaps | animation library | 12–13 | Storyboarded |
| Era 1 environment kit | 1 shell, desk, 7 anchors, 8–10 props, 4 light states | layered sources + cropped exports | 13 | Concepted |
| Era 2 environment kit | 1 room shell, 6 new anchors, 8–10 props | layered sources | 13 | Pullback concepted |
| Era 3 environment kit | 1 house/closet shell, 7 anchors, 10–12 props | layered sources | 13 | Planned |
| Infrastructure milestone sets | 18 families × up to 4 states, heavily sharing masters | layered vector/raster | 13+ | Planned |
| Category/state icons | 3 category + 8–10 state | SVG | 12 | Retained semantic approach |
| Effects/light masks | 8 semantic families | grayscale masks/code | 12–13 | Timings specified |
| Era transition rigs | 1→2, 2→3 | reuse environment bands/camera framing | 13 | 1→2 storyboarded |

## Revised effort estimate

Person-days after Phase 11 execution approval; not calendar commitments.

| Workstream | Art/animation | Godot/UI | Cost control |
| --- | ---: | ---: | --- |
| Font packaging/type proof | 1–2 | 1–2 | Existing pinned records. |
| Diorama compositor, drawers, context shelf | 3–5 | 8–11 | One reusable world-first frame. |
| WATT physical rig and six expressions | 8–11 | 4–6 | One body rig; era housings reuse face/core. |
| Anchor/cable system and authoring proof | 2–3 | 5–8 | Authored curves; no physics. |
| Modular shell/furniture/equipment kit | 8–12 | 4–6 | Shared props/material masks. |
| Era 1 scene and milestone states | 8–11 | 5–8 | Seven anchors, four lighting states. |
| Era 2 scene and milestone states | 7–10 | 5–7 | Reuses complete desk subsystem. |
| Era 3 scene and milestone states | 9–12 | 5–8 | Reuses room/house modules. |
| Purchase/reaction animation families | 8–12 | 8–12 | Three reusable sequences and WATT hooks. |
| Icons, labels, compact status visuals | 5–7 | 2–3 | Exact semantic set, not generic glyphs. |
| Cleanup, accessibility variants, revision reserve | 6–9 | 3–5 | 320-wide and reduced-motion variants. |
| **Total** | **65–94** | **50–76** | Eras 1–3 through Phases 12–14; later eras/audio excluded. |

The estimate rises from the rejected package because the main world is now animated, WATT is physically embedded, and purchase states require environmental continuity. Modular parts, four milestone states, three shared animation families, and authored cable anchors keep the increase bounded and prevent per-unit/per-screen one-offs.

## Runtime and Android targets

- No full-screen baked UI. Dynamic labels, values, focus, and controls remain live.
- Target each active era's four opaque/cropped environment bands at ≤28 MiB estimated uncompressed total on the 720 × 1280 reference.
- WATT rig, cable masks, light masks, and icon atlases target ≤10 MiB additional uncompressed.
- Keep current era plus only transition-required parts of the next era resident; release previous bands after transition.
- Author sources at 2× target and inspect at 320, 360, 393, 480, and 720 logical widths.
- Collapse texture detail, not WATT/request information, at the smallest layout.

## Provenance and rights

- The Atkinson font records and OFL 1.1 packaging requirements remain unchanged.
- Phase 11 living-workshop SVGs are code-authored project concepts with retained sources and mechanical PNG renders.
- No external image, traced product, manufacturer mark, generated raster, or third-party texture is used in this package.
- Production references may establish generic functional plausibility but must remove branded/product-specific trade dress.
- If later AI-assisted ideation is used, record prompt, model/tool, date, references, contextual review, and license/commercial status; reconstruct UI, WATT, icons, labels, and final geometry manually.
- Commissions must grant commercial game/store/marketing use, modification, source delivery, and distribution sublicensing.

## Risks and mitigation

| Risk | Mitigation |
| --- | --- |
| Diorama becomes unreadable clutter | Four depth bands, silhouette budget, quiet zones around WATT/request, three active motions maximum. |
| World-first hides grid comprehension | Colored physical endpoints plus full bottleneck label and one contextual action shelf. |
| WATT becomes toy-like | Asymmetric low cradle, mature terminal proportions, no rounded mascot body, no permanent mouth, physical cable/vent behavior. |
| Animation burden expands | Three purchase families, five WATT body reactions, reusable light/fan/cable response hooks. |
| Cable paths overlap text or objects | Named anchors and authored curves per milestone state; deterministic screenshot tests later. |
| Per-unit art explodes | Single/cluster/bank/facility visual states, numeric counts, representative nodes after Era 4. |
| Later eras become unrelated neon | Physical frames, service access, bounded cyan, amber work light, retained plug/label relics. |
| Painted textures soften Android text | No text baked into scene; opaque tested plates for every essential label/value. |
| Generated concepts mistaken for approved art | This package uses no generated raster; all artifacts remain candidate until explicit approval. |

## Gate

This plan is retained only as superseded exploration. A future direction must replace or explicitly re-adopt its assumptions. Runtime implementation and font import remain prohibited.
