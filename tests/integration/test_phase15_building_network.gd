extends SceneTree

const ERA4_REQUEST_IDS := [
	"era04_restore_elevator_service",
	"era04_schedule_rooftop_sunlight",
	"era04_stabilize_shared_backup",
	"era04_reduce_server_room_weather",
	"era04_certify_stairwell_extension",
	"era04_standardize_building_power",
]
const ERA4_INFRASTRUCTURE_IDS := [
	"building_transformer", "commercial_battery_room", "parking_lot_solar",
	"diesel_backup_array", "central_cooling", "medium_voltage_connection",
	"emergency_extension_stairwell",
]

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_repository = ContentRepository.new()
	var loaded := _repository.load_from_manifest()
	_check(loaded.is_ok(), "Phase 15 canonical content validates")
	if loaded.is_ok():
		_test_catalog_and_migration()
		_test_maintenance_choices_and_offline_boundary()
		_test_predictive_reserve_guard()
		_test_endpoint_and_assets()
	_finish()


func _test_catalog_and_migration() -> void:
	_check(_repository.get_content_version() == "0.9.0", "canonical content advances to 0.9.0")
	_check(_repository.get_era("era_04_building_network").get_number() == 4, "Building Network preserves authoritative Era 4 numbering")
	_check(_repository.get_era("era_05_neighborhood_microgrid") == null, "Phase 15 does not create Era 5")
	for id: String in ERA4_REQUEST_IDS:
		var request := _repository.get_request(id)
		_check(request != null and bool(request.get_value("required", false)), "%s is a required Era 4 request" % id)
		_check("provisional_copy" in request.get_value("tags", []), "%s dialogue is explicitly provisional" % id)
		_check(not str(request.get_value("operator_payoff_key", "")).is_empty(), "%s declares a concrete operator payoff" % id)
	for id: String in ERA4_INFRASTRUCTURE_IDS:
		var infrastructure := _repository.get_infrastructure(id)
		_check(infrastructure != null and ResourceLoader.exists(str(infrastructure.get_value("icon_path", ""))), "%s has an integrated production vector icon" % id)

	var legacy := GameSession.new()
	_check(legacy.configure(_repository), "legacy fixture session configures")
	legacy.economy.state.stored_energy = 321987.0
	legacy.requests.grid.state.stored_energy = 321987.0
	legacy.economy.state.owned["outdoor_transformer"] = 2
	legacy.economy.state.unlocked_eras = {"era_01_cold_boot": true, "era_02_bedroom_assistant": true, "era_03_home_server_closet": true}
	legacy.economy.state.current_era_id = "era_03_home_server_closet"
	_mark_prior_requests_reported(legacy)
	legacy.economy.state.prototype_complete = true
	var legacy_snapshot := legacy.snapshot()
	for field: String in ["predictive_reserve_guard_enabled", "predictive_reserve_target_ratio", "maintenance_choices", "pending_maintenance_id", "temporary_effects", "temporary_effect_request_id", "completed_eras"]:
		(legacy_snapshot["economy"] as Dictionary).erase(field)
	for id: String in ERA4_REQUEST_IDS + ["era04_improve_lobby_directory"]:
		(legacy_snapshot["requests"]["states"] as Dictionary).erase(id)

	var migrated := GameSession.new()
	_check(migrated.configure(_repository) and migrated.restore(legacy_snapshot, _repository), "additive 0.8-era endpoint payload restores into 0.9.0")
	_check(migrated.economy.state.current_era_id == "era_04_building_network", "migrated endpoint exposes Building Network")
	_check(migrated.economy.state.pending_era_transition_id == "era_04_building_network", "migrated endpoint requires explicit Era 4 transition authorization")
	_check(is_equal_approx(migrated.requests.grid.state.stored_energy, 321987.0), "migration preserves Stored Energy without spending it")
	_check(int(migrated.economy.state.owned.get("outdoor_transformer", 0)) == 2, "migration preserves existing ownership")
	_check(not migrated.economy.state.predictive_reserve_guard_enabled, "Predictive Reserve Guard migrates disabled by default")
	_check(migrated.economy.state.maintenance_choices.is_empty() and not migrated.has_pending_maintenance(), "maintenance migrates to deterministic empty defaults")
	_check(migrated.acknowledge_era_transition(), "operator explicitly authorizes the migrated Building connection")
	_check(migrated.current_request_id() == ERA4_REQUEST_IDS[0], "first Era 4 request is reachable after authorization")
	_check(migrated.preview_infrastructure("building_transformer").status != EconomyPreview.LOCKED, "Building Transformer blueprint is available at the transition")


func _test_maintenance_choices_and_offline_boundary() -> void:
	var source := _pending_transformer_session()
	_check(source.has_pending_maintenance(), "Rooftop Sunlight deterministically triggers one transformer review")
	_check(source.current_request_id().is_empty(), "unresolved maintenance blocks the next request authorization boundary")
	var offline := OfflineSimulator.simulate(source, 1000, 1600)
	_check(offline.stopped_for_input and is_zero_approx(offline.effective_elapsed), "offline simulation never selects a maintenance choice")
	var pending_snapshot := source.snapshot()

	var repair := _restore_snapshot(pending_snapshot)
	var repair_before := repair.requests.grid.state.stored_energy
	_check(repair.choose_maintenance("repair"), "Repair resolves the deterministic prompt")
	_check(is_equal_approx(repair.requests.grid.state.stored_energy, repair_before - 30000.0), "Repair charges its exact disclosed cost")
	_check(repair.economy.state.temporary_effects.is_empty(), "Repair adds no hidden temporary modifier")

	var replace := _restore_snapshot(pending_snapshot)
	_check(replace.choose_maintenance("replace"), "Replace resolves the deterministic prompt")
	_check(int(replace.economy.state.upgrade_levels.get("transformer_replacement_program", 0)) == 1, "Replace grants the authored permanent Transmission upgrade")
	_check(replace.economy.state.temporary_effects.is_empty(), "Replace adds no temporary demand challenge")

	var overclock := _restore_snapshot(pending_snapshot)
	var base_demand := float(_repository.get_request("era04_stabilize_shared_backup").get_value("continuous_demand", 0.0)) * float(overclock.economy.get_derived_values().get("request_demand_multiplier", 1.0))
	_check(overclock.choose_maintenance("overclock"), "Overclock resolves the prompt without a purchase cost")
	_check(not overclock.economy.state.temporary_effects.is_empty(), "Overclock discloses and stores a one-request modifier")
	var preview := overclock.requests.build_preview("era04_stabilize_shared_backup")
	_check(preview.continuous_demand > base_demand, "Overclock applies the disclosed demand challenge to the next request preview")
	_check(overclock.authorize_current_request(), "the challenged next request remains authorizable")
	_check(overclock.economy.state.temporary_effect_request_id == "era04_stabilize_shared_backup", "temporary effects bind to one stable request ID")
	var restored_active := _restore_snapshot(overclock.snapshot())
	_check(restored_active.economy.state.temporary_effect_request_id == "era04_stabilize_shared_backup", "active overclock survives save/load")
	_complete_running(restored_active, "era04_stabilize_shared_backup")
	_check(restored_active.economy.state.temporary_effects.is_empty() and restored_active.economy.state.temporary_effect_request_id.is_empty(), "overclock clears exactly after the bound request")


func _test_predictive_reserve_guard() -> void:
	var session := _make_era4_session()
	session.economy.state.unlocked_features["predictive_reserve_guard"] = true
	_check(session.authorize_current_request(), "guard test request authorizes")
	session.advance_time(25.0)
	session.requests.grid.state.reserve_stored = 0.0
	_check(session.configure_predictive_reserve_guard(true, 0.75), "Predictive Reserve Guard enables only after its feature unlock")
	_check(session.requests.grid.state.allocation_mode == "feed_watt", "enabling the guard does not change the selected allocation mode")
	session.advance_time(0.25)
	_check(session.requests.predictive_guard_active, "guard becomes visibly active inside the authored pre-peak window")
	_check(session.requests.grid.state.allocation_mode == "feed_watt", "guard throttles through an override without silently changing player allocation")
	_check(session.configure_predictive_reserve_guard(false, 0.75), "operator can disable the guard immediately")
	_check(not session.economy.state.predictive_reserve_guard_enabled, "disabled guard state persists explicitly")
	var offline_session := _make_era4_session()
	offline_session.economy.state.unlocked_features["predictive_reserve_guard"] = true
	_check(offline_session.authorize_current_request(), "offline guard fixture authorizes")
	offline_session.advance_time(25.0, true)
	offline_session.requests.grid.state.reserve_stored = 0.0
	_check(offline_session.configure_predictive_reserve_guard(true, 0.75), "offline guard fixture enables")
	offline_session.advance_time(0.25, true)
	_check(offline_session.requests.predictive_guard_active, "the same deterministic pre-peak guard behavior applies during offline simulation")


func _test_endpoint_and_assets() -> void:
	var skin := EraSkinRegistry.get_skin(EraSkinRegistry.ERA_04_ID)
	_check(skin.era_number == 4 and skin.validate().is_empty(), "Building presentation validates through the reusable skin contract")
	_check(skin.watt_variant == "scratched_core", "Building WATT preserves the original scratched core")
	_check(skin.power_flow_paths.size() == 4, "Building uses authored representative cable paths rather than wire placement")
	var inventory := AssetInventoryValidator.validate(false)
	_check(bool(inventory["ok"]), "Phase 15 asset inventory resolves every integrated civic asset")
	var session := _make_era4_session()
	for id: String in ERA4_REQUEST_IDS:
		var state := session.requests.get_request_state(id)
		state.status = RequestRunState.REPORTED
		session.requests._completed[id] = true
		session.economy.state.completed_requests[id] = true
	session.economy.mark_report_viewed("era04_standardize_building_power")
	_check(session.economy.state.completed_eras.has("era_04_building_network"), "capstone marks Building Network complete")
	_check(_repository.get_era("era_05_neighborhood_microgrid") == null, "completion remains a locked Neighborhood preview, not playable Era 5")


func _pending_transformer_session() -> GameSession:
	var session := _make_era4_session()
	_complete_and_acknowledge(session, "era04_restore_elevator_service")
	_complete_and_acknowledge(session, "era04_schedule_rooftop_sunlight")
	return session


func _make_era4_session() -> GameSession:
	var session := GameSession.new()
	_check(session.configure(_repository), "Era 4 fixture session configures")
	for era_id: String in ["era_01_cold_boot", "era_02_bedroom_assistant", "era_03_home_server_closet", "era_04_building_network"]:
		session.economy.state.unlocked_eras[era_id] = true
	session.economy.state.current_era_id = "era_04_building_network"
	session.economy.state.pending_era_transition_id = ""
	_mark_prior_requests_reported(session)
	session.economy.state.prototype_complete = true
	session.economy.state.unlocked_features["offline_progress"] = true
	session.economy.state.owned.merge({
		"server_rack": 3, "whole_home_battery": 2, "backup_generator": 2,
		"reinforced_wiring": 2, "outdoor_transformer": 2,
		"building_transformer": 2, "commercial_battery_room": 2,
		"parking_lot_solar": 4, "diesel_backup_array": 3,
		"central_cooling": 1, "medium_voltage_connection": 1,
		"emergency_extension_stairwell": 1,
	}, true)
	session.economy.state.stored_energy = 12000000.0
	session.economy.rebuild_derived_state()
	session.requests.refresh_availability(session.economy.state)
	session._sync_request_grid_from_economy()
	session.requests.set_allocation_mode("feed_watt")
	session._announce_next_required_if_needed()
	return session


func _mark_prior_requests_reported(session: GameSession) -> void:
	session.requests._selected_id = ""
	session.requests._active_id = ""
	session.last_report_id = ""
	for request_value: Variant in _repository.get_all("requests"):
		var request := request_value as RequestDefinition
		if request == null:
			continue
		var era := _repository.get_era(str(request.get_value("era_id", "")))
		if era == null or era.get_number() > 3 or not bool(request.get_value("required", false)):
			continue
		var request_id := request.get_id()
		session.requests._completed[request_id] = true
		session.economy.state.completed_requests[request_id] = true
		session.requests.get_request_state(request_id).status = RequestRunState.REPORTED


func _complete_and_acknowledge(session: GameSession, request_id: String) -> void:
	_check(session.current_request_id() == request_id, "%s becomes current" % request_id)
	_check(session.authorize_current_request(), "%s authorizes" % request_id)
	_complete_running(session, request_id)
	_check(session.acknowledge_report(request_id), "%s report acknowledges" % request_id)


func _complete_running(session: GameSession, request_id: String) -> void:
	var state := session.requests.get_request_state(request_id)
	var guard := 0
	while state.status == RequestRunState.RUNNING and guard < 200:
		session.advance_time(60.0)
		guard += 1
	_check(state.status == RequestRunState.COMPLETED, "%s completes under deterministic simulation" % request_id)


func _restore_snapshot(snapshot: Dictionary) -> GameSession:
	var restored := GameSession.new()
	_check(restored.configure(_repository) and restored.restore(snapshot, _repository), "Phase 15 snapshot restores")
	return restored


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 15 BUILDING NETWORK TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 15 BUILDING NETWORK TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
