# Visual, Skin, and Mobile QA Checklist

## Test record

- Build/commit: Runtime artifact `738732db1f9bf3086d06e2b2d913eb0f559d561c`; Phase 14 baseline/handoff `a3799b5`
- Device/resolution: Host Godot at 320 × 568, 360 × 640, 393 × 873, 480 × 800, and 720 × 1280; partial Motorola Moto G (2025) evidence at 720 × 1604 / 280 dpi
- Android version: Skipped by external tester; unverified
- Tester/date: Codex host audit and user targeted Moto retest; 2026-07-20
- Theme version: Phase 12 token/Theme architecture plus Phase 13 Eras 1–3 code-native skin
- Era/screen scope: Existing Eras 1–3 only; Grid, Build, Upgrades, Reports, request/report/offline/settings modals, brownout, transition

## Direction consistency

- [x] WATT remains the primary focal point. Host captures and Phase 13 evidence.
- [x] Palette and typography match approved tokens. Token/font tests and capture inspection.
- [x] Components share consistent geometry and states. Phase 12/13 component suites.
- [x] Visual humor supports rather than obscures gameplay. Host report/request capture review.
- [x] Era presentation advances the scale while preserving identity. Desk/Room/House evidence.
- [x] No unapproved style from rejected candidates appears. Phase 13 provenance and capture review.

## Mobile layout

- [ ] Safe areas and system bars do not obscure content.
- [ ] UI is comfortably sized, not merely technically readable.
- [x] Minimum touch targets pass. Automated 48-pixel target checks at five layouts.
- [x] No clipped text at supported text sizes. Host default/115%/130% matrix.
- [x] No overlapping panels at narrow/tall ratios. Five-layout host matrix and captures.
- [x] Modals fit without unreachable controls. Shared touch scroll plus authorization/settings coverage.
- [x] Numeric growth does not break layouts. Existing large-number and formatter coverage.

## Core states

- [x] Generation-limited
- [x] Transmission-limited
- [x] Reserve charging
- [x] Reserve discharging
- [x] Brownout and recovery
- [x] Affordable/unaffordable/locked purchase
- [x] Upgrade complete
- [x] Request announcement/running/completed
- [x] Performance grades S through D
- [x] Offline report
- [x] Settings and authorization/report confirmation; purchases are intentionally immediate under `DEC-031`.

## Motion and effects

- [x] Animation communicates state without delaying input. Host state/input tests.
- [x] Brownout effect avoids rapid flashing. Authored dim/broken-path review.
- [x] Reduced-motion substitutions preserve meaning. Automated transition/state checks.
- [ ] Repeated effects do not become tiring.
- [x] Environment animation stays within host performance budget.

## Accessibility

- [x] Critical states do not depend on color alone. Labels, icons, arrows, paths, and text reasons covered.
- [x] Contrast passes the documented target. Preserved exact-token contrast evidence.
- [x] Larger text remains usable. 130% host layout/capture pass.
- [x] Focus order and Android Back behavior remain logical in host automation. Physical Back comfort remains device-only.
- [x] Audio-muted play remains fully understandable. All essential states retain visual/text feedback.
- [x] Haptics can be disabled. Runtime setting and persistence coverage pass.

## Asset quality

- [x] No unintended placeholder art. Intentional provisional layer remains declared under `ISSUE-007`.
- [x] No generated-image text artifacts. Generated concepts are not loaded by runtime.
- [x] Icon stroke/perspective is consistent. Code-native glyph family inspection.
- [x] Images are sharp at intended host sizes. Code/vector/font capture inspection.
- [x] Compression artifacts are acceptable. No new compressed production raster introduced.
- [x] Asset sources/licenses are recorded. Phase 12/13 inventories and provenance.

## Performance

- [ ] Main screen meets FPS target.
- [x] No major skin-related host memory regression. 10,019.4 KiB isolated delta / 294 nodes.
- [x] Scene transitions do not stall in host automation.
- [ ] Device heat/battery observation recorded for representative session.
- [x] APK size change is recorded and justified. Replacement APK 55,939,625 bytes.

## Evidence

Capture representative screenshots for the main screen, Build, report, brownout, each completed era skin, smallest supported layout, and larger-text mode.

## Verdict

- [ ] Approved
- [ ] Approved with targeted revisions
- [ ] Rework required

## Phase 14 baseline note

`./tools/validate.sh` passed the complete repository suite at Phase 14 entry. Host performance measured 1,308.2 ms for 25 full Build rebuilds, 496.0 ms for 500 live refreshes, and 294 UI nodes. The successful targeted Moto scrolling/purchase retest is retained, but the user explicitly skipped the remainder of the Phase 13 playtest. Physical safe areas/comfort, device FPS, repeated-effect comfort, 30-minute heat/battery, screenshots, Android/API, Settings `EFFECTIVE UI`, and lifecycle behavior remain unchecked. No Phase 14 verdict or content-expansion go/no-go is recorded yet.
