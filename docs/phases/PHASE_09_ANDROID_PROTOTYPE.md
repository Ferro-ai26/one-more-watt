# Phase 09 — Android Prototype

## Objective

Produce and verify an installable Android prototype from a recorded source commit.

## Player-facing result

The Eras 1–3 vertical slice installs, launches, plays, saves, backgrounds, resumes, and calculates offline progress on a physical Android device.

## Required reading

`ANDROID_RELEASE_SPEC.md`, `SAVE_AND_OFFLINE_SPEC.md`, `PROJECT_SETUP_CHECKLIST.md`, and `PLAYTEST_CHECKLIST.md`.

## Included

- Android export configuration
- Debug APK from a known commit
- Touch/safe-area/device lifecycle fixes
- Physical-device install and smoke test
- Performance notes
- Export/build documentation
- Prototype distribution instructions when requested
- Final prototype go/no-go checkpoint

## Excluded

Play Store production rollout, release AAB signing unless explicitly requested, monetization, analytics, Era 4, and unsupported claims about untested hardware.

## Implementation requirements

- Record every toolchain version and export command.
- Keep signing secrets outside version control.
- If the VPS architecture cannot execute part of the Android toolchain, prepare a reproducible x86_64/PC handoff and state the blocker accurately.
- An APK's existence is not device verification.
- Build version/commit is visible in diagnostics.
- Device test uses a fresh install and a saved-progress resume case.

## Automated verification

- Full tests and content validation
- Clean export from documented command/environment
- APK signature/package inspection where tools allow
- Artifact checksum

## Physical-device playtest

- Install and cold launch
- Complete early onboarding
- Purchase from Build and Upgrades
- Trigger and recover from a brownout
- Background during an active request
- Resume and inspect offline report
- Force-close and reopen
- Verify sound, haptics, safe areas, back behavior, and readable text
- Record performance and battery/heat observations during a representative session

## Acceptance criteria

- [ ] APK tied to a recorded commit and checksum
- [ ] Installs and launches on physical Android hardware
- [ ] Core loop works through the agreed endpoint
- [ ] Save survives force-close/relaunch
- [ ] Background/resume produces correct offline report
- [ ] No screen obstruction or unusable touch target on test device
- [ ] No blocker/critical issue
- [ ] Device evidence and setup instructions recorded
- [ ] Decision recorded: revise prototype, expand to Era 6, or stop

## Stop condition

Do not begin Phase 10 automatically. Expansion requires explicit user authorization after reviewing the Android prototype.

