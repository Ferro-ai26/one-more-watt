# Playtest Checklist

Record build identifier, device/platform, tester, date, and notes for every formal pass.

## Phase 09 Android host preflight — 2026-07-20

- Build/commit: `e165b2b7ace78a848b1eed4431f919804a8b8e6f`
- Platform/device: Ubuntu 24.04 ARM64 VPS; no Android device attached
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Android Platform 35, build-tools 35.0.1, platform-tools 37.0.0, matching export templates, and a local debug keystore are present.
- [x] App version and build identifier are visible in Settings and the diagnostic summary at all four portrait test sizes.
- [x] Android Back notification closes the top modal; the shared handler then returns secondary screens to Grid before root exit.
- [x] Application pause saves through the existing lifecycle controller and stops feedback audio; resume applies the existing bounded offline path and restores playback eligibility.
- [x] Clean-tree export tooling is prepared to inject the exact commit, verify APK package/signature metadata, and write a SHA-256 manifest.
- [x] Approved permanent package identifier `com.ferroai.onemorewatt` recorded and export preset validated with 21 checks.
- [x] Initial export configuration failure (partial debug-keystore fields) was corrected without producing or mis-signing an artifact; signing configuration remains outside version control.
- [x] A second export exposed the approved package/API/architectures/permission/signature correctly, then was rejected because of a missing project icon and incompatible host inspection binaries; both acceptance-path defects were corrected before recording a final artifact.
- [x] Debug APK exported and inspected: 55,797,809 bytes; SHA-256 `8402cde8c980c6f226dc7ac88df977692ba0822bd332d1e246055afd66c1785a`.
- [x] Package/version/API 24–35, arm64-v8a/x86_64 payloads, `VIBRATE`-only permission, v2/v3 signature, ZIP alignment, portrait manifest, embedded build ID, and launcher icon verified.
- [x] Complete repository regression passed after the final icon/export changes: 55 foundation, 24 Android configuration, all prior domain/integration suites, 111 performance checks at 985.1/955.6 ms, and headless smoke launch.
- [ ] APK installed and launched on physical Android hardware.
- [ ] Early onboarding, Build, Upgrades, brownout/recovery, background/resume, force-close/reopen, sound, haptics, safe areas, Back, readable text, performance, battery, and heat verified on device.

Notes: ADB reported no connected devices; `adb install -r` failed with `no devices/emulators found`, as expected. The ARM64 VPS has no emulator binary or KVM device. Available ARM64 system-image listings do not replace an executable, accelerated runtime, so this preflight is not represented as Android runtime or physical-device evidence. Phase 09 is NO-GO for completion/advancement until `docs/ANDROID_DEVICE_TEST.md` is completed on hardware.

## Phase 08 balance and prototype-polish rounds — 2026-07-20

- Build/commit: `2cffcd1`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- External tester: Unavailable. No unfamiliar-player result is claimed; the required fallback is a documented structured self-test.

### Round 1 — Developer clean-save baseline

- Reproduced the Phase 07 no-debug route: 46.8 mechanical minutes, Era 2 at 4.6, Era 3 at 22.8, 31.5 idle minutes, and a 660-second Reinforced Wiring gap.
- Earliest pacing defect: era arrivals were much earlier than their documented windows. First frustration: the single 11-minute late affordability wait.
- Core comprehension, reachability, save boundaries, and WATT tone remained sound, so the revision target stayed balance/presentation rather than core-loop rework.

### Round 2 — Structured unfamiliar-player substitute

- Used only ordinary request, purchase, allocation, transition, report, idle-generation, and save commands with no currency/ownership injection.
- Applied a conservative interaction cadence of 40 seconds per request review/report, 10 seconds per purchase, and 15 seconds per era transition. The tuned 65.8-minute mechanical route therefore measures 79.8 structured minutes.
- Milestones: first request 25 seconds; first funded purchase before 60 seconds; Era 2 at 11.7 minutes; Era 3 at 37.0 minutes; endpoint at 65.8 mechanical/79.8 structured minutes.
- The first five minutes contain continuously changing request progress, reports, and purchasing with zero unexplained idle wait over 30 seconds.

### Round 3 — Earliest-confusion revision

- Increased authored request work so time is visible in WATT progress rather than an inert currency gate; reduced Portable Generator to 425 Stored Energy and Reinforced Wiring to 41,000.
- Added exact next-action forecast copy, approximate affordability time, Reserve direction text/arrows, automatic online idle generation, era-specific brownout callbacks, local focal feedback, and seven short procedural sound cues.
- The first 320 × 568 graphical pass exposed two UI defects: authorization required an initial scroll and secondary screens had almost no content area. Authorization now precedes supporting advice, and secondary tabs use a compact WATT header that reveals the first card while keeping the character visible.

### Round 4 — Regression clean-save pass

- [x] Two clean deterministic paths produced the same 65.8-minute mechanical route, 79.8-minute structured cadence, request milestones, 21 earned purchases, 18.5 idle minutes, 1,143.2 recoverable brownout seconds, ownership, currency, and endpoint.
- [x] The longest gaps are exactly 300 seconds for Portable Generator and Reinforced Wiring; every other recorded gap is 220 seconds or less.
- [x] Prepared-route Era 3 requests take 302.25, 288.25, 246.0, and 344.25 seconds, all within the 3–6 minute target.
- [x] Frame-size independence, content/localization validation, old-save compatibility, and both era-boundary save/load checks pass.
- [x] All core screens fit 320 × 568 through 480 × 800; authorization is initially visible, the first Build card is visible, 48-pixel targets remain, and reduced motion retains semantic feedback.
- [x] Cold Boot, both transitions, endpoint, 320-pixel authorization, Build, brownout, and accessibility/settings captures were visually inspected after the revision.
- [x] Worst endpoint state stays under the available-host budgets: graphical run measured 25 full Build rebuilds at 921.1 ms, 500 live refreshes at 904.0 ms, and 217 UI nodes.
- [ ] Audible mix listened to on speakers/headphones (host exposes only dummy audio; cue generation, bus routing, variants, cooldowns, and settings integration are tested).
- [ ] A player unfamiliar with the design completed the run (outside tester unavailable; structured fallback above is not represented as external evidence).
- [ ] Physical Android touch, safe-area, lifecycle, haptic, audio, storage, performance, and clock behavior verified (Phase 09 prerequisites remain unavailable).

Strongest moment: the absurd escalation remains legible because WATT stays visible while the grid grows, and the Home Server Closet requests now have enough time for their jokes and systems to register.

Most confusing moment: the first 320-pixel authorization and Build layouts buried their primary actions. Both were corrected during Round 3 and verified in Round 4.

First boring or frustrating moment: the Phase 07 660-second Reinforced Wiring wait. The tuned route caps it at 300 seconds with ongoing offline capability already taught.

Requested improvement: obtain one unfamiliar human timing/comprehension pass and an audible/device mix pass as soon as suitable testers and hardware are available.

Prototype verdict: GO recommended for Phase 09 Android verification, conditional on explicit user authorization and resolution of `ISSUE-001`. Do not expand content or begin Android work automatically.

## Phase 07 clean Eras 1–3 playthrough — 2026-07-20

- Build/commit: `abbf967`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- Method: Controlled accelerated clean-state playthrough using only normal request, idle-generation, purchase, report, transition, and save commands; no debug currency or ownership injection. A matching graphical run exercised the production UI at 393 × 873.
- [x] WATT, `Finish Booting`, the review/authorize action, Generation/Transmission/Reserve, and the non-punitive tutorial were legible in the initial capture; WATT's role was clear immediately.
- [x] `Finish Booting` completed at 15 seconds. Six required Cold Boot requests and visible desk purchases completed before Era 2 at 4.6 simulated minutes, satisfying the multiple-request first-five-minute check.
- [x] Era 2 unlocked at 4.6 minutes and Era 3 at 22.8 minutes; each pending transition survived a complete checksummed save/load before acknowledgement.
- [x] The Home Server Closet endpoint was reached at 46.8 optimized simulated minutes and survived save/load. It visibly says `ERAS 1–3 COMPLETE • MORE COMING` without naming or fabricating Era 4.
- [x] Purchases were earned in order: two additional Wall Outlets; Questionable Power Strip; Laptop Battery; Tiny Desk Fan; Extension Cord; Upgraded Breaker; Portable Generator; Rooftop Solar Panel; Home Battery; Second Questionable Power Strip; Generator Coordination; Gaming GPU; Dedicated Circuit Research; Server Rack; Whole-Home Battery; Reinforced Wiring; Backup Generator; Smart Meter; Dedicated Cooling; and Outdoor Transformer.
- [x] The run accumulated 408.5 brownout seconds without losing progress. Generation, Transmission, and Reserve upgrades were all required by forecasts/gates or observed service pressure, and at least one Stability report cleared the 85% Era 3 gate.
- [x] Allocation, automatic/offline progress, Reserve forecast, detailed forecast, and low-Reserve protection unlocked before use; an optional vanity request was selected and skipped, then the required path resumed.
- [x] Total idle earning was 31.5 minutes. The longest continuous gap was 660 seconds before an Era 3 purchase; offline progress was already unlocked, but this is still recorded as `ISSUE-002` for Phase 08 tuning.
- [x] All 18 announcement/completion pairs and tutorial strings passed localization/content review. No request line repeated in the one-pass route; brownout dialogue retained its 60-second cooldown and unseen-first selection tests.
- [x] Cold Boot, Bedroom Assistant, Home Server Closet, and prototype-complete captures were inspected. Text, controls, transitions, and scrolling remained accessible; an initially truncated endpoint line/stale forecast was corrected and recaptured.
- [ ] A measured human first run meets the 75–120 minute target (`ISSUE-002`; optimized harness is 46.8 minutes).
- [ ] Physical Android touch, lifecycle, safe-area, haptic, audio, storage, and clock behavior verified (device/export unavailable).

Confusion/pacing notes: The system path was coherent and every gate exposed an actionable requirement. The only material concern was the uneven pacing combination of a short optimized total and one long late purchase gap. No repeated-dialogue fatigue was observed.

Prototype verdict: Continue with targeted Phase 08 pacing revisions; do not rework the core loop.

## Phase 06 save/offline verification — 2026-07-20

- Build/commit: `143ccf9`
- Platform/device: Ubuntu 24.04 ARM64 VPS, Xvfb with Mesa llvmpipe and dummy audio
- Godot version: 4.6.2.stable.official.71f334935
- Tester: Codex
- [x] Started `Finish Booting`, advanced two seconds, invoked the background save trigger at controlled UTC 10002, and resumed at UTC 10012.
- [x] Offline Return visibly disclosed 10.0 seconds away/recognized, 80% efficiency, 8.0 effective seconds, the 120-minute cap, zero Stored Energy, zero brownout, and request progress from 13.3% to 66.7%.
- [x] Repeated the boundary across request completion; the report showed 66.7% to 100%, one completed stable request ID, and exactly +12 Stored Energy.
- [x] Reloaded the completed-before-report state and verified the completion reward could not be granted twice.
- [x] Deliberately replaced isolated `save_main.json` with invalid text while retaining Backup 1, then bootstrapped recovery.
- [x] Recovery preserved the corrupt main as timestamped diagnostic evidence, restored `save_backup_1.json`, reapplied the controlled offline interval, and named the restored backup in the UI.
- [x] Both 393 × 873 captures were inspected without clipping, overlap, inaccessible controls, or accusatory clock/recovery language.
- [x] The isolated recovery directory and test saves were removed after verification; actual user save files were not modified by the exercise.
- [ ] Physical Android suspension, process death, storage, and device-clock behavior verified (device/export unavailable).

Notes: The graphical harness controls timestamps rather than waiting in real time. Xvfb cannot control V-Sync; headless project validation is warning-free.

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
