extends SceneTree

const EVIDENCE_DIR := "res://docs/phase_15/evidence"
const ERA4_REQUEST_IDS := [
	"era04_restore_elevator_service",
	"era04_schedule_rooftop_sunlight",
	"era04_stabilize_shared_backup",
	"era04_reduce_server_room_weather",
	"era04_certify_stairwell_extension",
	"era04_standardize_building_power",
]

var _failures: Array[String] = []
var _checks := 0
var _capture := false


func _init() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	_capture = "--capture-phase15" in OS.get_cmdline_user_args()
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
	_prepare_building_session(main.session)
	main.refresh_now(true)
	await process_frame

	_check(main.environment_view.skin.skin_id == EraSkinRegistry.ERA_04_ID, "Main uses the approved Building skin")
	_check(main.environment_view.skin.watt_variant == "scratched_core", "Building preserves the scratched physical WATT core")
	_check(main.environment_label.text.contains("BUILDING GRID"), "Building scale is explicit without replacing the world")
	_check(main.request_action_button.text == "Review + Authorize", "the human operator still authorizes physical expansion")
	_check(main.dialogue_label.text.contains("elevator"), "Building interaction remains contextual over the world")
	if _capture:
		await _save_capture(viewport, "building_main_393x873.png")

	main.select_tab("build")
	await process_frame
	var transformer := main.screen_content.find_child("BuildingTransformerCard", true, false) as ShopItemCard
	_check(transformer != null and transformer.glyph.icon_texture != null, "Building Transformer uses its integrated production vector icon")
	_check(main.environment_frame.is_visible_in_tree(), "Build remains a world-first contextual drawer")
	var drawer := main.screen_scroll
	_check(drawer.get_v_scroll_bar().max_value > drawer.get_v_scroll_bar().page, "expanded Building catalog remains vertically scrollable")
	if _capture:
		drawer.scroll_vertical = roundi(drawer.get_v_scroll_bar().max_value)
		await process_frame
		await _save_capture(viewport, "building_build_drawer_393x873.png")

	main.select_tab("grid")
	main.set_process(false)
	main.environment_view.set_runtime_state(main.session.economy.state.owned, true, false, true, "discharging", "concerned")
	await process_frame
	_check(main.environment_view.brownout_active and main.environment_view.expression == "concerned", "Building brownout is labeled and WATT remains concerned, not monstrous")
	if _capture:
		await _save_capture(viewport, "building_brownout_393x873.png")
	main.set_process(true)

	main.session.economy.state.pending_maintenance_id = "era04_transformer_thermal_review"
	main.session.requests.grid.state.stored_energy = 12000000.0
	main.session.economy.set_stored_energy(12000000.0)
	main.refresh_now(true)
	main.open_maintenance_modal()
	await process_frame
	_check(main.navigation.top_modal() == "maintenance_choice", "maintenance is an explicit operator decision")
	for option_id: String in ["Repair", "Replace", "Overclock"]:
		var button := main.modal_content.find_child("Maintenance%sButton" % option_id, true, false) as Button
		_check(button != null and button.custom_minimum_size.y >= 48.0, "%s remains a reachable touch target" % option_id)
	_check(_all_text(main.modal_content).contains("No progress or owned infrastructure can be lost"), "maintenance states its non-punitive boundary")
	if _capture:
		await _save_capture(viewport, "maintenance_review_393x873.png")

	main.session.settings.set_text_scale_index(2)
	main._apply_text_scale()
	viewport.size = Vector2i(320, 568)
	main.size = Vector2(320.0, 568.0)
	main._apply_responsive_layout()
	await process_frame
	await process_frame
	var modal_limit := main.modal_scroll.get_v_scroll_bar().max_value - main.modal_scroll.get_v_scroll_bar().page
	var shell := main.get_node("SafeArea/AppShell") as Control
	_check(shell.size.x <= 320.0, "maintenance stays within the 320-pixel logical width (%.1f px)" % shell.size.x)
	_check(modal_limit > 0.0, "130% maintenance content remains reachable by vertical scrolling at 320×568")
	if _capture:
		main.modal_scroll.scroll_vertical = roundi(main.modal_scroll.get_v_scroll_bar().max_value)
		await process_frame
		await _save_capture(viewport, "maintenance_large_text_320x568.png")

	viewport.size = Vector2i(393, 873)
	main.session.settings.set_text_scale_index(0)
	main.close_top_modal()
	_check(main.session.choose_maintenance("repair"), "evidence route resolves maintenance through the public operator action")
	main.session.settings.reduced_motion = true
	main.session.settings.effects_volume = 0.0
	main.environment_view.set_reduced_motion(true)
	_check(main.environment_view.reduced_motion and is_zero_approx(main.session.settings.effects_volume), "reduced-motion and muted-audio states remain independently understandable")

	_prepare_capstone_report(main.session)
	main.refresh_now(true)
	main.open_report_modal("era04_standardize_building_power")
	await process_frame
	var report_text := _all_text(main.modal_content)
	_check(report_text.contains("TAKEOVER REPORT"), "Era 4 capstone produces the shareable takeover report")
	_check(report_text.contains("BUILDING LOAD AUTHORITY"), "takeover report states the commandeered authority")
	_check(report_text.contains("CIVILIAN INCONVENIENCE"), "visual consequences contradict WATT's reassurance in report form")
	if _capture:
		await _save_capture(viewport, "building_takeover_report_393x873.png")
	var acknowledge := main.modal_content.find_child("AcknowledgeButton", true, false) as Button
	acknowledge.emit_signal("pressed")
	await process_frame
	_check(main.view_model.request_snapshot().get("status") == "phase15_complete", "capstone stops at the explicit Phase 15 endpoint")
	_check(main.request_action_button.text == "Neighborhood Locked", "Neighborhood remains preview-only and cannot be entered")
	_check(main.environment_view._transition_progress >= 0.0, "capstone starts the overload/blackout/reboot/pullback sequence")
	main.environment_view._transition_progress = 0.82
	main.environment_view.queue_redraw()
	await process_frame
	if _capture:
		await _save_capture(viewport, "building_neighborhood_pullback_393x873.png")

	viewport.queue_free()
	await process_frame
	_finish()


func _prepare_building_session(session: GameSession) -> void:
	for era_id: String in ["era_01_cold_boot", "era_02_bedroom_assistant", "era_03_home_server_closet", "era_04_building_network"]:
		session.economy.state.unlocked_eras[era_id] = true
	session.economy.state.current_era_id = "era_04_building_network"
	session.economy.state.pending_era_transition_id = ""
	session.economy.state.prototype_complete = true
	session.last_report_id = ""
	session.requests._active_id = ""
	session.requests._selected_id = ""
	for request_value: Variant in session.repository.get_all("requests"):
		var request := request_value as RequestDefinition
		var era := session.repository.get_era(str(request.get_value("era_id", "")))
		if era != null and era.get_number() <= 3 and bool(request.get_value("required", false)):
			var request_id := request.get_id()
			session.economy.state.completed_requests[request_id] = true
			session.requests._completed[request_id] = true
			session.requests.get_request_state(request_id).status = RequestRunState.REPORTED
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
	session._announce_next_required_if_needed()


func _prepare_capstone_report(session: GameSession) -> void:
	session.economy.state.pending_maintenance_id = ""
	session.last_report_id = "era04_standardize_building_power"
	session.requests._active_id = ""
	session.requests._selected_id = "era04_standardize_building_power"
	for request_id: String in ERA4_REQUEST_IDS:
		var state := session.requests.get_request_state(request_id)
		state.status = RequestRunState.COMPLETED if request_id == "era04_standardize_building_power" else RequestRunState.REPORTED
		state.progress = 1.0
		state.reward_granted = true
		session.requests._completed[request_id] = true
		session.economy.state.completed_requests[request_id] = true
	var report := PerformanceReport.new()
	report.request_id = "era04_standardize_building_power"
	report.kind = "stability"
	report.grade = "A"
	report.stability_score = 94.0
	report.completion_seconds = 625.0
	report.demand_served_ratio = 0.97
	report.demanded_energy = 100000000.0
	report.served_energy = 97000000.0
	report.peak_demand = 360000.0
	report.peak_served = 340000.0
	report.brownout_seconds = 12.0
	report.stored_energy_earned = 2200000.0
	report.reward_stored_energy = 4000000.0
	report.ending_reserve = 230000.0
	report.ending_reserve_capacity = 300000.0
	report.completion_key = "request.era04_standardize_building_power.completion"
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
		print("PHASE 15 CAPTURE: %s" % path)


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 15 BUILDING UI TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 15 BUILDING UI TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
