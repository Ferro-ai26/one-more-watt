extends SceneTree

const TEST_SIZES := [Vector2i(320, 568), Vector2i(360, 640), Vector2i(393, 873), Vector2i(480, 800), Vector2i(720, 1280)]

var _failures: Array[String] = []
var _checks := 0
var _capture_layouts := false


func _init() -> void:
	_capture_layouts = "--capture-layouts" in OS.get_cmdline_user_args()
	call_deferred("_run")


func _run() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	var packed := load("res://scenes/app/Main.tscn") as PackedScene
	_check(packed != null, "main scene loads")
	if packed == null:
		_finish()
		return
	for test_size: Vector2i in TEST_SIZES:
		await _exercise_size(packed, test_size)
	_finish()


func _exercise_size(packed: PackedScene, test_size: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.size = test_size
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var main := packed.instantiate() as MainUI
	viewport.add_child(main)
	await process_frame
	await process_frame

	var shell := main.get_node("SafeArea/AppShell") as Control
	_check(main.size.is_equal_approx(Vector2(test_size)), "%s root fills viewport" % test_size)
	_check(shell.size.x <= test_size.x and shell.size.y <= test_size.y, "%s shell %s stays within viewport" % [test_size, shell.size])
	_check(shell.get_combined_minimum_size().x <= test_size.x, "%s shell minimum %s has no horizontal clipping" % [test_size, shell.get_combined_minimum_size()])
	_check(main.watt_core.is_visible_in_tree() and "◉" in main.watt_core.text, "%s WATT remains visible" % test_size)
	_check(main.request_title_label.text == "Finish Booting", "%s request focal panel shows the announcement" % test_size)
	_check(main.request_action_button.text == "Review + Authorize", "%s request action is obvious" % test_size)

	main.open_request_modal()
	await process_frame
	_check(main.navigation.top_modal() == "request_detail" and main.modal_overlay.visible, "%s request detail opens as a modal" % test_size)
	_check(_modal_text(main).contains("LOAD 5 W") and _modal_text(main).contains("REWARD 12 SE"), "%s authorization shows load and reward" % test_size)
	var authorize_button := main.modal_content.find_child("AuthorizeButton", true, false) as Button
	_check(authorize_button != null and authorize_button.get_global_rect().end.y <= test_size.y, "%s primary authorization action is visible without scrolling" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "authorization")
	await _press(main.modal_content.find_child("AuthorizeButton", true, false) as Button)
	_check(main.session.requests.get_active_state() != null, "%s authorization starts the request" % test_size)
	main.session.advance_time(120.0)
	main.refresh_now()
	main.open_report_modal("era01_finish_booting")
	await process_frame
	_check(_modal_text(main).contains("PERFORMANCE") or main.modal_title.text == "PERFORMANCE REPORT", "%s report modal opens" % test_size)
	_check(_modal_text(main).contains("GRADE") and _modal_text(main).contains("EARNED"), "%s report exposes grade and earnings" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "report")
	await _press(main.modal_content.find_child("AcknowledgeButton", true, false) as Button)
	_check(main.session.current_request_id() == "era01_remember_name", "%s report acknowledgement reveals next request" % test_size)

	main.open_request_modal()
	await _press(main.modal_content.find_child("AuthorizeButton", true, false) as Button)
	_check((main.allocation_buttons["feed_watt"] as Button).disabled, "%s allocation remains tutorial-locked before language research" % test_size)
	main.session.requests.grid.state.reserve_stored = 0.0
	main.session.advance_time(0.25)
	main.refresh_now()
	var active := main.session.requests.get_request_state("era01_remember_name")
	_check(active.brownout_seconds > 0.0, "%s underprepared request triggers a recoverable brownout" % test_size)
	var limiting_visible := false
	for vital: Variant in main.vital_cards.values():
		limiting_visible = limiting_visible or "LIMITING" in (vital as VitalCard).state_label.text
	_check(limiting_visible, "%s bottleneck uses explicit limiting text" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "brownout")
	main.session.advance_time(120.0)
	main.refresh_now()
	main.open_report_modal("era01_remember_name")
	await process_frame
	_check(_modal_text(main).contains("BROWNOUT") and not _modal_text(main).contains("BROWNOUT 0.0s"), "%s brownout is recorded in report" % test_size)
	await _press(main.modal_content.find_child("AcknowledgeButton", true, false) as Button)

	_check(main.select_tab("build"), "%s Build navigation works" % test_size)
	await process_frame
	_check(shell.get_combined_minimum_size().x <= test_size.x, "%s Build tab does not widen the shell" % test_size)
	var wall_card := main.screen_content.find_child("WallOutletCard", true, false) as ShopItemCard
	_check(wall_card != null, "%s reusable infrastructure card renders" % test_size)
	_check(wall_card != null and Rect2(Vector2.ZERO, Vector2(test_size)).intersects(wall_card.get_global_rect()), "%s compact secondary header leaves the first Build card visible" % test_size)
	_check("PREDICTED" in wall_card.effect_label.text and "+5.0" in wall_card.effect_label.text, "%s purchase effect is visible before buying" % test_size)
	var old_generation := main.session.requests.grid.state.generation_rate
	await _press(wall_card.buy_button)
	if main.navigation.top_modal() == "purchase_confirmation":
		await _press(main.modal_content.find_child("ConfirmPurchaseButton", true, false) as Button)
	_check(int(main.session.economy.state.owned["wall_outlet"]) == 2, "%s purchase increments ownership" % test_size)
	_check(main.session.requests.grid.state.generation_rate > old_generation, "%s purchase changes the live grid" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "build")

	_check(main.select_tab("upgrades"), "%s Upgrades navigation works" % test_size)
	await process_frame
	_check(shell.get_combined_minimum_size().x <= test_size.x, "%s Upgrades tab does not widen the shell" % test_size)
	_check(main.screen_content.find_child("OutletCalibrationCard", true, false) is ShopItemCard, "%s reusable upgrade card renders" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "upgrades")
	_check(main.select_tab("reports"), "%s Reports navigation works" % test_size)
	await process_frame
	_check(shell.get_combined_minimum_size().x <= test_size.x, "%s Reports tab does not widen the shell" % test_size)
	_check(main.screen_content.find_child("Era01FinishBootingReportButton", true, false) is Button, "%s report archive exposes completed report" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "reports_archive")
	_check(main.handle_back() and main.navigation.current_tab == "grid", "%s back returns primary navigation to Grid" % test_size)

	main.open_settings_modal()
	await process_frame
	_check(_modal_text(main).contains("v0.10.0-dev") and _modal_text(main).contains("BUILD phase10-dev"), "%s settings expose build provenance" % test_size)
	var diagnostic := main.modal_content.find_child("DiagnosticButton", true, false) as Button
	await _press(diagnostic)
	_check("v0.10.0-dev • build phase10-dev" in diagnostic.text, "%s diagnostic summary exposes build provenance" % test_size)
	var reduced := main.modal_content.find_child("ReducedMotionCheck", true, false) as CheckButton
	reduced.button_pressed = true
	reduced.toggled.emit(true)
	await _press(main.modal_content.find_child("TextSizeButton", true, false) as Button)
	await _press(main.modal_content.find_child("TextSizeButton", true, false) as Button)
	await _press(main.modal_content.find_child("NotationButton", true, false) as Button)
	_check(main.session.settings.reduced_motion, "%s reduced motion persists in runtime settings" % test_size)
	_check(is_equal_approx(main.session.settings.get_text_scale(), 1.3), "%s maximum text size option reaches 130%%" % test_size)
	_check(main.request_title_label.get_theme_font_size("font_size") == 25, "%s maximum text setting scales explicit label overrides" % test_size)
	_check(shell.get_combined_minimum_size().x <= test_size.x, "%s larger text minimum %.1f keeps the shell within the viewport width" % [test_size, shell.get_combined_minimum_size().x])
	_check(main.session.settings.number_notation == RuntimeSettings.NOTATION_SCIENTIFIC, "%s number notation option changes formatter mode" % test_size)
	if _capture_layouts:
		await _capture(viewport, test_size, "settings")
	_check(main.handle_back() and not main.modal_overlay.visible, "%s back closes the top modal" % test_size)
	main.open_settings_modal()
	await process_frame
	_check((main.modal_content.find_child("ReducedMotionCheck", true, false) as CheckButton).button_pressed, "%s accessibility setting survives modal reopen" % test_size)
	main.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await process_frame
	_check(not main.modal_overlay.visible, "%s Android back notification closes the top modal" % test_size)

	for button_value: Variant in main.find_children("*", "Button", true, false):
		var button := button_value as Button
		if button.is_visible_in_tree():
			_check(button.custom_minimum_size.y >= 48.0, "%s visible button %s keeps 48px target" % [test_size, button.name])
	viewport.queue_free()
	await process_frame


func _modal_text(main: MainUI) -> String:
	var parts: PackedStringArray = [main.modal_title.text]
	for label_value: Variant in main.modal_content.find_children("*", "Label", true, false):
		parts.append((label_value as Label).text)
	return "\n".join(parts)


func _press(button: Button) -> void:
	_check(button != null, "expected button exists before press")
	if button != null:
		button.emit_signal("pressed")
	await process_frame


func _capture(viewport: SubViewport, test_size: Vector2i, state: String) -> void:
	await process_frame
	await process_frame
	var path := "user://main_ui_%dx%d_%s.png" % [test_size.x, test_size.y, state]
	var error := viewport.get_texture().get_image().save_png(path)
	_check(error == OK, "%s %s capture saves" % [test_size, state])
	print("MAIN UI CAPTURE: %s" % ProjectSettings.globalize_path(path))


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN UI INTEGRATION TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("MAIN UI INTEGRATION TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
