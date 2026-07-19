# Phase 08 — Balance and Prototype Polish

## Objective

Turn the mechanically complete vertical slice into a clear, funny, attractive, and appropriately paced external playtest build.

## Player-facing result

The first 75–120 minutes feel intentional: frequent early rewards, understandable bottlenecks, earned automation, strong WATT characterization, and no unexplained dead time.

## Required reading

`PROGRESSION_AND_BALANCE.md`, `WATT_CHARACTER_BIBLE.md`, `UI_UX_SPEC.md`, `ART_AND_AUDIO_DIRECTION.md`, and all recorded playtest evidence.

## Included

- Balance simulation and human playtest tuning
- Request ordering and duration tuning
- Infrastructure cost/output tuning
- Clearer forecasts and recommendations
- Dialogue trimming, variety, and callback improvement
- Placeholder-art consistency and key feedback animation
- Essential sound effects and mix
- Accessibility pass
- Performance optimization within prototype budgets
- Defect fixing

## Excluded

New eras, new core currencies, prestige implementation, monetization, extensive production asset replacement, and speculative content expansion.

## Implementation requirements

- Change one balance hypothesis at a time when practical.
- Record material formula or pacing decisions.
- Preserve automated reachability.
- Fix first-run comprehension before adding explanatory text walls.
- Prioritize WATT/request feedback over decorative background work.
- Measure and record actual milestone times.

## Playtest rounds

1. Developer clean-save pass
2. At least one player unfamiliar with the design
3. Revision pass addressing the earliest confusion/frustration
4. Regression clean-save pass

If outside testers are unavailable, document the limitation and run structured self-tests; do not claim external validation.

## Automated tests

- Full existing suite
- Balance/reachability simulation
- Frame/time-independent request results
- Content and localization validation
- Performance smoke on worst representative content state

## Acceptance criteria

- [ ] First request completes in target range
- [ ] Era arrival times are reasonably near documented targets or decisions explain changes
- [ ] No early unexplained wait over 30 seconds
- [ ] New systems are taught before penalizing progress
- [ ] Repetition controls prevent obvious dialogue spam
- [ ] Core screens pass small-device accessibility review
- [ ] Performance budgets pass in available environment
- [ ] No blocker/critical issue and major issues have explicit disposition
- [ ] Go/no-go recommendation recorded

## Stop condition

Do not begin Android export work until a go decision for the prototype is recorded.

