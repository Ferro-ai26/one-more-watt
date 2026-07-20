#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${GODOT_BIN:-godot4}"

if ! command -v "$godot_bin" >/dev/null 2>&1; then
  echo "Request tests require '$godot_bin' on PATH." >&2
  exit 1
fi

"$godot_bin" --headless --path "$project_dir" --script res://tests/unit/test_request_simulation.gd
echo "Request simulation tests passed."
