class_name InfrastructureAggregator
extends RefCounted

const AGGREGATE_KEYS := [
	"generation_rate", "transmission_capacity", "reserve_capacity",
	"reserve_charge_rate", "reserve_discharge_rate", "request_efficiency",
	"automation_capacity", "request_demand_multiplier",
]
const MULTIPLIER_TARGETS := ["category_output", "tag_output", "global_output"]


static func rebuild(
	owned: Dictionary,
	repository: ContentRepository,
	base_values: Dictionary = {},
	balance: BalanceDefinition = null,
	upgrade_levels: Dictionary = {}
) -> Dictionary:
	var values: Dictionary = {}
	var item_outputs: Dictionary = {}
	var direct_adds: Dictionary = {}
	var direct_multipliers: Dictionary = {}
	for key: String in AGGREGATE_KEYS:
		var default_value := 1.0 if key == "request_demand_multiplier" else 0.0
		values[key] = maxf(float(base_values.get(key, default_value)), 0.0)
		item_outputs[key] = 0.0
		direct_adds[key] = 0.0
		direct_multipliers[key] = 1.0
	var category_multipliers: Dictionary = {}
	var tag_multipliers: Dictionary = {}
	var global_group := {"value": 1.0}
	var errors: PackedStringArray = []

	for infrastructure_id: Variant in owned:
		var count_value: Variant = owned[infrastructure_id]
		if typeof(count_value) != TYPE_INT or int(count_value) < 0:
			errors.append("Owned count for '%s' must be a nonnegative integer" % infrastructure_id)
			continue
		var definition := repository.get_infrastructure(str(infrastructure_id))
		if definition == null:
			errors.append("Unknown infrastructure ID '%s'" % infrastructure_id)
			continue
		_apply_effects(
			definition.get_value("passive_effects", []), int(count_value),
			category_multipliers, tag_multipliers, direct_adds,
			direct_multipliers, global_group, errors
		)

	for upgrade_id: Variant in upgrade_levels:
		var level_value: Variant = upgrade_levels[upgrade_id]
		if typeof(level_value) != TYPE_INT or int(level_value) < 0:
			errors.append("Upgrade level for '%s' must be a nonnegative integer" % upgrade_id)
			continue
		var upgrade := repository.get_upgrade(str(upgrade_id))
		if upgrade == null:
			errors.append("Unknown upgrade ID '%s'" % upgrade_id)
			continue
		if int(level_value) > int(upgrade.get_value("max_level", 1)):
			errors.append("Upgrade level for '%s' exceeds max_level" % upgrade_id)
			continue
		_apply_effects(
			upgrade.get_effects(), int(level_value), category_multipliers,
			tag_multipliers, direct_adds, direct_multipliers, global_group, errors
		)
	var global_multiplier := float(global_group["value"])

	for infrastructure_id: Variant in owned:
		var count := int(owned[infrastructure_id])
		if count <= 0:
			continue
		var definition := repository.get_infrastructure(str(infrastructure_id))
		if definition == null:
			continue
		var output_multiplier := EconomyCalculator.milestone_multiplier(definition, count, balance)
		output_multiplier *= float(category_multipliers.get(definition.get_category(), 1.0))
		for tag_value: Variant in definition.get_value("tags", []):
			output_multiplier *= float(tag_multipliers.get(str(tag_value), 1.0))
		var effects: Dictionary = definition.get_value("base_effects", {})
		for effect_key: Variant in effects:
			var key := str(effect_key)
			if key in AGGREGATE_KEYS:
				item_outputs[key] += float(effects[effect_key]) * count * output_multiplier

	for key: String in AGGREGATE_KEYS:
		values[key] = (float(values[key]) + float(item_outputs[key]) + float(direct_adds[key])) * float(direct_multipliers[key])
		if key != "request_demand_multiplier":
			values[key] *= global_multiplier
		if not is_finite(float(values[key])) or float(values[key]) < 0.0:
			errors.append("Derived value '%s' is invalid" % key)
			values[key] = 0.0

	values.make_read_only()
	var multipliers := {
		"category": category_multipliers.duplicate(true),
		"tag": tag_multipliers.duplicate(true),
		"direct": direct_multipliers.duplicate(true),
		"global": global_multiplier,
	}
	multipliers.make_read_only()
	return {"ok": errors.is_empty(), "values": values, "multipliers": multipliers, "errors": errors}


static func _apply_effects(
	effects: Variant,
	repeats: int,
	category_multipliers: Dictionary,
	tag_multipliers: Dictionary,
	direct_adds: Dictionary,
	direct_multipliers: Dictionary,
	global_group: Dictionary,
	errors: PackedStringArray
) -> void:
	if repeats <= 0 or not effects is Array:
		return
	for effect_value: Variant in effects:
		if not effect_value is Dictionary:
			errors.append("Effect must be an object")
			continue
		var effect: Dictionary = effect_value
		var operation := str(effect.get("operation", ""))
		var target := str(effect.get("target", ""))
		var value := float(effect.get("value", 0.0))
		if operation == "multiply":
			var factor := pow(value, repeats)
			match target:
				"category_output":
					var category := str(effect.get("category", ""))
					category_multipliers[category] = float(category_multipliers.get(category, 1.0)) * factor
				"tag_output":
					var tag := str(effect.get("tag", ""))
					tag_multipliers[tag] = float(tag_multipliers.get(tag, 1.0)) * factor
				"global_output":
					global_group["value"] = float(global_group.get("value", 1.0)) * factor
				_:
					if direct_multipliers.has(target):
						direct_multipliers[target] = float(direct_multipliers[target]) * factor
					else:
						errors.append("Unsupported multiplier target '%s'" % target)
		elif operation == "add" and direct_adds.has(target):
			direct_adds[target] = float(direct_adds[target]) + value * repeats
		else:
			errors.append("Unsupported effect '%s:%s'" % [operation, target])
