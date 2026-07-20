class_name UnlockEvaluator
extends RefCounted


static func evaluate(conditions: Variant, state: EconomyState) -> Dictionary:
	var unmet: Array[String] = []
	if not conditions is Array:
		return {"unlocked": false, "unmet": ["invalid_conditions"]}
	for condition_value: Variant in conditions:
		if not condition_value is Dictionary:
			unmet.append("invalid_condition")
			continue
		var condition: Dictionary = condition_value
		match str(condition.get("type", "")):
			"default":
				continue
			"request_completed":
				var request_id := str(condition.get("request_id", ""))
				if not state.completed_requests.has(request_id):
					unmet.append("request_completed:%s" % request_id)
			"infrastructure_owned":
				var infrastructure_id := str(condition.get("infrastructure_id", ""))
				var amount := int(condition.get("amount", 0))
				if int(state.owned.get(infrastructure_id, 0)) < amount:
					unmet.append("infrastructure_owned:%s:%d" % [infrastructure_id, amount])
			"upgrade_owned":
				var upgrade_id := str(condition.get("upgrade_id", ""))
				var level := int(condition.get("level", 0))
				if int(state.upgrade_levels.get(upgrade_id, 0)) < level:
					unmet.append("upgrade_owned:%s:%d" % [upgrade_id, level])
			"era_unlocked":
				var era_id := str(condition.get("era_id", ""))
				if not state.unlocked_eras.has(era_id):
					unmet.append("era_unlocked:%s" % era_id)
			"stability_service_at_least":
				var minimum_ratio := float(condition.get("minimum_ratio", 1.0))
				if state.best_stability_service_ratio + 0.000000001 < minimum_ratio:
					unmet.append("stability_service_at_least:%.2f" % minimum_ratio)
			"maintenance_choice":
				var maintenance_id := str(condition.get("maintenance_id", ""))
				var option_id := str(condition.get("option_id", ""))
				if str(state.maintenance_choices.get(maintenance_id, "")) != option_id:
					unmet.append("maintenance_choice:%s:%s" % [maintenance_id, option_id])
			_:
				unmet.append("unsupported_condition:%s" % condition.get("type", ""))
	return {"unlocked": unmet.is_empty(), "unmet": unmet}
