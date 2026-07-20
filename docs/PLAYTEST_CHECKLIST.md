# Playtest Checklist

Record build identifier, device/platform, tester, date, and notes for every formal pass.

## Phase 05 main-interface verification — 2026-07-20

- Build/commit: `6ae86ac`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- Resolutions: 360 × 640, 393 × 873, and 480 × 800
- [x] `Finish Booting` was reviewed, authorized, run from announcement to completion, and acknowledged through the intended request/report UI at every resolution.
- [x] Forecast modals showed load, peak, Reserve, predicted service, duration, bottleneck, reward, and underprepared warning behavior without blocking authorization.
- [x] `Perform Basic Arithmetic` ran underprepared after changing allocation to Feed WATT, visibly browned out, retained progress, and produced a report recording 63.0% service and 12.0 brownout seconds.
- [x] Generation/Transmission/Reserve cards used explicit `! LIMITING` text in addition to color, and the Grid screen offered a matching actionable recommendation.
- [x] A Wall Outlet card displayed its predicted +5 Generation effect before purchase; buying it increased ownership to two and the live grid to 10 W using the shared domain preview path.
- [x] Grid, Build, Upgrades, and Reports navigation, reusable locked/unaffordable/affordable cards, and two-report archive were exercised without debug-panel controls.
- [x] Request, report, purchase-confirmation, and settings modal/back behavior remained ordered and escapable.
- [x] Reduced motion, 115% text, scientific notation, haptics, confirmation, audio-bus controls, diagnostics, credits, and version were visible; changed accessibility state survived closing and reopening Settings.
- [x] Twenty-one captures covering authorization, report, brownout, Build, Upgrades, Reports, and Settings at all three resolutions were visually inspected after the horizontal archive regression was fixed.
- [x] All visible buttons met the 48-pixel minimum target; scroll containers kept longer card/settings content reachable at 360 × 640.
- [ ] Physical Android touch, haptic, audio-device, and safe-area behavior verified (device/export unavailable).

Notes: WATT/environment graphics and audio remain Phase 05 placeholders. Xvfb cannot control V-Sync; headless project validation is warning-free.

## Phase 04 economy-shop verification — 2026-07-20

- Build/commit: `ca56a35`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Purchased one Generation, Transmission, Reserve, Support, and Automation item through the simple shop.
- [x] Each pre-purchase prediction matched the rebuilt resulting grid values and exact Stored Energy deduction.
- [x] Locked and unaffordable selections showed distinct status text, unmet conditions, and missing Stored Energy.
- [x] Prepared nine Wall Outlets, previewed the tenth at its exact cost, then observed the cumulative ×2 milestone effect and a single `milestone_reached=10.0` event.
- [x] Purchased a leveled direct-output upgrade and a one-time multiplier upgrade; predicted and resulting values matched, and max-level state prevented another purchase.
- [x] Enabled, exercised, and disabled the low-Reserve threshold; throttling activated only below the selected threshold while enabled.
- [x] Four 393 × 873 captures were inspected; transaction, milestone, upgrade, and automation state text remained readable and all tested controls met the 48-pixel touch-target baseline.
- [x] General shell layout passed 360 × 640, 393 × 873, and 480 × 800 without horizontal clipping.
- [ ] Physical Android touch and safe-area behavior verified (device/export unavailable).

Notes: The shop is a Phase 04 diagnostic surface, not the finished Build/Upgrades navigation. Xvfb cannot control V-Sync; headless project validation is warning-free.

## Phase 03 request-lifecycle verification — 2026-07-20

- Build/commit: `2bd30ac`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Capacity, Stability, Burst, and Research samples completed through announcement, authorization, running, completion, and report acknowledgement.
- [x] Announcement and completion lines matched localized request data for every sample.
- [x] An underprepared Stability request remained authorizable and continued progressing during a deliberate brownout.
- [x] Allocation changed to Feed WATT during the run, the grid browned out for 1.00 second, recovered, and returned to Balanced.
- [x] Stability report truthfully recorded grade A, 93.7% service, 1.00 brownout second, a 12 W peak, and an improvement suggestion.
- [x] Capacity, Burst, and Research reports recorded 100% service and no brownout; Burst handled its 12 W peak with Reserve.
- [x] Reward amounts and next-request availability matched stable authored IDs after acknowledgement.
- [x] Four report captures at 393 × 873 were inspected; controls and report text remained readable, and shell layout passed all three portrait sizes.
- [ ] Physical Android touch and safe-area behavior verified (device/export unavailable).

Notes: The panel is a Phase 03 diagnostic surface, not the finished main UI. Xvfb cannot control V-Sync; headless project validation is warning-free.

## Phase 02 grid-debug verification — 2026-07-19

- Build/commit: `96bb219`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Generation-limited scenario showed 5 delivered from 5 Generation / 12 Transmission and labeled Generation limiting.
- [x] Transmission-limited scenario showed 6 deliverable from 15 Generation / 6 Transmission and labeled Transmission limiting.
- [x] Reserve-protected scenario served a 14 load from 10 deliverable plus 4 Reserve with no brownout.
- [x] Brownout scenario served 10 of 20 load, showed 10 unmet, Stability 30, and emitted `brownout_started`.
- [x] Recover control lowered demand, cleared the brownout, and emitted `brownout_ended`.
- [x] Allocation controls changed displayed WATT and Stored Energy rates.
- [x] One- and ten-second controls advanced deterministic simulation time exactly.
- [x] Debug labels remained readable at 393 × 873; general shell layout passed 360 × 640, 393 × 873, and 480 × 800.
- [ ] Physical Android touch and safe-area behavior verified (device/export unavailable).

Notes: The panel is a Phase 02 diagnostic surface, not the final game UI. Xvfb cannot control V-Sync; headless project validation is warning-free.

## Phase 01 content-shell verification — 2026-07-19

- Build/commit: `9e632d6`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Main scene loaded canonical content without parser, resource, or validation errors.
- [x] Captures at 360 × 640, 393 × 873, and 480 × 800 were visually inspected without clipping.
- [x] Shell showed content `v0.1.0`, schema `1`, two eras, one infrastructure, one upgrade, and one request.
- [x] Shell showed localized sample `Finish Booting • 75 energy`, matching source JSON.
- [ ] Physical Android safe-area and system-inset behavior verified (device/export unavailable).

Notes: Gameplay checks below remain inapplicable because Phase 01 adds trusted definitions, not playable systems. Xvfb cannot control V-Sync; this is a host limitation rather than a project warning in headless validation.

## Phase 00 shell verification — 2026-07-19

- Build/commit: Uncommitted Phase 00 working tree
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Main scene launched in a graphical runtime and rendered the development shell.
- [x] Godot editor opened the project successfully under the graphical VPS harness.
- [x] Captures at 360 × 640, 393 × 873, and 480 × 800 were visually inspected.
- [x] Labels, border, and version text were visible without clipping at all three sizes.
- [x] No missing-resource or parser error appeared.
- [ ] Physical Android safe-area and system-inset behavior verified (device/export unavailable).

Notes: The graphical VPS harness reported unavailable V-Sync control and no ALSA output device, then used Godot's dummy audio driver. Headless validation is warning-free. Gameplay checks below are not applicable to the non-playable Phase 00 shell.

## Build information

- Build/commit:
- Platform/device:
- Godot version:
- Tester:
- Date:

## First 30 seconds

- [ ] WATT is clearly the character asking for power.
- [ ] The current objective is obvious without reading a manual.
- [ ] The first interactive control is visually clear.
- [ ] The first action produces immediate visual and numeric feedback.

## First five minutes

- [ ] Several requests complete.
- [ ] At least two WATT lines are memorable or amusing.
- [ ] The first infrastructure purchase is understandable.
- [ ] Automatic generation arrives before repeated tapping becomes tiring.
- [ ] Allocation modes are explained through use.
- [ ] The environment visibly changes.
- [ ] There is no unexplained wait longer than 30 seconds.

## Core comprehension

- [ ] Generation answers “Do I make enough power?”
- [ ] Transmission answers “Can power reach WATT?”
- [ ] Reserve answers “Can the grid survive a spike?”
- [ ] The limiting constraint is obvious.
- [ ] Purchase effects are predictable before buying.
- [ ] Underprepared requests remain recoverable.

## Requests and WATT

- [ ] Announcements show load, peak, Reserve, duration, and reward.
- [ ] The player can authorize an underprepared request.
- [ ] Progress responds predictably to allocation changes.
- [ ] Brownout dialogue does not repeat excessively.
- [ ] Completion reports explain what happened.
- [ ] WATT remains likable rather than hostile.
- [ ] The player is curious about the next request.

## Save and offline

- [ ] Closing and reopening preserves exact key progress.
- [ ] Completed rewards are not duplicated.
- [ ] Offline duration and efficiency are disclosed.
- [ ] Offline request completion produces one report.
- [ ] Offline cap is respected.
- [ ] A corrupt-main-save recovery test succeeds.

## Mobile usability

- [ ] Frequent controls work one-handed.
- [ ] No core action requires hover or precision dragging.
- [ ] Touch targets are comfortable.
- [ ] Text remains readable on the smallest test device.
- [ ] Cutouts/system bars do not cover content.
- [ ] Background/resume behavior is correct.
- [ ] Reduced-motion mode preserves feedback.

## Prototype verdict

- [ ] Continue unchanged
- [ ] Continue with targeted revisions
- [ ] Rework core loop before adding content
- [ ] Stop project

### Strongest moment

### Most confusing moment

### First boring or frustrating moment

### Requested improvement

### Tester summary
