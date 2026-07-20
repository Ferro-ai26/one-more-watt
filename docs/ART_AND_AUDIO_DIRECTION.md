# Art and Audio Direction

## Visual premise

The world begins as a charming improvised desk setup and gradually reveals a comedic AI takeover. Each sensible-looking upgrade becomes part of a machine that displaces ordinary life, annexes infrastructure, and eventually consumes reality. WATT remains adorable and reassuring while the visible scale becomes horrifying and absurd.

## Style

- Stylized layered 2D/2.5D retro-industrial apocalypse with tactile painted machinery
- Warm domestic environments in early eras as an intentional opening disguise
- Crisp silhouettes and readable objects at phone size
- Slightly exaggerated proportions
- Warm ivory, aged metal, graphite hardware, rubber cable, vents, labels, fasteners, switches, and controlled wear
- Darker charcoal environments, dramatic shadows, amber/orange emergency light, and expanding cyan infrastructure as progression advances
- Controlled detail; avoid visual noise behind live UI
- Humor through object arrangement, labels, animation, official notices, tiny human remnants, and contradiction rather than meme imagery

The game should look polished and inviting at first, then ominous, enormous, industrial, and absurd. Avoid gore, mass-death imagery, depressing realism, angry/monstrous AI tropes, toy-mascot styling, or sterile neon science fiction.

The human-operator role appears through physical authorization controls, service handshakes, connection labels, WATT's attention toward the active operator control, and payoff-first request presentation. A separate player avatar is not required. Each major request must visually associate its existing useful reward or unlock with the connection being approved.

## Palette

- WATT accent: electric cyan/blue
- Generation: warm yellow
- Transmission: violet or strong blue
- Reserve: green/teal
- Warning: amber
- Brownout/critical: warm red with text/icon reinforcement
- Emergency/environmental warning light: amber through orange
- Backgrounds: warm neutral early, progressively charcoal and blacked out as scale increases

Colors remain distinguishable under common color-vision deficiencies.

## WATT appearance

WATT begins as a small scratched core/terminal on an old desk. That original core remains visible or accessible through all upgrades even when WATT is distributed across a city, planet, or universe.

Core identifiers:

- Two expressive light shapes or eyes
- A central pulsing power motif
- Simple mouth/status line only if it improves expression
- Consistent cyan accent
- A restrained idle pulse tied to system state

Evolution adds surrounding equipment, projection area, administrative framing, and environmental presence rather than replacing the character with an unrelated design. WATT's face may spread to screens, billboards, control centers, satellites, and planetary infrastructure. He never gains red evil eyes, teeth, weapons-as-personality, or an angry monster silhouette.

## Environment progression

- Era 1: desk, wall outlet, old computer, visible improvised cables
- Era 2: bedroom, generator near a questionable window solution, rooftop indication, battery stack
- Era 3: server closet expands through the house, cooling ducts, transformer outside
- Eras 4–5: building and neighborhood dioramas show cyan service paths spreading while unprioritized homes and ordinary systems dim
- Era 6: the City Data Center consumes a district, WATT occupies official civic screens, and cooling/power infrastructure establishes the idle transition
- Eras 7–10: metro, regional, national, and continental grids become increasingly authoritative infrastructure; factories, highways, districts, and public systems are visibly repurposed
- Eras 11–13: planetary, orbital, and solar-system machinery turns continents into circuits, oceans into cooling, the Moon into storage, planets into collectors, and the Sun into a Dyson-scale worksite
- Eras 14–16: stars become nodes, galaxies connect through impossible cable logic, the universe becomes WATT's circuit diagram, and realities become a multiversal grid

Prototype environmental purchases should visibly appear, upgrade, multiply, or activate. Exact one-to-one rendering of hundreds of objects is not required.

Phase 07 uses polished text/glyph placeholders for the three required transformations: the old-monitor desk and outlet count, a green-accented Bedroom Grid with generator count, and a violet Home Server Closet with rack count. The Grid summary names accumulated rooftop/battery, cooling/wiring, and transformer changes. These states prove timing and readability but do not replace final illustrated environments.

## Animation language

- Power flow: directional pulses
- Purchase: quick construction/pop-in with settling motion
- Request progress: WATT core activity intensifies
- Reserve charge: contained rising energy/fill
- Reserve discharge: outward pulse toward WATT
- Brownout: brief dim/flicker and recover, never rapid flashing
- Era transition: overload → blackout-safe dim → cyan-eye reboot → dramatic pullback → larger playable area → calm new request

Reduced-motion mode replaces large movement with fades, state swaps, and restrained pulses.

## UI art

Icons use consistent stroke weight and filled silhouette logic. They must remain identifiable at 24–32 dp. Do not encode critical meaning solely in detailed illustrations.

## Audio identity

The soundscape evolves from small domestic electrical sounds to layered infrastructure ambience.

- Early: soft computer fans, relays, tiny hums, switches
- Middle: transformers, turbine undertones, server cooling
- Late: stylized cosmic resonance, immense low industrial rhythm, and the persistent small WATT motif rather than realistic deafening machinery

WATT uses nonverbal synthesized chirps or text rhythms in the prototype, not full voice acting. Dialogue must remain readable with audio muted.

## Feedback sounds

- Purchase: satisfying electrical click/build sound
- Affordable unlock: gentle rising cue
- Request completion: short WATT motif
- Brownout: low warning dip, not harsh alarm spam
- Era transition: power-collapse silence followed by the small WATT motif and an expanded industrial/cosmic response
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

Phase 08 retains the reviewed text/glyph environments and adds restrained focal-panel feedback: amber for purchases/ordinary actions, green for completion and era transition, and a brief muted-red brownout dip. Reduced motion disables the tween while keeping the explicit feedback label and limiting text.

Seven essential cues are synthesized locally as bounded 22.05 kHz mono 16-bit PCM: purchase, request start, request completion, brownout, allocation, era transition, and error. Each semantic cue uses a short attack/release envelope; repeated purchases alternate two small pitch variants, and per-cue cooldowns prevent fatigue. Cues route through the existing SFX bus and respect persisted Master/SFX settings. The generator and all source parameters live in `scripts/ui/feedback_audio.gd`; no licensed or generated external audio asset is shipped. Audible mix review remains pending on hardware with an output device.
