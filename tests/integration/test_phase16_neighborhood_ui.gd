extends SceneTree

const EVIDENCE_DIR := "res://docs/phase_16/evidence"
const ERA5_REQUEST_IDS := [
	"era05_restore_evening_service", "era05_coordinate_community_solar",
	"era05_prepare_overnight_reserve", "era05_automate_routine_switchovers",
	"era05_route_underground_distribution", "era05_unify_neighborhood_service",
]

var _failures: Array[String] = []
var _checks := 0
var _capture := false


func _init() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	_capture = "--capture-phase16" in OS.get_cmdline_user_args()
	call_deferred("_run")


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(393, 873)
	viewport.disable_3d = true
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var main := (load("res://scenes/app/Main.tscn") as PackedScene).instantiate() as MainUI
	viewport.add_child(main)
	await process_frame
	await process_frame
	main.set_process(false)
	_prepare_neighborhood_session(main.session)
	main.refresh_now(true)
	await process_frame

	_check(main.environment_view.skin.skin_id == EraSkinRegistry.ERA_05_ID, "Main uses the approved Neighborhood skin")
	_check(main.environment_view.skin.watt_variant == "scratched_core", "Neighborhood preserves the original scratched core")
	_check(main.environment_label.text.contains("NEIGHBORHOOD GRID"), "Neighborhood scale remains explicit in the world-first view")
	_check(main.request_action_button.text == "Review + Authorize", "human authorization remains the request-route action")
	_check(main.environment_view.owned_counts.has("neighborhood_substation"), "Neighborhood infrastructure is represented in the live environment")
	if _capture:
		await _save_capture(viewport, "neighborhood_main_393x873.png")

	main.session.economy.state.unlocked_features["neighborhood_forecast"] = true
	main.refresh_now(true)
	main._open_operator_drawer()
	await process_frame
	_check(main.environment_frame.is_visible_in_tree() and main.environment_frame.custom_minimum_size.y >= main.size.y * 0.38, "operator controls remain a contextual drawer beneath the live neighborhood")
	_check(main.screen_content.find_child("NeighborhoodForecastDetail", true, false) != null, "forecast detail appears at its sequential unlock")
	_check(main.screen_content.find_child("BalancedPolicyButton", true, false) == null, "Reserve policy is not exposed with the first forecast unlock")
	if _capture:
		await _save_capture(viewport, "forecast_drawer_393x873.png")

	main.session.economy.state.unlocked_features["reserve_policy"] = true
	main.refresh_now(true)
	await process_frame
	_check(main.screen_content.find_child("BalancedPolicyButton", true, false) != null, "Reserve presets appear only after the policy unlock")
	_check(main.screen_content.find_child("ReserveFloorButton", true, false) != null and main.screen_content.find_child("RequestStartTargetButton", true, false) != null, "advanced floor and start-target controls are reachable")
	if _capture:
		await _save_capture(viewport, "reserve_policy_drawer_393x873.png")

	main.session.economy.state.unlocked_features["routine_maintenance_automation"] = true
	main.refresh_now(true)
	await process_frame
	_check(main.screen_content.find_child("RoutineAutomationCheck", true, false) != null, "routine automation appears only after its sequential unlock")
	main.session.economy.state.pending_maintenance_id = "era05_feeder_relay_reset"
	_check(main.session.configure_routine_automation(true, 1000000.0), "UI fixture enables policy-bounded routine automation")
	_check(not main.session.has_pending_maintenance(), "eligible routine service resolves without replacing the neighborhood")
	main.refresh_now(true)
	await process_frame
	_check(_all_text(main.screen_content).contains("ROUTINE MAINTENANCE"), "contextual action log explains the automatic service")
	if _capture:
		await _save_capture(viewport, "routine_automation_drawer_393x873.png")

	main.session.economy.state.unlocked_features["request_scheduling"] = true
	main.refresh_now(true)
	await process_frame
	var schedule_button := main.screen_content.find_child("ScheduleNextReturnButton", true, false) as Button
	_check(schedule_button != null and schedule_button.custom_minimum_size.y >= 48.0, "one-request scheduling is a reachable 48 dp contextual action")
	if schedule_button != null:
		schedule_button.emit_signal("pressed")
	await process_frame
	_check(main.screen_content.find_child("ScheduledRequestStatus", true, false) != null, "scheduled state is labeled redundantly in the drawer")
	_check(main.request_action_button.text == "Scheduled • Review", "world request plate remains contextual after authorization")
	if _capture:
		await _save_capture(viewport, "request_scheduled_drawer_393x873.png")

	main.session.settings.set_text_scale_index(2)
	main._apply_text_scale()
	viewport.size = Vector2i(320, 568)
	main.size = Vector2(320.0, 568.0)
	main._apply_responsive_layout()
	await process_frame
	await process_frame
	var shell := main.get_node("SafeArea/AppShell") as Control
	var scroll_limit := main.screen_scroll.get_v_scroll_bar().max_value - main.screen_scroll.get_v_scroll_bar().page
	_check(shell.size.x <= 320.0, "operator drawer stays within the 320-pixel logical width")
	_check(scroll_limit > 0.0, "130% operator controls remain reachable by vertical scrolling at 320×568")
	if _capture:
		main.screen_scroll.scroll_vertical = roundi(main.screen_scroll.get_v_scroll_bar().max_value)
		await process_frame
		await _save_capture(viewport, "operator_controls_large_text_320x568.png")

	viewport.size = Vector2i(393, 873)
	main.size = Vector2(393.0, 873.0)
	main.session.settings.set_text_scale_index(0)
	main._close_operator_drawer()
	_prepare_capstone_report(main.session)
	main.refresh_now(true)
	main.open_report_modal("era05_unify_neighborhood_service")
	await process_frame
	var report_text := _all_text(main.modal_content)
	_check(report_text.contains("TAKEOVER REPORT") and report_text.contains("NEIGHBORHOOD GRID AUTHORITY"), "capstone completion card is shareable and states commandeered authority")
	_check(report_text.contains("AUTOMATION ACTIONS"), "performance report explains automation activity")
	if _capture:
		await _save_capture(viewport, "neighborhood_takeover_report_393x873.png")
	var acknowledge := main.modal_content.find_child("AcknowledgeButton", true, false) as Button
	acknowledge.emit_signal("pressed")
	await process_frame
	_check(main.view_model.request_snapshot().get("status") == "phase16_complete", "capstone stops at the explicit Phase 16 endpoint")
	_check(main.request_action_button.text == "City Data Center Locked", "City Data Center remains preview-only")
	main.environment_view._transition_progress = 0.82
	main.environment_view.queue_redraw()
	await process_frame
	if _capture:
		await _save_capture(viewport, "neighborhood_city_pullback_393x873.png")

	viewport.queue_free()
	await process_frame
	_finish()


func _prepare_neighborhood_session(session: GameSession) -> void:
	for era_id: String in ["era_01_cold_boot", "era_02_bedroom_assistant", "era_03_home_server_closet", "era_04_building_network", "era_05_neighborhood_microgrid"]:
		session.economy.state.unlocked_eras[era_id] = true
	session.economy.state.current_era_id = "era_05_neighborhood_microgrid"
	session.economy.state.pending_era_transition_id = ""
	session.last_report_id = ""
	session.requests._active_id = ""
	session.requests._selected_id = ""
	for request_value: Variant in session.repository.get_all("requests"):
		var request := request_value as RequestDefinition
		var era := session.repository.get_era(str(request.get_value("era_id", "")))
		if era != null and era.get_number() <= 4 and bool(request.get_value("required", false)):
			var request_id := request.get_id()
			session.economy.state.completed_requests[request_id] = true
			session.requests._completed[request_id] = true
			session.requests.get_request_state(request_id).status = RequestRunState.REPORTED
	for feature_id: String in ["allocation_modes", "automatic_generation", "offline_progress", "reserve_forecast", "detailed_forecast", "reserve_thresholds", "predictive_reserve_guard"]:
		session.economy.state.unlocked_features[feature_id] = true
	session.economy.state.owned.merge({
		"building_transformer": 3, "commercial_battery_room": 3, "parking_lot_solar": 4, "central_cooling": 2,
		"neighborhood_substation": 3, "community_solar_farm": 4, "municipal_generator": 3, "battery_warehouse": 3,
		"small_hydroelectric_plant": 2, "underground_distribution": 2, "borrowed_utility_connection": 1,
	}, true)
	session.economy.state.stored_energy = 500000000.0
	session.economy.rebuild_derived_state()
	session.requests.refresh_availability(session.economy.state)
	session._sync_request_grid_from_economy()
	session.requests.grid.state.reserve_stored = session.requests.grid.state.reserve_capacity
	session._announce_next_required_if_needed()


func _prepare_capstone_report(session: GameSession) -> void:
	session.economy.state.pending_maintenance_id = ""
	session.economy.state.scheduled_request_id = ""
	session.economy.state.scheduled_start_rule = ""
	session.last_report_id = "era05_unify_neighborhood_service"
	session.requests._active_id = ""
	session.requests._selected_id = "era05_unify_neighborhood_service"
	for request_id: String in ERA5_REQUEST_IDS:
		var state := session.requests.get_request_state(request_id)
		state.status = RequestRunState.COMPLETED if request_id == "era05_unify_neighborhood_service" else RequestRunState.REPORTED
		state.progress = 1.0
		state.reward_granted = true
		session.requests._completed[request_id] = true
		session.economy.state.completed_requests[request_id] = true
	var report := PerformanceReport.new()
	report.request_id = "era05_unify_neighborhood_service"
	report.kind = "stability"
	report.grade = "A"
	report.stability_score = 94.0
	report.completion_seconds = 1380.0
	report.demand_served_ratio = 0.97
	report.demanded_energy = 4400000000.0
	report.served_energy = 4268000000.0
	report.peak_demand = 5400000.0
	report.peak_served = 5200000.0
	report.brownout_seconds = 18.0
	report.stored_energy_earned = 8000000.0
	report.reward_stored_energy = 60000000.0
	report.ending_reserve = 12000000.0
	report.ending_reserve_capacity = 20000000.0
	report.safe_throttle_seconds = 42.0
	report.safe_throttle_events = 1
	report.automation_actions = [{"sequence": 4, "type": "routine_maintenance", "target_id": "era05_battery_filter_service", "outcome": "resolved", "cost": 800000.0, "reason": "authored_safe_action_within_operator_cap"}]
	report.completion_key = "request.era05_unify_neighborhood_service.completion"
	report.suggestion_key = "report.suggestion.preserve_reserve"
	session.requests._reports[report.request_id] = report


func _all_text(root: Node) -> String:
	var parts := PackedStringArray()
	for label_value: Variant in root.find_children("*", "Label", true, false):
		parts.append((label_value as Label).text)
	return "\n".join(parts)


func _save_capture(viewport: SubViewport, filename: String) -> void:
	await process_frame
	await process_frame
	var absolute_dir := ProjectSettings.globalize_path(EVIDENCE_DIR)
	DirAccess.make_dir_recursive_absolute(absolute_dir)
	var path := "%s/%s" % [absolute_dir, filename]
	var captured := viewport.get_texture().get_image()
	_check(captured != null and not captured.is_empty(), "graphical evidence renders: %s" % filename)
	if captured != null and not captured.is_empty():
		_check(captured.save_png(path) == OK, "graphical evidence saves: %s" % filename)
		print("PHASE 16 CAPTURE: %s" % path)


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 16 NEIGHBORHOOD UI TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 16 NEIGHBORHOOD UI TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
