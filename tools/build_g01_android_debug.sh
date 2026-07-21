#!/usr/bin/env bash
set -euo pipefail

OMW_SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMW_EXPORT_PRESET="Android G01 Debug" \
OMW_BUILD_LABEL="G01" \
OMW_APK_PATH="$OMW_SCRIPT_ROOT/build/android/one_more_watt_g01_debug.apk" \
OMW_EXPECT_G01_FEATURE="1" \
exec "$OMW_SCRIPT_ROOT/tools/build_android_debug.sh"
