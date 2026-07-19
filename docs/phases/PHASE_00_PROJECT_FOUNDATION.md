# Phase 00 — Project Foundation

## Objective

Create a clean, reproducible Godot repository foundation that later phases can extend without restructuring.

## Player-facing result

The game launches to a clearly labeled development shell with no parser/resource errors. It is not yet playable.

## Required reading

`GAME_VISION.md`, `TECHNICAL_ARCHITECTURE.md`, `ANDROID_RELEASE_SPEC.md`, and `PROJECT_SETUP_CHECKLIST.md`.

## Included

- Confirm or initialize the Git repository
- Record exact engine/toolchain values
- Create the documented directory layout
- Create `project.godot` with portrait mobile baseline
- Establish input actions, audio buses, safe-area root, and theme skeleton
- Add placeholder main scene and debug/version label
- Establish test and content-validation entry points
- Add Android export preset only when locally supportable
- Add ignore rules for generated/imported/secrets

## Excluded

Gameplay simulation, final UI, authored requests, production art, release signing, analytics, monetization, and external services.

## Implementation requirements

- Project opens in the recorded Godot version.
- Headless launch exits successfully.
- Root layout can adapt to tall and narrow portrait sizes.
- Secrets, keystores, `.godot`, exports, and local SDK paths are ignored.
- Version/build information has a single source.
- Placeholder assets are clearly identified as placeholders.

## Expected files

`project.godot`, base `scenes/app/Main.tscn`, application bootstrap script, base theme, test runner or documented test command, export preset if possible, `.gitignore`, and completed setup checklist.

## Automated tests

- Project import/parse
- Headless main-scene launch
- Directory/config validation

## Manual verification

Open the project, run the main scene, resize to at least three portrait aspect ratios, and confirm no clipping or missing-resource errors.

## Acceptance criteria

- [ ] Clean project import
- [ ] Main scene launches headlessly and in editor
- [ ] Portrait shell responds to size changes
- [ ] Test command is recorded and produces a meaningful result
- [ ] Setup checklist contains known values and clearly marks unknowns
- [ ] Git status contains no generated import/cache output
- [ ] Living documents updated

## Stop condition

Stop after the stable shell and development workflow exist. Do not create content loaders or simulation logic.

