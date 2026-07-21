#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_EXECUTABLE="${GODOT_EXECUTABLE:-godot4}"
OMW_ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/home/ubuntu/.local/share/android-sdk}}"
OMW_BUILD_ROOT="$PROJECT_ROOT/build/android"
OMW_APK_PATH="$OMW_BUILD_ROOT/one_more_watt_phase16_debug.apk"
OMW_EXPORT_LOG="$OMW_BUILD_ROOT/export.log"
OMW_MANIFEST="$OMW_BUILD_ROOT/build_manifest.txt"
OMW_PROJECT_FILE="$PROJECT_ROOT/project.godot"
OMW_ANDROID_INSPECT_ROOT="${OMW_ANDROID_INSPECT_ROOT:-/usr/lib/android-sdk/build-tools/debian}"

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
OMW_AAPT="$OMW_ANDROID_INSPECT_ROOT/aapt"
OMW_APKSIGNER="$OMW_ANDROID_INSPECT_ROOT/apksigner"

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
	echo "ONE MORE WATT Phase 16 Android debug export"
	echo "UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "Commit: $OMW_COMMIT"
	echo "Godot: $($GODOT_EXECUTABLE --version)"
	echo "Android SDK: $OMW_ANDROID_SDK_ROOT"
	echo "Inspection aapt: $($OMW_AAPT version 2>&1)"
	echo "Inspection apksigner: $($OMW_APKSIGNER version 2>&1)"
} | tee "$OMW_EXPORT_LOG"

"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --export-debug "Android Debug" "$OMW_APK_PATH" 2>&1 | tee -a "$OMW_EXPORT_LOG"

if grep -q '^ERROR:' "$OMW_EXPORT_LOG"; then
	echo "Godot reported an export error; refusing to accept the APK." >&2
	exit 1
fi

OMW_BADGING="$($OMW_AAPT dump badging "$OMW_APK_PATH")"
OMW_PACKAGE="$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" <<<"$OMW_BADGING")"
if [[ "$OMW_PACKAGE" != "com.ferroai.onemorewatt" ]]; then
	echo "Exported APK has the wrong package identifier: $OMW_PACKAGE" >&2
	exit 1
fi

if [[ "$OMW_BADGING" != *"versionCode='10'"* || "$OMW_BADGING" != *"versionName='0.10.0-dev'"* ]]; then
	echo "Exported APK has unexpected version metadata." >&2
	exit 1
fi

OMW_PERMISSIONS="$($OMW_AAPT dump permissions "$OMW_APK_PATH")"
if [[ "$OMW_PERMISSIONS" != *"android.permission.VIBRATE"* ]]; then
	echo "Exported APK is missing the optional-haptics vibration permission." >&2
	exit 1
fi
if [[ "$OMW_PERMISSIONS" == *"android.permission.INTERNET"* || "$OMW_PERMISSIONS" == *"android.permission.ACCESS_NETWORK_STATE"* ]]; then
	echo "Exported APK unexpectedly requests network access." >&2
	exit 1
fi

OMW_APK_FILES="$(unzip -Z1 "$OMW_APK_PATH")"
for OMW_ARCHIVE_PATH in \
	"lib/arm64-v8a/libgodot_android.so" \
	"lib/x86_64/libgodot_android.so" \
	"assets/project.binary"; do
	if [[ "$OMW_APK_FILES" != *"$OMW_ARCHIVE_PATH"* ]]; then
		echo "Exported APK is missing $OMW_ARCHIVE_PATH" >&2
		exit 1
	fi
done

if ! unzip -p "$OMW_APK_PATH" assets/project.binary | strings | grep -qx "$OMW_COMMIT_SHORT"; then
	echo "Exported APK does not contain the expected build identifier $OMW_COMMIT_SHORT" >&2
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
	echo "permissions=android.permission.VIBRATE"
	echo "architectures=arm64-v8a,x86_64"
	sed -n "/^sdkVersion:/p;/^targetSdkVersion:/p" <<<"$OMW_BADGING"
} | tee "$OMW_MANIFEST"

echo "Android debug export verified: $OMW_APK_PATH"
