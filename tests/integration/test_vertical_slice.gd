extends SceneTree

const MAIN_REQUEST_IDS := [
	"era01_finish_booting",
	"era01_remember_name",
	"era01_identify_cat",
	"era01_basic_arithmetic",
	"era01_friendlier_thanks",
	"era01_understand_tuesdays",
	"era02_organize_photographs",
	"era02_recommend_dinner",
	"era02_rewrite_text_message",
	"era02_learn_tuesdays",
	"era02_improve_loading_animation",
	"era03_sort_photo_archive",
	"era03_predict_package_arrival",
	"era03_write_grocery_list",
	"era03_leftovers_edible",
]
const OPTIONAL_REQUEST_IDS := [
	"era01_larger_loading_dot",
	"era02_nineteen_plug_certification",
	"era03_rename_every_device",
]

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0
var _elapsed := 0.0
var _idle_elapsed := 0.0
var _max_idle_gap := 0.0
var _save_root := ""


func _init() -> void:
	_save_root = "user://phase07_vertical_%d" % Time.get_ticks_usec()
	_repository = ContentRepository.new()
	var loaded := _repository.load_from_manifest()
	_check(loaded.is_ok(), "canonical Phase 07 content loads")
	if loaded.is_ok():
		_test_catalog_and_localization()
		var first := _run_clean_path(true)
		var second := _run_clean_path(false)
		_compare_runs(first, second)
	_cleanup_tree(_save_root)
	_finish()


func _test_catalog_and_localization() -> void:
	_check(_repository.get_counts()["requests"] == 18, "all eighteen catalog requests are authored")
	var kinds: Dictionary = {}
	for request_value: Variant in _repository.get_all("requests"):
		var request := request_value as RequestDefinition
		kinds[request.get_kind()] = true
		for key: String in ["title_key", "summary_key", "announcement_key", "completion_key"]:
			_check(not _repository.localize(str(request.get_value(key, ""))).begins_with("["), "%s has localized %s" % [request.get_id(), key])
		var tutorial_key := str(request.get_value("tutorial_text_key", ""))
		if not tutorial_key.is_empty():
			_check(not _repository.localize(tutorial_key).begins_with("["), "%s tutorial is localized" % request.get_id())
	_check(kinds.size() == 5, "capacity, stability, burst, research, and vanity are all represented")
	for request_id: String in MAIN_REQUEST_IDS:
		_check(bool(_repository.get_request(request_id).get_value("required", false)), "%s is on the required path" % request_id)
	for request_id: String in OPTIONAL_REQUEST_IDS:
		_check(not bool(_repository.get_request(request_id).get_value("required", true)), "%s remains optional" % request_id)


func _run_clean_path(verify_boundary_saves: bool) -> Dictionary:
	_elapsed = 0.0
	_idle_elapsed = 0.0
	_max_idle_gap = 0.0
	var session := GameSession.new()
	_check(session.configure(_repository), "clean vertical-slice session configures")
	var milestones: Dictionary = {}
	var purchases: Array[String] = []
	var total_brownout_seconds := 0.0
	var era2_saved := false
	var era3_saved := false
	for request_id: String in MAIN_REQUEST_IDS:
		_prepare_for_request(session, request_id, purchases)
		if not session.economy.state.pending_era_transition_id.is_empty():
			var transition_id := session.economy.state.pending_era_transition_id
			milestones[transition_id] = _elapsed
			if verify_boundary_saves:
				session = _round_trip(session, transition_id)
			_check(session.economy.state.pending_era_transition_id == transition_id, "%s pending transition survives save/load" % transition_id)
			_check(session.acknowledge_era_transition(), "%s transition acknowledges after restore" % transition_id)
			if transition_id == "era_02_bedroom_assistant":
				era2_saved = true
			elif transition_id == "era_03_home_server_closet":
				era3_saved = true
		_check(session.current_request_id() == request_id, "%s becomes the selected required request" % request_id)
		var definition := _repository.get_request(request_id)
		var research_cost := float(definition.get_value("research_cost", 0.0))
		_earn_until(session, research_cost)
		_check(session.authorize_current_request(), "%s authorizes without injected currency" % request_id)
		var state := session.requests.get_request_state(request_id)
		var guard := 0
		while state.status == RequestRunState.RUNNING and guard < 2000:
			var before := state.elapsed_seconds
			_check(session.advance_time(30.0), "%s advances through normal simulation" % request_id)
			_elapsed += state.elapsed_seconds - before
			guard += 1
		_check(state.status == RequestRunState.COMPLETED, "%s reaches completion" % request_id)
		var report := session.requests.get_report(request_id)
		_check(report != null and state.reward_granted, "%s produces one rewarded report" % request_id)
		if report != null:
			total_brownout_seconds += report.brownout_seconds
		milestones[request_id] = _elapsed
		if not session.economy.state.pending_era_transition_id.is_empty():
			var transition_id := session.economy.state.pending_era_transition_id
			milestones[transition_id] = _elapsed
			if verify_boundary_saves:
				session = _round_trip(session, transition_id)
			_check(session.economy.state.pending_era_transition_id == transition_id, "%s pending transition survives save/load" % transition_id)
			_check(session.acknowledge_era_transition(), "%s transition acknowledges after restore" % transition_id)
			if transition_id == "era_02_bedroom_assistant":
				era2_saved = true
			elif transition_id == "era_03_home_server_closet":
				era3_saved = true
		_check(session.acknowledge_report(request_id), "%s report is viewed" % request_id)
	_check(session.economy.state.prototype_complete, "leftovers report reaches the explicit prototype endpoint")
	_check(session.current_request_id().is_empty(), "prototype endpoint does not invent an Era 4 request")
	_check(session.available_optional_request_ids().size() == 3, "all three vanity requests remain reachable without blocking the endpoint")
	_check(session.economy.state.current_era_id == "era_03_home_server_closet", "final current era remains Home Server Closet")
	_check(session.economy.state.best_stability_service_ratio >= 0.85, "a Stability request reaches the documented 85% gate")
	_check(session.has_feature("allocation_modes"), "allocation unlock is reachable")
	_check(session.has_feature("automatic_generation"), "automatic generation unlock is reachable before repetition")
	_check(session.has_feature("offline_progress"), "offline progress unlock is reachable")
	_check(session.has_feature("reserve_forecast"), "Reserve forecast unlock is reachable")
	_check(session.has_feature("detailed_forecast"), "detailed forecast unlock is reachable")
	_check(session.has_feature("reserve_thresholds"), "Reserve threshold unlock is reachable")
	_check(session.configure_reserve_automation(true, 0.25), "Smart Meter Reserve protection operates after its feature unlock")
	_check(is_equal_approx(session.requests.grid.conversion_efficiency, 0.9), "Era 3 Stored Energy efficiency comes from authored balance")
	if verify_boundary_saves:
		_check(era2_saved and era3_saved, "both era transitions were saved and restored")
		session = _round_trip(session, "prototype_endpoint")
		_check(session.economy.state.prototype_complete, "prototype endpoint persists through save/load")
	return {
		"elapsed": _elapsed,
		"idle_elapsed": _idle_elapsed,
		"max_idle_gap": _max_idle_gap,
		"milestones": milestones,
		"purchases": purchases,
		"brownout_seconds": total_brownout_seconds,
		"stored_energy": session.requests.grid.state.stored_energy,
		"owned": session.economy.state.owned.duplicate(true),
	}


func _prepare_for_request(session: GameSession, request_id: String, purchases: Array[String]) -> void:
	match request_id:
		"era01_remember_name": _buy_infrastructure(session, "wall_outlet", purchases)
		"era01_identify_cat": _buy_infrastructure(session, "questionable_power_strip", purchases)
		"era01_basic_arithmetic": _buy_infrastructure(session, "laptop_battery", purchases)
		"era01_friendlier_thanks": _buy_infrastructure(session, "wall_outlet", purchases)
		"era01_understand_tuesdays":
			_buy_infrastructure(session, "tiny_desk_fan", purchases)
			_check(session.set_allocation_mode("feed_watt"), "allocation modes operate after their tutorial unlock")
		"era02_organize_photographs":
			_buy_infrastructure(session, "extension_cord", purchases)
			_buy_infrastructure(session, "upgraded_breaker", purchases)
			_buy_infrastructure(session, "portable_generator", purchases)
		"era02_recommend_dinner":
			_buy_infrastructure(session, "rooftop_solar_panel", purchases)
			_buy_infrastructure(session, "home_battery", purchases)
		"era02_rewrite_text_message": _buy_infrastructure(session, "second_questionable_power_strip", purchases)
		"era02_learn_tuesdays": _buy_upgrade(session, "generator_coordination", purchases)
		"era02_improve_loading_animation": _buy_infrastructure(session, "gaming_gpu", purchases)
		"era03_sort_photo_archive":
			_buy_upgrade(session, "dedicated_circuit_research", purchases)
			if not session.economy.state.pending_era_transition_id.is_empty():
				return
			_buy_infrastructure(session, "server_rack", purchases)
		"era03_predict_package_arrival":
			_buy_infrastructure(session, "server_rack", purchases)
			_buy_infrastructure(session, "whole_home_battery", purchases)
			_buy_infrastructure(session, "reinforced_wiring", purchases)
		"era03_write_grocery_list":
			_buy_infrastructure(session, "backup_generator", purchases)
			_buy_infrastructure(session, "smart_meter", purchases)
		"era03_leftovers_edible":
			_buy_infrastructure(session, "dedicated_cooling", purchases)
			_buy_infrastructure(session, "outdoor_transformer", purchases)


func _buy_infrastructure(session: GameSession, id: String, purchases: Array[String]) -> void:
	var preview := session.preview_infrastructure(id)
	_check(preview.status != EconomyPreview.LOCKED, "%s is reachable before purchase" % id)
	_earn_until(session, preview.cost)
	_check(session.purchase_infrastructure(id), "%s purchases with earned Stored Energy" % id)
	purchases.append(id)


func _buy_upgrade(session: GameSession, id: String, purchases: Array[String]) -> void:
	var preview := session.preview_upgrade(id)
	_check(preview.status != EconomyPreview.LOCKED, "%s is reachable before purchase" % id)
	_earn_until(session, preview.cost)
	_check(session.purchase_upgrade(id), "%s purchases with earned Stored Energy" % id)
	purchases.append(id)


func _earn_until(session: GameSession, target: float) -> void:
	var guard := 0
	var gap := 0.0
	while session.requests.grid.state.stored_energy + 0.000001 < target and guard < 10000:
		_check(session.advance_idle_time(10.0), "idle grid earns through normal conversion")
		_elapsed += 10.0
		_idle_elapsed += 10.0
		gap += 10.0
		guard += 1
	_max_idle_gap = maxf(_max_idle_gap, gap)
	_check(session.requests.grid.state.stored_energy + 0.000001 >= target, "earned Stored Energy reaches %.1f" % target)


func _round_trip(session: GameSession, label: String) -> GameSession:
	var path := "%s/%s" % [_save_root, label]
	var manager := SaveManager.new(path, _repository.get_content_version())
	var saved := manager.save({"session": session.snapshot()}, 100000 + roundi(_elapsed), 100000 + roundi(_elapsed), label)
	_check(bool(saved.get("ok", false)), "%s boundary writes a valid save" % label)
	var loaded := manager.load()
	_check(loaded.ok, "%s boundary reloads its main save" % label)
	var restored := GameSession.new()
	_check(restored.configure(_repository) and restored.restore(loaded.envelope.get("payload", {}).get("session", {}), _repository), "%s boundary restores complete domain state" % label)
	return restored


func _compare_runs(first: Dictionary, second: Dictionary) -> void:
	_check(is_equal_approx(float(first["elapsed"]), float(second["elapsed"])), "clean full-path elapsed time is deterministic")
	_check(first["milestones"] == second["milestones"], "request and era milestone times are deterministic")
	_check(first["purchases"] == second["purchases"], "purchase path is deterministic")
	_check(is_equal_approx(float(first["brownout_seconds"]), float(second["brownout_seconds"])), "brownout summary is deterministic")
	_check(is_equal_approx(float(first["stored_energy"]), float(second["stored_energy"])), "final currency is deterministic")
	_check(first["owned"] == second["owned"], "final ownership is deterministic")
	_check(is_equal_approx(float(first["idle_elapsed"]), float(second["idle_elapsed"])), "idle-time total is deterministic")
	print("PHASE 07 BALANCE REPORT: elapsed %.1f minutes, Era 2 %.1f, Era 3 %.1f, idle %.1f minutes, longest idle gap %.1fs, brownout %.1fs, purchases %d" % [
		float(first["elapsed"]) / 60.0,
		float(first["milestones"].get("era_02_bedroom_assistant", 0.0)) / 60.0,
		float(first["milestones"].get("era_03_home_server_closet", 0.0)) / 60.0,
		float(first["idle_elapsed"]) / 60.0,
		float(first["max_idle_gap"]),
		float(first["brownout_seconds"]),
		(first["purchases"] as Array).size(),
	])


func _cleanup_tree(path: String) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	var directory := DirAccess.open(absolute)
	if directory == null:
		return
	directory.list_dir_begin()
	var name := directory.get_next()
	while not name.is_empty():
		var child := "%s/%s" % [absolute, name]
		if directory.current_is_dir():
			_cleanup_tree(child)
		else:
			DirAccess.remove_absolute(child)
		name = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(absolute)


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 07 VERTICAL SLICE TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 07 TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
