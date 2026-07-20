# Phase 24 — Release-Candidate Stabilization

## Objective

Create a feature- and content-frozen release candidate and eliminate defects that prevent safe external closed testing.

## Included

- Release branch/tag strategy
- Full automated suite from clean checkout
- Fresh install and upgrade install
- Save migrations, backup recovery, offline and prestige stress
- Multi-device layout/lifecycle/performance testing
- Long-session and background/process-death testing
- Crash/log review
- Accessibility regression
- Defect triage and targeted fixes
- Reproducible signed candidate build process without exposing secrets

## Change policy

Only defect fixes, required compatibility work, disclosure corrections, and narrowly approved presentation corrections enter the release candidate. New features return to a future release roadmap.

## Acceptance criteria

- [ ] Candidate builds reproducibly from recorded commit
- [ ] Fresh and upgrade installs pass
- [ ] Supported save migrations pass
- [ ] No blocker/critical defect
- [ ] Major defects fixed or explicitly accepted
- [ ] Device/performance/accessibility matrix reaches approved coverage
- [ ] Release candidate artifact, checksum, symbols, and notes recorded
- [ ] Closed-test readiness decision recorded

## Stop condition

Do not publish to production. Proceed only to closed testing after explicit authorization.
