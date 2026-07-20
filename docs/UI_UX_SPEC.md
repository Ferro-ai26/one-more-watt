# Mobile UI and UX Specification

## Experience goals

The player should understand three things at a glance:

1. What WATT wants
2. What is limiting progress
3. What action can improve the situation

The UI should feel like a friendly, slightly improvised control panel that becomes more capable and ridiculous with WATT. It must not resemble an industrial SCADA system or a generic spreadsheet idle game.

## Mobile baseline

- Primary layout: portrait
- Design reference: 1080 × 1920 logical composition, implemented responsively
- Minimum touch target: 48 × 48 density-independent pixels
- Critical text remains readable at 320 logical pixels wide
- Respect Android safe areas and display cutouts
- Do not rely on hover
- Never require precision dragging for a core action
- Support one-handed access for frequent actions where practical

## Main screen hierarchy

### Top status band

Displays:

- Current era and scale
- Stored Energy
- Current aggregate power unit
- Settings access

### WATT/request panel

This is the visual focal point and occupies the upper-middle portion of the screen.

It contains:

- WATT portrait/core animation
- Current dialogue
- Request title and type
- Progress bar and remaining time
- Forecast summary
- Authorize or report button when applicable

WATT must remain visible during routine purchasing. Do not bury the character on a separate tab.

### Grid vital cards

Three equal-priority cards:

- Generation: current output and capacity trend
- Transmission: capacity and utilization
- Reserve: stored/capacity and charge/discharge direction

The limiting card receives a clear highlight plus a text label such as `LIMITING REQUEST`. Color alone is insufficient.

### Allocation control

Three segmented buttons:

- Expand Grid
- Balanced
- Feed WATT

Each selection shows the resulting Stored Energy rate and estimated request duration before or immediately after selection.

### Primary navigation

Prototype tabs:

- Grid
- Build
- Upgrades
- Reports

Settings opens separately. Locked tabs may appear only when showing their unlock condition improves anticipation.

## Screens

### Grid overview

Shows WATT, request state, vital cards, allocation mode, and the most relevant recommended action.

### Build shop

Infrastructure cards show:

- Icon and name
- Owned count
- Next cost
- Primary effect
- Resulting improvement or percentage change
- Buy 1 control
- Bulk-buy control after it unlocks
- Locked reason when unavailable

Affordable items are distinguishable without flashing. A purchase produces immediate numeric and visual feedback.

### Upgrades

Organized by unlocked, affordable, and completed. Completed one-time upgrades remain discoverable in a compact archive.

### Request detail/authorization

Before authorization, show:

- Continuous load
- Expected peak
- Recommended Reserve
- Current predicted service level
- Estimated completion time
- Identified likely bottleneck
- Rewards and unlocks

Underprepared authorization is allowed after a plain-language warning.

### Performance report

Shows:

- Grade
- Completion time
- Demand served
- Peak handled
- Brownout time
- Stored Energy earned
- Unlocks
- WATT completion line
- One actionable improvement suggestion

The report should feel rewarding even after a poor run.

### Offline return report

Shows elapsed recognized time, time simulated, progress earned, requests completed, Stored Energy gained, brownout summary, and any cap that limited progress.

### Reports archive

Stores recent request reports and lifetime best grades. It is not required to preserve every raw tick.

### Settings

Prototype settings:

- Master, music, effects, and voice-style text sound volume
- Reduced motion
- Number notation
- Text size
- Haptics
- Confirm large purchases
- Save/export diagnostic information
- Credits and version

## First five-minute onboarding

Teach through WATT requests, not a disconnected tutorial carousel.

1. WATT boots and requests power.
2. The player taps the obvious power control or authorizes the first simple request.
3. Completion awards enough Stored Energy for the first purchase.
4. WATT points to the Build tab.
5. The next request exposes a limitation.
6. Allocation modes unlock with a short forced comparison.
7. Automatic generation replaces repeated tapping before tapping becomes tiring.

Instruction overlays must block only the minimum required region and remain dismissible after the first successful action.

## Tapping policy

If a manual tap action is retained, it represents briefly overclocking or hand-cranking WATT's improvised setup—not tapping a battery. Tapping is an onboarding accelerator and optional short-term boost, not the permanent primary income source.

The tap target must have animation, sound, and a visible numeric response. Automation should make tapping unnecessary within the first few minutes.

## Visual feedback

- Purchases visibly add or upgrade objects in the current environment.
- Power flow uses restrained animated pulses.
- Reserve direction is visible through fill motion and arrow state.
- Brownouts dim local elements briefly without obscuring controls.
- Major unlocks alter the environment, WATT's presentation, or both.
- Large number changes animate quickly and can be reduced through accessibility settings.

## Accessibility

- Do not communicate state through color alone.
- Provide text alternatives for icons.
- Support reduced motion without removing state feedback.
- Allow larger dialogue and numeric text.
- Avoid rapid full-screen flashes.
- Ensure controls have logical focus order for keyboard/controller testing.
- Maintain adequate contrast across normal, locked, affordable, warning, and limiting states.
- Timed requests do not require time-sensitive tapping.

## Error and empty states

- Missing content: show a development-visible error in debug builds and a safe fallback in release builds.
- Save recovery: explain which backup was restored.
- No active request: show the next available announcement, never a dead empty panel.
- Cannot afford: show the missing amount and approximate time at current income.
- Offline cap reached: disclose the cap without blaming the player.

## UI acceptance questions

- Can a new player explain WATT's request within 30 seconds?
- Can the player identify the bottleneck without opening a secondary screen?
- Does every purchase explain its effect before confirmation?
- Can the main loop be operated with one thumb?
- Does WATT remain visually central?
- Is every warning actionable?

## Phase 05 implementation baseline

The production-structured prototype shell keeps its top status, WATT/request focal panel, three vital cards, allocation control, and primary navigation visible as one portrait hierarchy. Grid, Build, Upgrades, and Reports replace only the lower scrollable screen region, so WATT remains present during routine purchasing.

Request authorization and performance reports use one blocking modal layer with explicit action/back controls. The application back action closes the top modal first, then returns a secondary tab to Grid. Infrastructure and upgrade cards consume economy previews directly and show ownership/level, availability, exact next cost, missing currency or lock reason, and predicted effect before issuing a command.

Runtime accessibility state covers reduced motion, three text scales, engineering/scientific notation, haptics, and large-purchase confirmation. Audio controls map to the existing Master, Music, SFX, and UI buses. These settings intentionally remain in memory until Phase 06 defines persistence.
