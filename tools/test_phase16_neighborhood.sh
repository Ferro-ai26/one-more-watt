#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${GODOT_BIN:-godot4}"

if ! command -v "$godot_bin" >/dev/null 2>&1; then
	printf 'Phase 16 Neighborhood Microgrid tests require %s on PATH.\n' "$godot_bin" >&2
	exit 1
fi

"$godot_bin" --headless --path "$project_dir" --script res://tests/integration/test_phase16_neighborhood_microgrid.gd
"$godot_bin" --headless --path "$project_dir" --script res://tests/integration/test_phase16_neighborhood_ui.gd
printf 'Phase 16 Neighborhood Microgrid tests passed.\n'
