#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_EXECUTABLE="${GODOT_EXECUTABLE:-godot4}"
OMW_ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/home/ubuntu/.local/share/android-sdk}}"
OMW_BUILD_ROOT="$PROJECT_ROOT/build/android"
OMW_APK_PATH="$OMW_BUILD_ROOT/one_more_watt_phase09_debug.apk"
OMW_EXPORT_LOG="$OMW_BUILD_ROOT/export.log"
OMW_MANIFEST="$OMW_BUILD_ROOT/build_manifest.txt"
OMW_PROJECT_FILE="$PROJECT_ROOT/project.godot"

cd "$PROJECT_ROOT"

if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
	echo "Android export requires a clean working tree so the APK can be tied to one commit." >&2
	exit 1
fi

if [[ ! -f export_presets.cfg ]]; then
	echo "Missing export_presets.cfg. Record the approved package identifier before exporting." >&2
	exit 1
fi

OMW_COMMIT="$(git rev-parse HEAD)"
OMW_COMMIT_SHORT="$(git rev-parse --short=12 HEAD)"
OMW_AAPT="$OMW_ANDROID_SDK_ROOT/build-tools/35.0.1/aapt"
OMW_APKSIGNER="$OMW_ANDROID_SDK_ROOT/build-tools/35.0.1/apksigner"

for OMW_REQUIRED_TOOL in "$OMW_AAPT" "$OMW_APKSIGNER"; do
	if [[ ! -x "$OMW_REQUIRED_TOOL" ]]; then
		echo "Required Android tool is unavailable: $OMW_REQUIRED_TOOL" >&2
		exit 1
	fi
done

mkdir -p "$OMW_BUILD_ROOT"
OMW_PROJECT_BACKUP="$(mktemp)"
cp "$OMW_PROJECT_FILE" "$OMW_PROJECT_BACKUP"
restore_project_file() {
	cp "$OMW_PROJECT_BACKUP" "$OMW_PROJECT_FILE"
	rm -f "$OMW_PROJECT_BACKUP"
}
trap restore_project_file EXIT

sed -i "s/config\/build_commit=\"[^\"]*\"/config\/build_commit=\"$OMW_COMMIT_SHORT\"/" "$OMW_PROJECT_FILE"

{
	echo "ONE MORE WATT Phase 09 Android debug export"
	echo "UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "Commit: $OMW_COMMIT"
	echo "Godot: $($GODOT_EXECUTABLE --version)"
	echo "Android SDK: $OMW_ANDROID_SDK_ROOT"
} | tee "$OMW_EXPORT_LOG"

"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --export-debug "Android Debug" "$OMW_APK_PATH" 2>&1 | tee -a "$OMW_EXPORT_LOG"

OMW_BADGING="$($OMW_AAPT dump badging "$OMW_APK_PATH")"
OMW_PACKAGE="$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" <<<"$OMW_BADGING")"
if [[ -z "$OMW_PACKAGE" || "$OMW_PACKAGE" == "com.godot.game" ]]; then
	echo "Exported APK has an invalid or default package identifier: $OMW_PACKAGE" >&2
	exit 1
fi

"$OMW_APKSIGNER" verify --verbose --print-certs "$OMW_APK_PATH" | tee -a "$OMW_EXPORT_LOG"
OMW_SHA256="$(sha256sum "$OMW_APK_PATH" | awk '{print $1}')"
OMW_SIZE="$(stat -c '%s' "$OMW_APK_PATH")"

{
	echo "artifact=$OMW_APK_PATH"
	echo "sha256=$OMW_SHA256"
	echo "bytes=$OMW_SIZE"
	echo "commit=$OMW_COMMIT"
	echo "build_identifier=$OMW_COMMIT_SHORT"
	echo "package=$OMW_PACKAGE"
	sed -n "/^sdkVersion:/p;/^targetSdkVersion:/p" <<<"$OMW_BADGING"
} | tee "$OMW_MANIFEST"

echo "Android debug export verified: $OMW_APK_PATH"
