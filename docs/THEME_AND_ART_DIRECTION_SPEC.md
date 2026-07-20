# Theme and Art Direction Specification

## Purpose

This document defines the decisions Phase 11 must make before broad production skinning. It is a specification for creating and approving the visual identity, not permission to apply an unapproved style to the whole game.

## Creative objective

ONE MORE WATT should look like a charming, increasingly overbuilt electrical control system assembled around a likable AI. The visual comedy comes from serious presentation applied to wildly disproportionate infrastructure.

The game must remain attractive and readable on a phone while evolving from a cluttered desk into a multiversal utility network.

## Required direction decisions

### WATT

Define:

- Core silhouette and face/display language
- Idle, thinking, pleased, concerned, brownout, and completion expressions
- How WATT evolves without losing recognition
- Relationship between WATT's cyan identity and grid-category colors
- How WATT remains the focal point on every routine screen

### Visual style

Choose and document one coherent production style. Candidate exploration may compare styles, but the final system must select one.

The approved style must address:

- Illustration dimensionality: flat 2D, layered 2.5D, or stylized rendered sprites
- Line weight and edge treatment
- Material language: plastic, painted metal, cables, glass, energy, domestic objects
- Lighting and shadow rules
- Texture/noise limits
- Detail density at phone scale
- Humor through props, labels, motion, and accumulation

### Color system

Define exact color tokens for:

- Background layers
- Surfaces and elevated panels
- Primary text and secondary text
- WATT accent
- Generation
- Transmission
- Reserve
- Affordable/positive
- Warning
- Brownout/critical
- Locked/disabled
- Focus and selection

All important states require shape, icon, text, or motion reinforcement; color alone is insufficient.

### Typography

Define:

- Display, heading, body, numeric, caption, and button roles
- Minimum device sizes
- Numeric alignment and large-number readability
- Dialogue styling for WATT
- Font licensing and Android packaging
- Fallbacks and localization expansion allowance

### Shape language

Define corner radii, borders, depth, shadows, highlights, dividers, status lights, progress bars, tabs, buttons, cards, modals, and tooltips. Avoid mixing unrelated UI styles.

### Iconography

Define grid, stroke/fill, perspective, minimum size, category color use, locked/upgrade states, and treatment for infrastructure that evolves across eras.

### Motion and effects

Define timing ranges and easing for:

- Tap/press
- Purchase
- Unlock
- Request authorization
- Power flow
- Reserve charge/discharge
- Brownout
- Request completion
- Era transition
- WATT state changes

Every effect requires a reduced-motion equivalent.

### Environmental escalation

Create a visual progression plan for all 16 eras. Each era needs:

- Scale reveal
- Dominant environment
- WATT presence
- Infrastructure presentation
- New visual motif
- Connection to earlier equipment
- Transition concept to the next scale

## Representative approval screens

Phase 11 must produce direction-level mockups or styled prototypes for:

1. Main Grid screen during an active request
2. Build screen with affordable, unaffordable, locked, and milestone states
3. Performance report containing a WATT punchline

Also produce one brownout state and one Era 1-to-2 environment transition frame.

Do not skin the entire game until these samples form a coherent system and are approved.

## Theme options and decision process

Create no more than three genuinely distinct direction candidates. Each candidate includes:

- Short premise
- Palette
- Type pairing
- WATT treatment
- One representative main-screen concept
- Strengths, risks, Android readability, and asset-production cost

Record the selected direction in `DECISION_LOG.md`. Rejected candidates remain reference material but are not mixed into production.

## AI-assisted artwork policy

AI may help explore concepts and create candidate raster assets, but:

- Prompts and source/reference provenance are retained.
- Outputs are reviewed for inconsistent geometry, unreadable text, copied marks, and visual drift.
- UI text is rendered by Godot, not baked into generated images.
- Reusable icons and UI geometry should prefer controlled vector or code-native assets.
- Generated assets are not considered final merely because they look polished in isolation.
- Licensing and store-use suitability must be documented.

## Approval gate

Phase 11 completes only when one direction is explicitly approved, its tokens are recorded, representative screens agree, production cost is plausible, and Sol has enough rules to skin new scenes consistently.
