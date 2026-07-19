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

## Incident schema

Incidents contain authored timing or a deterministic trigger, duration, modifier list, dialogue keys, severity, and whether they may occur offline. Prototype incidents default to `offline_allowed: false` unless they are purely beneficial or cosmetic.

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

