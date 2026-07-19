# Game Vision

## Product statement

**ONE MORE WATT** is a character-driven incremental power-grid game in which the player becomes the increasingly exhausted grid operator for WATT, a friendly AI whose supposedly small requests require increasingly ridiculous electrical infrastructure.

The player begins with a wall outlet and an old computer. Over many hours and repeated WATT upgrades, the grid grows from a desk to a room, house, building, neighborhood, city, nation, planet, solar system, galaxy, universe, and multiverse.

The core promise is simple: **WATT always has another request.**

## Product targets

- Platform: Android first
- Engine: Godot
- Genre: Comedy incremental / idle management
- Orientation: Portrait preferred unless device testing proves landscape materially better
- Play pattern: Short active sessions that evolve into planned offline progress
- Audience: Players who enjoy number growth, visible transformation, light management, collectible jokes, and long-term optimization
- Business model: Undecided; no monetization systems belong in the prototype

## Player fantasy

The player is the only competent grid operator standing between civilization and an AI that considers every power budget a temporary inconvenience.

The emotional arc should move through:

1. Curiosity: What does WATT want next?
2. Competence: I understand why this request is slowing down.
3. Anticipation: I can prepare for the next demand spike.
4. Attachment: WATT is unreasonable, but I like it.
5. Escalation: I cannot believe a grocery-list assistant now owns Mercury.
6. Mastery: My new model version tears through what once took hours.

## Design pillars

### Character first

WATT supplies the goals, dialogue, humor, unlocks, and escalating pressure. Electricity is the system the player manages; WATT is the reason the player cares.

### Readable grid management

Generation, Transmission, and Reserve create meaningful bottlenecks without simulating individual wires or requiring electrical-engineering knowledge.

### Earned escalation

The game spends meaningful time at human scale. Cosmic infrastructure is a culmination, not a first-evening gag.

### Active-to-idle evolution

Early requests arrive in seconds or minutes. Automation arrives before waits become long. Era 6, City Data Center, deliberately marks the transition into long-running idle management.

### Fair failure

Underbuilding slows progress and creates funny reports. It does not erase hours of work. Offline players are never punished by random disasters they could not prevent.

### Endless absurdity

Prestige compresses early eras while model upgrades and multiversal modifiers support long-term scaling.

## Core loop

1. WATT announces a request and forecast.
2. The player identifies the limiting grid constraint.
3. The player buys, upgrades, or reconfigures infrastructure.
4. The player chooses an allocation mode.
5. The request consumes delivered power and survives demand peaks.
6. A completion report provides rewards, performance feedback, and a punchline.
7. WATT immediately discovers a larger need.

## Pacing commitment

| Era range | Player behavior | Typical request duration |
| --- | --- | --- |
| 1–2 | Active onboarding | 15 seconds–3 minutes |
| 3–5 | Developing automation | 3–25 minutes |
| 6 | Idle transition | 20–60 minutes |
| 7–10 | Long-term management | 45 minutes–8 hours |
| 11–13 | Offline planning | 6–24 hours |
| 14–16 | Prestige/endless play | Days and increasing |

Durations are first-run targets. Prestige should eventually compress early requests to seconds.

## Era ladder

1. Cold Boot — Desk
2. Bedroom Assistant — Room
3. Home Server Closet — House
4. Building Network — Building/block
5. Neighborhood Microgrid — Neighborhood
6. City Data Center — City
7. Metropolitan Grid — Metro
8. Regional Utility — Region/state
9. National Compute Grid — Country
10. Continental Supergrid — Continent
11. Planetary Intelligence — Earth
12. Orbital Grid — Earth and Moon
13. Solar-System Thought Engine — Solar system
14. Galactic Utility — Galaxy
15. Universal Grid — Universe
16. Multiversal Infrastructure — Endless realities

## Prototype definition

The vertical slice includes Eras 1–3 and must prove:

- WATT is understood within 30 seconds.
- Several requests, jokes, and visible upgrades occur within five minutes.
- Generation, Transmission, and Reserve create understandable decisions.
- The player cares about the next request, not only the number increase.
- Brownouts are amusing and informative.
- Automation feels earned.
- Save and conservative offline progress are reliable.

The prototype contains 12–18 authored requests, four request types, three allocation modes, one home-scale visual transformation, and enough infrastructure to reach the Home Server Closet.

## Non-goals

- A realistic electrical engineering simulator
- Wire-by-wire placement
- A city builder with individual citizens
- Frequent manual repairs
- Random offline catastrophes
- A cynical anti-AI message
- Live generative dialogue
- Multiplayer, accounts, or cloud dependence in the prototype
- Advertising or purchases in the prototype

## Creative north star

Every major unlock should be attached to a WATT request, reaction, accident, or behavioral change. If the game remains equally understandable and entertaining after removing WATT, the design has drifted into a generic power idle game.

