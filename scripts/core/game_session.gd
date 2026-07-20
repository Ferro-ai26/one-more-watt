class_name GameSession
extends RefCounted

var economy := EconomySimulation.new()
var requests := RequestSimulation.new()
var settings := RuntimeSettings.new()
var feedback := FeedbackHooks.new(settings)
var repository: ContentRepository
var last_report_id := ""


func configure(content_repository: ContentRepository) -> bool:
	if content_repository == null or not content_repository.is_loaded():
		return false
	repository = content_repository
	if not economy.configure(repository) or not requests.configure(repository):
		return false
	last_report_id = ""
	_sync_request_grid_from_economy()
	var next_id := requests.get_next_available_request_id()
	if not next_id.is_empty():
		requests.announce_request(next_id)
	return true


func current_request_id() -> String:
	var active := requests.get_active_state()
	if active != null:
		return active.request_id
	for request_value: Variant in repository.get_all("requests"):
		var definition := request_value as RequestDefinition
		var state := requests.get_request_state(definition.get_id())
		if state != null and state.status in [RequestRunState.ANNOUNCED, RequestRunState.AUTHORIZED, RequestRunState.COMPLETED]:
			return definition.get_id()
	return requests.get_next_available_request_id()


func authorize_current_request() -> bool:
	var request_id := current_request_id()
	if request_id.is_empty():
		return false
	var accepted := requests.authorize_request(request_id)
	if accepted:
		accepted = requests.start_request(request_id)
		if accepted:
			feedback.request("request_started", true)
	return accepted


func advance_time(delta_seconds: float) -> bool:
	var active := requests.get_active_state()
	if active == null:
		return false
	var active_id := active.request_id
	var accepted := requests.advance_time(delta_seconds)
	if not accepted:
		return false
	economy.set_stored_energy(requests.grid.state.stored_energy)
	var completed_state := requests.get_request_state(active_id)
	if completed_state != null and completed_state.status == RequestRunState.COMPLETED:
		economy.mark_request_completed(active_id)
		last_report_id = active_id
		feedback.request("request_complete", true)
	elif requests.grid.get_last_result().brownout_started:
		feedback.request("brownout")
	return true


func acknowledge_report(request_id: String) -> bool:
	if not requests.acknowledge_report(request_id):
		return false
	if request_id == last_report_id:
		last_report_id = ""
	var next_id := requests.get_next_available_request_id()
	if not next_id.is_empty():
		requests.announce_request(next_id)
	return true


func set_allocation_mode(mode: String) -> bool:
	var accepted := requests.set_allocation_mode(mode)
	if accepted:
		feedback.request("allocation_changed")
	return accepted


func purchase_infrastructure(id: String, amount: int = 1) -> bool:
	_sync_economy_currency_from_request()
	if not economy.purchase_infrastructure(id, amount):
		feedback.request("error")
		return false
	_sync_request_grid_from_economy()
	feedback.request("purchase", true)
	return true


func purchase_upgrade(id: String) -> bool:
	_sync_economy_currency_from_request()
	if not economy.purchase_upgrade(id):
		feedback.request("error")
		return false
	_sync_request_grid_from_economy()
	feedback.request("purchase", true)
	return true


func preview_infrastructure(id: String, amount: int = 1) -> EconomyPreview:
	_sync_economy_currency_from_request()
	return economy.preview_infrastructure(id, amount)


func preview_upgrade(id: String) -> EconomyPreview:
	_sync_economy_currency_from_request()
	return economy.preview_upgrade(id)


func _sync_economy_currency_from_request() -> void:
	economy.set_stored_energy(requests.grid.state.stored_energy)


func _sync_request_grid_from_economy() -> void:
	var reserve_stored := requests.grid.state.reserve_stored
	requests.grid.set_grid_values(economy.get_derived_values())
	requests.grid.state.reserve_stored = minf(reserve_stored, requests.grid.state.reserve_capacity)
	requests.grid.state.stored_energy = economy.state.stored_energy
