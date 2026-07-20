# Phase 25 — Closed Testing and Store Preparation

## Objective

Collect external evidence across devices and complete an accurate Google Play submission package without publishing to production.

## Included

- Closed-test build and tester instructions
- Multiple tester/device coverage
- Feedback intake, deduplication, severity, and disposition
- Onboarding and pacing observations
- Crash/device compatibility review
- Store title, descriptions, icon, feature graphic, screenshots, and release notes
- Privacy policy/data-safety/content-rating/permission disclosures matching actual behavior
- Support contact and license notices
- Final AAB inspection and versioning
- Rollback/hotfix plan

## Evidence

Record tester/device matrix, install path, playtime/era reached, observed defects, lifecycle/offline results, comfort/readability, performance/heat, and whether the player wanted to continue.

## Acceptance criteria

- [ ] Closed test reaches approved tester/device minimum
- [ ] Feedback is triaged and dispositioned
- [ ] No unresolved blocker/critical defect
- [ ] Store assets accurately show the real game
- [ ] Disclosures match implementation and permissions
- [ ] Production candidate AAB is signed, inspected, checksummed, and tied to a commit
- [ ] Support and rollback plan exists
- [ ] Production go/no-go package is ready for user review

## Stop condition

Do not publish. Production release requires explicit user authorization in Phase 26.
