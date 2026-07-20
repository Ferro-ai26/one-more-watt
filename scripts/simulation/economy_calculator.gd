class_name EconomyCalculator
extends RefCounted


static func infrastructure_cost(definition: InfrastructureDefinition, owned_count: int, amount: int = 1) -> float:
	if definition == null or owned_count < 0 or amount <= 0:
		return -1.0
	var base_cost := float(definition.get_value("base_cost", 0.0))
	var growth := float(definition.get_value("cost_growth", 1.0))
	if base_cost < 0.0 or growth < 1.0 or not is_finite(base_cost) or not is_finite(growth):
		return -1.0
	var total := 0.0
	for offset: int in amount:
		var item_cost: float = floor(base_cost * pow(growth, owned_count + offset))
		if not is_finite(item_cost) or item_cost < 0.0:
			return -1.0
		total += item_cost
		if not is_finite(total):
			return -1.0
	return total


static func upgrade_cost(definition: UpgradeDefinition, current_level: int) -> float:
	if definition == null or current_level < 0:
		return -1.0
	var costs: Dictionary = definition.get_value("cost", {})
	var base_cost := float(costs.get("stored_energy", 0.0))
	var growth := float(definition.get_value("cost_growth", 1.0))
	var cost: float = floor(base_cost * pow(growth, current_level))
	return cost if is_finite(cost) and cost >= 0.0 else -1.0


static func milestone_multiplier(definition: InfrastructureDefinition, owned_count: int, balance: BalanceDefinition) -> float:
	if definition == null or balance == null or owned_count <= 0:
		return 1.0
	var sets: Dictionary = balance.get_value("milestone_sets", {})
	var milestones: Array = sets.get(str(definition.get_value("milestone_set", "")), [])
	var multiplier := 1.0
	for milestone_value: Variant in milestones:
		if milestone_value is Dictionary and owned_count >= int(milestone_value.get("owned", 0)):
			multiplier = float(milestone_value.get("multiplier", multiplier))
	return maxf(multiplier, 0.0)


static func crossed_milestones(definition: InfrastructureDefinition, old_count: int, new_count: int, balance: BalanceDefinition) -> Array[Dictionary]:
	var crossed: Array[Dictionary] = []
	if definition == null or balance == null or new_count <= old_count:
		return crossed
	var sets: Dictionary = balance.get_value("milestone_sets", {})
	for milestone_value: Variant in sets.get(str(definition.get_value("milestone_set", "")), []):
		if milestone_value is Dictionary:
			var threshold := int(milestone_value.get("owned", 0))
			if old_count < threshold and new_count >= threshold:
				crossed.append((milestone_value as Dictionary).duplicate(true))
	return crossed
