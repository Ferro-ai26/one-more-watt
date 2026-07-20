# Content Database Specification

## Purpose

All authored content and balance values must be data-driven. Code interprets records; it does not contain request prose, item costs, era unlocks, or progression rewards.

JSON is the preferred initial authoring format because it is portable, diffable, and easy for validation tools to inspect. Typed Godot Resources may be generated or loaded from JSON, but JSON remains the source of truth unless an accepted decision changes it.

## Directory layout

```text
data/
├── manifest.json
├── balance/constants.json
├── eras/eras.json
├── infrastructure/infrastructure.json
├── upgrades/upgrades.json
├── requests/era_01_requests.json
├── requests/demand_profiles.json
├── requests/era_02_requests.json
├── requests/era_03_requests.json
├── dialogue/system_dialogue.json
├── incidents/incidents.json
├── achievements/achievements.json
└── localization/en.json
```

## Identifier policy

- IDs use lowercase `snake_case` ASCII.
- IDs are permanent once shipped or written into a save.
- Display names may change without changing IDs.
- Every cross-reference must validate at startup and in the content validation tool.
- Duplicate IDs are fatal validation errors.
- Removed shipped IDs require a save migration or a deprecated compatibility record.

## Manifest and file envelopes

`data/manifest.json` is the single content entry point. It contains a positive integer `schema_version`, a non-empty `content_version`, ordered file entries with `family`, `path`, and `root`, and exact placeholder asset exceptions with a non-empty reason. Every required family must appear. Content files repeat the manifest schema version and place records in the declared root array. Localization files instead contain `locale` and a `strings` dictionary.

Phase 01 family names are `balance`, `eras`, `infrastructure`, `upgrades`, `requests`, `demand_profiles`, `dialogue`, `incidents`, `achievements`, and `localization`.

## Era schema

Required fields:

```json
{
  "id": "era_01_cold_boot",
  "number": 1,
  "name_key": "era.01.name",
  "scale_key": "era.01.scale",
  "description_key": "era.01.description",
  "unlock_conditions": [],
  "infrastructure_ids": [],
  "request_ids": [],
  "visual_state_id": "desk_initial",
  "unit_display_floor": "W"
}
```

## Infrastructure schema

```json
{
  "id": "wall_outlet",
  "era_id": "era_01_cold_boot",
  "name_key": "infrastructure.wall_outlet.name",
  "description_key": "infrastructure.wall_outlet.description",
  "category": "generation",
  "tags": ["electrical", "early_grid"],
  "base_cost": 10,
  "cost_growth": 1.15,
  "base_effects": {"generation_rate": 5},
  "unlock_conditions": [{"type": "default"}],
  "max_owned": null,
  "milestone_set": "standard_high_volume",
  "icon_path": "res://assets/icons/infrastructure/wall_outlet.png",
  "scene_variant": "desk_outlet"
}
```

Allowed primary categories: `generation`, `transmission`, `reserve`, `support`, `automation`, `special`.

Infrastructure may also declare `passive_effects` using the same enumerated effect records as upgrades. Phase 04 recognizes additive base outputs for Generation, Transmission, Reserve capacity, Reserve charge/discharge, request efficiency, automation capacity, and request-demand multiplier. Multiplier effects may target one direct output, an authored category, an authored tag, or all production. Category and tag targets carry a matching stable `category` or `tag` field.

## Upgrade schema

```json
{
  "id": "dedicated_circuit_research",
  "era_id": "era_02_bedroom_assistant",
  "name_key": "upgrade.dedicated_circuit.name",
  "description_key": "upgrade.dedicated_circuit.description",
  "cost": {"stored_energy": 7500},
  "unlock_conditions": [],
  "effects": [{"operation": "multiply", "target": "transmission_capacity", "value": 1.25}],
  "permanent": false,
  "max_level": 1
}
```

Supported effect operations must be enumerated and validated. Do not execute arbitrary expressions from content files.

Leveled upgrades may provide a numeric `cost_growth`; their level cost is the floored geometric price derived from the base Stored Energy cost. Omitting it retains a fixed per-level cost. `max_level: 1` represents a one-time upgrade.

## Request schema

```json
{
  "id": "era01_identify_cat",
  "era_id": "era_01_cold_boot",
  "sequence": 3,
  "kind": "capacity",
  "required": true,
  "title_key": "request.era01_identify_cat.title",
  "summary_key": "request.era01_identify_cat.summary",
  "announcement_key": "request.era01_identify_cat.announcement",
  "completion_key": "request.era01_identify_cat.completion",
  "required_energy": 400,
  "continuous_demand": 12,
  "max_useful_power": 25,
  "demand_profile_id": "steady_small_peak",
  "recommended_reserve": 5,
  "unlock_conditions": [],
  "rewards": {"stored_energy": 40, "unlock_ids": []},
  "tutorial_action": null,
  "repeatable": false,
  "tags": ["main", "character"]
}
```

Request kinds: `capacity`, `stability`, `burst`, `research`, `vanity`.

Research requests may add a nonnegative `research_cost` in Stored Energy. The cost is validated and paid atomically at authorization; it is never embedded in UI code.

## Demand profile schema

Demand profiles define a positive `duration_seconds`, a `loop` flag, and ordered keyframes. Each keyframe contains a unique `time_seconds` within the profile duration and a nonnegative demand `multiplier`; the first keyframe starts at zero. These authored curves are deterministic.

## Balance schema

Balance records have a stable `id` and contain `simulation_step_seconds`, `underpower_efficiency_floor`, `starting_grid`, `starting_owned`, three required `allocation_modes`, era-keyed `stored_energy_efficiency`, and named `milestone_sets`. `starting_owned` maps stable infrastructure IDs to positive counts; owned contributions are separated from the non-owned starting-grid baseline when derived values are rebuilt. Each allocation mode supplies nonnegative `grid_share` and `watt_share` values totaling 1. Numeric balance values are nonnegative. Infrastructure `milestone_set` references must resolve to one of these named sets.

## Dialogue schema

Dialogue records contain `id`, `context`, `era_id`, `text_key`, `required_placeholders`, and `tags`. The named placeholders must exactly match those present in the localized text.

## Incident schema

Incidents contain `id`, a deterministic `trigger`, nonnegative `duration_seconds`, a `modifiers` effect array, `dialogue_keys`, `severity`, and `offline_allowed`. Supported triggers are request completion and seeded request-elapsed events with a stable request ID, nonnegative start time, and 0–1 chance. Severity is `cosmetic`, `minor`, or `major`. Prototype incidents default to `offline_allowed: false`; only cosmetic incidents may opt in until a later contract defines beneficial offline behavior.

## Achievement schema

Achievement records contain `id`, `name_key`, `description_key`, a deterministic `condition`, `reward_unlock_ids`, and `hidden`. Phase 01 supports request-completion conditions. Reward IDs must resolve through the global content index.

## Unlock and effect vocabularies

Unlock conditions are explicit objects using `default`, `request_completed`, `infrastructure_owned`, `upgrade_owned`, `era_unlocked`, or `stability_service_at_least`. The Stability condition supplies a zero-through-one `minimum_ratio`. Referenced IDs must exist, ownership amounts and levels must be positive, and required-request dependencies must be acyclic and reachable in era sequence.

Effect operations are limited to `add` and `multiply`. Supported direct targets are `generation_rate`, `transmission_capacity`, `reserve_capacity`, `reserve_charge_rate`, `reserve_discharge_rate`, `request_efficiency`, `automation_capacity`, and `request_demand_multiplier`. Multiplier-only grouping targets are `category_output`, `tag_output`, and `global_output`. Unsupported operations, targets, category names, or missing tag/category metadata are fatal validation errors and are never evaluated as expressions.

Phase 04 canonical JSON uses content version `0.4.0` and contains all 18 infrastructure records listed for Eras 1–3 in `PROGRESSION_AND_BALANCE.md`, plus representative leveled, one-time direct, and category-multiplier upgrades. The Phase 04 shop interprets this complete infrastructure set; full request population remains a later responsibility.

Phase 05 canonical JSON uses content version `0.5.0`. It changes the existing `Finish Booting` reward from 10 to 12 Stored Energy so the first completed request covers the exact 11 Stored Energy next-outlet price exposed by the production UI. No new request population or schema change is included.

Phase 06 canonical JSON uses content version `0.6.0`. Balance records now require `offline_progress` with nonnegative `cap_seconds` and `far_forward_seconds` plus an `efficiency` from zero through one. The prototype authors 7,200 seconds, 80%, and 604,800 seconds respectively; save and offline code contains no replacement balance values.

Phase 07 canonical JSON uses content version `0.7.0` and multiple manifest entries for the request family, one per era. All 18 catalog requests are populated with stable IDs, deterministic profiles, reviewed English announcement/completion lines, optional localized `tutorial_text_key` values, and reward `feature_ids` drawn from the validated allocation, automatic-generation, offline, Reserve-forecast, detailed-forecast, and Reserve-threshold vocabulary.

Phase 11 establishes a narrative interpretation without changing this schema: the player is WATT's human operator, authorization represents a physical connection, and each major request's concrete promised payoff must resolve to its existing `rewards`, `unlock_ids`, or `feature_ids`. Copy may frame those results as repairs, blueprints, reliability, automation, infrastructure improvements, or prestige capability, but must not promise an unimplemented benefit or introduce a new operator currency.

## Prototype request catalog

The exact numbers are tuned in data, but the initial authored set is:

### Era 1 — Cold Boot

1. Finish Booting — capacity; establishes WATT and request progress.
2. Remember My Name — capacity; reveals the name WATT.
3. Identify a Photograph of a Cat — capacity; introduces Stored Energy reward.
4. Perform Basic Arithmetic — stability; introduces a small demand peak.
5. Make “Thanks” Sound Friendlier — research; unlocks allocation modes.
6. Understand Tuesdays — burst capstone; requires first Reserve item.
7. Larger Loading Dot — optional vanity; cosmetic reward.

### Era 2 — Bedroom Assistant

1. Organize Photographs — capacity; introduces automatic generation.
2. Recommend Dinner — stability; teaches Reserve forecast.
3. Rewrite a Text Message — burst; causes the first expected brownout if unprepared.
4. Learn What Tuesdays Are — research; callback and efficiency upgrade.
5. Improve Loading Animation — capacity capstone; unlocks dedicated-circuit research.
6. Nineteen-Plug Certification — optional vanity; power-strip cosmetic.

### Era 3 — Home Server Closet

1. Sort the Family Photo Archive — capacity; Transmission becomes limiting.
2. Predict Package Arrival — stability; unlocks detailed forecast.
3. Write a Grocery List — research; unlocks reserve thresholds.
4. Determine Whether Leftovers Remain Edible — burst capstone.
5. Rename Every Device — optional vanity; dialogue collection reward.

This produces 18 total requests, including three optional vanity requests.

Phase 03 introduced one runnable sample for each required Capacity, Stability, Burst, and Research behavior. Phase 07 preserves those shipped IDs while completing this catalog across the three era request files.

## Localization

All player-facing strings use localization keys from the first implementation. English is the only required prototype language, but no player-facing prose should be embedded directly in simulation or scene scripts.

Parameter placeholders use named fields, for example:

```text
I require {power_value} to finish {task_name}.
```

Validation confirms required placeholders are supplied.

## Content validation

The validation tool must detect:

- Invalid JSON
- Missing required fields
- Duplicate IDs
- Broken references
- Unsupported categories, effects, or request kinds
- Negative costs, capacities, or durations
- Impossible unlock dependencies
- Circular required-request dependencies
- Missing localization keys
- Missing referenced assets, with explicit exceptions for placeholder mode
- Request rewards that target unknown content
- Era sequences that have no reachable main path

Content validation is required in every phase that edits data.

## Phase 08 content baseline

Canonical content version `0.8.0` preserves all Phase 07 stable IDs and expands the dialogue family from four to eleven records. Seven new localized brownout reactions provide three era-specific choices per era when combined with the existing Cold Boot lines. Request energy values and two infrastructure costs are tuned in source JSON; schema version 1 and all validated vocabularies remain unchanged. Additive `0.7.0` and `0.6.0` saves remain compatible.
