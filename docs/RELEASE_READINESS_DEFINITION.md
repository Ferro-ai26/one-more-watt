# Release Readiness Definition

## Purpose

Release readiness is a chain of evidence, not the existence of a working APK or the completion of the last content era.

For base game v1.0, the approved content scope is Eras 1–6. City Data Center is the final base-v1 content era and must include the active-to-idle transition plus the first complete Model Retraining/Prestige loop. Eras 7–16 are preserved post-launch expansion scope and are not prerequisites for base-v1 release readiness.

## Gates

### Scope lock

- Version 1.0 era/content scope explicitly approved as Eras 1–6 under `DEC-040`
- City idle transition and first complete Model Retraining/Prestige loop included
- Eras 7–16 identified as deferred post-launch expansion-sized updates
- Gameplay Gate G01 records an explicit proceed decision before Phase 17 implementation begins
- No unresolved major design dependency
- Deferred features documented

### Content complete

- All required Eras 1–6 requests, upgrades, infrastructure, WATT dialogue, tutorials, achievements, reports, City idle behavior, and first Prestige content present
- Base-v1 fresh-run and first-Prestige reachability validated
- No placeholder release content

### Presentation complete

- Approved production skin applied to all release-scope screens and eras
- Art, animation, audio, haptics, accessibility, and transitions verified
- Asset licenses/inventory complete

### Technical stabilization

- Save migrations and recovery pass
- Offline progress and reward idempotency pass
- Performance and memory targets pass on representative devices
- No blocker or critical defect
- Major defects fixed or explicitly accepted with rationale

### External testing

- Closed test includes multiple devices and testers
- G01 fresh-player first-30/60-minute evidence and the later full Android QA matrix are complete
- Onboarding, retention/pacing, device compatibility, City idle returns, first Prestige, and store installation are evaluated
- Feedback is triaged and resolved or deferred explicitly

### Store readiness

- Signed reproducible AAB
- Version/tag/checksum recorded
- Listing, screenshots, icon, feature graphic, descriptions, support contact, privacy/data-safety, content rating, and licenses complete
- Disclosures match actual app behavior

### Publisher authorization

Production publication is an explicit user decision. Codex may prepare and verify the release candidate but may not publish automatically.
