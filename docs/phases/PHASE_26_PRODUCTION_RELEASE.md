# Phase 26 — Production Release

## Objective

Release the explicitly approved build through Google Play using the reviewed store package and a controlled rollout.

## Authorization boundary

Preparing evidence, validating artifacts, and drafting release actions are allowed within the phase. Uploading, submitting for review, changing production rollout, or publishing requires explicit user authorization at the relevant external-action boundary.

## Included

- Final production checklist review
- Artifact/commit/checksum identity confirmation
- Store listing and disclosure confirmation
- Controlled rollout plan
- Explicit approval capture
- Submission and status recording when authorized
- Post-release monitoring and support handoff
- Hotfix threshold and rollback actions

## Acceptance criteria

- [ ] Every gate in `RELEASE_READINESS_DEFINITION.md` passes
- [ ] Exact AAB and store package are approved by the user
- [ ] Production action is explicitly authorized
- [ ] Submission/rollout status is recorded truthfully
- [ ] Monitoring/support owner and response plan are active
- [ ] Version tag, release notes, and durable evidence are preserved

## Stop condition

Do not expand rollout or publish an update without the corresponding explicit authorization. Future features begin a new version roadmap.
