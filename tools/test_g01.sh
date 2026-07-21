#!/usr/bin/env bash
set -euo pipefail

OMW_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMW_GODOT_BIN="${GODOT_BIN:-godot4}"

"$OMW_GODOT_BIN" --headless --path "$OMW_PROJECT_ROOT" --script res://tests/unit/test_g01_recorder.gd
"$OMW_GODOT_BIN" --headless --path "$OMW_PROJECT_ROOT" --script res://tests/integration/test_g01_playtest_ui.gd
echo "G01 baseline recorder and isolated-profile tests passed."
