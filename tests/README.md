# Test entry points

Run all repository validation from the repository root:

```bash
./tools/validate.sh
```

After the approved Android package identifier and export preset are committed, build the provenance-checked current Phase 16 debug APK with:

```bash
./tools/build_android_debug.sh
```

The full validation entry point also checks the permanent package name, version, architectures, permissions, debug-only signing boundary, and APK resource exclusions in `export_presets.cfg`.

When a physical Android device is attached, run `./tools/android_device_smoke.sh` for the non-destructive install/launch/memory preflight, then complete `docs/ANDROID_DEVICE_TEST.md` manually.

Gameplay Gate G01's temporary debug recorder and isolated playtest profile run with:

```bash
./tools/test_g01.sh
```

After committing the G01 checkpoint, export the separately flagged local-evidence APK with `./tools/build_g01_android_debug.sh`. The normal `Android Debug` preset and onboarding remain unchanged.

Set `GODOT_BIN` when the executable is not named `godot`. The command imports and parses the project, validates the foundation and content configuration, runs valid and invalid content fixtures, exercises the shell at 320 × 568, 360 × 640, 393 × 873, 480 × 800, and the 720 × 1280 reference, and launches the main scene in smoke-test mode.

Run only deterministic content validation with:

```bash
./tools/validate_content.sh
```

Run the standalone grid equation and invariant suite with:

```bash
./tools/test_simulation.sh
```

Run the request lifecycle, WATT dialogue, incident, reward, unlock, and report suite with:

```bash
./tools/test_requests.sh
```

The repository-level validation entry point also exercises all diagnostic panels and the full request lifecycle at portrait size.

Run exact cost, purchasing, milestone, upgrade, rebuild, unlock, and Reserve automation checks with:

```bash
./tools/test_economy.sh
```

The repository-level entry point exercises the grid, request, and economy diagnostic surfaces while keeping them independent of the finished Phase 05 UI.

Run centralized number formatting, runtime accessibility state, navigation/back-stack, shared online-session, view-model parity, and full main-interface checks with:

```bash
./tools/test_ui.sh
```

The main-interface integration suite drives request authorization through report, online idle generation, the early allocation feature gate, a brownout, infrastructure purchasing, compact secondary headers, all four tabs, settings, audio feedback, density-scaling calculations, maximum text size with reduced motion, and modal back behavior at all five portrait sizes.

Run the Phase 13 Desk/Room/House environment, WATT expression, state/effect, contextual drawer, provenance-boundary, and phone-composition checks with:

```bash
./tools/test_phase13_skin.sh
```

On a graphical Linux host, append `--capture-phase13` to the underlying Godot test command documented in `docs/phase_13/VISUAL_QA_RECORD.md` to regenerate review evidence. Generated Phase 11 concepts are never loaded by this test or the runtime.

Run versioned save envelopes, checksum validation, atomic writes, backup recovery, migration, full session round trips, autosave debounce, clock anomalies, bounded offline simulation, reward idempotency, and the offline-return UI with:

```bash
./tools/test_persistence.sh
```

The persistence tests use isolated temporary user-data directories and remove them after each run. Deliberately corrupt fixtures are preserved long enough to verify recovery diagnostics, then removed with their isolated test directory.

Run the complete Eras 1–3 reachability, deterministic balance targets, era-boundary save/load, structured newcomer cadence, worst-state performance, and progression UI suite with:

```bash
./tools/test_vertical_slice.sh
```

Phase 15 Building Network domain and graphical regressions run with:

```bash
./tools/test_phase15_building.sh
```

On a graphical Linux host, append `--capture-phase15` to the Phase 15 UI test command recorded in `docs/phase_15/VISUAL_QA_RECORD.md` to regenerate the reviewed Building, maintenance, brownout, report, and pullback evidence.

Phase 16 Neighborhood Microgrid domain and contextual-UI regressions run with:

```bash
./tools/test_phase16_neighborhood.sh
```

On a graphical Linux host, run the Phase 16 UI test through Xvfb with `--capture-phase16` to regenerate the eight reviewed Neighborhood, operator-control, report, and locked-City captures recorded in `docs/phase_16/VISUAL_QA_RECORD.md`.
