# Android Build and Release Specification

## Prototype target

Produce an installable debug APK that supports device playtesting. A production AAB and store listing are Phase 16 deliverables, not required to prove the prototype loop.

## Configuration record

Fill exact values in `PROJECT_SETUP_CHECKLIST.md`:

- Godot version
- Renderer
- Package identifier
- Minimum and target Android SDK
- Java/JDK version
- Android SDK/build-tools versions
- Keystore policy
- Version name and version code

## Package identity

Use a reverse-domain package identifier owned or controlled by the project publisher. Do not casually change it after external testing begins because saves and store identity may depend on it.

## Device behavior

- Preserve progress through pause, backgrounding, process death, and device restart.
- Recalculate layout after orientation/window changes even if portrait is locked.
- Respect cutouts, navigation bars, and gesture insets.
- Keep the screen awake only during clearly justified short interactions; idle timers do not require it.
- Audio pauses or ducks appropriately when focus is lost.
- Back navigation closes the topmost modal before attempting to exit.

## Permissions

The prototype requests no sensitive permissions. Internet access is unnecessary unless a later approved feature adds a real dependency. Any added permission requires documented player value and privacy review.

## Performance verification

Test at minimum:

- One representative low/mid Android device
- One modern Android device or emulator profile
- Narrow and tall aspect ratios
- Cold launch and warm resume
- 30-minute active session
- Two-hour offline return
- Low-memory background/process recreation when possible

Record device model, Android version, build identifier, observed FPS, memory, launch time, and defects.

## Export artifacts

Development artifacts:

- Debug APK
- Export log
- Commit hash/build identifier
- Automated test report
- Device test notes

Release artifacts:

- Signed AAB
- Mapping/symbol files when applicable
- Store icon, feature graphic, screenshots, short and full descriptions
- Privacy policy if required by implemented features
- Data safety declaration
- Content rating answers
- Release notes

Never commit release keystore secrets or passwords.

## Release gate

A release candidate must pass:

- Clean project import
- Content validation
- Automated tests
- Save migration tests
- Android export without errors
- Install, launch, suspend, resume, and update testing
- No blocker or critical known issue
- Complete store disclosure matching actual behavior
- License review for fonts, art, audio, and third-party code
- Versioned tagged commit

## Prototype acceptance

Phase 09 passes when an APK built from a recorded commit installs and runs on a physical Android device, the player can complete Eras 1–3 or the agreed prototype endpoint, save/resume works, and offline progress produces a truthful report.

## Phase 09 host build baseline

The approved permanent package identifier is `com.ferroai.onemorewatt`. The debug prototype uses Godot 4.6.2's matching prebuilt template, version code/name 9/`0.9.0-dev`, API 24 minimum/API 35 target, arm64-v8a and x86_64, local debug signing, and only the `VIBRATE` permission required for optional haptics. Internet and network-state permissions are disabled.

`tools/build_android_debug.sh` requires a clean Git tree, injects the exact source commit into in-app diagnostics, rejects engine export errors, and verifies package, version, API, permissions, architectures, embedded build ID, signature, and checksum. `tools/android_device_smoke.sh` refuses to mutate anything when no ready ADB device exists, and performs a non-clearing install/launch preflight when one is selected.

The first recorded host-verified artifact is documented in `ANDROID_BUILD_RECORD.md`. Static verification and an APK's existence do not satisfy Phase 09 physical-device acceptance; complete `ANDROID_DEVICE_TEST.md` before recording an expand/revise/stop decision.

## Phase 10 stabilization baseline

The Phase 10 debug build advances to version code/name 10/`0.10.0-dev` and `build/android/one_more_watt_phase10_debug.apk`. It retains the approved package, SDK, architecture, permission, signing, and reproducible-inspection boundaries above. Android startup now derives a bounded canvas scale from the physical window and Android's reported density so logical controls approach density-independent sizing without reducing the effective viewport below the verified 320 × 568 layout. Settings exposes the reported physical dimensions, density, effective logical viewport, and applied scale for targeted device evidence.
