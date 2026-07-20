# Test entry points

Run all repository validation from the repository root:

```bash
./tools/validate.sh
```

Set `GODOT_BIN` when the executable is not named `godot`. The command imports and parses the project, validates the foundation and content configuration, runs valid and invalid content fixtures, exercises the shell at three portrait sizes, and launches the main scene in smoke-test mode.

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

The main-interface integration suite drives request authorization through report, allocation changes, a brownout, infrastructure purchasing, all four tabs, settings, and modal back behavior at 360 × 640, 393 × 873, and 480 × 800.

Run versioned save envelopes, checksum validation, atomic writes, backup recovery, migration, full session round trips, autosave debounce, clock anomalies, bounded offline simulation, reward idempotency, and the offline-return UI with:

```bash
./tools/test_persistence.sh
```

The persistence tests use isolated temporary user-data directories and remove them after each run. Deliberately corrupt fixtures are preserved long enough to verify recovery diagnostics, then removed with their isolated test directory.
