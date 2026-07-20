class_name MainViewModel
extends RefCounted

var session: GameSession


func _init(game_session: GameSession = null) -> void:
	session = game_session


func status_snapshot() -> Dictionary:
	var grid := session.requests.grid.state
	var derived := session.economy.get_derived_values()
	return {
		"era": session.repository.localize("era.01.name"),
		"scale": session.repository.localize("era.01.scale"),
		"stored_energy": grid.stored_energy,
		"deliverable_power": minf(grid.generation_rate, grid.transmission_capacity),
		"generation": grid.generation_rate,
		"transmission": grid.transmission_capacity,
		"reserve_stored": grid.reserve_stored,
		"reserve_capacity": grid.reserve_capacity,
		"reserve_rate": grid.reserve_discharge_rate,
		"request_efficiency": float(derived.get("request_efficiency", 0.0)),
	}


func request_snapshot() -> Dictionary:
	var request_id := session.current_request_id()
	if request_id.is_empty():
		return {"id": "", "status": "none", "title": "No request available", "dialogue": "WATT is considering the next sensible use of electricity."}
	var definition := session.repository.get_request(request_id)
	var state := session.requests.get_request_state(request_id)
	var preview := session.requests.build_preview(request_id)
	var dialogue := session.requests.current_dialogue
	if dialogue.is_empty():
		dialogue = session.repository.localize(str(definition.get_value("summary_key", "")))
	return {
		"id": request_id,
		"title": session.repository.localize(definition.get_title_key()),
		"kind": definition.get_kind(),
		"status": state.status,
		"progress": state.progress,
		"elapsed_seconds": state.elapsed_seconds,
		"dialogue": dialogue,
		"continuous_demand": preview.continuous_demand,
		"peak": preview.predicted_peak,
		"recommended_reserve": preview.recommended_reserve,
		"service_ratio": preview.predicted_service_ratio,
		"estimated_seconds": preview.estimated_seconds,
		"bottleneck": _current_bottleneck(preview),
		"underprepared": preview.underprepared,
		"warning": session.repository.localize(preview.warning_key) if not preview.warning_key.is_empty() else "Grid forecast is ready.",
		"reward": preview.reward_stored_energy,
		"unlocks": preview.unlock_ids.duplicate(),
	}


func infrastructure_cards() -> Array[Dictionary]:
	var definitions: Array = session.repository.get_all("infrastructure")
	var authored_order: Dictionary = {}
	for era_value: Variant in session.repository.get_all("eras"):
		var era := era_value as EraDefinition
		var era_ids: Array = era.get_value("infrastructure_ids", [])
		for index: int in era_ids.size():
			authored_order[str(era_ids[index])] = era.get_number() * 1000 + index
	definitions.sort_custom(func(a: InfrastructureDefinition, b: InfrastructureDefinition) -> bool:
		var order_a := int(authored_order.get(a.get_id(), 2147483647))
		var order_b := int(authored_order.get(b.get_id(), 2147483647))
		return a.get_id() < b.get_id() if order_a == order_b else order_a < order_b
	)
	var cards: Array[Dictionary] = []
	for value: Variant in definitions:
		var definition := value as InfrastructureDefinition
		cards.append(_economy_card(definition, session.preview_infrastructure(definition.get_id()), "infrastructure"))
	return cards


func upgrade_cards() -> Array[Dictionary]:
	var definitions: Array = session.repository.get_all("upgrades")
	definitions.sort_custom(func(a: UpgradeDefinition, b: UpgradeDefinition) -> bool: return a.get_id() < b.get_id())
	var cards: Array[Dictionary] = []
	for value: Variant in definitions:
		var definition := value as UpgradeDefinition
		cards.append(_economy_card(definition, session.preview_upgrade(definition.get_id()), "upgrade"))
	return cards


func reports() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for request_value: Variant in session.repository.get_all("requests"):
		var definition := request_value as RequestDefinition
		var report := session.requests.get_report(definition.get_id())
		if report != null:
			result.append(report_snapshot(report))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["id"]) < str(b["id"]))
	return result


func report_snapshot(report: PerformanceReport) -> Dictionary:
	var definition := session.repository.get_request(report.request_id)
	return {
		"id": report.request_id,
		"title": session.repository.localize(definition.get_title_key()),
		"grade": report.grade,
		"score": report.stability_score,
		"completion_seconds": report.completion_seconds,
		"service_ratio": report.demand_served_ratio,
		"peak_demand": report.peak_demand,
		"peak_served": report.peak_served,
		"brownout_seconds": report.brownout_seconds,
		"stored_energy": report.stored_energy_earned + report.reward_stored_energy,
		"unlock_ids": report.unlock_ids.duplicate(),
		"completion": session.repository.localize(report.completion_key),
		"suggestion": session.repository.localize(report.suggestion_key),
	}


func _economy_card(definition: ContentDefinition, preview: EconomyPreview, family: String) -> Dictionary:
	var ownership := ""
	if family == "infrastructure":
		ownership = "Owned %d" % int(session.economy.state.owned.get(definition.get_id(), 0))
	else:
		ownership = "Level %d/%d" % [preview.current_level, int(definition.get_value("max_level", 1))]
	var effect_parts: PackedStringArray = []
	for key: Variant in preview.deltas:
		var delta := float(preview.deltas[key])
		if absf(delta) > 0.000001:
			effect_parts.append("%s %+.1f" % [_friendly_key(str(key)), delta])
	if effect_parts.is_empty() and family == "infrastructure":
		for key: Variant in definition.get_value("base_effects", {}):
			effect_parts.append("%s +%s each" % [_friendly_key(str(key)), NumberFormatter.format_number(float(definition.get_value("base_effects", {})[key]))])
	var unmet: Array = preview.unmet_conditions
	return {
		"id": definition.get_id(),
		"family": family,
		"name": session.repository.localize(str(definition.get_value("name_key", ""))),
		"description": session.repository.localize(str(definition.get_value("description_key", ""))),
		"ownership": ownership,
		"status": preview.status,
		"cost": preview.cost,
		"missing": preview.missing_currency,
		"effect": "No immediate grid change" if effect_parts.is_empty() else " • ".join(effect_parts),
		"locked_reason": "" if unmet.is_empty() else _friendly_conditions(unmet),
		"can_purchase": preview.can_purchase(),
	}


func _current_bottleneck(preview: RequestPreview) -> String:
	var active := session.requests.get_active_state()
	if active != null:
		var live := session.requests.grid.get_last_result().limiting_constraint
		if live != "none":
			return live
	return preview.likely_bottleneck


static func _friendly_key(key: String) -> String:
	return key.replace("_rate", "").replace("_capacity", "").replace("_", " ").capitalize()


static func _friendly_conditions(conditions: Array) -> String:
	var result: PackedStringArray = []
	for value: Variant in conditions:
		var parts := str(value).split(":")
		match parts[0]:
			"request_completed": result.append("Complete %s" % str(parts[1]).replace("_", " ").capitalize())
			"infrastructure_owned": result.append("Own %s ×%s" % [str(parts[1]).replace("_", " ").capitalize(), parts[2]])
			"upgrade_owned": result.append("Upgrade %s to %s" % [str(parts[1]).replace("_", " ").capitalize(), parts[2]])
			"era_unlocked": result.append("Reach %s" % str(parts[1]).replace("_", " ").capitalize())
			_: result.append(str(value))
	return ", ".join(result)
