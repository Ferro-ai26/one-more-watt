extends SceneTree

const MAIN_IDS := [
	"era01_finish_booting", "era01_remember_name", "era01_identify_cat", "era01_basic_arithmetic", "era01_friendlier_thanks", "era01_understand_tuesdays",
	"era02_organize_photographs", "era02_recommend_dinner", "era02_rewrite_text_message", "era02_learn_tuesdays", "era02_improve_loading_animation",
	"era03_sort_photo_archive", "era03_predict_package_arrival", "era03_write_grocery_list", "era03_leftovers_edible",
]

var _failures: Array[String] = []
var _checks := 0
var _capture_layouts := false


func _init() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	_capture_layouts = "--capture-layouts" in OS.get_cmdline_user_args()
	call_deferred("_run")


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(393, 873)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var packed := load("res://scenes/app/Main.tscn") as PackedScene
	var main := packed.instantiate() as MainUI
	viewport.add_child(main)
	await process_frame
	await process_frame
	_check(main.status_era_label.text.contains("COLD BOOT"), "clean UI begins in Cold Boot")
	_check(main.dialogue_label.text.contains("almost awake"), "WATT's role and first request are immediately visible")
	_check(main.screen_content.find_child("TutorialPrompt", true, false) is Label, "embedded authorization tutorial appears before the first action")
	_check((main.allocation_buttons["feed_watt"] as Button).disabled, "allocation controls begin locked")
	_check(main.forecast_label.text.contains("NEXT"), "compact forecast names the next useful action")
	_check(main.feedback_audio != null, "essential feedback audio player is present")
	if _capture_layouts:
		await _capture(viewport, "cold_boot")

	_complete_through(main.session, "era01_identify_cat")
	_check("era01_larger_loading_dot" in main.session.available_optional_request_ids(), "Era 1 vanity request becomes reachable")
	_check(main.session.choose_request("era01_larger_loading_dot"), "player can select an optional request without debug controls")
	_check(main.session.current_request_id() == "era01_larger_loading_dot", "optional request becomes the focal request")
	_check(main.session.skip_current_optional_request(), "optional request can be skipped without blocking progression")
	_check(main.session.current_request_id() == "era01_basic_arithmetic", "required path resumes after an optional skip")
	_complete_through(main.session, "era01_friendlier_thanks")
	main.refresh_now(true)
	await process_frame
	_check(main.session.has_feature("allocation_modes"), "language research unlocks allocation")
	_check(not (main.allocation_buttons["feed_watt"] as Button).disabled, "allocation controls visibly enable")
	_complete_through(main.session, "era01_understand_tuesdays")
	main.refresh_now(true)
	await process_frame
	_check(main.navigation.top_modal() == "era_transition", "Era 2 transition opens as a player-facing modal")
	_check(_modal_text(main).to_upper().contains("BEDROOM ASSISTANT"), "Era 2 transition names the new environment")
	if _capture_layouts:
		await _capture(viewport, "bedroom_transition")
	await _press(main.modal_content.find_child("EraContinueButton", true, false) as Button)
	_check(main.environment_label.text.contains("BEDROOM GRID"), "Era 2 transforms the visible environment")

	_complete_through(main.session, "era02_improve_loading_animation")
	_buy_upgrade(main.session, "dedicated_circuit_research")
	main.refresh_now(true)
	await process_frame
	_check(main.navigation.top_modal() == "era_transition", "Era 3 transition opens after all three gates")
	_check(_modal_text(main).to_upper().contains("HOME SERVER CLOSET"), "Era 3 transition names the server-closet scale")
	if _capture_layouts:
		await _capture(viewport, "server_closet_transition")
	await _press(main.modal_content.find_child("EraContinueButton", true, false) as Button)
	_check(main.environment_label.text.contains("SERVER CLOSET"), "Era 3 transforms the visible environment")

	_complete_through(main.session, "era03_leftovers_edible")
	main.refresh_now(true)
	await process_frame
	_check(main.session.economy.state.prototype_complete, "final report acknowledgement reaches prototype completion")
	_check(main.request_title_label.text == "Home Server Closet Complete", "endpoint is explicit in the focal panel")
	_check(main.dialogue_label.text.contains("More coming"), "endpoint promises more without presenting Era 4")
	_check(not main.dialogue_label.text.contains("Building Network"), "Era 4 is not exposed")
	var automation := main.screen_content.find_child("ReserveAutomationCheck", true, false) as CheckButton
	_check(automation != null, "Smart Meter Reserve protection is visible after its tutorial")
	if automation != null:
		automation.button_pressed = true
		automation.toggled.emit(true)
		_check(main.session.economy.state.reserve_automation_enabled, "Reserve protection can be enabled from the Grid screen")
	if _capture_layouts:
		await _capture(viewport, "prototype_complete")
	main.select_tab("build")
	await process_frame
	var performance_started := Time.get_ticks_usec()
	for index: int in 25:
		main.refresh_now(true)
	var rebuild_msec := float(Time.get_ticks_usec() - performance_started) / 1000.0
	_check(rebuild_msec < 1500.0, "worst-state Build screen rebuilds 25 times inside the 1500ms host budget (%.1fms)" % rebuild_msec)
	performance_started = Time.get_ticks_usec()
	for index: int in 500:
		main.refresh_now(false)
	var refresh_msec := float(Time.get_ticks_usec() - performance_started) / 1000.0
	_check(refresh_msec < 1000.0, "worst-state presentation refreshes 500 times inside the 1000ms host budget (%.1fms)" % refresh_msec)
	var worst_state_nodes := main.find_children("*", "Node", true, false).size()
	_check(worst_state_nodes < 500, "worst representative UI state remains below 500 nodes")
	print("PHASE 08 PERFORMANCE REPORT: 25 full Build rebuilds %.1fms, 500 live refreshes %.1fms, %d UI nodes" % [rebuild_msec, refresh_msec, worst_state_nodes])
	main.session.feedback.request("error")
	_check(main.feedback_audio.last_played == "error", "semantic feedback produces a mixed procedural sound cue")

	viewport.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PHASE 08 UI AND PERFORMANCE TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 08 UI TEST FAILED: %s" % failure)
	quit(1)


func _complete_through(session: GameSession, target_id: String) -> void:
	for request_id: String in MAIN_IDS:
		var state := session.requests.get_request_state(request_id)
		if state.status == RequestRunState.REPORTED:
			if request_id == target_id:
				return
			continue
		_prepare(session, request_id)
		_check(session.current_request_id() == request_id, "%s is current in graphical path" % request_id)
		_earn_until(session, float(session.repository.get_request(request_id).get_value("research_cost", 0.0)))
		_check(session.authorize_current_request(), "%s authorizes in graphical path" % request_id)
		var guard := 0
		while state.status == RequestRunState.RUNNING and guard < 2000:
			session.advance_time(30.0)
			guard += 1
		_check(state.status == RequestRunState.COMPLETED, "%s completes in graphical path" % request_id)
		_check(session.acknowledge_report(request_id), "%s report acknowledges in graphical path" % request_id)
		if request_id == target_id:
			return


func _prepare(session: GameSession, request_id: String) -> void:
	match request_id:
		"era01_remember_name": _buy_infrastructure(session, "wall_outlet")
		"era01_identify_cat": _buy_infrastructure(session, "questionable_power_strip")
		"era01_basic_arithmetic": _buy_infrastructure(session, "laptop_battery")
		"era01_friendlier_thanks": _buy_infrastructure(session, "wall_outlet")
		"era01_understand_tuesdays": _buy_infrastructure(session, "tiny_desk_fan")
		"era02_organize_photographs":
			_buy_infrastructure(session, "extension_cord")
			_buy_infrastructure(session, "upgraded_breaker")
			_buy_infrastructure(session, "portable_generator")
		"era02_recommend_dinner":
			_buy_infrastructure(session, "rooftop_solar_panel")
			_buy_infrastructure(session, "home_battery")
		"era02_rewrite_text_message": _buy_infrastructure(session, "second_questionable_power_strip")
		"era02_learn_tuesdays": _buy_upgrade(session, "generator_coordination")
		"era02_improve_loading_animation": _buy_infrastructure(session, "gaming_gpu")
		"era03_sort_photo_archive": _buy_infrastructure(session, "server_rack")
		"era03_predict_package_arrival":
			_buy_infrastructure(session, "server_rack")
			_buy_infrastructure(session, "whole_home_battery")
			_buy_infrastructure(session, "reinforced_wiring")
		"era03_write_grocery_list":
			_buy_infrastructure(session, "backup_generator")
			_buy_infrastructure(session, "smart_meter")
		"era03_leftovers_edible":
			_buy_infrastructure(session, "dedicated_cooling")
			_buy_infrastructure(session, "outdoor_transformer")


func _buy_infrastructure(session: GameSession, id: String) -> void:
	var preview := session.preview_infrastructure(id)
	_earn_until(session, preview.cost)
	_check(session.purchase_infrastructure(id), "%s purchases in graphical clean path" % id)


func _buy_upgrade(session: GameSession, id: String) -> void:
	var preview := session.preview_upgrade(id)
	_earn_until(session, preview.cost)
	_check(session.purchase_upgrade(id), "%s purchases in graphical clean path" % id)


func _earn_until(session: GameSession, target: float) -> void:
	var guard := 0
	while session.requests.grid.state.stored_energy + 0.000001 < target and guard < 10000:
		session.advance_idle_time(10.0)
		guard += 1


func _modal_text(main: MainUI) -> String:
	var parts: PackedStringArray = [main.modal_title.text]
	for value: Variant in main.modal_content.find_children("*", "Label", true, false):
		parts.append((value as Label).text)
	return "\n".join(parts)


func _press(button: Button) -> void:
	button.emit_signal("pressed")
	await process_frame


func _capture(viewport: SubViewport, name: String) -> void:
	await process_frame
	await process_frame
	var path := "user://phase08_%s.png" % name
	var error := viewport.get_texture().get_image().save_png(path)
	_check(error == OK, "%s capture saves" % name)
	print("PHASE 08 UI CAPTURE: %s" % ProjectSettings.globalize_path(path))


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
