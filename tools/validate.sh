#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -n "${GODOT_BIN:-}" ]]; then
	GODOT_EXECUTABLE="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
	GODOT_EXECUTABLE="godot"
elif command -v godot4 >/dev/null 2>&1; then
	GODOT_EXECUTABLE="godot4"
else
	printf 'Godot executable not found. Set GODOT_BIN to its command or path.\n' >&2
	exit 127
fi

"$GODOT_EXECUTABLE" --headless --editor --path "$PROJECT_ROOT" --quit
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/validate_foundation.gd
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/validate_content.sh"
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/test_simulation.sh"
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/test_requests.sh"
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/test_economy.sh"
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/test_ui.sh"
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/test_persistence.sh"
GODOT_BIN="$GODOT_EXECUTABLE" "$PROJECT_ROOT/tools/test_vertical_slice.sh"
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/integration/test_portrait_layout.gd
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/integration/test_grid_debug_panel.gd
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/integration/test_request_debug_panel.gd
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/integration/test_economy_debug_panel.gd
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" -- --smoke-test

printf 'Phase 08 validation passed.\n'
