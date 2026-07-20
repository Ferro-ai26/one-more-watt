#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${GODOT_BIN:-godot4}"

if ! command -v "$godot_bin" >/dev/null 2>&1; then
  echo "Main UI tests require '$godot_bin' on PATH." >&2
  exit 1
fi

"$godot_bin" --headless --path "$project_dir" --script res://tests/unit/test_main_ui_systems.gd
"$godot_bin" --headless --path "$project_dir" --script res://tests/integration/test_main_ui.gd
GODOT_BIN="$godot_bin" "$project_dir/tools/test_skin_system.sh"

echo "Main UI tests passed."
