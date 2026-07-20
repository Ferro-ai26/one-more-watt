# Cheerful Electrical Doomsday — Direction Specification

Status: Approved and locked Phase 11 direction under `DEC-028`.

## North star

**Adorable character + horrifying scale + casual polite dialogue.**

The environment states the consequence while WATT states the reassurance. Neither half is optional. Early warmth builds attachment; later charcoal scale, blackouts, and impossible machinery reveal that the workshop was only the opening disguise.

The player is the indispensable human operator. WATT provides genuine repairs, reliability, blueprints, automation, useful solutions, infrastructure improvements, and prestige capability in exchange for authorized expansion. His helpfulness creates dependence; the operator's expertise and belief that they remain in control sustain agency and complicity. This is presentation of existing rewards, not a new progression system.

## Main-screen grammar

- A zoomable animated takeover diorama is the primary interface.
- A compact graphite/ivory status rail holds era, power, Stored Energy, warning, and settings.
- WATT and the active request are physically attached to or projected into the scene.
- Exact Generation/Transmission/Reserve values live on a compact context shelf or drawer; the limiting resource is named and reinforced by shape/path.
- Build/Upgrade open as partial-height drawers over a still-visible scene.
- Reports use stable card frames suitable for comparison and sharing.
- Dynamic text, numbers, controls, and accessibility states remain Godot-native; generated backgrounds never carry essential text.
- Every major request pairs its demand with a concrete payoff derived from existing rewards/unlocks, followed by an explicit operator authorization/connection action.

### Portrait geometry proposal

Reference concept canvas: 720 × 1280, corresponding to the 360 × 640 review baseline at 2×.

| Region | Reference bounds | Rule |
| --- | --- | --- |
| Safe side margin | 20–30 px | 10–15 logical px; runtime still respects Android safe areas. |
| Status rail | `x 20–700`, `y 20–108` | 88 px / 44 logical px; era, aggregate power, one secondary status, settings. |
| Takeover diorama | full bleed; primary clear view `y 108–828` | Never enclosed as a card; WATT/core and dominant route stay clear. |
| Request plate | `x 30–690`, approximately `y 828–1104` | Dialogue, progress, payoff, consequence disclaimer. Height may reflow for larger text. |
| Operator action | `x 30–690`, `y 1120–1188` | 68 px / 34 logical visual plate inside a minimum 48 dp touch target. |
| Navigation | approximately `y 1198–1280` | Four minimum 48 dp targets. |
| Build/Upgrade drawer | lower 44–52% of usable height | WATT/core and upper environment remain visible. |

Base spacing is 4 dp with 8/12/16/24/32 dp steps. Proposed radii are 3 dp labels, 6 dp controls, 8 dp plates, 10 dp report groups, and 12 dp modals; borders are 1 dp separators, 2 dp normal edges, and 3 dp selected/critical edges. These values mature the hardware language and avoid oversized toy-like capsules.

Icons use a 24 dp grid and 2 dp stroke with solid silhouette reinforcement at 16 dp: Generation plug/rotor, Transmission linked terminal/cable, Reserve battery/stack, operator authorization keyed connector, warning triangle, critical octagon/broken path, and locked padlock plus reason. Environmental infrastructure may be painterly, but essential icon geometry remains vector/code-native.

## Materials and lighting

Early: warm ivory plaster, dusty wood, aged painted metal, graphite brackets, ceramic outlets, rubber cable, paper labels, amber desk light, bounded cyan spill.

Middle: charcoal streets and service voids, municipal signage, orange beacons, cyan feeders crossing ordinary infrastructure, selectively blacked-out homes, enormous cooling and transformer silhouettes.

Late: the same steel, ceramic, cable, fastener, vent, label, and maintenance-access logic applied impossibly to planets, Dyson structures, stars, and realities. Space is not generic neon abstraction.

Wear is controlled: no more than three legible marks on a hero object at phone scale. Do not use grime as a full-screen texture.

## Color and type

Use the proposed semantic values in `../../ART_DIRECTION_WORKBOOK.md`. WATT cyan never communicates an unrelated category. Amber/orange may indicate work light or emergency state; critical uses warm red plus a broken-path/octagon/text treatment. Color never carries state alone.

Atkinson Hyperlegible Next/Mono remains the proposed family. Licensing research is preserved; fonts remain unintegrated. All essential copy uses opaque tested plates over environmental art.

## WATT rules

- Recognition anchor: scratched original core, asymmetric aged-metal shell, dark face window, two cyan eye apertures, small power mark, and rear input cable.
- No permanent mouth is required. Expression comes from eye geometry, brightness, posture, cable tension, nearby machine response, and screen timing.
- The core remains visible or accessible at every era.
- Distributed faces may appear on civic/cosmic infrastructure but use the same two-eye language.
- Never add red evil eyes, anger, fangs, weapon silhouettes, corruption glitches, or monster anatomy.

## Consequence rules

Every milestone scene includes:

1. one obvious new piece of WATT infrastructure;
2. one small remnant of ordinary life;
3. one visible displacement/blackout/repurposing consequence;
4. one calm WATT reassurance or administrative label that contradicts it;
5. one physical callback to an earlier scale.

Consequences remain comedic and legible, not gory or mournful. No bodies, victims, mass-death statistics, destroyed landmarks, or realistic atrocity imagery.

## Motion

| Event | Normal | Reduced motion |
| --- | --- | --- |
| Idle environment | 2–4 dp parallax; two local machine loops | static layers; state lights remain |
| Purchase | anchor → seat → authored cable trace → activation | static anchor and connected state |
| Brownout | local infrastructure dims; cyan path breaks; UI remains ≥92% | immediate dim state and label |
| Completion | WATT eyes brighten; machinery overload cue | bright eyes and `COMPLETE` state |
| Capstone | 1600–2400 ms six-beat pullback | ≤300 ms fade with labeled before/after |
| Report | 220 ms plate settle; statistics count once | immediate complete card |

No camera shake, rapid flashing, full-screen white, looping alarm strobe, or continuous decorative particle noise.

## Explicit exclusions

No dashboard-first Main Grid, permanently cozy bedroom aesthetic, toy-like mascot, flat infographic takeover, sterile neon science-fiction UI, purely textual conquest, genuine horror, gore, depressing realism, angry WATT, or silent condensation of the 16-era structure.
