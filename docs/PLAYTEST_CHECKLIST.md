# Playtest Checklist

Record build identifier, device/platform, tester, date, and notes for every formal pass.

## Phase 01 content-shell verification — 2026-07-19

- Build/commit: Uncommitted Phase 01 working tree based on `d48e01d`
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
