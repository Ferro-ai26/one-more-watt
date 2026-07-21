extends SceneTree

const ERA5_REQUEST_IDS := [
	"era05_restore_evening_service",
	"era05_coordinate_community_solar",
	"era05_prepare_overnight_reserve",
	"era05_automate_routine_switchovers",
	"era05_route_underground_distribution",
	"era05_unify_neighborhood_service",
]
const ERA5_INFRASTRUCTURE_IDS := [
	"neighborhood_substation", "community_solar_farm", "municipal_generator",
	"battery_warehouse", "small_hydroelectric_plant", "underground_distribution",
	"borrowed_utility_connection",
]

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_repository = ContentRepository.new()
	var loaded := _repository.load_from_manifest()
	_check(loaded.is_ok(), "Phase 16 canonical content validates")
	if loaded.is_ok():
		_test_catalog_and_migration()
		_test_forecast_and_reserve_policy()
		_test_routine_automation_boundaries()
		_test_single_request_scheduling_and_offline()
		_test_tuned_route_endpoint_and_assets()
	_finish()


func _test_catalog_and_migration() -> void:
	_check(_repository.get_content_version() == "0.10.0", "canonical content advances to 0.10.0")
	_check(_repository.get_era("era_05_neighborhood_microgrid").get_number() == 5, "Neighborhood preserves authoritative Era 5 numbering")
	_check(_repository.get_era("era_06_city_data_center") == null, "Phase 16 does not create Era 6")
	for id: String in ERA5_REQUEST_IDS:
		var request := _repository.get_request(id)
		_check(request != null and bool(request.get_value("required", false)), "%s is required" % id)
		_check("provisional_copy" in request.get_value("tags", []), "%s dialogue remains explicitly provisional" % id)
		_check(not str(request.get_value("operator_payoff_key", "")).is_empty(), "%s promises a concrete operator payoff" % id)
	for id: String in ERA5_INFRASTRUCTURE_IDS:
		var infrastructure := _repository.get_infrastructure(id)
		_check(infrastructure != null and ResourceLoader.exists(str(infrastructure.get_value("icon_path", ""))), "%s has an integrated project-original vector icon" % id)

	var legacy := _make_era5_session(false)
	var snapshot := legacy.snapshot()
	for field: String in ["reserve_policy_preset", "request_start_target_ratio", "routine_automation_enabled", "routine_automation_max_cost", "scheduled_request_id", "scheduled_start_rule", "scheduled_target_ratio", "automation_action_sequence", "automation_history"]:
		(snapshot["economy"] as Dictionary).erase(field)
	var migrated := GameSession.new()
	_check(migrated.configure(_repository) and migrated.restore(snapshot, _repository), "additive 0.9.0-style payload restores into 0.10.0")
	_check(migrated.economy.state.reserve_policy_preset == "balanced" and not migrated.economy.state.routine_automation_enabled, "operator policy migrates to safe deterministic defaults")
	_check(migrated.economy.state.scheduled_request_id.is_empty() and migrated.economy.state.automation_history.is_empty(), "schedule and action log migrate empty without spending")


func _test_forecast_and_reserve_policy() -> void:
	var session := _make_era5_session(false)
	var first_id := ERA5_REQUEST_IDS[0]
	var limited := session.requests.build_preview(first_id)
	_check(limited.forecast_confidence == "limited" and limited.estimated_seconds_high > limited.estimated_seconds_low, "forecast begins Limited with a conservative deterministic range")
	_check(not session.configure_reserve_policy("balanced"), "Reserve policy cannot be configured before its sequential feature unlock")
	session.economy.state.unlocked_features["neighborhood_forecast"] = true
	var modeled := session.requests.build_preview(first_id)
	_check(modeled.forecast_confidence == "modeled" and modeled.forecast_reason == "profile_known_policy_variable", "forecast becomes Modeled when the neighborhood load model unlocks")
	_check(is_finite(modeled.seconds_until_peak) and modeled.projected_minimum_reserve >= 0.0, "forecast exposes peak timing and projected minimum Reserve")
	session.economy.state.unlocked_features["reserve_policy"] = true
	var selected_mode := session.requests.grid.state.allocation_mode
	_check(session.configure_reserve_policy("conservative"), "operator can choose the disclosed Conservative preset")
	_check(is_equal_approx(session.economy.state.reserve_threshold_ratio, 0.60) and is_equal_approx(session.economy.state.request_start_target_ratio, 0.85), "preset applies separate floor and request-start target")
	_check(session.requests.grid.state.allocation_mode == selected_mode, "policy configuration does not change allocation mode")
	_check(session.configure_reserve_policy_custom(true, 0.55, 0.80), "advanced numeric Reserve ratios remain configurable")
	_check(session.economy.state.reserve_policy_preset == "custom", "numeric adjustment is visibly persisted as Custom")
	_check(session.authorize_current_request(), "policy fixture request starts")
	session.requests.grid.state.generation_rate = 100000.0
	session.requests.grid.state.transmission_capacity = 100000.0
	session.requests.grid.state.reserve_stored = 0.0
	session.advance_time(0.25)
	var active := session.requests.get_active_state()
	_check(active != null and active.safe_throttle_seconds > 0.0 and active.safe_throttle_events == 1, "safe throttle activates below the operator floor")
	_check(session.requests.grid.state.allocation_mode == selected_mode, "safe throttle preserves the player-selected allocation mode")
	var actions := session.automation_actions_since(0)
	_check(actions.any(func(action: Dictionary) -> bool: return action.get("type") == "reserve_safe_throttle" and action.get("outcome") == "started"), "safe throttle records an ordered explanatory action")


func _test_routine_automation_boundaries() -> void:
	var session := _make_era5_session(true)
	session.economy.state.unlocked_features["routine_maintenance_automation"] = true
	session.economy.state.pending_maintenance_id = "era05_feeder_relay_reset"
	_check(session.configure_routine_automation(true, 1000000.0), "routine automation enables with a disclosed Stored Energy cap")
	_check(not session.has_pending_maintenance() and session.economy.state.maintenance_choices.get("era05_feeder_relay_reset") == "service", "eligible routine maintenance selects its sole authored safe action")
	var actions := session.automation_actions_since(0)
	_check(actions.any(func(action: Dictionary) -> bool: return action.get("target_id") == "era05_feeder_relay_reset" and action.get("outcome") == "resolved" and float(action.get("cost", -1.0)) == 300000.0), "routine action records ID, outcome, reason, order, and exact cost")

	var capped := _make_era5_session(true)
	capped.economy.state.unlocked_features["routine_maintenance_automation"] = true
	capped.economy.state.pending_maintenance_id = "era05_battery_filter_service"
	_check(capped.configure_routine_automation(true, 100000.0), "below-cost routine policy still configures reversibly")
	_check(capped.has_pending_maintenance(), "routine maintenance above the operator cap stops for input")
	_check(capped.automation_actions_since(0).any(func(action: Dictionary) -> bool: return action.get("outcome") == "blocked" and action.get("reason") == "operator_cost_cap"), "blocked routine action explains the policy-cap stop")

	var strategic := _make_era5_session(true)
	strategic.economy.state.unlocked_features["routine_maintenance_automation"] = true
	strategic.economy.state.pending_maintenance_id = "era04_transformer_thermal_review"
	strategic.configure_routine_automation(true, 10000000.0)
	_check(strategic.has_pending_maintenance(), "strategic Repair/Replace/Overclock maintenance is never automated")
	_check(strategic.automation_actions_since(0).any(func(action: Dictionary) -> bool: return action.get("reason") == "strategic_or_ineligible"), "strategic stop is explicit in the automation log")


func _test_single_request_scheduling_and_offline() -> void:
	var session := _make_era5_session(true)
	session.economy.state.unlocked_features["neighborhood_forecast"] = true
	session.economy.state.unlocked_features["reserve_policy"] = true
	session.economy.state.unlocked_features["request_scheduling"] = true
	session.configure_reserve_policy("max_throughput")
	_check(session.schedule_current_request("next_return_safe"), "operator can preauthorize the one named required request")
	var request_id := session.economy.state.scheduled_request_id
	_check(request_id == ERA5_REQUEST_IDS[0] and session.requests.get_request_state(request_id).status == RequestRunState.AUTHORIZED, "schedule persists the stable ID and normal authorization state")
	_check(session.requests.build_preview(request_id).forecast_confidence == "verified", "scheduled known conditions produce Verified deterministic confidence")
	_check(not session.schedule_current_request("reserve_target"), "a second request cannot be scheduled while one authorization is armed")
	var restored := _restore_snapshot(session.snapshot())
	_check(restored.economy.state.scheduled_request_id == request_id and restored.economy.state.scheduled_start_rule == "next_return_safe", "schedule restores idempotently by stable ID")
	var offline := OfflineSimulator.simulate(restored, 1000, 2800)
	_check(offline.automation_actions.any(func(action: Dictionary) -> bool: return action.get("type") == "request_schedule" and action.get("outcome") == "started"), "offline simulation explains the preauthorized request start")
	_check(offline.completed_request_ids.size() <= 1, "offline simulation never chains into a second request")
	if not offline.completed_request_ids.is_empty():
		_check(offline.stopped_for_input and offline.stop_reason == "completion_report_ready", "offline simulation stops at the completion/report boundary")
	var cancel := _make_era5_session(true)
	cancel.economy.state.unlocked_features["request_scheduling"] = true
	_check(cancel.schedule_current_request("reserve_target") and cancel.cancel_scheduled_request(), "operator may cancel an armed schedule")
	_check(cancel.economy.state.scheduled_request_id.is_empty() and cancel.requests.get_request_state(ERA5_REQUEST_IDS[0]).status == RequestRunState.ANNOUNCED, "cancel returns to announced without progress loss or a hidden request")


func _test_tuned_route_endpoint_and_assets() -> void:
	var skin := EraSkinRegistry.get_skin(EraSkinRegistry.ERA_05_ID)
	_check(skin.era_number == 5 and skin.validate().is_empty(), "Neighborhood presentation validates through the reusable skin contract")
	_check(skin.watt_variant == "scratched_core" and skin.power_flow_paths.size() == 3, "Neighborhood preserves the scratched core and authored lateral cable paths")
	_check(bool(AssetInventoryValidator.validate(false)["ok"]), "Phase 16 asset inventory resolves every integrated Neighborhood asset")
	var route := _make_era5_session(true)
	var total_seconds := 0.0
	for request_id: String in ERA5_REQUEST_IDS:
		_check(route.current_request_id() == request_id, "%s becomes current sequentially" % request_id)
		_check(route.authorize_current_request(), "%s authorizes through the request route" % request_id)
		var state := route.requests.get_request_state(request_id)
		while state.status == RequestRunState.RUNNING and state.elapsed_seconds < 1800.0:
			route.advance_time(15.0)
		_check(state.status == RequestRunState.COMPLETED, "%s completes deterministically" % request_id)
		_check(state.elapsed_seconds >= 600.0 and state.elapsed_seconds <= 1500.0, "%s fits the prepared 10–25 minute target (%.1fs)" % [request_id, state.elapsed_seconds])
		total_seconds += state.elapsed_seconds
		if route.has_pending_maintenance():
			_check(route.choose_maintenance("service"), "%s routine boundary remains manually resolvable" % request_id)
		_check(route.acknowledge_report(request_id), "%s report acknowledges" % request_id)
	_check(total_seconds >= 5700.0 and total_seconds <= 8100.0, "prepared main route fits the 95–135 minute Era target (%.1fs)" % total_seconds)
	_check(route.economy.state.completed_eras.has("era_05_neighborhood_microgrid"), "capstone marks Neighborhood Microgrid complete")
	_check(_repository.get_era("era_06_city_data_center") == null, "endpoint remains a locked City Data Center preview")


func _make_era5_session(prepared: bool) -> GameSession:
	var session := GameSession.new()
	_check(session.configure(_repository), "Era 5 fixture configures")
	for era_id: String in ["era_01_cold_boot", "era_02_bedroom_assistant", "era_03_home_server_closet", "era_04_building_network", "era_05_neighborhood_microgrid"]:
		session.economy.state.unlocked_eras[era_id] = true
	session.economy.state.current_era_id = "era_05_neighborhood_microgrid"
	session.economy.state.pending_era_transition_id = ""
	session.last_report_id = ""
	session.requests._active_id = ""
	session.requests._selected_id = ""
	for request_value: Variant in _repository.get_all("requests"):
		var request := request_value as RequestDefinition
		var era := _repository.get_era(str(request.get_value("era_id", "")))
		if era != null and era.get_number() <= 4 and bool(request.get_value("required", false)):
			var request_id := request.get_id()
			session.economy.state.completed_requests[request_id] = true
			session.requests._completed[request_id] = true
			session.requests.get_request_state(request_id).status = RequestRunState.REPORTED
	session.economy.state.unlocked_features["offline_progress"] = true
	session.economy.state.owned.merge({
		"server_rack": 3, "whole_home_battery": 3, "backup_generator": 3, "reinforced_wiring": 3, "outdoor_transformer": 3,
		"building_transformer": 4, "commercial_battery_room": 4, "parking_lot_solar": 6, "diesel_backup_array": 4, "central_cooling": 3, "medium_voltage_connection": 3,
		"neighborhood_substation": 5, "community_solar_farm": 8, "municipal_generator": 6, "battery_warehouse": 5, "small_hydroelectric_plant": 4, "underground_distribution": 4, "borrowed_utility_connection": 2,
	}, true)
	session.economy.state.stored_energy = 500000000.0 if prepared else 20000000.0
	session.economy.rebuild_derived_state()
	session.requests.refresh_availability(session.economy.state)
	session._sync_request_grid_from_economy()
	session.requests.grid.state.reserve_stored = session.requests.grid.state.reserve_capacity
	session.requests.set_allocation_mode("feed_watt")
	session._announce_next_required_if_needed()
	return session


func _restore_snapshot(snapshot: Dictionary) -> GameSession:
	var restored := GameSession.new()
	_check(restored.configure(_repository) and restored.restore(snapshot, _repository), "Phase 16 snapshot restores")
	return restored


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 16 NEIGHBORHOOD MICROGRID TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 16 NEIGHBORHOOD MICROGRID TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
