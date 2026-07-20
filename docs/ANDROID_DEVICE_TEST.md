# Android Device Tests

## Phase 10 targeted stabilization retest — Deferred to Phase 14

This preserved checklist records the exact revised artifact and the device checks that were not performed in Phase 10. The user explicitly accepted the Phase 10 limitation and transferred the Moto verification requirement to Phase 14. Unchecked items below remain unverified; none are promoted to passing evidence.

### Artifact identity

- Source commit: `0c4f44e259c919065ff40ff4142c2ea0e33ed5fe`
- Package: `com.ferroai.onemorewatt`
- Version/build shown in Settings: `0.10.0-dev` / `0c4f44e259c9`
- APK: `build/android/one_more_watt_phase10_debug.apk`
- Expected SHA-256: `c5ab857ef877284a8c09e84bdf136c06b8789be6effdf3d8b6ff931f95e8c5c4`

Prefer a non-destructive update first:

```bash
sha256sum build/android/one_more_watt_phase10_debug.apk
adb install -r build/android/one_more_watt_phase10_debug.apk
adb shell monkey -p com.ferroai.onemorewatt -c android.intent.category.LAUNCHER 1
```

Warning: uninstalling the package deletes its local save. Preserve any wanted save before a fresh-install pass.

### Device and scale evidence

- Tester/date:
- Manufacturer/exact model:
- Android version/API:
- Navigation mode and cutout/system-bar notes:
- Settings `DISPLAY` line (physical pixels and dpi):
- Settings `EFFECTIVE UI` line (logical dimensions and scale):
- Screenshot/video identifiers:

### Required targeted checks

- [ ] APK hash matches and update/fresh install succeeds.
- [ ] Cold launch succeeds and Settings shows `0.10.0-dev` / `0c4f44e259c9`.
- [ ] Early onboarding is comfortably sized, not merely technically readable.
- [ ] Authorize, Build, Upgrades, and primary navigation work by touch.
- [ ] Default, 115%, and 130% Text size remain usable; 130% may scroll vertically but must not clip horizontally.
- [ ] Reduced motion retains semantic state feedback.
- [ ] Cutout, status/navigation bars, and gesture insets do not obstruct controls.
- [ ] Android Back closes a modal, returns a secondary tab to Grid, then exits from Grid.
- [ ] A brownout can be triggered/recovered without lost progress.
- [ ] Background/resume produces the bounded offline report and preserves active progress.
- [ ] Force-close/relaunch preserves key state and does not duplicate rewards.
- [ ] Sound is audible/pauses appropriately; haptics follow the setting.
- [ ] If practical, record endpoint reachability, 30-minute FPS/memory/battery/heat, and the two-hour offline cap.
- [ ] Each additional small bug has concrete reproduction/expected/actual evidence, or remains Needs Information.

### Phase 10 retest result

Deferred by explicit user direction at Phase 10 closure. The current VPS had no attached Android device, and the revised APK was not run on the Moto phone. Host build/static inspection passed, but no revised-APK runtime claim is made. Phase 14 — Visual, Mobile, and Accessibility QA owns the preserved Moto comfort/display/density and related physical-device checks.

## Phase 09 historical device test

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

- Tester and date: Kevin; date not provided
- Manufacturer/model: Moto; exact model not provided
- Android version/API: Skipped by tester
- Display size/aspect and cutout/navigation mode: Skipped by tester
- Build identifier visible in Settings: Yes — version `0.9.0-dev`, build `e165b2b7ace7`
- APK install and cold launch: Passed
- Cold-launch time: Not observed
- Warm-resume time: Not observed
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
- [x] Early onboarding is readable and the first request can be authorized. Tester note: presentation resolution/scale appeared too small; a 720p target was requested for a later revision.
- [x] Build purchases work by touch.
- [x] Upgrade purchases work by touch.
- [ ] A brownout can be triggered and recovered without losing progress. Skipped by tester.
- [ ] Android Back closes the top modal, then returns a secondary tab to Grid. Skipped by tester.
- [ ] Background during an active request saves state. Skipped by tester.
- [ ] Resume shows a truthful bounded offline report. Skipped by tester.
- [ ] Force-close/relaunch preserves the exact key state and does not duplicate rewards. Skipped by tester.
- [ ] Sound is audible and pauses appropriately; haptics follow the setting. Skipped by tester.
- [ ] Cutout, status/navigation bars, and gesture insets do not obstruct content. Skipped by tester.
- [ ] All frequent controls are usable and text remains readable. Partial: onboarding was readable and touch purchases worked; full review skipped.
- [ ] The agreed Eras 1–3 endpoint is reachable on the device build. Skipped by tester.
- [ ] A 30-minute representative session records FPS, memory, battery, and heat observations. Skipped by tester.
- [ ] A two-hour offline return applies the documented cap/efficiency truthfully. Skipped by tester.

Tester reported additional small bugs to address later but did not provide details; no undocumented behavior is inferred. At the tester's request, all remaining questions were skipped.

## Evidence capture

Record screenshots or video for cold launch, authorization, Build, brownout, offline return, Settings/build ID, and prototype endpoint. Capture relevant logs without including private device data:

```bash
adb logcat -c
adb logcat -v time Godot:D godot:D '*:S'
```

After the checklist, update `docs/PLAYTEST_CHECKLIST.md`, `docs/KNOWN_ISSUES.md`, `docs/CURRENT_HANDOFF.md`, and the Phase 09 go/no-go decision. Do not begin Phase 10 automatically.

## Final result

- Manual tester: Kevin
- Device: Moto; exact model, Android/API, display details, and test date not provided
- Verified on hardware: install, cold launch, build/version identity, readable/authorizable onboarding, Build purchases, and Upgrade purchases
- Concrete issue: presentation appeared too small; tester requested a future 720p/scale revision
- Unverified by tester: all other device checklist items above
- Phase 09 decision: **Continue with targeted revisions**
- Phase 10: Not started; existing roadmap/document pack is being revised
