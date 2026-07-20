extends SceneTree

const TOLERANCE := 0.000001
const REQUEST_IDS := [
	"era01_finish_booting",
	"era01_remember_name",
	"era01_identify_cat",
	"era01_basic_arithmetic",
	"era01_friendlier_thanks",
	"era01_understand_tuesdays",
]
const STABILITY_ID := "era01_basic_arithmetic"

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_repository = ContentRepository.new()
	var load_result := _repository.load_from_manifest("res://tests/fixtures/content/valid_manifest.json")
	_check(load_result.is_ok(), "content fixture loads before request tests")
	if load_result.is_ok():
		_test_state_transitions_and_four_kinds()
		_test_invalid_and_underprepared_authorization()
		_test_demand_profile_and_reserve_peak()
		_test_brownout_progress_and_truthful_report()
		_test_reward_idempotence_and_unlock_order()
		_test_dialogue_selection()
		_test_grade_boundaries()
		_test_seeded_incidents()
		_test_fixed_step_repeatability()

	if _failures.is_empty():
		print("REQUEST SIMULATION TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("REQUEST SIMULATION TEST FAILED: %s" % failure)
	quit(1)


func _test_state_transitions_and_four_kinds() -> void:
	var simulation := _new_simulation(41)
	_set_rich_grid(simulation)
	_check(simulation.get_request_state(REQUEST_IDS[0]).status == RequestRunState.AVAILABLE, "first request begins available")
	for index: int in range(1, REQUEST_IDS.size()):
		_check(simulation.get_request_state(REQUEST_IDS[index]).status == RequestRunState.LOCKED, "later request %d begins locked" % index)
	var observed_kinds: Array[String] = []
	for index: int in REQUEST_IDS.size():
		var request_id: String = REQUEST_IDS[index]
		var request := _repository.get_request(request_id)
		observed_kinds.append(request.get_kind())
		_check(simulation.get_next_available_request_id() == request_id, "%s is identified as next available" % request_id)
		_check(simulation.announce_request(request_id), "%s transitions available to announced" % request_id)
		_check(simulation.get_request_state(request_id).status == RequestRunState.ANNOUNCED, "%s stores announced state" % request_id)
		var preview := simulation.build_preview(request_id)
		_check(preview.valid and preview.predicted_peak >= preview.continuous_demand, "%s preview uses authored demand" % request_id)
		_check(preview.reward_stored_energy > 0.0 and not preview.unlock_ids.is_empty(), "%s preview exposes authored reward and unlock IDs" % request_id)
		_check(simulation.authorize_request(request_id), "%s transitions announced to authorized" % request_id)
		_check(simulation.get_request_state(request_id).status == RequestRunState.AUTHORIZED, "%s stores authorized state" % request_id)
		_check(simulation.start_request(request_id), "%s transitions authorized to running" % request_id)
		_check(simulation.get_request_state(request_id).status == RequestRunState.RUNNING, "%s stores running state" % request_id)
		if index == 3:
			_check(simulation.set_allocation_mode("feed_watt"), "allocation can change mid-request")
		_check(simulation.advance_time(600.0), "%s advances to completion" % request_id)
		var state := simulation.get_request_state(request_id)
		_check(state.status == RequestRunState.COMPLETED and is_equal_approx(state.progress, 1.0), "%s completes monotonically" % request_id)
		var report := simulation.get_report(request_id)
		_check(report != null and report.kind == request.get_kind(), "%s produces a typed summary report" % request_id)
		_check(not simulation.grant_completion_rewards(request_id), "%s reward cannot be granted twice" % request_id)
		_check(simulation.acknowledge_report(request_id), "%s transitions completed to reported" % request_id)
		_check(state.status == RequestRunState.REPORTED, "%s stores reported state" % request_id)
		if index + 1 < REQUEST_IDS.size():
			_check(simulation.get_next_available_request_id() == REQUEST_IDS[index + 1], "acknowledgement identifies the next request")
	observed_kinds.sort()
	_check("burst" in observed_kinds and "capacity" in observed_kinds and "research" in observed_kinds and "stability" in observed_kinds, "all four required request behaviors are authored and runnable")
	_check(simulation.get_request_state("era01_friendlier_thanks").research_cost_paid, "research authorization consumes its documented cost once")


func _test_invalid_and_underprepared_authorization() -> void:
	var simulation := _new_simulation()
	_check(not simulation.authorize_request(REQUEST_IDS[0]), "authorization before announcement is rejected")
	_check(not simulation.announce_request("missing_request"), "unknown announcement is rejected")
	_check(simulation.grid.set_grid_values(_grid(1, 1, 0, 0, 0, 0)), "underprepared grid values apply")
	_check(simulation.announce_request(REQUEST_IDS[0]), "underprepared request can be announced")
	var preview := simulation.build_preview(REQUEST_IDS[0])
	_check(preview.underprepared and preview.predicted_service_ratio < 1.0, "preview warns when predicted service is insufficient")
	_check(not preview.warning_key.is_empty(), "underprepared preview identifies its localized warning")
	_check(not simulation.start_request(REQUEST_IDS[0]), "request cannot run before authorization")
	_check(simulation.authorize_request(REQUEST_IDS[0]), "underprepared request remains authorizable")
	_check(simulation.get_request_state(REQUEST_IDS[0]).underprepared_warning, "warning state persists after authorization")
	_check(not simulation.authorize_request(REQUEST_IDS[0]), "repeat authorization is rejected")
	_check(simulation.start_request(REQUEST_IDS[0]), "authorized underprepared request starts")
	_check(not simulation.advance_time(-1.0), "negative request time is rejected")
	_check(not simulation.advance_time(INF), "non-finite request time is rejected")


func _test_demand_profile_and_reserve_peak() -> void:
	var profile := _repository.get_demand_profile("arithmetic_peak")
	_check_near(DemandProfileSampler.multiplier_at(profile, 3.5), 1.5, "demand curve interpolates deterministically")
	_check_near(DemandProfileSampler.multiplier_at(profile, 11.5), 1.5, "looping demand curve wraps deterministically")
	_check_near(DemandProfileSampler.peak_multiplier(profile), 2.0, "preview and runtime share authored peak")

	var simulation := _new_simulation()
	_set_rich_grid(simulation)
	_run_path_until(simulation, STABILITY_ID)
	simulation.grid.set_grid_values(_grid(8, 8, 10, 4, 8, simulation.grid.state.stored_energy, 10))
	_check(simulation.announce_request(STABILITY_ID), "stability request announces after prerequisites")
	_check(simulation.authorize_request(STABILITY_ID) and simulation.start_request(STABILITY_ID), "stability request starts")
	var reserve_before := simulation.grid.state.reserve_stored
	simulation.advance_time(5.5)
	_check(simulation.grid.state.reserve_stored < reserve_before, "authored demand peak discharges Reserve")
	_check(simulation.get_request_state(STABILITY_ID).progress > 0.0, "stability request progresses through its curve")


func _test_brownout_progress_and_truthful_report() -> void:
	var simulation := _new_simulation()
	simulation.grid.set_grid_values(_grid(1, 1, 0, 0, 0, 0))
	simulation.announce_request(REQUEST_IDS[0])
	simulation.authorize_request(REQUEST_IDS[0])
	simulation.start_request(REQUEST_IDS[0])
	simulation.advance_time(2.0)
	var state := simulation.get_request_state(REQUEST_IDS[0])
	var brownout_progress := state.progress
	_check(brownout_progress > 0.0, "brownout reduces rate without freezing positive served power")
	_check(state.brownout_seconds > 0.0, "brownout duration is accumulated")
	_set_rich_grid(simulation)
	simulation.advance_time(120.0)
	_check(state.progress >= brownout_progress and state.status == RequestRunState.COMPLETED, "recovery completes without losing accumulated progress")
	var report := simulation.get_report(REQUEST_IDS[0])
	_check(report.brownout_seconds >= 2.0, "report preserves observed brownout time")
	_check(report.demand_served_ratio < 1.0, "report preserves reduced service ratio")
	_check(report.peak_demand >= report.peak_served, "report peak service does not exceed demand")
	_check(report.suggestion_key == "report.suggestion.brownout", "brownout report selects an actionable localized suggestion")


func _test_reward_idempotence_and_unlock_order() -> void:
	var simulation := _new_simulation()
	_set_rich_grid(simulation)
	simulation.announce_request(REQUEST_IDS[0])
	simulation.authorize_request(REQUEST_IDS[0])
	simulation.start_request(REQUEST_IDS[0])
	var before := simulation.grid.state.stored_energy
	simulation.advance_time(120.0)
	var after := simulation.grid.state.stored_energy
	var events := simulation.drain_events()
	_check(after >= before + 10.0, "completion grants authored Stored Energy reward")
	_check(not simulation.grant_completion_rewards(REQUEST_IDS[0]), "repeated reward call is idempotently rejected")
	_check_near(simulation.grid.state.stored_energy, after, "repeated reward call does not change balance")
	var completed_index := _event_index(events, RequestEvent.STATE_CHANGED, "to", RequestRunState.COMPLETED)
	var unlock_index := _event_index(events, RequestEvent.CONTENT_UNLOCKED, "content_id", "era01_remember_name")
	_check(completed_index >= 0 and unlock_index > completed_index, "stable-ID unlock event follows completion")


func _test_dialogue_selection() -> void:
	var candidates: Array = [
		DialogueDefinition.new({"id": "line_b", "context": "brownout", "text_key": "b"}),
		DialogueDefinition.new({"id": "line_a", "context": "brownout", "text_key": "a"}),
		DialogueDefinition.new({"id": "critical", "context": "tutorial", "text_key": "critical"}),
	]
	var selector := DialogueSelector.new()
	var first := selector.select(candidates, "brownout", 0.0)
	_check(first != null and first.get_id() == "line_a", "unseen dialogue uses deterministic ID tie-break")
	_check(selector.select(candidates, "brownout", 30.0) == null, "brownout dialogue obeys 60-second cooldown")
	var second := selector.select(candidates, "brownout", 60.0)
	_check(second != null and second.get_id() == "line_b", "unseen line has priority after cooldown")
	var critical := selector.select(candidates, "tutorial", 61.0, "critical")
	_check(critical != null and critical.get_id() == "critical", "required tutorial dialogue bypasses random selection")
	_check(selector.recent_ids().size() == 3, "dialogue history records selected events")


func _test_grade_boundaries() -> void:
	for sample: Dictionary in [
		{"score": 100.0, "grade": "S"}, {"score": 98.0, "grade": "S"},
		{"score": 97.99, "grade": "A"}, {"score": 90.0, "grade": "A"},
		{"score": 89.99, "grade": "B"}, {"score": 75.0, "grade": "B"},
		{"score": 74.99, "grade": "C"}, {"score": 50.0, "grade": "C"},
		{"score": 49.99, "grade": "D"},
	]:
		_check(RequestSimulation.grade_for_score(sample["score"]) == sample["grade"], "%.2f maps to grade %s" % [sample["score"], sample["grade"]])


func _test_seeded_incidents() -> void:
	var first := RequestIncidentTimeline.new()
	var second := RequestIncidentTimeline.new()
	first.configure(STABILITY_ID, _repository.get_all("incidents"), 991)
	second.configure(STABILITY_ID, _repository.get_all("incidents"), 991)
	_check(first.scheduled_ids() == second.scheduled_ids(), "identical seeds schedule identical incidents")
	_check(first.scheduled_ids() == ["browser_tab_bloom"], "eligible seeded incident uses stable authored ID")
	var found_omitted_seed := false
	for alternate_seed: int in range(1, 65):
		var alternate := RequestIncidentTimeline.new()
		alternate.configure(STABILITY_ID, _repository.get_all("incidents"), alternate_seed)
		if alternate.scheduled_ids().is_empty():
			found_omitted_seed = true
			break
	_check(found_omitted_seed, "authored incident chance is controlled by the stored seed")
	var first_events := first.events_between(0.0, 2.0)
	var second_events := second.events_between(0.0, 2.0)
	_check(first_events.size() == second_events.size() and first_events.size() == 1, "seeded incident starts at deterministic boundary")
	_check_near(first.request_efficiency_at(3.0), 0.8, "active incident applies enumerated request modifier")
	_check_near(first.request_efficiency_at(4.0), 1.0, "incident modifier ends without destructive state")


func _test_fixed_step_repeatability() -> void:
	var large := _new_simulation(73)
	var small := _new_simulation(73)
	for simulation: RequestSimulation in [large, small]:
		_set_rich_grid(simulation)
		simulation.announce_request(REQUEST_IDS[0])
		simulation.authorize_request(REQUEST_IDS[0])
		simulation.start_request(REQUEST_IDS[0])
	large.advance_time(4.0)
	for index: int in 16:
		small.advance_time(0.25)
	var large_state := large.get_request_state(REQUEST_IDS[0])
	var small_state := small.get_request_state(REQUEST_IDS[0])
	_check_near(large_state.progress, small_state.progress, "large and small deltas produce equal request progress")
	_check_near(large_state.demanded_energy, small_state.demanded_energy, "large and small deltas produce equal demand summary")
	_check_near(large.grid.state.reserve_stored, small.grid.state.reserve_stored, "large and small deltas produce equal Reserve")


func _new_simulation(simulation_seed: int = 1) -> RequestSimulation:
	var simulation := RequestSimulation.new()
	_check(simulation.configure(_repository, "prototype_balance", simulation_seed), "request simulation configures")
	var progression := EconomyState.new()
	progression.owned["laptop_battery"] = 1
	progression.unlocked_eras["era_01_cold_boot"] = true
	simulation.refresh_availability(progression)
	return simulation


func _set_rich_grid(simulation: RequestSimulation) -> void:
	_check(simulation.grid.set_grid_values(_grid(30, 30, 20, 10, 10, 50, 20)), "rich test grid applies")


func _grid(generation: float, transmission: float, reserve_capacity: float, charge_rate: float, discharge_rate: float, stored_energy: float, reserve_stored: float = 0.0) -> Dictionary:
	return {
		"generation_rate": generation,
		"transmission_capacity": transmission,
		"reserve_capacity": reserve_capacity,
		"reserve_charge_rate": charge_rate,
		"reserve_discharge_rate": discharge_rate,
		"stored_energy": stored_energy,
		"reserve_stored": reserve_stored,
	}


func _run_to_reported(simulation: RequestSimulation, request_id: String) -> void:
	_check(simulation.announce_request(request_id), "%s announces in helper" % request_id)
	_check(simulation.authorize_request(request_id), "%s authorizes in helper" % request_id)
	_check(simulation.start_request(request_id), "%s starts in helper" % request_id)
	_check(simulation.advance_time(600.0), "%s advances in helper" % request_id)
	_check(simulation.acknowledge_report(request_id), "%s acknowledges in helper" % request_id)
	simulation.drain_events()


func _run_path_until(simulation: RequestSimulation, target_id: String) -> void:
	for request_id: String in REQUEST_IDS:
		if request_id == target_id:
			return
		_run_to_reported(simulation, request_id)


func _event_index(events: Array[RequestEvent], type: String, field: String, value: Variant) -> int:
	for index: int in events.size():
		var event := events[index]
		if event.type == type and event.payload.get(field) == value:
			return index
	return -1


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= TOLERANCE, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
