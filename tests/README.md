# Test entry points

Run all Phase 00 validation from the repository root:

```bash
./tools/validate.sh
```

Set `GODOT_BIN` when the executable is not named `godot`. The command imports and parses the project, validates the foundation configuration, exercises the shell at three portrait sizes, and launches the main scene in smoke-test mode.

Later phases may add a dedicated unit-test framework under `tests/unit/`; this script remains the repository-level validation entry point.
