class_name EconomySimulation
extends RefCounted

const EPSILON := 0.000000001

var state := EconomyState.new()
var grid := GridSimulation.new()

var _repository: ContentRepository
var _balance: BalanceDefinition
var _base_grid: Dictionary = {}
var _derived_values: Dictionary = {}
var _events: Array[EconomyEvent] = []


func configure(repository: ContentRepository, balance_id: String = "prototype_balance") -> bool:
	if repository == null or not repository.is_loaded():
		return false
	var balance := repository.get_balance(balance_id)
	if balance == null or not grid.configure(balance):
		return false
	_repository = repository
	_balance = balance
	state = EconomyState.new()
	var starting_grid: Dictionary = balance.get_value("starting_grid", {}).duplicate(true)
	state.stored_energy = float(starting_grid.get("stored_energy", 0.0))
	starting_grid.erase("stored_energy")
	_base_grid = starting_grid
	var starting_owned: Dictionary = balance.get_value("starting_owned", {})
	for id_value: Variant in starting_owned:
		var id := str(id_value)
		var count := int(starting_owned[id_value])
		state.owned[id] = count
		var definition := repository.get_infrastructure(id)
		if definition == null or count < 0:
			return false
		for effect_key: Variant in (definition.get_value("base_effects", {}) as Dictionary):
			var key := str(effect_key)
			if _base_grid.has(key):
				_base_grid[key] = maxf(float(_base_grid[key]) - float(definition.get_value("base_effects", {})[effect_key]) * count, 0.0)
	var first_era := _first_era_id()
	if not first_era.is_empty():
		state.unlocked_eras[first_era] = true
		state.current_era_id = first_era
	_events.clear()
	_refresh_unlocks(false)
	return rebuild_derived_state()


func set_stored_energy(value: float) -> bool:
	if not is_finite(value) or value < 0.0:
		return false
	state.stored_energy = value
	grid.state.stored_energy = value
	return true


func sync_currency_from_grid() -> void:
	state.stored_energy = grid.state.stored_energy


func preview_infrastructure(id: String, amount: int = 1) -> EconomyPreview:
	var preview := EconomyPreview.new()
	preview.content_id = id
	preview.family = "infrastructure"
	preview.amount = amount
	var definition := _repository.get_infrastructure(id)
	if definition == null or amount <= 0:
		return preview
	var owned_count := int(state.owned.get(id, 0))
	var unlock := UnlockEvaluator.evaluate(definition.get_value("unlock_conditions", []), state)
	if not bool(unlock["unlocked"]):
		preview.status = EconomyPreview.LOCKED
		preview.unmet_conditions = unlock["unmet"]
		return preview
	var max_owned: Variant = definition.get_value("max_owned", null)
	if max_owned != null and owned_count + amount > int(max_owned):
		preview.status = EconomyPreview.MAXED
		return preview
	preview.cost = EconomyCalculator.infrastructure_cost(definition, owned_count, amount)
	if preview.cost < 0.0:
		return preview
	var current_result := _rebuild_for(state.owned, state.upgrade_levels)
	var prospective_owned := state.owned.duplicate(true)
	prospective_owned[id] = owned_count + amount
	var prospective_result := _rebuild_for(prospective_owned, state.upgrade_levels)
	if not bool(current_result["ok"]) or not bool(prospective_result["ok"]):
		return preview
	preview.current_values = current_result["values"]
	preview.resulting_values = prospective_result["values"]
	preview.deltas = _deltas(preview.current_values, preview.resulting_values)
	preview.missing_currency = maxf(preview.cost - state.stored_energy, 0.0)
	preview.status = EconomyPreview.AFFORDABLE if preview.missing_currency <= EPSILON else EconomyPreview.UNAFFORDABLE
	return preview


func purchase_infrastructure(id: String, amount: int = 1) -> bool:
	var preview := preview_infrastructure(id, amount)
	if not preview.can_purchase():
		return false
	var old_count := int(state.owned.get(id, 0))
	var new_count := old_count + amount
	var prospective_owned := state.owned.duplicate(true)
	prospective_owned[id] = new_count
	var rebuilt := _rebuild_for(prospective_owned, state.upgrade_levels)
	if not bool(rebuilt["ok"]):
		return false
	state.stored_energy -= preview.cost
	state.owned = prospective_owned
	_apply_rebuild(rebuilt)
	_events.append(EconomyEvent.new(EconomyEvent.CURRENCY_CHANGED, "stored_energy", {"value": state.stored_energy, "delta": -preview.cost}))
	_events.append(EconomyEvent.new(EconomyEvent.INFRASTRUCTURE_PURCHASED, id, {"amount": amount, "owned": new_count, "cost": preview.cost}))
	for milestone: Dictionary in EconomyCalculator.crossed_milestones(_repository.get_infrastructure(id), old_count, new_count, _balance):
		var threshold := int(milestone.get("owned", 0))
		var milestone_key := "%s:%d" % [id, threshold]
		if state.awarded_milestones.has(milestone_key):
			continue
		state.awarded_milestones[milestone_key] = true
		_events.append(EconomyEvent.new(EconomyEvent.MILESTONE_REACHED, id, milestone))
	_refresh_unlocks(true)
	return true


func preview_upgrade(id: String) -> EconomyPreview:
	var preview := EconomyPreview.new()
	preview.content_id = id
	preview.family = "upgrade"
	preview.amount = 1
	var definition := _repository.get_upgrade(id)
	if definition == null:
		return preview
	var current_level := int(state.upgrade_levels.get(id, 0))
	preview.current_level = current_level
	preview.resulting_level = current_level + 1
	var unlock := UnlockEvaluator.evaluate(definition.get_value("unlock_conditions", []), state)
	if not bool(unlock["unlocked"]):
		preview.status = EconomyPreview.LOCKED
		preview.unmet_conditions = unlock["unmet"]
		return preview
	if current_level >= int(definition.get_value("max_level", 1)):
		preview.status = EconomyPreview.MAXED
		preview.resulting_level = current_level
		return preview
	preview.cost = EconomyCalculator.upgrade_cost(definition, current_level)
	if preview.cost < 0.0:
		return preview
	var current_result := _rebuild_for(state.owned, state.upgrade_levels)
	var prospective_levels := state.upgrade_levels.duplicate(true)
	prospective_levels[id] = current_level + 1
	var prospective_result := _rebuild_for(state.owned, prospective_levels)
	if not bool(current_result["ok"]) or not bool(prospective_result["ok"]):
		return preview
	preview.current_values = current_result["values"]
	preview.resulting_values = prospective_result["values"]
	preview.deltas = _deltas(preview.current_values, preview.resulting_values)
	preview.missing_currency = maxf(preview.cost - state.stored_energy, 0.0)
	preview.status = EconomyPreview.AFFORDABLE if preview.missing_currency <= EPSILON else EconomyPreview.UNAFFORDABLE
	return preview


func purchase_upgrade(id: String) -> bool:
	var preview := preview_upgrade(id)
	if not preview.can_purchase():
		return false
	var prospective_levels := state.upgrade_levels.duplicate(true)
	prospective_levels[id] = preview.resulting_level
	var rebuilt := _rebuild_for(state.owned, prospective_levels)
	if not bool(rebuilt["ok"]):
		return false
	state.stored_energy -= preview.cost
	state.upgrade_levels = prospective_levels
	_apply_rebuild(rebuilt)
	_events.append(EconomyEvent.new(EconomyEvent.CURRENCY_CHANGED, "stored_energy", {"value": state.stored_energy, "delta": -preview.cost}))
	_events.append(EconomyEvent.new(EconomyEvent.UPGRADE_PURCHASED, id, {"level": preview.resulting_level, "cost": preview.cost}))
	_refresh_unlocks(true)
	return true


func rebuild_derived_state() -> bool:
	var rebuilt := _rebuild_for(state.owned, state.upgrade_levels)
	if not bool(rebuilt["ok"]):
		return false
	_apply_rebuild(rebuilt)
	return true


func get_derived_values() -> Dictionary:
	return _derived_values.duplicate(true)


func snapshot() -> Dictionary:
	return state.snapshot()


func restore(data: Dictionary, repository: ContentRepository, balance_id: String = "prototype_balance") -> bool:
	if not configure(repository, balance_id):
		return false
	var restored := EconomyState.new()
	if not restored.restore(data):
		return false
	if repository.get_era(restored.current_era_id) == null:
		return false
	if not restored.pending_era_transition_id.is_empty() and repository.get_era(restored.pending_era_transition_id) == null:
		return false
	state = restored
	_events.clear()
	_refresh_unlocks(false)
	return rebuild_derived_state()


func mark_request_completed(id: String) -> void:
	state.completed_requests[id] = true
	_refresh_unlocks(true)


func record_request_report(report: PerformanceReport) -> void:
	if report == null:
		return
	state.completed_requests[report.request_id] = true
	if report.kind == "stability":
		state.best_stability_service_ratio = maxf(state.best_stability_service_ratio, report.demand_served_ratio)
	var definition := _repository.get_request(report.request_id)
	if definition != null:
		var rewards: Dictionary = definition.get_value("rewards", {})
		for feature_value: Variant in rewards.get("feature_ids", []):
			var feature_id := str(feature_value)
			if feature_id.is_empty() or state.unlocked_features.has(feature_id):
				continue
			state.unlocked_features[feature_id] = true
			_events.append(EconomyEvent.new(EconomyEvent.FEATURE_UNLOCKED, feature_id))
	_refresh_unlocks(true)


func mark_report_viewed(request_id: String) -> bool:
	var definition := _repository.get_request(request_id)
	if definition == null or "prototype_capstone" not in definition.get_value("tags", []) or state.prototype_complete:
		return false
	state.prototype_complete = true
	_events.append(EconomyEvent.new(EconomyEvent.PROTOTYPE_COMPLETED, request_id))
	return true


func has_feature(feature_id: String) -> bool:
	return state.unlocked_features.has(feature_id)


func acknowledge_era_transition() -> bool:
	if state.pending_era_transition_id.is_empty():
		return false
	state.pending_era_transition_id = ""
	return true


func unlock_era(id: String) -> bool:
	if _repository.get_era(id) == null:
		return false
	state.unlocked_eras[id] = true
	_refresh_unlocks(true)
	return true


func configure_reserve_automation(enabled: bool, threshold_ratio: float) -> bool:
	if not is_finite(threshold_ratio) or threshold_ratio < 0.0 or threshold_ratio > 1.0:
		return false
	if enabled and not _owns_automation():
		return false
	state.reserve_automation_enabled = enabled
	state.reserve_threshold_ratio = threshold_ratio
	_events.append(EconomyEvent.new(EconomyEvent.AUTOMATION_CHANGED, "reserve_threshold", {"enabled": enabled, "threshold_ratio": threshold_ratio}))
	return true


func apply_safe_throttle(requested_demand: float) -> Dictionary:
	if not is_finite(requested_demand) or requested_demand < 0.0:
		return {"ok": false, "demand_rate": 0.0, "throttled": false}
	var demand := requested_demand
	var throttled := false
	var reserve_ratio := 0.0 if grid.state.reserve_capacity <= EPSILON else grid.state.reserve_stored / grid.state.reserve_capacity
	if state.reserve_automation_enabled and reserve_ratio + EPSILON < state.reserve_threshold_ratio:
		demand = minf(requested_demand, minf(grid.state.generation_rate, grid.state.transmission_capacity))
		throttled = demand + EPSILON < requested_demand
		if throttled:
			_events.append(EconomyEvent.new(EconomyEvent.DEMAND_THROTTLED, "reserve_threshold", {"requested": requested_demand, "applied": demand}))
	return {"ok": true, "demand_rate": demand, "throttled": throttled}


func drain_events() -> Array[EconomyEvent]:
	var drained := _events.duplicate()
	_events.clear()
	return drained


func _rebuild_for(owned: Dictionary, levels: Dictionary) -> Dictionary:
	return InfrastructureAggregator.rebuild(owned, _repository, _base_grid, _balance, levels)


func _apply_rebuild(rebuilt: Dictionary) -> void:
	_derived_values = (rebuilt["values"] as Dictionary).duplicate(true)
	grid.state.apply_grid_values(_derived_values)
	grid.state.stored_energy = state.stored_energy
	_events.append(EconomyEvent.new(EconomyEvent.GRID_REBUILT, "grid", {"values": _derived_values}))


func _refresh_unlocks(emit_events: bool) -> void:
	_refresh_era_unlocks(emit_events)
	for family: String in ["infrastructure", "upgrades"]:
		for definition_value: Variant in _repository.get_all(family):
			var definition := definition_value as ContentDefinition
			var unlocked := bool(UnlockEvaluator.evaluate(definition.get_value("unlock_conditions", []), state)["unlocked"])
			if unlocked and not state.unlocked_content.has(definition.get_id()):
				state.unlocked_content[definition.get_id()] = true
				if emit_events:
					_events.append(EconomyEvent.new(EconomyEvent.CONTENT_UNLOCKED, definition.get_id(), {"family": family}))


func _refresh_era_unlocks(emit_events: bool) -> void:
	var eras: Array = _repository.get_all("eras")
	eras.sort_custom(func(a: EraDefinition, b: EraDefinition) -> bool: return a.get_number() < b.get_number())
	for era_value: Variant in eras:
		var era := era_value as EraDefinition
		if state.unlocked_eras.has(era.get_id()):
			continue
		if not bool(UnlockEvaluator.evaluate(era.get_value("unlock_conditions", []), state)["unlocked"]):
			continue
		state.unlocked_eras[era.get_id()] = true
		state.current_era_id = era.get_id()
		state.pending_era_transition_id = era.get_id()
		if emit_events:
			_events.append(EconomyEvent.new(EconomyEvent.ERA_CHANGED, era.get_id(), {"number": era.get_number()}))


func _owns_automation() -> bool:
	for id_value: Variant in state.owned:
		if int(state.owned[id_value]) <= 0:
			continue
		var definition := _repository.get_infrastructure(str(id_value))
		if definition != null and definition.get_category() == "automation":
			return true
	return false


func _first_era_id() -> String:
	var first_id := ""
	var first_number := 2147483647
	for era_value: Variant in _repository.get_all("eras"):
		var era := era_value as EraDefinition
		if era != null and era.get_number() < first_number:
			first_number = era.get_number()
			first_id = era.get_id()
	return first_id


static func _deltas(current: Dictionary, resulting: Dictionary) -> Dictionary:
	var deltas: Dictionary = {}
	for key: Variant in resulting:
		deltas[key] = float(resulting[key]) - float(current.get(key, 0.0))
	deltas.make_read_only()
	return deltas
