class_name RequestSimulation
extends RefCounted

const EPSILON := 0.000000001

var grid := GridSimulation.new()
var seed := 0
var current_dialogue := ""

var _repository: ContentRepository
var _balance: BalanceDefinition
var _states: Dictionary = {}
var _completed: Dictionary = {}
var _unlocked: Dictionary = {}
var _reports: Dictionary = {}
var _active_id := ""
var _accumulator_seconds := 0.0
var _events: Array[RequestEvent] = []
var _dialogue_selector := DialogueSelector.new()
var _incident_timeline := RequestIncidentTimeline.new()
var _underpower_floor := 0.05
var _progression_state: EconomyState
var _selected_id := ""
var _request_demand_multiplier := 1.0
var _predictive_guard_enabled := false
var _predictive_guard_target_ratio := 0.75
var predictive_guard_active := false
var predictive_guard_seconds_to_peak := INF


func configure(repository: ContentRepository, balance_id: String = "prototype_balance", simulation_seed: int = 1) -> bool:
	if repository == null or not repository.is_loaded():
		return false
	var balance := repository.get_balance(balance_id)
	if balance == null or not grid.configure(balance, "era_01_cold_boot", simulation_seed):
		return false
	_repository = repository
	_balance = balance
	seed = simulation_seed
	_underpower_floor = clampf(float(balance.get_value("underpower_efficiency_floor", 0.05)), 0.0, 1.0)
	_states.clear()
	_completed.clear()
	_unlocked.clear()
	_reports.clear()
	_events.clear()
	_active_id = ""
	_selected_id = ""
	_accumulator_seconds = 0.0
	current_dialogue = ""
	_request_demand_multiplier = 1.0
	_predictive_guard_enabled = false
	_predictive_guard_target_ratio = 0.75
	predictive_guard_active = false
	predictive_guard_seconds_to_peak = INF
	for request_value: Variant in repository.get_all("requests"):
		var request := request_value as RequestDefinition
		if request != null:
			_states[request.get_id()] = RequestRunState.new(request.get_id())
	_refresh_availability(false)
	return true


func get_request_state(request_id: String) -> RequestRunState:
	return _states.get(request_id) as RequestRunState


func get_active_state() -> RequestRunState:
	return get_request_state(_active_id)


func get_report(request_id: String) -> PerformanceReport:
	return _reports.get(request_id) as PerformanceReport


func get_next_available_request_id(required_only: bool = false) -> String:
	var candidates: Array[RequestDefinition] = []
	for request_value: Variant in _repository.get_all("requests"):
		var request := request_value as RequestDefinition
		var state := get_request_state(request.get_id())
		if state != null and state.status == RequestRunState.AVAILABLE and (not required_only or bool(request.get_value("required", true))):
			candidates.append(request)
	candidates.sort_custom(func(a: RequestDefinition, b: RequestDefinition) -> bool:
		var a_required := bool(a.get_value("required", true))
		var b_required := bool(b.get_value("required", true))
		if a_required != b_required:
			return a_required
		var a_era := _repository.get_era(str(a.get_value("era_id", "")))
		var b_era := _repository.get_era(str(b.get_value("era_id", "")))
		var a_era_number := 0 if a_era == null else a_era.get_number()
		var b_era_number := 0 if b_era == null else b_era.get_number()
		if a_era_number != b_era_number:
			return a_era_number < b_era_number
		var a_sequence := int(a.get_value("sequence", 0))
		var b_sequence := int(b.get_value("sequence", 0))
		return a_sequence < b_sequence if a_sequence != b_sequence else a.get_id() < b.get_id()
	)
	return "" if candidates.is_empty() else candidates[0].get_id()


func get_selected_request_id() -> String:
	return _selected_id


func get_available_optional_request_ids() -> Array[String]:
	var result: Array[String] = []
	for request_value: Variant in _repository.get_all("requests"):
		var request := request_value as RequestDefinition
		var state := get_request_state(request.get_id())
		if not bool(request.get_value("required", true)) and state != null and state.status in [RequestRunState.AVAILABLE, RequestRunState.ANNOUNCED]:
			result.append(request.get_id())
	result.sort_custom(func(a: String, b: String) -> bool:
		return int(_repository.get_request(a).get_value("sequence", 0)) < int(_repository.get_request(b).get_value("sequence", 0))
	)
	return result


func refresh_availability(progression_state: EconomyState = null) -> void:
	_progression_state = progression_state
	if _progression_state != null:
		var efficiencies: Dictionary = _balance.get_value("stored_energy_efficiency", {})
		grid.conversion_efficiency = clampf(float(efficiencies.get(_progression_state.current_era_id, 1.0)), 0.0, 1.0)
	_refresh_availability(true)


func configure_runtime_modifiers(request_demand_multiplier: float, predictive_guard_enabled: bool, predictive_guard_target_ratio: float) -> bool:
	if not is_finite(request_demand_multiplier) or request_demand_multiplier < 0.0 or not is_finite(predictive_guard_target_ratio) or predictive_guard_target_ratio < 0.0 or predictive_guard_target_ratio > 1.0:
		return false
	_request_demand_multiplier = request_demand_multiplier
	_predictive_guard_enabled = predictive_guard_enabled
	_predictive_guard_target_ratio = predictive_guard_target_ratio
	return true


func select_request(request_id: String) -> bool:
	if not _active_id.is_empty():
		return false
	var target := get_request_state(request_id)
	if target == null or target.status not in [RequestRunState.AVAILABLE, RequestRunState.ANNOUNCED]:
		return false
	if not _selected_id.is_empty() and _selected_id != request_id:
		var previous := get_request_state(_selected_id)
		if previous != null and previous.status == RequestRunState.ANNOUNCED:
			previous.status = RequestRunState.AVAILABLE
	if target.status == RequestRunState.AVAILABLE:
		return announce_request(request_id)
	_selected_id = request_id
	return true


func announce_request(request_id: String) -> bool:
	var state := get_request_state(request_id)
	var request := _repository.get_request(request_id)
	if state == null or request == null or state.status != RequestRunState.AVAILABLE:
		return false
	_set_status(state, RequestRunState.ANNOUNCED)
	_selected_id = request_id
	current_dialogue = _repository.localize(str(request.get_value("announcement_key", "")))
	_events.append(RequestEvent.new(RequestEvent.DIALOGUE_SHOWN, request_id, grid.state.elapsed_seconds, {"role": "announcement", "text": current_dialogue}))
	return true


func build_preview(request_id: String) -> RequestPreview:
	var preview := RequestPreview.new()
	preview.request_id = request_id
	var request := _repository.get_request(request_id)
	if request == null:
		return preview
	var profile := _repository.get_demand_profile(str(request.get_value("demand_profile_id", "")))
	preview.continuous_demand = float(request.get_value("continuous_demand", 0.0)) * _request_demand_multiplier
	preview.predicted_peak = preview.continuous_demand * DemandProfileSampler.peak_multiplier(profile)
	preview.recommended_reserve = float(request.get_value("recommended_reserve", 0.0))
	preview.research_cost = float(request.get_value("research_cost", 0.0))
	var rewards: Dictionary = request.get_value("rewards", {})
	preview.reward_stored_energy = float(rewards.get("stored_energy", 0.0))
	for unlock_value: Variant in rewards.get("unlock_ids", []):
		preview.unlock_ids.append(str(unlock_value))
	var deliverable := minf(grid.state.generation_rate, grid.state.transmission_capacity)
	var peak_support := deliverable + minf(grid.state.reserve_discharge_rate, grid.state.reserve_stored / grid.fixed_step_seconds)
	preview.predicted_service_ratio = 1.0 if preview.predicted_peak <= EPSILON else clampf(peak_support / preview.predicted_peak, 0.0, 1.0)
	var base_served := minf(preview.continuous_demand, peak_support)
	var surplus := maxf(deliverable - minf(deliverable, preview.continuous_demand), 0.0)
	var watt_power := surplus * float(grid.get_allocation().get("watt_share", 0.5))
	var useful := minf(float(request.get_value("max_useful_power", 0.0)), base_served + watt_power)
	if useful > EPSILON:
		preview.estimated_seconds = float(request.get_value("required_energy", 0.0)) / useful
	preview.likely_bottleneck = _preview_bottleneck(preview.predicted_peak)
	preview.underprepared = preview.predicted_service_ratio < 1.0 - EPSILON or grid.state.reserve_stored + EPSILON < preview.recommended_reserve
	if preview.underprepared:
		preview.warning_key = "request.warning.underprepared"
	preview.valid = true
	return preview


func authorize_request(request_id: String) -> bool:
	if not _active_id.is_empty():
		return false
	var state := get_request_state(request_id)
	var request := _repository.get_request(request_id)
	if state == null or request == null or state.status != RequestRunState.ANNOUNCED:
		return false
	var research_cost := float(request.get_value("research_cost", 0.0))
	if str(request.get_value("kind", "")) == "research" and grid.state.stored_energy + EPSILON < research_cost:
		return false
	if research_cost > 0.0:
		grid.state.stored_energy -= research_cost
		state.research_cost_paid = true
	var preview := build_preview(request_id)
	state.underprepared_warning = preview.underprepared
	_set_status(state, RequestRunState.AUTHORIZED)
	return true


func start_request(request_id: String) -> bool:
	var state := get_request_state(request_id)
	if state == null or state.status != RequestRunState.AUTHORIZED or not _active_id.is_empty():
		return false
	_active_id = request_id
	state.starting_stored_energy = grid.state.stored_energy
	_incident_timeline.configure(request_id, _repository.get_all("incidents"), seed)
	_set_status(state, RequestRunState.RUNNING)
	return true


func skip_request(request_id: String) -> bool:
	var state := get_request_state(request_id)
	var request := _repository.get_request(request_id)
	if state == null or request == null or bool(request.get_value("required", true)):
		return false
	if state.status not in [RequestRunState.AVAILABLE, RequestRunState.ANNOUNCED]:
		return false
	_set_status(state, RequestRunState.SKIPPED)
	if _selected_id == request_id:
		_selected_id = ""
	return true


func set_allocation_mode(mode: String) -> bool:
	var old_mode := grid.state.allocation_mode
	if not grid.set_allocation_mode(mode):
		return false
	var active := get_active_state()
	if active != null and active.status == RequestRunState.RUNNING and old_mode != mode:
		active.allocation_changes += 1
	return true


func advance_time(delta_seconds: float, offline: bool = false) -> bool:
	if not is_finite(delta_seconds) or delta_seconds < 0.0 or delta_seconds > GridSimulation.MAX_ACTIVE_ADVANCE_SECONDS:
		return false
	var active := get_active_state()
	if active == null or active.status != RequestRunState.RUNNING:
		return false
	_accumulator_seconds += delta_seconds
	while _accumulator_seconds + EPSILON >= grid.fixed_step_seconds:
		_process_step(active, grid.fixed_step_seconds, offline)
		_accumulator_seconds -= grid.fixed_step_seconds
		if _accumulator_seconds < EPSILON:
			_accumulator_seconds = 0.0
		if active.status == RequestRunState.COMPLETED:
			_accumulator_seconds = 0.0
			break
	return true


func snapshot() -> Dictionary:
	var states: Dictionary = {}
	for id_value: Variant in _states:
		states[str(id_value)] = (_states[id_value] as RequestRunState).snapshot()
	var reports: Dictionary = {}
	for id_value: Variant in _reports:
		reports[str(id_value)] = (_reports[id_value] as PerformanceReport).snapshot()
	return {
		"seed": seed,
		"current_dialogue": current_dialogue,
		"states": states,
		"completed": _completed.duplicate(true),
		"unlocked": _unlocked.duplicate(true),
		"reports": reports,
		"active_id": _active_id,
		"selected_id": _selected_id,
		"accumulator_seconds": _accumulator_seconds,
		"grid": grid.state.snapshot(),
		"dialogue_selector": _dialogue_selector.snapshot(),
	}


func restore(data: Dictionary, repository: ContentRepository, balance_id: String = "prototype_balance") -> bool:
	if not configure(repository, balance_id, int(data.get("seed", 1))):
		return false
	var saved_states: Dictionary = data.get("states", {})
	for id_value: Variant in saved_states:
		var id := str(id_value)
		var state := get_request_state(id)
		if state == null or not state.restore(saved_states[id_value]):
			return false
	_completed = (data.get("completed", {}) as Dictionary).duplicate(true)
	_unlocked = (data.get("unlocked", {}) as Dictionary).duplicate(true)
	_reports.clear()
	for id_value: Variant in (data.get("reports", {}) as Dictionary):
		var report := PerformanceReport.new()
		if repository.get_request(str(id_value)) == null or not report.restore(data["reports"][id_value]):
			return false
		_reports[str(id_value)] = report
	_active_id = str(data.get("active_id", ""))
	_selected_id = str(data.get("selected_id", _active_id))
	if not _active_id.is_empty():
		var active := get_request_state(_active_id)
		if active == null or active.status != RequestRunState.RUNNING:
			return false
	if not _selected_id.is_empty() and get_request_state(_selected_id) == null:
		return false
	_accumulator_seconds = float(data.get("accumulator_seconds", 0.0))
	if not is_finite(_accumulator_seconds) or _accumulator_seconds < 0.0 or _accumulator_seconds >= grid.fixed_step_seconds:
		return false
	if not grid.state.restore(data.get("grid", {})) or not grid.set_allocation_mode(grid.state.allocation_mode):
		return false
	current_dialogue = str(data.get("current_dialogue", ""))
	_dialogue_selector.restore(data.get("dialogue_selector", {}))
	if not _active_id.is_empty():
		var active_state := get_request_state(_active_id)
		_incident_timeline.configure(_active_id, repository.get_all("incidents"), seed)
		_incident_timeline.seek(active_state.elapsed_seconds)
	_events.clear()
	grid.drain_events()
	return true


func acknowledge_report(request_id: String) -> bool:
	var state := get_request_state(request_id)
	if state == null or state.status != RequestRunState.COMPLETED or get_report(request_id) == null:
		return false
	_set_status(state, RequestRunState.REPORTED)
	if _selected_id == request_id:
		_selected_id = ""
	return true


func grant_completion_rewards(request_id: String) -> bool:
	var state := get_request_state(request_id)
	var request := _repository.get_request(request_id)
	if state == null or request == null or state.status != RequestRunState.COMPLETED or state.reward_granted:
		return false
	var rewards: Dictionary = request.get_value("rewards", {})
	var stored_reward := float(rewards.get("stored_energy", 0.0))
	grid.state.stored_energy += stored_reward
	state.reward_granted = true
	_events.append(RequestEvent.new(RequestEvent.REWARD_GRANTED, request_id, grid.state.elapsed_seconds, {"stored_energy": stored_reward}))
	return true


func drain_events() -> Array[RequestEvent]:
	var drained := _events.duplicate()
	_events.clear()
	return drained


func _process_step(active: RequestRunState, delta_seconds: float, offline: bool = false) -> void:
	var request := _repository.get_request(active.request_id)
	var profile := _repository.get_demand_profile(str(request.get_value("demand_profile_id", "")))
	var demand_multiplier := DemandProfileSampler.multiplier_at(profile, active.elapsed_seconds)
	var demand_rate := float(request.get_value("continuous_demand", 0.0)) * demand_multiplier * _request_demand_multiplier
	predictive_guard_seconds_to_peak = DemandProfileSampler.seconds_until_next_peak(profile, active.elapsed_seconds)
	var reserve_ratio := 0.0 if grid.state.reserve_capacity <= EPSILON else grid.state.reserve_stored / grid.state.reserve_capacity
	predictive_guard_active = _predictive_guard_enabled and predictive_guard_seconds_to_peak <= 30.0 and reserve_ratio + EPSILON < _predictive_guard_target_ratio
	grid.set_allocation_override("expand_grid" if predictive_guard_active else "")
	grid.set_demand_rate(demand_rate)
	grid.advance_time(delta_seconds)
	grid.set_allocation_override("")
	var result := grid.get_last_result()
	var previous_elapsed := active.elapsed_seconds
	active.elapsed_seconds += delta_seconds
	active.demanded_energy += demand_rate * delta_seconds
	active.served_energy += result.served_power * delta_seconds
	active.peak_demand = maxf(active.peak_demand, demand_rate)
	active.peak_served = maxf(active.peak_served, result.served_power)
	if result.brownout_active:
		active.brownout_seconds += delta_seconds
	_process_incidents(active, previous_elapsed, active.elapsed_seconds, offline)
	var useful_power := minf(float(request.get_value("max_useful_power", 0.0)), result.served_power + result.watt_power)
	if useful_power > EPSILON:
		useful_power = maxf(useful_power, float(request.get_value("max_useful_power", 0.0)) * _underpower_floor)
	useful_power *= _incident_timeline.request_efficiency_at(active.elapsed_seconds, offline)
	var required_energy := float(request.get_value("required_energy", 0.0))
	if required_energy > EPSILON:
		active.progress = clampf(active.progress + useful_power * delta_seconds / required_energy, active.progress, 1.0)
	for grid_event: GridEvent in grid.drain_events():
		if grid_event.type == GridEvent.BROWNOUT_STARTED:
			_show_brownout_dialogue(active.request_id)
	if active.progress >= 1.0 - EPSILON:
		_complete_request(active, request)


func _process_incidents(active: RequestRunState, previous_elapsed: float, current_elapsed: float, offline: bool = false) -> void:
	for incident_event: Dictionary in _incident_timeline.events_between(previous_elapsed, current_elapsed):
		var incident: IncidentDefinition = incident_event["definition"]
		if offline and not bool(incident.get_value("offline_allowed", false)):
			continue
		if incident_event["type"] == RequestEvent.INCIDENT_STARTED and incident.get_id() not in active.incident_ids:
			active.incident_ids.append(incident.get_id())
			var keys: Array = incident.get_value("dialogue_keys", [])
			if not keys.is_empty():
				current_dialogue = _repository.localize(str(keys[0]))
		_events.append(RequestEvent.new(str(incident_event["type"]), active.request_id, grid.state.elapsed_seconds, {"incident_id": incident.get_id()}))


func _complete_request(state: RequestRunState, request: RequestDefinition) -> void:
	state.progress = 1.0
	_active_id = ""
	_completed[state.request_id] = true
	_set_status(state, RequestRunState.COMPLETED)
	grant_completion_rewards(state.request_id)
	var unlocked_ids := _collect_unlocks(request)
	_refresh_availability(true, unlocked_ids)
	current_dialogue = _repository.localize(str(request.get_value("completion_key", "")))
	_events.append(RequestEvent.new(RequestEvent.DIALOGUE_SHOWN, state.request_id, grid.state.elapsed_seconds, {"role": "completion", "text": current_dialogue}))
	var report := _build_report(state, request, unlocked_ids)
	_reports[state.request_id] = report
	_events.append(RequestEvent.new(RequestEvent.REPORT_READY, state.request_id, grid.state.elapsed_seconds, report.snapshot()))


func _build_report(state: RequestRunState, request: RequestDefinition, unlock_ids: Array[String]) -> PerformanceReport:
	var report := PerformanceReport.new()
	report.request_id = state.request_id
	report.kind = str(request.get_value("kind", ""))
	report.completion_seconds = state.elapsed_seconds
	report.demanded_energy = state.demanded_energy
	report.served_energy = state.served_energy
	report.demand_served_ratio = 1.0 if state.demanded_energy <= EPSILON else clampf(state.served_energy / state.demanded_energy, 0.0, 1.0)
	report.peak_demand = state.peak_demand
	report.peak_served = state.peak_served
	report.brownout_seconds = state.brownout_seconds
	report.ending_reserve = grid.state.reserve_stored
	report.ending_reserve_capacity = grid.state.reserve_capacity
	report.allocation_changes = state.allocation_changes
	report.incident_ids = state.incident_ids.duplicate()
	report.unlock_ids = unlock_ids.duplicate()
	report.reward_stored_energy = float((request.get_value("rewards", {}) as Dictionary).get("stored_energy", 0.0))
	report.stored_energy_earned = maxf(grid.state.stored_energy - state.starting_stored_energy - report.reward_stored_energy, 0.0)
	var brownout_penalty := 0.0 if state.elapsed_seconds <= EPSILON else minf(20.0, state.brownout_seconds / state.elapsed_seconds * 40.0)
	var reserve_ratio := 0.0 if grid.state.reserve_capacity <= EPSILON else clampf(grid.state.reserve_stored / grid.state.reserve_capacity, 0.0, 1.0)
	report.stability_score = clampf(100.0 * report.demand_served_ratio - brownout_penalty + minf(5.0, reserve_ratio * 5.0), 0.0, 100.0)
	report.grade = grade_for_score(report.stability_score)
	report.completion_key = str(request.get_value("completion_key", ""))
	report.suggestion_key = _report_suggestion_key(report)
	return report


static func grade_for_score(score: float) -> String:
	if score >= 98.0:
		return "S"
	if score >= 90.0:
		return "A"
	if score >= 75.0:
		return "B"
	if score >= 50.0:
		return "C"
	return "D"


func _collect_unlocks(request: RequestDefinition) -> Array[String]:
	var result: Array[String] = []
	var rewards: Dictionary = request.get_value("rewards", {})
	for unlock_value: Variant in rewards.get("unlock_ids", []):
		var unlock_id := str(unlock_value)
		if not unlock_id.is_empty() and unlock_id not in result:
			result.append(unlock_id)
	return result


func _refresh_availability(emit_events: bool, explicit_unlocks: Array[String] = []) -> void:
	var new_unlocks: Array[String] = explicit_unlocks.duplicate()
	for request_value: Variant in _repository.get_all("requests"):
		var request := request_value as RequestDefinition
		var state := get_request_state(request.get_id())
		if state.status == RequestRunState.LOCKED and _conditions_met(request.get_value("unlock_conditions", [])):
			state.status = RequestRunState.AVAILABLE
			_unlocked[request.get_id()] = true
			if request.get_id() not in new_unlocks:
				new_unlocks.append(request.get_id())
	if emit_events:
		for unlock_id: String in new_unlocks:
			_unlocked[unlock_id] = true
			_events.append(RequestEvent.new(RequestEvent.CONTENT_UNLOCKED, "", grid.state.elapsed_seconds, {"content_id": unlock_id}))


func _conditions_met(conditions: Variant) -> bool:
	if not conditions is Array or conditions.is_empty():
		return true
	for condition_value: Variant in conditions:
		if not condition_value is Dictionary:
			return false
		var condition: Dictionary = condition_value
		match str(condition.get("type", "")):
			"default":
				continue
			"request_completed":
				if not _completed.has(str(condition.get("request_id", ""))):
					return false
			"infrastructure_owned":
				if _progression_state == null or int(_progression_state.owned.get(str(condition.get("infrastructure_id", "")), 0)) < int(condition.get("amount", 0)):
					return false
			"upgrade_owned":
				if _progression_state == null or int(_progression_state.upgrade_levels.get(str(condition.get("upgrade_id", "")), 0)) < int(condition.get("level", 0)):
					return false
			"era_unlocked":
				if _progression_state == null or not _progression_state.unlocked_eras.has(str(condition.get("era_id", ""))):
					return false
			"stability_service_at_least":
				if _progression_state == null or _progression_state.best_stability_service_ratio + EPSILON < float(condition.get("minimum_ratio", 1.0)):
					return false
			_:
				return false
	return true


func _set_status(state: RequestRunState, status: String) -> void:
	var previous := state.status
	state.status = status
	_events.append(RequestEvent.new(RequestEvent.STATE_CHANGED, state.request_id, grid.state.elapsed_seconds, {"from": previous, "to": status}))


func _show_brownout_dialogue(request_id: String) -> void:
	var request := _repository.get_request(request_id)
	if request == null:
		return
	var candidates: Array = []
	for candidate_value: Variant in _repository.get_all("dialogue"):
		var candidate := candidate_value as DialogueDefinition
		if candidate != null and str(candidate.get_value("era_id", "")) == str(request.get_value("era_id", "")):
			candidates.append(candidate)
	var selected := _dialogue_selector.select(candidates, "brownout", grid.state.elapsed_seconds)
	if selected == null:
		return
	current_dialogue = _repository.localize(selected.get_text_key())
	_events.append(RequestEvent.new(RequestEvent.DIALOGUE_SHOWN, request_id, grid.state.elapsed_seconds, {"role": "brownout", "dialogue_id": selected.get_id(), "text": current_dialogue}))


func _preview_bottleneck(peak: float) -> String:
	if grid.state.generation_rate + EPSILON < minf(grid.state.transmission_capacity, peak):
		return "generation"
	if grid.state.transmission_capacity + EPSILON < minf(grid.state.generation_rate, peak):
		return "transmission"
	if peak > minf(grid.state.generation_rate, grid.state.transmission_capacity) + grid.state.reserve_discharge_rate + EPSILON:
		return "reserve"
	return "none"


func _report_suggestion_key(report: PerformanceReport) -> String:
	if report.brownout_seconds > EPSILON:
		return "report.suggestion.brownout"
	if report.allocation_changes == 0:
		return "report.suggestion.feed_watt"
	return "report.suggestion.preserve_reserve"
