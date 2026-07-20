# Phase 09 Android Device Test

Use this checklist on physical Android hardware. The current VPS cannot supply this evidence.

## Artifact identity

- Source commit: `e165b2b7ace78a848b1eed4431f919804a8b8e6f`
- Package: `com.ferroai.onemorewatt`
- APK: `build/android/one_more_watt_phase09_debug.apk`
- Expected SHA-256: `8402cde8c980c6f226dc7ac88df977692ba0822bd332d1e246055afd66c1785a`

Before transfer or install:

```bash
sha256sum build/android/one_more_watt_phase09_debug.apk
```

## Fresh install

Warning: `adb uninstall com.ferroai.onemorewatt` deletes that package's local save data. Use it only when beginning the required fresh-install pass and after preserving any wanted test save.

```bash
adb devices -l
adb uninstall com.ferroai.onemorewatt
adb install build/android/one_more_watt_phase09_debug.apk
adb shell monkey -p com.ferroai.onemorewatt -c android.intent.category.LAUNCHER 1
```

For a non-destructive reinstall that preserves an existing debug save, use `./tools/android_device_smoke.sh` or `adb install -r`.

## Record the device

- Tester and date:
- Manufacturer/model:
- Android version/API:
- Display size/aspect and cutout/navigation mode:
- Build identifier visible in Settings:
- Cold-launch time:
- Warm-resume time:
- Observed FPS/memory:
- Battery/heat notes after 30 minutes:

Useful read-only commands:

```bash
adb shell getprop ro.product.manufacturer
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell dumpsys meminfo com.ferroai.onemorewatt
```

## Required playtest

- [ ] Fresh install and cold launch succeed.
- [ ] Settings shows version `0.9.0-dev` and build `e165b2b7ace7`.
- [ ] Early onboarding is readable and the first request can be authorized.
- [ ] Build and Upgrades purchases work by touch.
- [ ] A brownout can be triggered and recovered without losing progress.
- [ ] Android Back closes the top modal, then returns a secondary tab to Grid.
- [ ] Background during an active request saves state.
- [ ] Resume shows a truthful bounded offline report.
- [ ] Force-close/relaunch preserves the exact key state and does not duplicate rewards.
- [ ] Sound is audible and pauses appropriately; haptics follow the setting.
- [ ] Cutout, status/navigation bars, and gesture insets do not obstruct content.
- [ ] All frequent controls are usable and text remains readable.
- [ ] The agreed Eras 1–3 endpoint is reachable on the device build.
- [ ] A 30-minute representative session records FPS, memory, battery, and heat observations.
- [ ] A two-hour offline return applies the documented cap/efficiency truthfully.

## Evidence capture

Record screenshots or video for cold launch, authorization, Build, brownout, offline return, Settings/build ID, and prototype endpoint. Capture relevant logs without including private device data:

```bash
adb logcat -c
adb logcat -v time Godot:D godot:D '*:S'
```

After the checklist, update `docs/PLAYTEST_CHECKLIST.md`, `docs/KNOWN_ISSUES.md`, `docs/CURRENT_HANDOFF.md`, and the Phase 09 go/no-go decision. Do not begin Phase 10 automatically.
