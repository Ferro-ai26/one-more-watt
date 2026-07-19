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

"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/validate_content.gd
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --script res://tests/content/test_invalid_content.gd

printf 'Content validation passed.\n'
