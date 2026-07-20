# Phase 11 Visual-Direction Candidates

Status: Presented for user approval; no direction selected.

All three candidates preserve the proven mobile hierarchy and the permanent category mapping: WATT cyan, Generation warm yellow, Transmission violet/blue, Reserve green/teal, warning amber, and critical warm red. The candidate palettes are exploration values, not approved implementation tokens.

## At-a-glance comparison

| | A — Soft Circuit Workshop | B — Blueprint Bureau | C — Midnight Appliance Theatre |
| --- | --- | --- | --- |
| Core appeal | Warm, tactile, immediately charming | Exceptionally scalable and system-readable | Most characterful, dramatic, and escalation-ready |
| Dimensionality | Layered 2.5D cut-paper machinery | Flat 2D illustrated technical manual | Layered 2.5D stage/diorama with glow |
| WATT | Rounded monitor companion with cyan face and bolt-heart | Circular inspection lens/core with expressive eye apertures | Floating cyan core in a portable projector halo |
| UI | Cream equipment labels and chunky physical controls | Blueprint plates, callouts, stamps, and crisp line icons | Large theatrical cards, caption ribbons, and luminous paths |
| Best strength | Domestic attachment and tactile upgrades | Readability, reuse, and lowest production burden | WATT centrality and spectacular era transitions |
| Main risk | Can become toy-like or beige | Can drift into sterile SCADA/technical-dashboard territory | Glow/detail can become noisy and expensive |
| Relative burden | Medium | Low–medium | High |
| Concept | [`candidate_a_soft_circuit_workshop.svg`](concepts/candidate_a_soft_circuit_workshop.svg) | [`candidate_b_blueprint_bureau.svg`](concepts/candidate_b_blueprint_bureau.svg) | [`candidate_c_midnight_appliance_theatre.svg`](concepts/candidate_c_midnight_appliance_theatre.svg) |

Comparison board: [`candidate_comparison_board.png`](concepts/candidate_comparison_board.png)

## Candidate A — Soft Circuit Workshop

### Visual premise

A friendly repair bench gradually annexes the room, house, and universe. Rounded painted-metal appliances, cream paper labels, chunky plugs, and neatly bundled cables make the grid feel handmade and trustworthy; the joke is how carefully a ludicrous machine has been assembled.

### WATT design

WATT begins as a squat, rounded CRT-like monitor with two cyan eye lamps and a central lightning-bolt heart below the screen. The face stays simple: eye shape, lid angle, and the heart's pulse provide idle, thinking, pleased, concerned, brownout, and completion states. Later eras replace the surrounding chassis, not the face-and-heart arrangement. Cyan is exclusive to WATT and active energy; category colors live on cables, labels, and infrastructure.

### UI treatment

Layered cream equipment cards sit over warm charcoal or domestic backdrops. Thick dark keylines, shallow offset shadows, folded label tabs, toggle-like segmented controls, and large filled action buttons create tactile hierarchy. Infrastructure icons are filled silhouettes with one interior cut line. Critical states add a striped edge and explicit status badge.

### Candidate palette

| Role | Value |
| --- | --- |
| Canvas / domestic wall | `#E7D6BB` |
| Primary surface | `#FFF8E8` |
| Recessed surface | `#E8DDC8` |
| Primary ink | `#263238` |
| Secondary ink | `#65706E` |
| WATT / active energy | `#00A7C4` |
| Generation | `#E7A91B` |
| Transmission | `#6657C8` |
| Reserve | `#26866E` |
| Positive | `#2D8A54` |
| Warning | `#C66A1D` |
| Critical | `#BD4148` |
| Disabled | `#9A958C` |

### Typography

- Display and friendly labels: Fredoka SemiBold.
- Body/dialogue: Atkinson Hyperlegible Next Regular/Medium.
- Numeric and compact telemetry: Atkinson Hyperlegible Mono Medium with tabular figures.
- Candidate concepts use platform fallbacks where those fonts are not installed. Proposed source is Google Fonts; each family must be retained with its directory-level SIL Open Font License before integration.

### Environment style

Early eras are shallow cutaway rooms with a small set of reusable painted-metal props. Purchases add, multiply, or visibly cable those props. Building-to-city eras pull back into warm model-town cutaways. Planetary and cosmic eras retain cream labels, rounded housings, and the original plug as a tiny relic inside increasingly impossible machinery.

### Animation language

Controls depress 2–3 pixels and settle with a soft overshoot. Purchases pop in as two or three assembled layers. Power moves as rounded dashes through physical cables; Reserve rises inside a glass canister. WATT's heart breathes at idle, ticks laterally while thinking, droops during brownout, and performs one buoyant bounce on completion. Reduced motion uses instant position changes, short opacity crossfades, and a single heart-brightness step.

### Strengths

- Strongest match for early domestic warmth and player attachment.
- Infrastructure purchases naturally become visible props and accumulation jokes.
- Tactile controls are understandable without industrial expertise.
- The simple WATT rig can remain expressive at small sizes.

### Risks

- Excess cream and rounding could feel juvenile or like a generic cozy app.
- Detailed prop painting can create a large era-by-era illustration workload.
- Cosmic scale needs disciplined materials so it does not look like a toy universe.

### Android readability

Large dark-on-light dialogue offers excellent daylight contrast. Thick outlines, filled state shapes, and low texture behind text survive 320-pixel width. The main risk is fitting long localized labels on physical tabs; tabs must expand rather than preserve a fixed sticker size.

### Production burden

Medium: approximately 25–35 art-days for the Eras 1–3 production skin after the reusable system exists—WATT rig 4–6, environment/props 12–16, UI/icons 6–8, motion/effects 3–5. Estimate excludes Godot integration, audio, QA, and later eras.

## Candidate B — Blueprint Bureau

### Visual premise

WATT documents each unreasonable expansion as an immaculate illustrated utility plan. The screen is a living field manual: deep-blue drafting paper, cyan construction lines, numbered callouts, approval stamps, and tiny deadpan annotations make serious process the source of comedy.

### WATT design

WATT is a circular diagnostic lens with two expressive cyan apertures and a central bolt waveform. Outer rings accumulate ports, brackets, and orbiting status tabs as eras advance. The face remains readable as two eye shapes plus the waveform even when the outer apparatus becomes city- or planet-scale.

### UI treatment

Mostly flat outlined plates with clipped corners, grid-backed environment diagrams, square status chips, and strong typographic hierarchy. Icons use a 32-unit orthographic grid, two stroke weights, and one solid state marker. Affordable, locked, milestone, and critical cards vary border pattern, corner badge, label, and icon—not only hue.

### Candidate palette

| Role | Value |
| --- | --- |
| Blueprint canvas | `#061C2A` |
| Primary plate | `#0C2A3C` |
| Secondary plate/grid | `#164B61` |
| Primary text | `#E7F4F5` |
| Secondary text | `#A8C3C8` |
| WATT / drawing line | `#55E6FF` |
| Generation | `#FFC857` |
| Transmission | `#A78BFA` |
| Reserve | `#52D6A2` |
| Positive | `#70D38B` |
| Warning | `#FF9F43` |
| Critical | `#FF6174` |
| Disabled | `#68808A` |

### Typography

- Display/headings: Barlow Condensed SemiBold.
- Body/dialogue: Barlow Regular/Medium.
- Numeric/captions: Space Mono Regular/Bold with tabular figures.
- Proposed sources are the Google Fonts OFL directories for Barlow and Space Mono. License files and exact font versions must be copied into the asset record before integration.

### Environment style

One continuous diagram language scales from desk elevation to room plan, neighborhood map, national network, and orbital chart. Purchased objects shift from outlined appliances to standardized map symbols while retaining their silhouette and callout number. Earlier equipment stays visible in inset detail bubbles, creating callbacks without rendering the full old scene at cosmic scale.

### Animation language

Lines draw on in 120–220 ms, callout leaders snap into place, stamps land with a restrained two-frame compression, and power moves as marching dashes. Brownout breaks selected line segments and adds a stable hatched warning region—never a rapid flicker. Era transitions zoom outward along a labeled scale bar. Reduced motion swaps completed drawing layers and uses static arrowheads.

### Strengths

- Most systematic route from phone UI to 16-era environmental escalation.
- Lowest unique raster burden; well suited to code-native/vector production.
- Excellent category and bottleneck legibility.
- Bureaucratic labels support WATT's calm, disproportionate comedy.

### Risks

- Highest risk of feeling like an industrial SCADA screen or generic technical dashboard.
- WATT can become a logo instead of a companion if the face is not large and expressive.
- Dense callouts and grid texture must be aggressively culled at phone scale.

### Android readability

High contrast, straight reading order, and concise condensed headings perform well at narrow widths. Grid lines remain below text contrast and disappear beneath dialogue. Condensed type is restricted to headings; body copy remains normal width. Critical states use hatching, broken-line symbols, and labels.

### Production burden

Low–medium: approximately 17–25 art-days for the Eras 1–3 production skin after the reusable system exists—WATT rig 3–4, environment diagrams 7–10, UI/icons 5–7, motion/effects 2–4. Estimate excludes Godot integration, audio, QA, and later eras.

## Candidate C — Midnight Appliance Theatre

### Visual premise

The grid is a small midnight stage where domestic appliances become a glowing mechanical cast. WATT floats in a portable projector halo while layered paper-and-light scenery pulls back from desk to room to impossible cosmic diorama. Serious captions anchor a playful, cinematic world.

### WATT design

WATT is a dark circular core with two cyan light eyes, a central bolt pupil/heart, and an offset projector halo. Expression uses eye geometry, halo tilt, and a small status pennant. The core-and-two-eyes remain unchanged; each era adds a larger frame, cable crown, projection field, or orbital rig around it.

### UI treatment

Large plum and ink cards overlap a little like stage flats. Dialogue uses a generous cream caption card; vitals are bold color blocks with distinct icons and edge shapes. Navigation is a low glowing footlight strip. Live power paths travel behind cards but never under text. Surface count is lower than the prototype, prioritizing WATT, bottleneck, and next action.

### Candidate palette

| Role | Value |
| --- | --- |
| Stage canvas | `#17122A` |
| Primary surface | `#272044` |
| Elevated caption | `#FFF5E8` |
| Primary light text | `#FFF5E8` |
| Secondary light text | `#BEB5D2` |
| WATT / active energy | `#45E8E0` |
| Generation | `#FFD166` |
| Transmission | `#B58CFF` |
| Reserve | `#56D69B` |
| Positive | `#86E57F` |
| Warning | `#FF9B54` |
| Critical | `#FF5D73` |
| Disabled | `#77708F` |

### Typography

- Display/headings/body: Space Grotesk Medium/SemiBold with sentence-case dialogue.
- Numeric/captions: Space Mono Regular/Bold with tabular figures.
- Proposed sources are the Google Fonts OFL directories for Space Grotesk and Space Mono. Exact packaged versions and license texts remain an approval-following task.

### Environment style

Each era is a layered diorama with three depth bands: foreground UI/status props, the active infrastructure stage, and a low-detail scale backdrop. Era transitions pull the camera through or beyond the current stage. Earlier objects become tiny illuminated props, constellation-like silhouettes, or labels on the next stage rather than disappearing.

### Animation language

WATT hovers within a four-pixel envelope; halo and cable layers lag slightly to imply weight. Purchases enter like stage props, settle, and switch on. Power travels as soft beads; Reserve breathes inside a lantern-like vessel. Brownout collapses the stage lighting toward WATT while controls and critical labels stay fully lit. Completion triggers a short halo bloom and curtain-like scale reveal. Reduced motion uses depth-free crossfades and static glow rings.

### Strengths

- Strongest WATT centrality and emotional presence.
- Best visual runway for dramatic room-to-cosmos escalation.
- Can feel premium and distinctive without relying on realism.
- Lower information density makes the routine hierarchy immediately legible.

### Risks

- Highest illustration, compositing, and motion cost.
- Glow, overlap, and saturated color can reduce daylight readability or create visual noise.
- Maintaining coherent prop perspective across 16 eras requires a firm template and art supervision.

### Android readability

The cream dialogue card and large block vitals remain readable at 320 pixels. Text never sits directly on glow or scenery. WATT and critical controls retain opaque backplates. A no-bloom accessibility variant and luminance caps are mandatory; state icons and labels duplicate every colored signal.

### Production burden

High: approximately 30–42 art-days for the Eras 1–3 production skin after the reusable system exists—WATT rig 7–9, environment/dioramas 15–20, UI/icons 6–8, motion/effects 5–7. Estimate excludes Godot integration, audio, QA, and later eras.

## Shared sourcing and rights position

- The concepts are original code-authored SVG compositions created for this repository. They contain no generated raster content, copied marks, external images, or baked production UI text.
- Proposed font families are available through the Google Fonts repository, whose family directories carry their redistribution license. The exact chosen font files, versions, copyright lines, and license text will be inventoried only after direction approval.
- Production UI geometry and icons should be Godot-native or editable SVG. Environment illustrations should retain layered editable sources.
- AI-assisted raster exploration remains optional after approval. Any such output must retain prompt/provenance, pass geometry and copied-mark review, and remain `candidate` until contextual and rights approval.

## Approval request

Choose A, B, or C, and optionally name required revisions. Approval selects a production logic, not every literal detail in the concept. No elements from rejected candidates will be mixed into the selected direction unless the approval explicitly calls them out.
