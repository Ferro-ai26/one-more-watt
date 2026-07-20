# Performance and Visual Evidence

Date: 2026-07-20
Host: Ubuntu 24.04 ARM64 VPS, Godot 4.6.2, GL Compatibility; graphical captures through Xvfb/Mesa llvmpipe with dummy audio.

## Measured cost

| Metric | Prior recorded baseline | Phase 12 measurement | Result |
| --- | ---: | ---: | --- |
| Debug APK | 55,802,078 bytes (Phase 10) | 55,922,875 bytes | +120,797 bytes / +0.216%; acceptable |
| Worst live UI nodes | 217 (Phase 8 endpoint) | 219 (clean Phase 12 sample) | +2 nodes; remains below 500 budget |
| Static-memory delta for instantiated 393 × 873 live sample | No directly comparable Phase 10 reading | 9,493.6 KiB headless; 10,648.5 KiB graphical | Below the explicit 32 MiB Phase 12 guard |
| Declared Desk environment budget | N/A | 28 KiB code/data estimate | No production texture loaded |
| Packaged font source bytes | 0 | 168,512 bytes | Two variable fonts under OFL 1.1 |

The APK was a direct dirty-tree measurement export to `/tmp`, not a clean provenance build, published artifact, device test, or release candidate. Final measurement SHA-256: `2baf7cdee1a04a0f3467ef0068d0fb879b8a9734e8276424348d70ac171938de`.

The complete existing performance suite remains authoritative for refresh/rebuild budgets. Phase 12 adds an isolated skin guard for memory and node count without loosening those thresholds.

The first final full-suite attempt measured 1,064.5 ms for 500 live refreshes and failed the unchanged 1,000 ms host guard; no error was suppressed and no threshold changed. The complete retry passed at 1,304.8 ms for 25 Build rebuilds, 972.4 ms for 500 live refreshes, and 219 nodes. This matches the previously documented VPS timing variance and remains below both established budgets on the accepted run.

## Visual baselines

| Baseline | SHA-256 | Review result |
| --- | --- | --- |
| `phase12_main_grid_393x873.png` | `33d09849f80c73fb2038262f4ed40b5aaaa9c93a24a86cf28a16b0c8e1572897` | Environment dominates; warm workshop/cyan spread, scratched WATT core, operator handshake, request and metrics readable |
| `phase12_build_393x873.png` | `fee67beec2e7f89ddd43a5c27581cd4e5918a01bebdd2dbe2bcd6ed006604004` | Environment persists above compact request plate; first stateful Build card and navigation remain visible |

The first compact Build capture exposed retained pixels from the prior Grid layout because the regression `SubViewport` did not explicitly clear between size changes. The environment boundary was clipped defensively, the capture viewport was changed to clear every frame, and both final images were regenerated and visually re-inspected. They are architecture baselines, not final production-art approval.

## Manual host verification

- Compared the live Main Grid and Build captures with the locked Phase 11 phone-board hierarchy.
- Verified WATT remains recognizable and charming, human authorization remains explicit, and the environment—not a dashboard—is the largest routine region.
- Verified the code-native fallback contains no generated Phase 11 concept raster or baked UI text.
- Verified Build retains the live environment, first card, state label, predicted effect, button, and four-tab navigation without overlap after the capture-clear correction.
- No physical Android device, touch comfort, GPU frame timing, heat/battery, or audible mix check occurred; Phase 14 retains that authority.
