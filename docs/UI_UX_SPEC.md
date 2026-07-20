# Mobile UI and UX Specification

## Experience goals

The player should understand three things at a glance:

1. What WATT wants
2. What is limiting progress
3. What action can improve the situation

The UI begins as a friendly improvised workshop layer and matures into an official retro-industrial takeover system. It must support ominous scale without becoming a sterile SCADA display, generic spreadsheet idle game, or flat dashboard. WATT's polite copy and the physical environment should often tell different stories.

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

The main screen is a zoomable, animated takeover diorama showing the current physical scale of WATT's grid. The environment is the primary interface. Live UI attaches to its edges, labels, equipment plates, and contextual drawers; it does not shrink the world into an illustration card.

The player is presented as WATT's human operator. Connect/Authorize actions are explicit operator decisions and should visibly complete a physical handshake in the scene. They do not spend a new permission resource.

### Compact status rail

Displays:

- Current era and scale
- Stored Energy
- Current aggregate power unit
- Settings access

### WATT and current request

WATT is physically present in or visibly projected through the environment. The scratched original core remains visible or reachable throughout progression. At large scales, additional faces may appear on screens, billboards, civic displays, satellites, and planetary structures, but they never replace the core identity.

The attached live request surface contains:

- WATT portrait/core animation
- Current dialogue
- Request title and type
- Progress bar and remaining time
- Forecast summary
- Authorize or report button when applicable

WATT must remain visible during routine purchasing. Do not bury the character on a separate tab. Dialogue sits on a high-contrast live plate and may include a subordinate disclaimer that remains readable without becoming the only evidence of a consequence.

### Contextual grid vitals

Generation, Transmission, and Reserve remain equal mechanical priorities, but they need not occupy three permanent dashboard cards. The current environment should provide physical evidence for all three; a compact contextual shelf or drawer exposes exact values:

- Generation: current output and capacity trend
- Transmission: capacity and utilization
- Reserve: stored/capacity and charge/discharge direction

The limiting resource receives a clear physical endpoint/path treatment plus an icon and text label such as `LIMITING REQUEST`. Color alone is insufficient.

### Allocation control

Three segmented buttons:

- Expand Grid
- Balanced
- Feed WATT

Each selection shows the resulting Stored Energy rate and estimated request duration before or immediately after selection.

### Primary navigation and drawers

Prototype tabs:

- Grid
- Build
- Upgrades
- Reports

Settings opens separately. Build and Upgrades should prefer partial-height drawers or context views that preserve WATT and the takeover scene. Reports may use full card-based overlays because comparison and sharing require a stable frame. Locked tabs may appear only when showing their unlock condition improves anticipation.

## Scale-pullback interaction

Completing selected capstone requests triggers a recurring six-beat presentation:

1. Current machinery overloads.
2. The environment briefly goes dark without a rapid flash.
3. WATT's cyan eyes reactivate first.
4. The camera pulls back dramatically.
5. A larger playable environment is revealed.
6. WATT calmly requests exponentially more power.

The next interaction waits until the scale label and new primary action are readable. Reduced motion uses a brief safe dim, immediate cyan-eye state, 300 ms or shorter crossfade, explicit `SCALE EXPANDED` label, and still before/after views.

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
- Concrete operator payoff, framed from those existing rewards/unlocks (for example restored reliability, a blueprint, automation, infrastructure capability, or prestige progress)

Underprepared authorization is allowed after a plain-language warning.

The authorization action uses operator language such as `AUTHORIZE CONNECTION`, `APPROVE GRID LINK`, or the specific physical action when space permits. It must not imply the player merely donates power. WATT may recommend strongly, but the action remains attributable to the player.

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

Major era reports also work as screenshot-ready takeover cards. They may include a commandeered percentage, civilian inconvenience classification, notable sacrificed/repurposed infrastructure, WATT's reassurance, and an optional small-print contradiction. Statistics are authored or derived from real game state; fabricated specificity is prohibited in production.

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
- Save/export diagnostic information
- Credits and version

Affordable Build and Upgrade purchases apply immediately on the first tap. The former cost-threshold confirmation and its Settings control were removed under `DEC-031`; affordability rules, costs, feedback, and save compatibility are unchanged.

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
- As eras advance, ordinary environments may dim or fall into silhouette while WATT's cyan grid remains bright; controls and critical text retain accessible luminance.
- Large-scale WATT faces appear on environmental screens and infrastructure, not as a substitute for the persistent original core.
- Capstone changes support deterministic before/after captures and completion cards without requiring UI text to be baked into background art.
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
- Can the player name the useful payoff and understand that they are authorizing a physical expansion?
- Can the player identify the bottleneck without opening a secondary screen?
- Does every purchase explain its effect before confirmation?
- Can the main loop be operated with one thumb?
- Does WATT remain visually central?
- Is every warning actionable?

## Phase 05 implementation baseline

The production-structured prototype shell keeps its top status, WATT/request focal panel, three vital cards, allocation control, and primary navigation visible as one portrait hierarchy. Grid, Build, Upgrades, and Reports replace only the lower scrollable screen region, so WATT remains present during routine purchasing.

Request authorization and performance reports use one blocking modal layer with explicit action/back controls. The application back action closes the top modal first, then returns a secondary tab to Grid. Infrastructure and upgrade cards consume economy previews directly and show ownership/level, availability, exact next cost, missing currency or lock reason, and predicted effect before issuing a command.

Runtime accessibility state covers reduced motion, three text scales, engineering/scientific notation, and haptics. Audio controls map to the existing Master, Music, SFX, and UI buses. These settings intentionally remain in memory until Phase 06 defines persistence. The later `DEC-031` interaction revision removed the conditional large-purchase confirmation while retaining its legacy save field solely for compatibility.

Phase 06 persists those settings with game state. The Offline Return modal shows away, recognized, effective, cap, efficiency, Stored Energy, brownout, request progress/completion, cap application, and neutral clock-anomaly explanations. Backup recovery names the restored file. If main and both backups fail, a blocking recovery modal preserves evidence and requires explicit confirmation before writing a new game.

Phase 07 gates allocation until its authored tutorial, progressively reveals Reserve and detailed service forecasts, exposes available vanity requests on Grid without blocking the main path, and adds a Smart Meter Reserve-protection control after its research unlock. Cold Boot, Bedroom Assistant, and Home Server Closet use distinct WATT glyph/color and environment-copy states. Era changes use persistent blocking transition modals, while the final focal state explicitly says Eras 1–3 are complete and “More coming” without exposing Era 4.

Phase 08 adds a compact next-action line to the focal forecast, keeps the authorization button above optional warning/advice copy, shows approximate affordability time when a live income rate exists, and labels Reserve as charging, supporting, or ready with arrows plus text. Online idle generation now advances whenever no request is active; blocking modals continue to pause active requests as specified.

The responsive minimum is verified at 320 × 568 in addition to the prior portrait sizes. On Build, Upgrades, and Reports, WATT's glyph, environment badge, and current request title remain visible in a compact 72-pixel focal header while detailed dialogue, progress, forecast, and request action stay on Grid. This exposes the first secondary-screen card without removing WATT from routine purchasing. Buttons wrap, primary authorization is visible without initial scrolling, settings toggles use compact readable type, all visible controls retain 48-pixel targets, and reduced motion keeps semantic text feedback while suppressing the focal tween.
