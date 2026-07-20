# Phase 14 — Visual, Mobile, and Accessibility QA

Status: Closed — Approved with User-Accepted Device-QA Limitations (2026-07-20)

## Objective

Independently verify and correct the production-skinned prototype across devices, aspect ratios, system states, accessibility settings, and longer sessions.

## Player-facing result

The skinned Eras 1–3 build is visually consistent, comfortably sized, responsive, accessible, and performant on representative Android hardware.

## Required reading

`VISUAL_QA_CHECKLIST.md`, `ANDROID_RELEASE_SPEC.md`, `RELEASE_READINESS_DEFINITION.md`, and all Phase 13 evidence.

## Included

- Screenshot/state audit of every core screen
- At least one physical Android device; more when available
- Narrow, tall, 720p-reference, and larger-text layouts
- Safe-area/navigation-mode review
- Touch and Android Back review
- Reduced-motion and color-independent state review
- Visual regression fixes
- Skin-related performance, memory, APK size, battery, and heat observations
- 30-minute representative session
- Save/background/offline regression on the skinned build
- Deferred `ISSUE-004` Moto-phone retest: record exact model/API/display density, Settings `DISPLAY` and `EFFECTIVE UI` values, screenshot evidence, and a physical-comfort verdict when the original device is available

## Excluded

- Era 4
- Major visual-direction changes without returning to Phase 11 decision process
- New gameplay features
- Store publication

## Acceptance criteria

- [ ] `VISUAL_QA_CHECKLIST.md` completed with evidence
- [ ] ISSUE-004 is verified fixed on the Moto phone, or original-device unavailability and a user-approved representative-device disposition are recorded with rationale
- [ ] All frequent controls are comfortably sized
- [x] No clipping/overlap at supported layouts and text sizes
- [x] Critical states do not depend on color alone
- [x] Reduced motion preserves meaning
- [ ] Main screen meets performance target on tested hardware
- [x] Save/offline behavior remains reliable in host regression; physical lifecycle remained skipped
- [x] No blocker/critical visual or functional issue remains in available evidence
- [x] User records go/no-go for content expansion — **GO: Phase 15 authorized**

Closure disposition: the user explicitly authorized Phase 15 after being told that device-only Phase 14 evidence remained open. The host baseline and targeted Moto scrolling/purchase retest are accepted as sufficient to continue content expansion, while the first three unchecked items and device FPS/heat/battery/lifecycle evidence remain limitations rather than passes. `ISSUE-004` is deferred for a later device/release QA gate; `ISSUE-007` remains open. This exception does not authorize Phase 16.

## Stop condition

Do not begin Era 4 without explicit expansion authorization.
