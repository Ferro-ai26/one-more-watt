#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${GODOT_BIN:-godot4}"

if ! command -v "$godot_bin" >/dev/null 2>&1; then
	printf 'Phase 15 Building Network tests require %s on PATH.\n' "$godot_bin" >&2
	exit 1
fi

"$godot_bin" --headless --path "$project_dir" --script res://tests/integration/test_phase15_building_network.gd
"$godot_bin" --headless --path "$project_dir" --script res://tests/integration/test_phase15_building_ui.gd
printf 'Phase 15 Building Network tests passed.\n'
