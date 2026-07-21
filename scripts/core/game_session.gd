class_name GameSession
extends RefCounted

signal mutation_committed(trigger: String)

var economy := EconomySimulation.new()
var requests := RequestSimulation.new()
var settings := RuntimeSettings.new()
var feedback := FeedbackHooks.new(settings)
var repository: ContentRepository
var last_report_id := ""
var run_id := ""


func configure(content_repository: ContentRepository) -> bool:
	if content_repository == null or not content_repository.is_loaded():
		return false
	repository = content_repository
	run_id = "%d-%d" % [Time.get_unix_time_from_system(), randi()]
	if not economy.configure(repository) or not requests.configure(repository):
		return false
	requests.refresh_availability(economy.state)
	last_report_id = ""
	_sync_request_grid_from_economy()
	_announce_next_required_if_needed()
	return true


func current_request_id() -> String:
	if has_pending_maintenance():
		return ""
	var active := requests.get_active_state()
	if active != null:
		return active.request_id
	var selected_id := requests.get_selected_request_id()
	if not selected_id.is_empty():
		return selected_id
	for request_value: Variant in repository.get_all("requests"):
		var definition := request_value as RequestDefinition
		var state := requests.get_request_state(definition.get_id())
		if state != null and state.status in [RequestRunState.ANNOUNCED, RequestRunState.AUTHORIZED, RequestRunState.COMPLETED]:
			return definition.get_id()
	return requests.get_next_available_request_id(true)


func authorize_current_request() -> bool:
	if has_pending_maintenance():
		return false
	var request_id := current_request_id()
	if request_id.is_empty():
		return false
	var accepted := requests.authorize_request(request_id)
	if accepted:
		if not economy.state.temporary_effects.is_empty() and economy.state.temporary_effect_request_id.is_empty():
			economy.state.temporary_effect_request_id = request_id
			_sync_request_grid_from_economy()
		accepted = requests.start_request(request_id)
		if accepted:
			feedback.request("request_started", true)
			mutation_committed.emit("request_started")
	return accepted


func advance_time(delta_seconds: float, offline: bool = false) -> bool:
	var active := requests.get_active_state()
	if active == null:
		return false
	var active_id := active.request_id
	var accepted := requests.advance_time(delta_seconds, offline)
	if not accepted:
		return false
	economy.set_stored_energy(requests.grid.state.stored_energy)
	var completed_state := requests.get_request_state(active_id)
	if completed_state != null and completed_state.status == RequestRunState.COMPLETED:
		economy.record_request_report(requests.get_report(active_id))
		_activate_maintenance_for_request(active_id)
		if economy.state.temporary_effect_request_id == active_id:
			economy.state.temporary_effect_request_id = ""
			economy.state.temporary_effects.clear()
			_sync_request_grid_from_economy()
		requests.refresh_availability(economy.state)
		last_report_id = active_id
		feedback.request("request_complete", true)
		mutation_committed.emit("request_completed")
	elif requests.grid.get_last_result().brownout_started:
		feedback.request("brownout")
		mutation_committed.emit("progress")
	else:
		mutation_committed.emit("progress")
	return true


func advance_idle_time(delta_seconds: float) -> bool:
	if requests.get_active_state() != null or not is_finite(delta_seconds) or delta_seconds < 0.0:
		return false
	var remaining := delta_seconds
	while remaining > 0.000000001:
		var chunk := minf(remaining, GridSimulation.MAX_ACTIVE_ADVANCE_SECONDS)
		requests.grid.set_demand_rate(0.0)
		if not requests.grid.advance_time(chunk):
			return false
		remaining -= chunk
	economy.set_stored_energy(requests.grid.state.stored_energy)
	mutation_committed.emit("progress")
	return true


func acknowledge_report(request_id: String) -> bool:
	if not requests.acknowledge_report(request_id):
		return false
	if request_id == last_report_id:
		last_report_id = ""
	var endpoint_reached := economy.mark_report_viewed(request_id)
	_announce_next_required_if_needed()
	mutation_committed.emit("prototype_completed" if endpoint_reached else "report_acknowledged")
	return true


func set_allocation_mode(mode: String) -> bool:
	if mode != requests.grid.state.allocation_mode and not has_feature("allocation_modes"):
		return false
	var accepted := requests.set_allocation_mode(mode)
	if accepted:
		feedback.request("allocation_changed")
		mutation_committed.emit("allocation_changed")
	return accepted


func purchase_infrastructure(id: String, amount: int = 1) -> bool:
	_sync_economy_currency_from_request()
	if not economy.purchase_infrastructure(id, amount):
		feedback.request("error")
		return false
	_sync_request_grid_from_economy()
	requests.refresh_availability(economy.state)
	_announce_next_required_if_needed()
	feedback.request("purchase", true)
	mutation_committed.emit("purchase")
	return true


func purchase_upgrade(id: String) -> bool:
	_sync_economy_currency_from_request()
	if not economy.purchase_upgrade(id):
		feedback.request("error")
		return false
	_sync_request_grid_from_economy()
	requests.refresh_availability(economy.state)
	_announce_next_required_if_needed()
	feedback.request("purchase", true)
	mutation_committed.emit("purchase")
	return true


func preview_infrastructure(id: String, amount: int = 1) -> EconomyPreview:
	_sync_economy_currency_from_request()
	return economy.preview_infrastructure(id, amount)


func preview_upgrade(id: String) -> EconomyPreview:
	_sync_economy_currency_from_request()
	return economy.preview_upgrade(id)


func choose_request(request_id: String) -> bool:
	if not requests.select_request(request_id):
		return false
	mutation_committed.emit("request_selected")
	return true


func skip_current_optional_request() -> bool:
	var request_id := current_request_id()
	if request_id.is_empty() or not requests.skip_request(request_id):
		return false
	var next_id := requests.get_next_available_request_id(true)
	if not next_id.is_empty():
		requests.announce_request(next_id)
	mutation_committed.emit("request_skipped")
	return true


func available_optional_request_ids() -> Array[String]:
	return requests.get_available_optional_request_ids()


func has_feature(feature_id: String) -> bool:
	return economy.has_feature(feature_id)


func configure_reserve_automation(enabled: bool, threshold_ratio: float) -> bool:
	if not has_feature("reserve_thresholds") or not economy.configure_reserve_automation(enabled, threshold_ratio):
		return false
	mutation_committed.emit("automation_changed")
	return true


func configure_reserve_policy(preset: String, enabled: bool = true) -> bool:
	if not has_feature("reserve_policy") or preset not in ["conservative", "balanced", "max_throughput"]:
		return false
	var settings_by_preset := {
		"conservative": {"floor": 0.60, "start": 0.85},
		"balanced": {"floor": 0.35, "start": 0.70},
		"max_throughput": {"floor": 0.15, "start": 0.40},
	}
	var policy: Dictionary = settings_by_preset[preset]
	economy.state.reserve_policy_preset = preset
	economy.state.reserve_automation_enabled = enabled
	economy.state.reserve_threshold_ratio = float(policy["floor"])
	economy.state.request_start_target_ratio = float(policy["start"])
	_sync_runtime_modifiers()
	economy.state.record_automation_action("reserve_policy", preset, "configured", {"enabled": enabled, "floor_ratio": policy["floor"], "start_target_ratio": policy["start"]})
	feedback.request("automation_changed")
	mutation_committed.emit("automation_changed")
	return true


func configure_reserve_policy_custom(enabled: bool, floor_ratio: float, start_target_ratio: float) -> bool:
	if not has_feature("reserve_policy") or not is_finite(floor_ratio) or floor_ratio < 0.0 or floor_ratio > 1.0 or not is_finite(start_target_ratio) or start_target_ratio < 0.0 or start_target_ratio > 1.0:
		return false
	economy.state.reserve_policy_preset = "custom"
	economy.state.reserve_automation_enabled = enabled
	economy.state.reserve_threshold_ratio = floor_ratio
	economy.state.request_start_target_ratio = start_target_ratio
	_sync_runtime_modifiers()
	economy.state.record_automation_action("reserve_policy", "custom", "configured", {"enabled": enabled, "floor_ratio": floor_ratio, "start_target_ratio": start_target_ratio})
	mutation_committed.emit("automation_changed")
	return true


func configure_routine_automation(enabled: bool, maximum_cost: float) -> bool:
	if not has_feature("routine_maintenance_automation") or not is_finite(maximum_cost) or maximum_cost < 0.0:
		return false
	economy.state.routine_automation_enabled = enabled
	economy.state.routine_automation_max_cost = maximum_cost
	economy.state.record_automation_action("routine_automation", "maintenance", "configured", {"enabled": enabled, "maximum_cost": maximum_cost})
	try_resolve_routine_maintenance()
	mutation_committed.emit("automation_changed")
	return true


func schedule_current_request(rule: String) -> bool:
	if not has_feature("request_scheduling") or rule not in ["reserve_target", "next_return_safe"] or has_pending_maintenance() or not economy.state.scheduled_request_id.is_empty():
		return false
	var request_id := current_request_id()
	var state := requests.get_request_state(request_id)
	if request_id.is_empty() or state == null or state.status not in [RequestRunState.ANNOUNCED, RequestRunState.AUTHORIZED]:
		return false
	if state.status == RequestRunState.ANNOUNCED and not requests.authorize_request(request_id):
		return false
	economy.state.scheduled_request_id = request_id
	economy.state.scheduled_start_rule = rule
	economy.state.scheduled_target_ratio = economy.state.request_start_target_ratio
	economy.state.record_automation_action("request_schedule", request_id, "armed", {"rule": rule, "target_ratio": economy.state.scheduled_target_ratio})
	feedback.request("request_scheduled", true)
	mutation_committed.emit("request_scheduled")
	return true


func cancel_scheduled_request() -> bool:
	var request_id := economy.state.scheduled_request_id
	if request_id.is_empty() or not requests.cancel_authorization(request_id):
		return false
	economy.state.scheduled_request_id = ""
	economy.state.scheduled_start_rule = ""
	economy.state.record_automation_action("request_schedule", request_id, "cancelled")
	mutation_committed.emit("request_schedule_cancelled")
	return true


func try_start_scheduled_request() -> bool:
	var request_id := economy.state.scheduled_request_id
	if request_id.is_empty() or has_pending_maintenance() or requests.get_active_state() != null:
		return false
	var reserve_ratio := 1.0 if requests.grid.state.reserve_capacity <= 0.000000001 else requests.grid.state.reserve_stored / requests.grid.state.reserve_capacity
	var ready := reserve_ratio + 0.000000001 >= economy.state.scheduled_target_ratio
	if economy.state.scheduled_start_rule == "next_return_safe":
		ready = not requests.build_preview(request_id).underprepared
	if not ready or not requests.start_request(request_id):
		return false
	economy.state.scheduled_request_id = ""
	economy.state.scheduled_start_rule = ""
	economy.state.record_automation_action("request_schedule", request_id, "started", {"reserve_ratio": reserve_ratio})
	feedback.request("request_started", true)
	mutation_committed.emit("scheduled_request_started")
	return true


func automation_actions_since(sequence: int) -> Array:
	return economy.state.automation_actions_since(sequence)


func configure_predictive_reserve_guard(enabled: bool, target_ratio: float) -> bool:
	if not has_feature("predictive_reserve_guard") or not economy.configure_predictive_reserve_guard(enabled, target_ratio):
		return false
	_sync_runtime_modifiers()
	mutation_committed.emit("automation_changed")
	return true


func has_pending_maintenance() -> bool:
	return not economy.state.pending_maintenance_id.is_empty()


func maintenance_snapshot() -> Dictionary:
	var maintenance := repository.get_maintenance(economy.state.pending_maintenance_id) if repository != null else null
	if maintenance == null:
		return {}
	var options: Array[Dictionary] = []
	for option_value: Variant in maintenance.get_value("options", []):
		var option: Dictionary = option_value
		options.append({
			"id": str(option.get("id", "")),
			"label": repository.localize(str(option.get("label_key", ""))),
			"description": repository.localize(str(option.get("description_key", ""))),
			"cost": float(option.get("stored_energy_cost", 0.0)),
			"affordable": requests.grid.state.stored_energy + 0.000000001 >= float(option.get("stored_energy_cost", 0.0)),
		})
	return {
		"id": maintenance.get_id(),
		"title": repository.localize(str(maintenance.get_value("title_key", ""))),
		"description": repository.localize(str(maintenance.get_value("description_key", ""))),
		"options": options,
	}


func choose_maintenance(option_id: String) -> bool:
	if not has_pending_maintenance():
		return false
	var maintenance := repository.get_maintenance(economy.state.pending_maintenance_id)
	if maintenance == null or economy.state.maintenance_choices.has(maintenance.get_id()):
		return false
	return _resolve_maintenance(maintenance, option_id, false)


func _resolve_maintenance(maintenance: MaintenanceDefinition, option_id: String, automated: bool) -> bool:
	var option := maintenance.get_option(option_id)
	if option.is_empty():
		return false
	_sync_economy_currency_from_request()
	var cost := float(option.get("stored_energy_cost", 0.0))
	if economy.state.stored_energy + 0.000000001 < cost:
		return false
	if not economy.set_stored_energy(economy.state.stored_energy - cost):
		return false
	var grant_value: Variant = option.get("grant_upgrade_id", null)
	if grant_value != null and not economy.grant_upgrade(str(grant_value)):
		economy.set_stored_energy(economy.state.stored_energy + cost)
		return false
	economy.state.maintenance_choices[maintenance.get_id()] = option_id
	economy.state.pending_maintenance_id = ""
	economy.state.temporary_effects = (option.get("next_request_effects", []) as Array).duplicate(true)
	economy.state.temporary_effect_request_id = ""
	_sync_request_grid_from_economy()
	requests.refresh_availability(economy.state)
	_announce_next_required_if_needed()
	feedback.request("maintenance_decision", true)
	mutation_committed.emit("maintenance_choice")
	if automated:
		var action := economy.state.record_automation_action("routine_maintenance", maintenance.get_id(), "resolved", {"option_id": option_id, "cost": cost, "reason": "authored_safe_action_within_operator_cap", "simulation_seconds": requests.grid.state.elapsed_seconds})
		_append_maintenance_action_to_report(maintenance, action)
		feedback.request("automation_action", true)
	return true


func acknowledge_era_transition() -> bool:
	if not economy.acknowledge_era_transition():
		return false
	feedback.request("era_transition", true)
	mutation_committed.emit("era_transition")
	return true


func snapshot() -> Dictionary:
	return {
		"run_id": run_id,
		"economy": economy.snapshot(),
		"requests": requests.snapshot(),
		"settings": settings.snapshot(),
		"last_report_id": last_report_id,
		"prestige": {"model_weights": 0, "permanent_upgrade_ids": []},
		"lifetime": {},
		"tutorial": {},
	}


func restore(data: Dictionary, content_repository: ContentRepository) -> bool:
	if content_repository == null or not content_repository.is_loaded():
		return false
	repository = content_repository
	if not economy.restore(data.get("economy", {}), repository):
		return false
	if not requests.restore(data.get("requests", {}), repository):
		return false
	for request_value: Variant in repository.get_all("requests"):
		var report := requests.get_report((request_value as RequestDefinition).get_id())
		if report != null:
			economy.record_request_report(report)
	if absf(economy.state.stored_energy - requests.grid.state.stored_energy) > 0.000001:
		return false
	if not settings.restore(data.get("settings", {})):
		return false
	run_id = str(data.get("run_id", ""))
	if run_id.is_empty():
		return false
	last_report_id = str(data.get("last_report_id", ""))
	if not _validate_maintenance_state():
		return false
	_validate_operator_state()
	_sync_request_grid_from_economy()
	requests.refresh_availability(economy.state)
	economy.drain_events()
	requests.drain_events()
	return true


func _sync_economy_currency_from_request() -> void:
	economy.set_stored_energy(requests.grid.state.stored_energy)


func _sync_request_grid_from_economy() -> void:
	var reserve_stored := requests.grid.state.reserve_stored
	var values := economy.get_derived_values()
	var demand_multiplier := float(values.get("request_demand_multiplier", 1.0))
	for effect_value: Variant in economy.state.temporary_effects:
		if not effect_value is Dictionary:
			continue
		var effect: Dictionary = effect_value
		var target := str(effect.get("target", ""))
		var operation := str(effect.get("operation", ""))
		var effect_value_number := float(effect.get("value", 0.0))
		if target == "request_demand_multiplier":
			demand_multiplier = demand_multiplier * effect_value_number if operation == "multiply" else demand_multiplier + effect_value_number
		elif values.has(target):
			values[target] = float(values[target]) * effect_value_number if operation == "multiply" else float(values[target]) + effect_value_number
	requests.grid.set_grid_values(values)
	requests.grid.state.reserve_stored = minf(reserve_stored, requests.grid.state.reserve_capacity)
	requests.grid.state.stored_energy = economy.state.stored_energy
	requests.configure_runtime_modifiers(demand_multiplier, economy.state.predictive_reserve_guard_enabled, economy.state.predictive_reserve_target_ratio, economy.state.reserve_automation_enabled and has_feature("reserve_policy"), economy.state.reserve_threshold_ratio)


func _sync_runtime_modifiers() -> void:
	_sync_request_grid_from_economy()


func _announce_next_required_if_needed() -> void:
	if requests.get_active_state() != null or not requests.get_selected_request_id().is_empty() or not last_report_id.is_empty() or has_pending_maintenance():
		return
	var next_id := requests.get_next_available_request_id(true)
	if not next_id.is_empty():
		requests.announce_request(next_id)


func _activate_maintenance_for_request(request_id: String) -> void:
	if has_pending_maintenance():
		return
	for maintenance_value: Variant in repository.get_all("maintenance"):
		var maintenance := maintenance_value as MaintenanceDefinition
		if maintenance != null and maintenance.get_trigger_request_id() == request_id and not economy.state.maintenance_choices.has(maintenance.get_id()):
			economy.state.pending_maintenance_id = maintenance.get_id()
			try_resolve_routine_maintenance()
			return


func try_resolve_routine_maintenance() -> bool:
	if not has_pending_maintenance() or not economy.state.routine_automation_enabled:
		return false
	var maintenance := repository.get_maintenance(economy.state.pending_maintenance_id)
	if maintenance == null or not maintenance.is_automation_eligible():
		_record_automation_block_once(economy.state.pending_maintenance_id, "strategic_or_ineligible")
		return false
	var option_id := maintenance.get_safe_option_id()
	var option := maintenance.get_option(option_id)
	var cost := float(option.get("stored_energy_cost", INF))
	if cost > economy.state.routine_automation_max_cost + 0.000000001:
		_record_automation_block_once(maintenance.get_id(), "operator_cost_cap")
		return false
	if requests.grid.state.stored_energy + 0.000000001 < cost:
		_record_automation_block_once(maintenance.get_id(), "insufficient_stored_energy")
		return false
	return _resolve_maintenance(maintenance, option_id, true)


func _record_automation_block_once(target_id: String, reason: String) -> void:
	if not economy.state.automation_history.is_empty():
		var latest: Dictionary = economy.state.automation_history[-1]
		if str(latest.get("type", "")) == "routine_maintenance" and str(latest.get("target_id", "")) == target_id and str(latest.get("outcome", "")) == "blocked" and str(latest.get("reason", "")) == reason:
			return
	var action := economy.state.record_automation_action("routine_maintenance", target_id, "blocked", {"reason": reason, "simulation_seconds": requests.grid.state.elapsed_seconds})
	var maintenance := repository.get_maintenance(target_id)
	if maintenance != null:
		_append_maintenance_action_to_report(maintenance, action)


func _append_maintenance_action_to_report(maintenance: MaintenanceDefinition, action: Dictionary) -> void:
	var report := requests.get_report(maintenance.get_trigger_request_id())
	if report != null:
		report.automation_actions.append(action.duplicate(true))


func _validate_maintenance_state() -> bool:
	if not economy.state.pending_maintenance_id.is_empty() and repository.get_maintenance(economy.state.pending_maintenance_id) == null:
		return false
	for maintenance_id_value: Variant in economy.state.maintenance_choices:
		var maintenance := repository.get_maintenance(str(maintenance_id_value))
		if maintenance == null or maintenance.get_option(str(economy.state.maintenance_choices[maintenance_id_value])).is_empty():
			return false
	if not economy.state.temporary_effect_request_id.is_empty() and repository.get_request(economy.state.temporary_effect_request_id) == null:
		return false
	return true


func _validate_operator_state() -> void:
	var scheduled_id := economy.state.scheduled_request_id
	if scheduled_id.is_empty():
		return
	var scheduled_state := requests.get_request_state(scheduled_id)
	if repository.get_request(scheduled_id) != null and scheduled_state != null and scheduled_state.status == RequestRunState.AUTHORIZED:
		return
	economy.state.scheduled_request_id = ""
	economy.state.scheduled_start_rule = ""
	economy.state.record_automation_action("request_schedule", scheduled_id, "invalidated", {"reason": "saved_reference_unavailable"})
