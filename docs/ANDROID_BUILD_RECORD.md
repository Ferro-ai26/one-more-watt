# Phase 09 Android Build Record

Status: Host build and static inspection passed; physical-device verification pending
Build UTC: 2026-07-20T04:25:54Z

## Source and artifact

- Source commit: `e165b2b7ace78a848b1eed4431f919804a8b8e6f`
- In-app build identifier: `e165b2b7ace7`
- Artifact: `build/android/one_more_watt_phase09_debug.apk`
- Bytes: 55,797,809
- SHA-256: `8402cde8c980c6f226dc7ac88df977692ba0822bd332d1e246055afd66c1785a`
- Export command: `./tools/build_android_debug.sh`

The artifact and generated `export.log`/`build_manifest.txt` are intentionally ignored by Git. Rebuilding from another commit or with another debug keystore can produce a different checksum or signature.

## Toolchain

- Host: Ubuntu 24.04 ARM64 (`aarch64`)
- Godot: 4.6.2.stable.official.71f334935
- Renderer: GL Compatibility
- JDK: OpenJDK 21.0.11
- Android SDK: `/home/ubuntu/.local/share/android-sdk`
- Android Platform: 35
- Build-tools used by Godot: 35.0.1
- Platform-tools: 37.0.0 installed; Debian ARM64 adb used for device discovery
- Static inspection: Debian ARM64 `aapt` v0.2 and `apksigner` 0.9
- Export template: matching Godot 4.6.2 prebuilt debug APK
- Signing: local Android debug keystore; no key or password committed

## Verified artifact properties

- Package: `com.ferroai.onemorewatt`
- Label: `ONE MORE WATT`
- Version: code 9, name `0.9.0-dev`
- Minimum/target SDK: API 24 / API 35
- Native architectures: arm64-v8a and x86_64
- Orientation: portrait; activity remains resizeable and declares configuration changes
- Permissions: `android.permission.VIBRATE` only; no Internet or network-state permission
- Backup flag: disabled in the generated manifest
- Debuggable: yes, as required for the debug prototype
- Signature: APK Signature Scheme v2 and v3 verified
- Debug certificate SHA-256: `dc02e125341858dd653149c58e1c3fa42da24f0210b2001054fa5d60cfe9192f`
- ZIP alignment: verified successfully at four-byte alignment
- Embedded project metadata contains version `0.9.0-dev` and build identifier `e165b2b7ace7`
- Generated launcher icon was extracted and visually inspected; it shows the intended WATT power-core/bolt mark rather than the Godot default.

## Host limitations

Godot's editor performs a background device probe using the SDK's x86_64 platform-tools binary, which prints an ARM64 binfmt loader message on this VPS. Export itself completes with exit 0, and static inspection uses native ARM64 tools. This does not constitute device execution.

ADB reported no connected device. `/dev/kvm` and an Android emulator binary are unavailable, so install/launch, touch, safe-area, lifecycle, audio, haptic, storage, performance, battery, and heat checks are not claimed.
