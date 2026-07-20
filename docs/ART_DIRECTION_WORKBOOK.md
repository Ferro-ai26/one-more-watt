# Art Direction Workbook

Use this workbook during Phase 11. Do not mark unanswered choices as approved defaults.

## Direction statement

- Working visual premise: Pending a major visual and narrative pivot under `DEC-026`. No current exploration package is selected.
- Intended emotional tone: Pending the new direction brief. Prior tone studies remain historical evidence only.
- Three adjectives: Pending.
- Three anti-adjectives: Pending.
- Player age/readability assumptions: Broad casual/incremental audience; no prior electrical knowledge; critical text and state recognition must work at 320 logical pixels wide, larger text, common color-vision deficiencies, muted audio, and reduced motion.
- Reference games/artworks and what is being referenced: No external artwork is copied or embedded. Candidate A refers generically to tactile repair benches and cut-paper machinery; B to illustrated field manuals and drafting diagrams; C to layered stage dioramas and practical light theatre. These are medium/process references, not imitation targets.
- Elements that must remain original: WATT's face/silhouette and evolution, category icon family, environment compositions, interface geometry, written labels/jokes, animation motifs, and all shipped illustration.

## Candidate comparison

### Candidate A

- Name: Soft Circuit Workshop
- Premise: A friendly repair bench gradually annexes the room, house, and universe through carefully assembled painted-metal machines, paper labels, plugs, and cables.
- WATT treatment: Rounded old-monitor companion; two cyan eye lamps and a bolt-heart remain constant while the surrounding chassis evolves.
- UI treatment: Warm cream equipment cards, thick keylines, shallow offset shadows, label tabs, chunky toggles, and filled silhouette icons.
- Environment treatment: Layered 2.5D domestic cutaways become model-town, planetary, and cosmic machinery while retaining early props as tiny relics.
- Strengths: Strong domestic attachment, tactile purchase feedback, and natural visual-accumulation comedy.
- Risks: Can become juvenile/beige; prop illustration burden grows; cosmic scale needs disciplined material continuity.
- Estimated production burden: Medium; 25–35 art-days for an Eras 1–3 skin after the reusable system exists, excluding integration/audio/QA.

### Candidate B

- Name: Blueprint Bureau
- Premise: WATT documents each unreasonable expansion as an immaculate living utility plan, with serious callouts and approval marks carrying the joke.
- WATT treatment: Circular diagnostic lens with two cyan eye apertures and a bolt waveform; outer rings and ports accumulate without replacing the face.
- UI treatment: Deep-blue drafting plates, clipped corners, line icons, scale bars, callouts, hatches, and labeled stamps.
- Environment treatment: A continuous diagram language scales from desk elevation to room plan, network map, and orbital chart; early equipment persists in inset details.
- Strengths: Highest system clarity, lowest unique raster burden, strongest vector reuse, and easy 16-era scaling.
- Risks: Can drift into sterile SCADA/dashboard territory; WATT may feel like a logo; callout density must be tightly controlled.
- Estimated production burden: Low–medium; 17–25 art-days for an Eras 1–3 skin after the reusable system exists, excluding integration/audio/QA.

### Candidate C

- Name: Midnight Appliance Theatre
- Premise: Domestic appliances become a glowing stage cast while layered scenery pulls back from desk to impossible cosmic diorama.
- WATT treatment: Dark circular core with two cyan light eyes, bolt-heart, and offset projector halo; successive eras add frames and projection rigs.
- UI treatment: Large plum/ink stage-flat cards, a cream dialogue caption, bold category blocks, and luminous power paths isolated from text.
- Environment treatment: Three-layer dioramas use camera pullbacks for scale changes; early objects return as illuminated props, silhouettes, and constellations.
- Strengths: Strongest WATT centrality, premium character, low information competition, and best dramatic era transitions.
- Risks: Highest art/motion burden; glow may hurt daylight access; perspective and asset consistency need strong templates.
- Estimated production burden: High; 30–42 art-days for an Eras 1–3 skin after the reusable system exists, excluding integration/audio/QA.

Full comparison, palettes, typography, motion, readability, and cost rationale: `phase_11/CANDIDATE_COMPARISON.md`.

## Approved direction

- Selected candidate: None. A major visual and narrative pivot is pending.
- Approval date: Pending.
- Decision-log entry: `DEC-026` reopens selection; `DEC-024` and `DEC-025` are superseded.
- Final-package approval: Not reached.
- Superseded exploration: `phase_11/selected_direction/` contains the rejected Soft Circuit final proposal. `phase_11/living_workshop/` contains the incomplete, unrendered Living Animated Workshop Diorama revision.
- Reusable technical evidence: Atkinson font/licensing records, tested contrast ratios, semantic category separation, provenance process, and phone-scale validation method. Reuse is optional and must be confirmed by the next direction.
- Explicitly rejected/withdrawn packages: all current main-screen, WATT, environment, transition, and production-plan executions. Do not resume them without new user direction.

## Design tokens

### Colors

The exact Soft Circuit colors and contrast calculations remain tested technical evidence in `phase_11/selected_direction/SOFT_CIRCUIT_DIRECTION_SPEC.md`, but no semantic palette is currently approved for the next direction.

### Typography

- Display and UI/body font proposal retained for reconsideration: Atkinson Hyperlegible Next variable upright, weights 450–700.
- Numeric/status font proposal retained for reconsideration: Atkinson Hyperlegible Mono variable upright, weights 550–650, tabular figures, stable unit alignment, and no decorative display numerals.
- Logical type scale at the 360-wide baseline: display 28/32, H1 24/29, H2 20/25, dialogue 18/25, body 16/22, button 16/20, numeric hero 24/28, numeric standard 18/22, caption 13/17, optional micro numeric 12/15. Larger-text scaling is 115% and 130% with semantic reflow.
- Fallbacks: Noto Sans and Noto Sans Mono with metrics reviewed during later integration.
- License/source: exact Google Fonts variable files under SIL Open Font License 1.1, with source commits and SHA-256 hashes recorded in the selected-direction spec and asset record. Font binaries were used only from a temporary review directory and are not yet committed or integrated.

### Geometry

The following values are preserved from the superseded package as implementation research, not approved visual tokens:

- Base spacing unit: 4 dp; named increments 2, 4, 8, 12, 16, 24, and 32 dp.
- Corner radii: 3 dp labels, 6 dp inputs, 8 dp cards, 10 dp focal cards, and 12 dp modals; avoid oversized capsules.
- Border widths: 1 dp separators, 2 dp standard edges, 3 dp selected/warning edges.
- Elevation/shadow levels: none, 0/2/6 at 14% black, and 0/4/12 at 18% black; no glow.
- Controls: 48 dp minimum touch target, 12 dp internal horizontal padding, 8 dp gap; selected state uses border/shape/fill plus text.
- Icon grid and stroke: 24 dp grid, 2 dp stroke, square/round caps chosen by physical material; Generation uses plug/open-square, Transmission uses linked hex/cable, Reserve uses battery/stack, warning uses triangle, critical uses octagon/banner.
- Standard animation durations: exact normal and reduced-motion values are recorded in the selected-direction spec; no bloom, scanline, rapid flicker, full-screen noise, or continuous decorative motion.

## WATT model sheet

- Base silhouette: Pending the major direction pivot. Prior monitor/cradle studies are superseded.
- Expression states: Idle, thinking, pleased, concerned, brownout, and completion remain contract requirements; their visual execution is pending.
- Era 1/2/3/6/cosmic evolution: Pending.
- Continuity and animation rules: Pending the new visual and narrative brief.

## Prototype screen approvals

| Screen/state | Artifact path | Approved | Notes |
| --- | --- | --- | --- |
| Main Grid | Superseded Soft Circuit PNG; incomplete Living Workshop SVG | No | No current approval candidate. |
| Build states | Superseded Soft Circuit PNG; incomplete Living Workshop SVG | No | No current approval candidate. |
| Performance report | Superseded Soft Circuit PNG only | No | Must be redesigned for the new direction. |
| Brownout | Superseded Soft Circuit PNG; incomplete Living Workshop SVG | No | No current approval candidate. |
| Era transition | Superseded Soft Circuit PNG; incomplete Living Workshop SVG | No | No current approval candidate. |

## Asset feasibility

- Assets Sol can produce directly in Godot: Semantic theme resources, panels, buttons, tabs, progress/Reserve fills, power-path effects, reduced-motion swaps, state patterns, simple shaders, and layout-safe icon presentation.
- Assets suitable for controlled AI generation: Pending the new direction. Any later ideation remains non-production until provenance, contextual review, cleanup, and rights approval.
- Assets requiring manual/vector production: Pending the new direction; WATT, environment, icon, and motion requirements must be re-estimated.
- Assets requiring commissioned or licensed work: Exact Atkinson Hyperlegible files under OFL 1.1; specialist illustration/animation cleanup is optional depending on staffing. Later audio remains separately scoped.
- Largest consistency risk: Resuming a superseded package or silently carrying its assumptions into the major pivot.
- Mitigation: Begin the next session from `DEC-026`, obtain the new brief, and explicitly identify which technical evidence—if any—is re-adopted.

Prior estimates and inventories are superseded planning evidence only. The next direction requires a new credible production estimate before Phase 11 approval.

Candidate provenance and inventory: `phase_11/CONCEPT_ASSET_RECORD.md`.
