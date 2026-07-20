# Playtest Checklist

Record build identifier, device/platform, tester, date, and notes for every formal pass.

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
