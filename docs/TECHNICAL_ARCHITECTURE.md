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

