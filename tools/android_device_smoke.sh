#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMW_ADB="${ADB_EXECUTABLE:-/usr/lib/android-sdk/platform-tools/adb}"
OMW_AAPT="${AAPT_EXECUTABLE:-/usr/lib/android-sdk/build-tools/debian/aapt}"
OMW_APK="${1:-$PROJECT_ROOT/build/android/one_more_watt_phase16_debug.apk}"
OMW_PACKAGE="com.ferroai.onemorewatt"

if [[ ! -f "$OMW_APK" ]]; then
	echo "APK not found: $OMW_APK" >&2
	exit 1
fi

OMW_DEVICE_LIST="$($OMW_ADB devices | awk 'NR > 1 && $2 == "device" {print $1}')"
if [[ -z "$OMW_DEVICE_LIST" ]]; then
	echo "No ready Android device is attached. No install was attempted." >&2
	exit 2
fi

if [[ -n "${ANDROID_SERIAL:-}" ]]; then
	OMW_SERIAL="$ANDROID_SERIAL"
elif [[ "$(wc -l <<<"$OMW_DEVICE_LIST")" -eq 1 ]]; then
	OMW_SERIAL="$OMW_DEVICE_LIST"
else
	echo "Multiple devices are attached. Set ANDROID_SERIAL explicitly." >&2
	exit 2
fi

OMW_BADGING="$($OMW_AAPT dump badging "$OMW_APK")"
if [[ "$OMW_BADGING" != *"package: name='$OMW_PACKAGE'"* ]]; then
	echo "APK package does not match $OMW_PACKAGE" >&2
	exit 1
fi

echo "Device: $OMW_SERIAL"
$OMW_ADB -s "$OMW_SERIAL" shell getprop ro.product.manufacturer
$OMW_ADB -s "$OMW_SERIAL" shell getprop ro.product.model
$OMW_ADB -s "$OMW_SERIAL" shell getprop ro.build.version.release
$OMW_ADB -s "$OMW_SERIAL" shell getprop ro.build.version.sdk

echo "Installing debug APK without clearing an existing save..."
$OMW_ADB -s "$OMW_SERIAL" install -r "$OMW_APK"
$OMW_ADB -s "$OMW_SERIAL" shell am force-stop "$OMW_PACKAGE"
$OMW_ADB -s "$OMW_SERIAL" shell monkey -p "$OMW_PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 3

OMW_PID="$($OMW_ADB -s "$OMW_SERIAL" shell pidof "$OMW_PACKAGE" | tr -d '\r')"
if [[ -z "$OMW_PID" ]]; then
	echo "Package did not remain running after launch." >&2
	exit 1
fi

echo "Launch process: $OMW_PID"
$OMW_ADB -s "$OMW_SERIAL" shell dumpsys meminfo "$OMW_PACKAGE" | sed -n '1,24p'
echo "Automated install/launch smoke passed. Complete docs/ANDROID_DEVICE_TEST.md manually on this device."
