# Phase 16 — Release Preparation

## Objective

Prepare the approved product scope for a truthful, stable Google Play release.

## Scope decision required

Before this phase begins, explicitly record which eras and features belong in version 1.0. Releasing a polished subset is preferable to shipping unfinished late-game content.

## Included

- Feature freeze and release scope
- Critical/major defect resolution
- Save migration from all external test versions
- Device/performance/accessibility coverage
- Production art/audio/license review
- Tutorial and balance regression
- Signed AAB pipeline
- Store listing text and assets
- Privacy/data-safety/content-rating disclosures matching actual behavior
- Internal/closed testing rollout plan
- Crash and support process if approved
- Versioning, release notes, and rollback plan

## Excluded

Unplanned major mechanics, last-minute live services, copied store claims, permissions without player value, and secret material in source control.

## Verification

- Clean clone/build from release commit
- Full content and automated test suite
- Upgrade installation over prior external-test build
- New installation
- Save migration and recovery
- Long offline return
- Low-memory resume/process recreation
- Store-device compatibility checks
- License manifest review
- Final manual playthrough of shipped scope

## Acceptance criteria

- [ ] Version 1.0 scope is frozen and documented
- [ ] Signed AAB is reproducible from protected release process
- [ ] No blocker/critical issue; major issues are fixed or explicitly accepted
- [ ] Store disclosures match implemented data behavior
- [ ] All shipped assets have documented rights
- [ ] Upgrade and fresh-install paths pass
- [ ] Release artifact is tied to a tagged commit and checksum
- [ ] Rollback/support plan exists

## Stop condition

Publishing to production requires explicit user authorization after reviewing the release candidate and store listing.

