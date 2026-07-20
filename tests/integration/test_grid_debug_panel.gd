extends SceneTree

var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/debug/GridDebugPanel.tscn") as PackedScene
	_check(packed != null, "standalone grid debug scene loads")
	if packed == null:
		_finish()
		return

	var viewport := SubViewport.new()
	viewport.size = Vector2i(393, 873)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var panel := packed.instantiate() as GridDebugPanel
	viewport.add_child(panel)
	await process_frame
	await process_frame

	var status := panel.get_node("GridStatusLabel") as Label
	var event_label := panel.get_node("GridEventLabel") as Label
	var capture_layouts := "--capture-layouts" in OS.get_cmdline_user_args()
	_check(panel.ready_for_debug, "debug panel configures from balance data")

	await _press(panel.get_node("Scenarios/GenerationLimitedButton") as Button)
	_check(status.text == "GRID STABLE  •  LIMITING: GENERATION", "generation scenario identifies Generation")
	_check_near(panel.simulation.get_last_result().deliverable_power, 5.0, "generation scenario delivered power")
	if capture_layouts:
		await _capture(viewport, "generation")

	await _press(panel.get_node("Scenarios/TransmissionLimitedButton") as Button)
	_check(status.text == "GRID STABLE  •  LIMITING: TRANSMISSION", "transmission scenario identifies Transmission")
	_check_near(panel.simulation.get_last_result().deliverable_power, 6.0, "transmission scenario delivered power")
	if capture_layouts:
		await _capture(viewport, "transmission")

	await _press(panel.get_node("Scenarios/ReserveProtectedButton") as Button)
	_check(status.text == "GRID STABLE  •  LIMITING: RESERVE", "Reserve scenario identifies Reserve")
	_check_near(panel.simulation.get_last_result().reserve_discharge_power, 4.0, "Reserve scenario covers peak")
	_check(not panel.simulation.state.brownout_active, "Reserve scenario remains stable")
	if capture_layouts:
		await _capture(viewport, "reserve")

	await _press(panel.get_node("Scenarios/BrownoutButton") as Button)
	_check("BROWNOUT" in status.text, "brownout scenario shows status")
	_check("brownout_started" in event_label.text, "brownout scenario shows start event")
	_check_near(panel.simulation.get_last_result().unmet_power, 10.0, "brownout scenario shows remaining deficit")
	if capture_layouts:
		await _capture(viewport, "brownout")

	await _press(panel.get_node("TimeControls/RecoverButton") as Button)
	_check("GRID STABLE" in status.text, "Recover control returns grid to stable")
	_check("brownout_ended" in event_label.text, "Recover control shows end event")
	if capture_layouts:
		await _capture(viewport, "recovery")

	panel.load_scenario("generation_limited")
	await _press(panel.get_node("Allocation/ExpandGridButton") as Button)
	var expand_watt := panel.simulation.get_last_result().watt_power
	await _press(panel.get_node("Allocation/FeedWattButton") as Button)
	var feed_watt := panel.simulation.get_last_result().watt_power
	_check(feed_watt > expand_watt, "allocation controls change WATT power")
	_check(panel.simulation.state.allocation_mode == "feed_watt", "Feed WATT control changes mode")

	var elapsed_before := panel.simulation.state.elapsed_seconds
	await _press(panel.get_node("TimeControls/AdvanceOneButton") as Button)
	_check_near(panel.simulation.state.elapsed_seconds - elapsed_before, 1.0, "one-second debug advance is exact")
	elapsed_before = panel.simulation.state.elapsed_seconds
	await _press(panel.get_node("TimeControls/AdvanceTenButton") as Button)
	_check_near(panel.simulation.state.elapsed_seconds - elapsed_before, 10.0, "ten-second debug advance is exact")

	viewport.queue_free()
	await process_frame
	_finish()


func _press(button: Button) -> void:
	button.emit_signal("pressed")
	await process_frame


func _capture(viewport: SubViewport, scenario: String) -> void:
	await process_frame
	await process_frame
	var path := "user://grid_debug_%s.png" % scenario
	var error := viewport.get_texture().get_image().save_png(path)
	_check(error == OK, "%s debug capture saves" % scenario)
	print("GRID DEBUG CAPTURE: %s" % ProjectSettings.globalize_path(path))


func _finish() -> void:
	if _failures.is_empty():
		print("GRID DEBUG PANEL TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("GRID DEBUG PANEL TEST FAILED: %s" % failure)
	quit(1)


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= 0.000001, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
