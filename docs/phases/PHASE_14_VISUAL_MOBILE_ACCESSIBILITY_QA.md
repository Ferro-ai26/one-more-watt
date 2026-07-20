# Phase 14 — Visual, Mobile, and Accessibility QA

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

## Excluded

- Era 4
- Major visual-direction changes without returning to Phase 11 decision process
- New gameplay features
- Store publication

## Acceptance criteria

- [ ] `VISUAL_QA_CHECKLIST.md` completed with evidence
- [ ] ISSUE-004 is verified fixed or explicitly accepted with rationale
- [ ] All frequent controls are comfortably sized
- [ ] No clipping/overlap at supported layouts and text sizes
- [ ] Critical states do not depend on color alone
- [ ] Reduced motion preserves meaning
- [ ] Main screen meets performance target on tested hardware
- [ ] Save/offline/lifecycle behavior remains reliable
- [ ] No blocker/critical visual or functional issue remains
- [ ] User records go/no-go for content expansion

## Stop condition

Do not begin Era 4 without explicit expansion authorization.
