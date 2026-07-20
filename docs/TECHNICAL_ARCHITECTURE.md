# Technical Architecture

## Goals

- Deterministic, testable simulation
- Data-driven content
- Reliable Android lifecycle behavior
- Versioned saves
- Clear boundaries between domain logic and presentation
- Easy extension from three eras to sixteen without replacing the core

## Target environment

Record exact engine and tool versions in `PROJECT_SETUP_CHECKLIST.md`. Use a stable Godot 4.x release supported by the chosen Android export toolchain. Do not upgrade engine versions during an active phase without an accepted decision and a full regression pass.

## Proposed repository layout

```text
assets/
  audio/ fonts/ icons/ illustrations/ shaders/
data/
  achievements/ balance/ dialogue/ eras/ incidents/
  infrastructure/ localization/ requests/ upgrades/
scenes/
  app/ components/ debug/ screens/ watt/ world/
scripts/
  content/ core/ persistence/ simulation/ ui/ utilities/
tests/
  fixtures/ integration/ unit/
tools/
docs/
```

## Architecture layers

### Content layer

Loads, validates, indexes, and exposes immutable authored definitions. It does not own player progress.

Suggested services:

- `ContentRepository`
- `ContentValidator`
- `LocalizationService`

### Simulation layer

Pure or near-pure domain logic operating on state and elapsed time.

Suggested components:

- `GridCalculator`
- `ReserveSimulator`
- `RequestSimulator`
- `EconomyCalculator`
- `UnlockEvaluator`
- `OfflineSimulator`
- `PrestigeCalculator`

Simulation functions should accept state/data and return results or events without requiring scene nodes.

### State layer

Owns current player state, applies validated commands, and emits domain events.

Suggested autoloads:

- `GameState`: authoritative runtime state and commands
- `ContentDB`: validated content index
- `SaveManager`: save/load/migration/backup
- `AppLifecycle`: pause, resume, and offline transition coordination
- `AudioManager`: global buses and sound settings

Avoid turning autoloads into UI controllers.

### Presentation layer

Scenes observe state and issue explicit commands. UI scripts format data but do not calculate economy rules.

## State model

Top-level runtime state should include:

- Schema version
- Run identifier
- Current era
- Currency balances
- Infrastructure counts
- Upgrade levels
- Request states and active request
- Grid aggregate/cache data
- Automation settings
- WATT/model progression
- Lifetime statistics
- Recent report summaries
- Tutorial state
- Timestamps

Derived values such as current generation should be reproducible from owned content and upgrades. Cache them for performance only; do not make the cache the sole truth.

## Command pattern

Player actions pass through explicit state methods such as:

- `purchase_infrastructure(id, amount)`
- `purchase_upgrade(id)`
- `set_allocation_mode(mode)`
- `authorize_request(id)`
- `acknowledge_report(id)`
- `set_automation_rule(id, value)`
- `perform_prestige()`

Commands validate preconditions, mutate state atomically, and emit meaningful domain events.

## Domain events

Examples:

- `currency_changed`
- `grid_metrics_changed`
- `infrastructure_purchased`
- `request_state_changed`
- `brownout_started`
- `brownout_ended`
- `content_unlocked`
- `era_changed`
- `save_completed`
- `offline_report_ready`

Avoid per-frame signals for values that have not changed.

## Simulation clock

- Use a fixed logical simulation step for active play, initially 0.25 seconds.
- Accumulate frame delta and process bounded steps.
- UI interpolation may run every frame but must not alter authoritative state.
- Large elapsed durations use event-boundary aggregation rather than millions of fixed steps.
- Limit catch-up work per rendered frame; offline calculation occurs before returning control.

The Phase 02 active simulator rejects non-finite or negative deltas and bounds one direct active-time call to one hour. Larger offline intervals belong to the later event-boundary offline simulator rather than the fixed-step active loop.

The Phase 03 request coordinator owns lifecycle commands and advances demand profiles at the same fixed-step boundary as `GridSimulation`. It consumes grid step results, emits summary domain events, and stores one aggregate `PerformanceReport` per completed sample; presentation never calculates rewards, grades, or progress.

The Phase 04 economy coordinator owns currency, stable-ID infrastructure counts, upgrade levels, reached milestones, and automation settings. `EconomyCalculator` is the single source for geometric costs and milestone lookup; `UnlockEvaluator` returns explicit unmet conditions; and `InfrastructureAggregator` rebuilds derived outputs from content plus ownership. Preview commands simulate the proposed ownership/level change through that same aggregate path before an atomic purchase applies it. Grid metrics remain derived cache data rather than purchase truth.

Starting ownership is separated from the non-owned hardware baseline during configuration. Reconfiguration or a future load therefore reconstructs the same Generation, Transmission, Reserve, request modifier, and automation values without serializing derived totals or counting starting infrastructure twice.

The Phase 05 online `GameSession` is a thin coordinator over the request and economy domains. It synchronizes the authoritative Stored Energy balance and pushes economy-derived grid values into the active request simulator after a purchase; it does not recalculate costs, effects, request progress, rewards, or reports. `MainViewModel` converts domain previews and reports into presentation-ready snapshots, while `MainUI` observes those snapshots and issues commands.

Navigation, runtime accessibility settings, number formatting, and feedback hooks are isolated UI services. Number promotion never alters simulation values. Haptic requests are conditional on both runtime preference and mobile capability, audio preferences address named buses, and missing sound assets degrade to a semantic feedback signal without a resource error. Phase 06 may serialize settings and session state but must not treat UI labels as state truth.

Phase 06 persistence is split between `SaveCodec`, `SaveMigrator`, `SaveManager`, and `PersistenceController`. The codec owns canonical SHA-256 integrity; the migrator owns sequential schema and stable-ID transformations; the manager owns temporary writes, backup rotation, corruption preservation, and candidate recovery; and the controller validates complete domain-restorable snapshots, applies lifecycle/autosave policy, advances trusted UTC, and invokes offline simulation. No presentation node reads or writes save JSON directly.

`OfflineSimulator` consumes the restored `GameSession`, authored balance policy, and two UTC timestamps. It clamps recognized time before applying efficiency, advances active requests through the existing deterministic coordinator with offline-disallowed incidents suppressed, detects completion as an event boundary, and uses the same grid simulator for remaining idle production. `OfflineReport` is a numeric reconciliation record rendered by the UI only after the resulting state is saved.

Phase 07 keeps era and feature progression inside the existing economy state: current/unlocked eras, best Stability service, feature flags, a pending transition, and prototype completion serialize with ownership. `GameSession` reconciles request reports into that state, refreshes cross-domain availability after completions and purchases, and keeps required-request selection separate from optional vanity selection. Request definitions remain the source for tutorial text, feature rewards, and capstone tags; presentation only renders snapshots.

## Determinism

- Demand profiles are authored curves or seeded sequences.
- Store seeds and event cursors required to resume a request.
- Identical state, content version, seed, and elapsed duration should produce equivalent results within documented floating-point tolerance.
- Unit tests compare key values using tolerances, not formatted strings.

## Number formatting

Simulation values remain numeric. `NumberFormatter` handles notation:

- Engineering/SI for early and midgame
- Optional scientific notation
- Named large-number notation if approved later

Formatting must be centralized and tested at unit boundaries.

## Testing strategy

### Unit tests

- Cost calculations
- Multiplier stacking
- Grid limitation
- Reserve charge/discharge
- Request progress
- Stability score
- Unlock conditions
- Number formatting
- Prestige previews

### Integration tests

- New game through first request
- Purchase affects grid and persists
- Request completes and rewards once
- Brownout does not lose progress
- Save/load round trip
- Offline request completion
- Era transition

### Content validation

Run on every content change and in CI when available.

### Headless smoke test

Launch the project, load content, create or load a game, advance simulation, and exit successfully without parser or resource errors.

## Performance budgets

Prototype targets on a representative mid/low Android device:

- 60 FPS on the main screen where supported; acceptable stable 30 FPS fallback
- Under 250 MB working memory target
- Main scene interactive within 5 seconds after process start on representative hardware
- Offline calculation under 2 seconds for the prototype maximum duration
- Save operation normally under 100 ms and never performed every frame

## Logging

Use structured categories: content, simulation, save, UI, lifecycle, export. Debug builds may be verbose. Release builds must not log full save contents or device-sensitive information.

## Security and privacy

The prototype requires no account, network connection, contact access, location, microphone, camera, or advertising identifier. Save files remain local unless a later approved feature changes this.

## Extension rules

Adding an era should require data and presentation assets, not new core simulation architecture. Add a new system only when the existing Generation/Transmission/Reserve/request model cannot express a meaningful planned decision.

## Phase 08 polish boundary

`FeedbackAudio` is a presentation-only node that converts semantic `FeedbackHooks` events into cached procedural PCM cues on the SFX bus; simulation remains silent and testable. Headless runs generate and validate cue data without opening playback. `MainUI` advances idle grid simulation when no request is active, retains the specified modal pause for active requests, and rebuilds secondary content only on explicit navigation/mutation while normal 5 Hz refreshes update existing controls.

The available-host worst-state budget is tested at the complete endpoint with all Build definitions and reports reachable: 500 non-rebuilding refreshes must complete under one second, 25 full Build rebuilds under 1.5 seconds, and the live tree under 500 UI nodes. These host checks supplement rather than replace the Android memory, launch, and frame budgets.
