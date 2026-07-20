# Phase 14 Host QA Baseline

Date: 2026-07-20

Source state: Phase 13 closed at `a3799b5`; runtime APK source `738732db1f9bf3086d06e2b2d913eb0f559d561c`

Host: Ubuntu 24.04 ARM64 VPS, Godot 4.6.2 GL Compatibility, headless/Xvfb evidence; no attached Android device

## Result

`./tools/validate.sh` passed the complete repository suite and headless launch at Phase 14 entry. No runtime correction was required.

- Main UI: 426 checks
- Phase 12 skin system: 81 checks
- Phase 13 production skin: 51 checks
- Persistence/offline: 81 domain and 14 UI checks
- Balance/reachability: 908 checks
- UI/performance: 111 checks; 25 Build rebuilds 1,308.2 ms, 500 refreshes 496.0 ms, 294 nodes
- Portrait layouts: 320 × 568, 360 × 640, 393 × 873, 480 × 800, and 720 × 1280
- Inherited isolated skin-memory measurement: 10,019.4 KiB
- Clean replacement APK: 55,939,625 bytes; SHA-256 `a26a4521494b2aa6d714abfae1545147e6dbade6ea0df55ea236be10e0e8b8cb`

## Evidence boundary

`docs/VISUAL_QA_CHECKLIST.md` records the host-evidenced passes. Existing Phase 13 captures remain the visual baseline and were already inspected against the locked phone board. The targeted Moto G (2025) retest proves install/cold launch, exact build identity, scrolling across both shared paths, and immediate purchasing.

Physical safe areas and comfort, device FPS, repeated-effect comfort, 30-minute heat/battery, screenshots, Android/API, Settings `EFFECTIVE UI`, and lifecycle behavior remain unverified. `ISSUE-004` therefore remains incomplete under the Phase 14 contract. No Phase 14 verdict or content-expansion go/no-go is recorded.

`ISSUE-007` remains open: this QA baseline does not promote the provisional code-native presentation to final painted-art approval. Era 4 and Phase 15 have not begun.
