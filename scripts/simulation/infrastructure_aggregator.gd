class_name InfrastructureAggregator
extends RefCounted

const AGGREGATE_KEYS := [
	"generation_rate", "transmission_capacity", "reserve_capacity",
	"reserve_charge_rate", "reserve_discharge_rate",
]


static func rebuild(owned: Dictionary, repository: ContentRepository, base_values: Dictionary = {}) -> Dictionary:
	var values: Dictionary = {}
	for key: String in AGGREGATE_KEYS:
		values[key] = maxf(float(base_values.get(key, 0.0)), 0.0)
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
		var effects: Dictionary = definition.get_value("base_effects", {})
		for effect_key: Variant in effects:
			if str(effect_key) in AGGREGATE_KEYS:
				values[effect_key] += float(effects[effect_key]) * int(count_value)

	values.make_read_only()
	return {"ok": errors.is_empty(), "values": values, "errors": errors}
