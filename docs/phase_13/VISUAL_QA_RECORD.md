# Phase 13 Visual QA Record

Date: 2026-07-20

Host: Ubuntu 24.04 ARM64 VPS, Godot 4.6.2, GL Compatibility, Xvfb/Mesa llvmpipe, dummy audio

Scope: Eras 1–3 production-functional skin, host phone-resolution review

## Evidence inventory

| File | SHA-256 | Reviewed purpose |
| --- | --- | --- |
| `era01_desk_393x420.png` | `e5d4db7977ce811501bd3053148b032fea19972b7014598ca6e0e6ee05a4e0ad` | Innocent Desk, WATT/core, practical props, authored route |
| `era02_room_393x420.png` | `fe899ac8d7c6756eda2462fb80e385d868ad5052c4bd257f792c70ff6c09dada` | Nested Desk-to-Room expansion and ordinary-life remnants |
| `era03_house_393x420.png` | `3aa7450aa698df1c007f1625d6b0d311e2a42425ba8ca6ed083c782c480ffcd3` | House/server-closet scale and representative infrastructure bank |
| `era03_brownout_393x420.png` | `42237e9ec138616e96de085579c656725b78e1d182b7cea7cae124e384bdd9ea` | Broken red path plus cyan concerned WATT and labeled state |
| `main_era01_393x873.png` | `6c5d4812f78a8983cd4e1de460e9218c49c9d970d522276059a903a6dd8444cf` | World-first Main, operator authorization, compact values |
| `main_era02_393x873.png` | `00f143fcde472b9516e80f5c344a8af40e201c4760c50ba0a929d4750daf2e5a` | Full live Room composition and WATT continuity |
| `build_drawer_393x873.png` | `e18b7e675b5da5daec0799ff47a1797789805db360f124601692a38163da3795` | Contextual Build drawer with live world retained |
| `build_drawer_era03_393x873.png` | `12b0851cd81209cb888b5ad8bc61e478dac0121144420903d8bdaa309ffc45b5` | Drawer reuse over House/server-closet world |
| `build_drawer_large_text_393x873.png` | `78e8d4df9c7743522a8ee86d1dabe0bb0c021335a4f45149d2f1f346a21a09bd` | 130% text and dynamic row height |
| `build_drawer_320x568.png` | `404e93974ffad7c9b9ea112441b2ca12ae961e98f84220fa7aaac5eb8ad34576` | Smallest supported portrait, scrolling, compact navigation |
| `operator_report_393x873.png` | `9db1552e2328902f2e2dca408f13d8651bd534525f0a0bf19b1d8703b2949b53` | Screenshot-ready report, payoff, statistics, WATT dialogue |
| `pullback_reboot_393x873.png` | `a10eac8d49d2136e935e52a55c67c4dab07e5cffd68d13b41aa317e52e30362a` | World-preserving era pullback/reboot presentation |

## Review result

- Direction: pass for Phase 13's provisional implementation boundary. WATT is focal, the world dominates routine play, Build/Upgrade remains contextual, and the warm-to-charcoal/cyan takeover grammar is clear across Eras 1–3.
- Layout: automated pass at 320 × 568, 360 × 640, 393 × 873, 480 × 800, and 720 × 1280. Host screenshots confirm scroll-safe small/large-text states.
- States/accessibility: pass in host automation and pixel review. Brownout avoids flashing and red WATT eyes; reduced motion preserves labels/borders; color is not the sole signal.
- Asset quality: no unintended/generated placeholder is present. The schematic code-native layer is intentional and declared. Final painted art remains unresolved under `ISSUE-007`.
- Performance: pass. 294 nodes; 10,016.1 KiB isolated static-memory delta in the inherited skin harness; final Build/refresh measurement 1,342.7/487.4 ms passes.
- APK measurement: 55,939,440 bytes, +16,565 / +0.030% from Phase 12; SHA-256 `c82bb39f8f854a90f6c5368fe93fd10436388e97e6e075ec25bc616943f24458`. Dirty-tree measurement only, not a provenance build.

## Manual limitations and closure disposition

The original host had no attached Android device. Subsequent external testing on a Motorola Moto G (2025), 720 × 1604 / 280 dpi, confirmed install/cold launch and found `ISSUE-009`; replacement build `738732db1f9b` then passed Build/Upgrades/Reports/Settings scrolling and immediate purchasing. The tester explicitly skipped effective-UI, Android/API, physical safe areas/font rendering, full route, audible mix/audio focus, haptics, GPU frame timing, heat, battery, and device screenshots, then accepted Phase 13 closure. These are unverified limitations, not passes. Verdict: **Phase 13 accepted with remaining device evidence explicitly skipped; Phase 14 authorized**.
