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
	if economy.state.prototype_complete:
		return ""
	return requests.get_next_available_request_id(true)


func authorize_current_request() -> bool:
	var request_id := current_request_id()
	if request_id.is_empty():
		return false
	var accepted := requests.authorize_request(request_id)
	if accepted:
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


func acknowledge_era_transition() -> bool:
	if not economy.acknowledge_era_transition():
		return false
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
	_sync_request_grid_from_economy()
	requests.refresh_availability(economy.state)
	economy.drain_events()
	requests.drain_events()
	return true


func _sync_economy_currency_from_request() -> void:
	economy.set_stored_energy(requests.grid.state.stored_energy)


func _sync_request_grid_from_economy() -> void:
	var reserve_stored := requests.grid.state.reserve_stored
	requests.grid.set_grid_values(economy.get_derived_values())
	requests.grid.state.reserve_stored = minf(reserve_stored, requests.grid.state.reserve_capacity)
	requests.grid.state.stored_energy = economy.state.stored_energy


func _announce_next_required_if_needed() -> void:
	if requests.get_active_state() != null or not requests.get_selected_request_id().is_empty() or not last_report_id.is_empty() or economy.state.prototype_complete:
		return
	var next_id := requests.get_next_available_request_id(true)
	if not next_id.is_empty():
		requests.announce_request(next_id)
