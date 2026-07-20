# Art and Audio Direction

## Visual premise

The world begins as a charming improvised desk setup and expands into an impossibly large but readable grid. The visual joke is accumulation: each sensible-looking upgrade becomes part of a machine far beyond its original purpose.

## Style

- Clean stylized 2D illustration with tactile machinery
- Warm domestic environments in early eras
- Crisp silhouettes and readable objects at phone size
- Slightly exaggerated proportions
- Controlled detail; avoid visual noise behind UI
- Humor through object arrangement, labels, and animation rather than meme imagery

The game should look polished and inviting, not grimy, dystopian, or technically sterile.

## Palette

- WATT accent: electric cyan/blue
- Generation: warm yellow
- Transmission: violet or strong blue
- Reserve: green/teal
- Warning: amber
- Brownout/critical: warm red with text/icon reinforcement
- Backgrounds: warm neutral early, cooler and more expansive as scale increases

Colors remain distinguishable under common color-vision deficiencies.

## WATT appearance

WATT begins as a small face or luminous core on an old monitor. The character remains recognizable through all upgrades.

Core identifiers:

- Two expressive light shapes or eyes
- A central pulsing power motif
- Simple mouth/status line only if it improves expression
- Consistent cyan accent
- A restrained idle pulse tied to system state

Evolution adds surrounding equipment, projection area, and environmental presence rather than replacing the character with an unrelated design.

## Environment progression

- Era 1: desk, wall outlet, old computer, visible improvised cables
- Era 2: bedroom, generator near a questionable window solution, rooftop indication, battery stack
- Era 3: server closet expands through the house, cooling ducts, transformer outside
- Era 4–6: building/neighborhood/city map becomes a layered operations view
- Later eras: maintain recognizable grid lines and WATT motif as scale becomes planetary and cosmic

Prototype environmental purchases should visibly appear, upgrade, multiply, or activate. Exact one-to-one rendering of hundreds of objects is not required.

Phase 07 uses polished text/glyph placeholders for the three required transformations: the old-monitor desk and outlet count, a green-accented Bedroom Grid with generator count, and a violet Home Server Closet with rack count. The Grid summary names accumulated rooftop/battery, cooling/wiring, and transformer changes. These states prove timing and readability but do not replace final illustrated environments.

## Animation language

- Power flow: directional pulses
- Purchase: quick construction/pop-in with settling motion
- Request progress: WATT core activity intensifies
- Reserve charge: contained rising energy/fill
- Reserve discharge: outward pulse toward WATT
- Brownout: brief dim/flicker and recover, never rapid flashing
- Era transition: environment pulls back or expands to reveal the new scale

Reduced-motion mode replaces large movement with fades, state swaps, and restrained pulses.

## UI art

Icons use consistent stroke weight and filled silhouette logic. They must remain identifiable at 24–32 dp. Do not encode critical meaning solely in detailed illustrations.

## Audio identity

The soundscape evolves from small domestic electrical sounds to layered infrastructure ambience.

- Early: soft computer fans, relays, tiny hums, switches
- Middle: transformers, turbine undertones, server cooling
- Late: stylized cosmic resonance rather than realistic deafening machinery

WATT uses nonverbal synthesized chirps or text rhythms in the prototype, not full voice acting. Dialogue must remain readable with audio muted.

## Feedback sounds

- Purchase: satisfying electrical click/build sound
- Affordable unlock: gentle rising cue
- Request completion: short WATT motif
- Brownout: low warning dip, not harsh alarm spam
- Era transition: expanded version of WATT motif
- Error: quiet differentiated cue

Repeated high-frequency actions require variants and cooldowns to prevent fatigue.

Phase 05 uses semantic purchase, request, allocation, completion, brownout, and error feedback hooks without shipping temporary sound files. Haptics run only when enabled on a supporting mobile platform, and missing audio assets remain a silent safe fallback. The placeholder WATT monitor uses restrained color modulation for feedback; reduced-motion mode suppresses that tween while preserving text and state changes.

## Music

Prototype music should be minimal and loopable, with dynamic layers optional. It must leave space for UI feedback and avoid turning long idle sessions into audio fatigue. Music is not required before core loop validation.

## Asset pipeline

Every asset must have:

- Stable filename and directory
- Source file retained when licensing allows
- Documented license/origin
- Import settings appropriate to target resolution
- Fallback placeholder during development
- Android memory consideration

Do not ship temporary AI-generated or web-sourced art without explicit rights review and a recorded decision.
