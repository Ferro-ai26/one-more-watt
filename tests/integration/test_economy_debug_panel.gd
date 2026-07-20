extends SceneTree

var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(393, 873)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var packed := load("res://scenes/debug/EconomyDebugPanel.tscn") as PackedScene
	_check(packed != null, "economy debug scene loads")
	if packed == null:
		_finish(viewport)
		return
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	viewport.add_child(scroll)
	var panel := packed.instantiate() as EconomyDebugPanel
	scroll.add_child(panel)
	await process_frame
	await process_frame
	_check(panel != null, "economy debug panel instantiates")
	if panel == null:
		_finish(viewport)
		return
	var capture_layouts := "--capture-layouts" in OS.get_cmdline_user_args()
	_check(panel.economy.state.stored_energy == 1000000.0, "debug panel starts with controlled funds")

	await _press(_button(panel, "LockedButton"))
	_check("LOCKED" in panel.selection_label.text and "request_completed" in panel.preview_label.text, "locked state and reason are visible")
	await _press(_button(panel, "GenerationButton"))
	await _press(_button(panel, "ClearFundsButton"))
	_check("UNAFFORDABLE" in panel.selection_label.text and "MISSING" in panel.preview_label.text, "unaffordable state is visibly distinct")
	await _press(_button(panel, "SeedFundsButton"))

	var core_cases := [
		{"button": "GenerationButton", "id": "wall_outlet", "key": "generation_rate"},
		{"button": "TransmissionButton", "id": "questionable_power_strip", "key": "transmission_capacity"},
		{"button": "ReserveButton", "id": "laptop_battery", "key": "reserve_capacity"},
	]
	for case: Dictionary in core_cases:
		await _press(_button(panel, case["button"]))
		var preview := panel.economy.preview_infrastructure(case["id"])
		var expected := float(preview.resulting_values[case["key"]])
		var old_owned := int(panel.economy.state.owned.get(case["id"], 0))
		await _press(_button(panel, "BuyOneButton"))
		_check(int(panel.economy.state.owned.get(case["id"], 0)) == old_owned + 1, "%s buy control increments ownership" % case["id"])
		_check(is_equal_approx(float(panel.economy.get_derived_values()[case["key"]]), expected), "%s result matches preview" % case["id"])
		_check("MATCHED" in panel.transaction_label.text, "%s shows preview/result confirmation" % case["id"])
	if capture_layouts:
		await _capture(viewport, scroll, "core_purchases", true)

	await _press(_button(panel, "MilestoneButton"))
	var milestone_preview := panel.economy.preview_infrastructure("wall_outlet")
	_check(int(panel.economy.state.owned["wall_outlet"]) == 9, "milestone setup stops at nine owned")
	_check(is_equal_approx(float(milestone_preview.resulting_values["generation_rate"]), 100.0), "milestone preview predicts threshold effect")
	await _press(_button(panel, "BuyOneButton"))
	_check(is_equal_approx(panel.economy.grid.state.generation_rate, 100.0), "tenth purchase applies milestone effect")
	_check("milestone_reached" in panel.events_label.text and "MATCHED" in panel.transaction_label.text, "milestone event and matching prediction are visible")
	if capture_layouts:
		await _capture(viewport, scroll, "milestone", true)

	await _press(_button(panel, "LeveledUpgradeButton"))
	var upgrade_preview := panel.economy.preview_upgrade("outlet_calibration")
	var predicted_generation := float(upgrade_preview.resulting_values["generation_rate"])
	await _press(_button(panel, "BuyOneButton"))
	_check(int(panel.economy.state.upgrade_levels["outlet_calibration"]) == 1, "upgrade control increments level")
	_check(is_equal_approx(panel.economy.grid.state.generation_rate, predicted_generation), "upgrade result matches preview")
	_check("MATCHED" in panel.transaction_label.text, "upgrade shows preview/result confirmation")
	if capture_layouts:
		await _capture(viewport, scroll, "upgrade", true)

	await _press(_button(panel, "SeedFundsButton"))
	await _press(_button(panel, "UnlockButton"))
	await _press(_button(panel, "AutomationButton"))
	_check("AFFORDABLE" in panel.selection_label.text, "automation item unlocks through stable era context")
	await _press(_button(panel, "BuyOneButton"))
	await _press(_button(panel, "EnableAutomationButton"))
	_check(panel.economy.state.reserve_automation_enabled, "automation control enables after purchase")
	await _press(_button(panel, "TestThrottleButton"))
	_check("THROTTLED" in panel.automation_label.text, "low-Reserve throttle result is visible")
	await _press(_button(panel, "DisableAutomationButton"))
	_check(not panel.economy.state.reserve_automation_enabled, "automation disable control is respected")
	if capture_layouts:
		await _capture(viewport, scroll, "automation", true)

	for button_value: Variant in panel.find_children("*", "Button", true, false):
		var button := button_value as Button
		_check(button.custom_minimum_size.y >= 48.0, "%s keeps a 48px touch target" % button.name)
	_finish(viewport)


func _button(panel: EconomyDebugPanel, name: String) -> Button:
	return panel.find_child(name, true, false) as Button


func _press(button: Button) -> void:
	button.emit_signal("pressed")
	await process_frame


func _capture(viewport: SubViewport, scroll: ScrollContainer, name: String, bottom: bool) -> void:
	scroll.scroll_vertical = 100000 if bottom else 0
	await process_frame
	await process_frame
	var path := "user://economy_debug_%s.png" % name
	var error := viewport.get_texture().get_image().save_png(path)
	_check(error == OK, "%s economy capture saves" % name)
	print("ECONOMY DEBUG CAPTURE: %s" % ProjectSettings.globalize_path(path))


func _finish(viewport: SubViewport) -> void:
	viewport.queue_free()
	if _failures.is_empty():
		print("ECONOMY DEBUG PANEL TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ECONOMY DEBUG PANEL TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
