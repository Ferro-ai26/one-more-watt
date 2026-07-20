# Current Handoff

Updated: 2026-07-20
Active phase: Phase 09 — Android Prototype
Final decision: Continue with targeted revisions

## Current state

Phase 09 is closed with partial physical-device evidence and the decision “continue with targeted revisions.” The recorded Android APK passed all host build/static checks and Kevin confirmed install, cold launch, build identity, readable/authorizable onboarding, and working Build/Upgrade touch purchases on a Moto phone. The remaining device questionnaire was skipped at the tester's request and is not claimed as passing. No blocker or critical defect was reported. The existing Phase 10 was not started because the roadmap/document pack is being revised.

## Completed

- Approved and recorded permanent package `com.ferroai.onemorewatt`.
- Built and statically verified a debug APK from `e165b2b7ace78a848b1eed4431f919804a8b8e6f`.
- Recorded SHA-256 `8402cde8c980c6f226dc7ac88df977692ba0822bd332d1e246055afd66c1785a` for the 55,797,809-byte artifact.
- Verified API 24/35, arm64-v8a/x86_64, portrait manifest, only `VIBRATE`, v2/v3 signature, ZIP alignment, embedded build ID, and launcher icon.
- Added version/build diagnostics, Android Back handling, pause/resume audio behavior, reproducible export checks, and device handoff tooling.
- Passed the complete host regression suite after final export changes.
- Recorded Kevin's manual Moto report exactly, including all skipped fields/checks.
- Logged `ISSUE-004`: presentation appeared too small; tester requested a future 720p/scale revision.
- Recorded the accepted Phase 09 decision in `DEC-020`.

## Tests

- `./tools/validate.sh` — passed: 55 foundation, 24 Android config, all content/simulation/economy/UI/persistence suites, 908 balance/reachability, 111 UI/performance, four portrait layouts, all diagnostic panels, and headless smoke launch.
- Host performance: 25 Build rebuilds in 985.1 ms, 500 live refreshes in 955.6 ms, 217 nodes.
- `./tools/build_android_debug.sh` — passed from clean source commit `e165b2b`.
- APK package/version/API/permission/architecture/signature/alignment/build-ID checks — passed.
- Physical Moto phone: install/cold launch, version/build display, onboarding authorization, Build purchases, and Upgrade purchases passed.

## Manual verification limitations

- Exact Moto model, Android/API, display/cutout/navigation details, test date, and launch timings were skipped or not provided.
- Brownout/recovery, Android Back, background/resume, offline report, force-close recovery, reward idempotency, audio/haptics, full safe-area review, Eras 1–3 endpoint, device FPS/memory, 30-minute battery/heat, and two-hour offline return were skipped.
- Additional small bugs were mentioned without details; none were inferred or fabricated.

## Known issues

- `ISSUE-004` (Minor): phone presentation appeared too small; target a future 720p/scale revision.
- No blocker or critical issue was reported in the executed checks.

## Next action

Stop. Do not begin the existing Phase 10. Carry `ISSUE-004` and the explicitly unverified device checks into the revised roadmap/document pack before any broader external-release claim.

## Files changed

- Android/runtime: `export_presets.cfg`, `project.godot`, launcher icon, Android Back/lifecycle presentation handling
- Tests/tools: Android config validation, build provenance/static inspection, device smoke handoff
- Documentation: Android build record, interactive device report, decision log, known issues, playtest evidence, progress, active phase, and this handoff
