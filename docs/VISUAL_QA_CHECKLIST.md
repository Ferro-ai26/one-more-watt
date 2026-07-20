# Visual, Skin, and Mobile QA Checklist

## Test record

- Build/commit:
- Device/resolution:
- Android version:
- Tester/date:
- Theme version:
- Era/screen scope:

## Direction consistency

- [ ] WATT remains the primary focal point.
- [ ] Palette and typography match approved tokens.
- [ ] Components share consistent geometry and states.
- [ ] Visual humor supports rather than obscures gameplay.
- [ ] Era presentation advances the scale while preserving identity.
- [ ] No unapproved style from rejected candidates appears.

## Mobile layout

- [ ] Safe areas and system bars do not obscure content.
- [ ] UI is comfortably sized, not merely technically readable.
- [ ] Minimum touch targets pass.
- [ ] No clipped text at supported text sizes.
- [ ] No overlapping panels at narrow/tall ratios.
- [ ] Modals fit without unreachable controls.
- [ ] Numeric growth does not break layouts.

## Core states

- [ ] Generation-limited
- [ ] Transmission-limited
- [ ] Reserve charging
- [ ] Reserve discharging
- [ ] Brownout and recovery
- [ ] Affordable/unaffordable/locked purchase
- [ ] Upgrade complete
- [ ] Request announcement/running/completed
- [ ] Performance grades S through D
- [ ] Offline report
- [ ] Settings and confirmation

## Motion and effects

- [ ] Animation communicates state without delaying input.
- [ ] Brownout effect avoids rapid flashing.
- [ ] Reduced-motion substitutions preserve meaning.
- [ ] Repeated effects do not become tiring.
- [ ] Environment animation stays within performance budget.

## Accessibility

- [ ] Critical states do not depend on color alone.
- [ ] Contrast passes the documented target.
- [ ] Larger text remains usable.
- [ ] Focus order and Android Back behavior remain logical.
- [ ] Audio-muted play remains fully understandable.
- [ ] Haptics can be disabled.

## Asset quality

- [ ] No unintended placeholder art.
- [ ] No generated-image text artifacts.
- [ ] Icon stroke/perspective is consistent.
- [ ] Images are sharp at intended size.
- [ ] Compression artifacts are acceptable.
- [ ] Asset sources/licenses are recorded.

## Performance

- [ ] Main screen meets FPS target.
- [ ] No major skin-related memory regression.
- [ ] Scene transitions do not stall visibly.
- [ ] Device heat/battery observation recorded for representative session.
- [ ] APK size change is recorded and justified.

## Evidence

Capture representative screenshots for the main screen, Build, report, brownout, each completed era skin, smallest supported layout, and larger-text mode.

## Verdict

- [ ] Approved
- [ ] Approved with targeted revisions
- [ ] Rework required
