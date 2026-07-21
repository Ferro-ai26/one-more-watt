# Android Build Records

## Phase 16 Neighborhood Microgrid build

Status: Clean source build/static inspection passed; physical phone gate unperformed and closed by accepted limitation under `DEC-039`
Build UTC: 2026-07-21T01:05:53Z

### Source and artifact

- Source commit: `cc51fbf883e6c50dbe2e2229b103693d69270a78`
- In-app build identifier: `cc51fbf883e6`
- Artifact: `build/android/one_more_watt_phase16_debug.apk`
- Bytes: 56,025,572
- SHA-256: `1a934d52355bfaa758f2fb6b0076215145e0cb097f330fa9cb53bf438ac85f37`
- Size delta from Phase 15: +42,871 bytes / +0.077%
- Export command: `./tools/build_android_debug.sh` from a clean detached worktree at the exact commit; artifact copied back unchanged

### Verified artifact properties

- Package/label: `com.ferroai.onemorewatt` / `ONE MORE WATT`
- Version: code 10, name `0.10.0-dev`
- Minimum/target SDK: API 24 / API 35
- Native architectures: arm64-v8a and x86_64
- Permissions: `android.permission.VIBRATE` only; no Internet or network-state permission
- Signature: APK Signature Scheme v2 and v3 verified
- Debug certificate SHA-256: `dc02e125341858dd653149c58e1c3fa42da24f0210b2001054fa5d60cfe9192f`
- Embedded project metadata contains build identifier `cc51fbf883e6`
- Export log contained no Godot `ERROR:` line

### Device boundary

`./tools/android_device_smoke.sh build/android/one_more_watt_phase16_debug.apk` found no ready ADB device and performed no installation. This artifact is not claimed as physical Android runtime evidence. `ISSUE-011` closed by the user's accepted verification limitation under `DEC-039`; its unchecked matrix is deferred to the later combined Eras 1–6 Android QA gate.

## Phase 15 Building Network build

Status: Clean source build/static inspection passed; physical runtime matrix unavailable on current host
Build UTC: 2026-07-20T23:17:10Z

### Source and artifact

- Source commit: `14b577fc8045e4de1b70692745f86591b3c38960`
- In-app build identifier: `14b577fc8045`
- Artifact: `build/android/one_more_watt_phase15_debug.apk`
- Bytes: 55,982,701
- SHA-256: `c82563de4bc3fdfb1c07f39cd626dc9f11d0b3f9dd28166453844718a58063e6`
- Size delta from the last Phase 13 device artifact: +43,076 bytes / +0.077%
- Export command: `./tools/build_android_debug.sh`

### Verified artifact properties

- Package/label: `com.ferroai.onemorewatt` / `ONE MORE WATT`
- Version: code 10, name `0.10.0-dev`
- Minimum/target SDK: API 24 / API 35
- Native architectures: arm64-v8a and x86_64
- Orientation: portrait; activity remains resizeable and declares configuration changes
- Permissions: `android.permission.VIBRATE` only; no Internet or network-state permission
- Signature: APK Signature Scheme v2 and v3 verified
- Debug certificate SHA-256: `dc02e125341858dd653149c58e1c3fa42da24f0210b2001054fa5d60cfe9192f`
- Embedded project metadata contains build identifier `14b577fc8045`
- Export log contained no Godot `ERROR:` line

### Device boundary

`./tools/android_device_smoke.sh build/android/one_more_watt_phase15_debug.apk` exited 2 because no ready ADB device was attached; it performed no installation. `/dev/kvm`, an emulator executable, and installed system images are absent on the host. This artifact is not claimed as physical Android runtime evidence. `ISSUE-010` retains the update-install, lifecycle, save-idempotency, touch/safe-area/font, audio/haptic, FPS, heat, and battery matrix.

## Phase 10 stabilization build

Status: Host build/static inspection passed; Moto verification deferred to Phase 14 by explicit user acceptance
Build UTC: 2026-07-20T07:39:10Z

### Source and artifact

- Source commit: `0c4f44e259c919065ff40ff4142c2ea0e33ed5fe`
- In-app build identifier: `0c4f44e259c9`
- Artifact: `build/android/one_more_watt_phase10_debug.apk`
- Bytes: 55,802,078
- SHA-256: `c5ab857ef877284a8c09e84bdf136c06b8789be6effdf3d8b6ff931f95e8c5c4`
- Export command: `./tools/build_android_debug.sh`

### Verified artifact properties

- Package/label: `com.ferroai.onemorewatt` / `ONE MORE WATT`
- Version: code 10, name `0.10.0-dev`
- Minimum/target/compile SDK: API 24 / API 35 / API 35
- Native architectures: arm64-v8a and x86_64
- Orientation: portrait; activity is resizeable and declares configuration changes
- Permissions: `android.permission.VIBRATE` only; no Internet or network-state permission
- Backup flag: disabled
- Signature: APK Signature Scheme v2 and v3 verified
- Debug certificate SHA-256: `dc02e125341858dd653149c58e1c3fa42da24f0210b2001054fa5d60cfe9192f`
- ZIP alignment: four-byte verification passed
- Embedded project metadata contains build identifier `0c4f44e259c9`
- Export log contained no Godot `ERROR:` line

The toolchain and signing boundary match the Phase 09 record below. The artifact, export log, and generated manifest remain ignored by Git. Rebuilding from another source commit or debug keystore may produce a different checksum/signature.

### Device boundary

`./tools/android_device_smoke.sh` found no ready ADB device and performed no installation. This build is not claimed as Android runtime evidence. The user accepted that Phase 10 limitation; the preserved Moto/device checklist in `ANDROID_DEVICE_TEST.md` is deferred to Phase 14.

## Phase 09 Android Build Record

Status: Host build/static inspection passed; partial manual Moto phone evidence recorded
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

ADB reported no connected device and `/dev/kvm`/emulator remain unavailable. Kevin separately reported successful APK install/cold launch, correct build identity, readable/authorizable onboarding, and working Build/Upgrade touch purchases on a Moto phone. Exact device/API details and all other device checks were skipped; see `ANDROID_DEVICE_TEST.md`.
