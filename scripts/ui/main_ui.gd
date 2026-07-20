class_name MainUI
extends Control

const SHOP_CARD_SCENE := preload("res://scenes/components/ShopItemCard.tscn")
const VITAL_CARD_SCENE := preload("res://scenes/components/VitalCard.tscn")

var session := GameSession.new()
var view_model: MainViewModel
var navigation := NavigationState.new()
var persistence: PersistenceController
var _refresh_accumulator := 0.0
var _last_report_modal_id := ""
var _last_era_transition_modal_id := ""
var _pending_purchase: Dictionary = {}
var _feedback_tween: Tween

var status_era_label: Label
var status_energy_label: Label
var status_power_label: Label
var watt_core: Label
var focal_panel: PanelContainer
var environment_label: Label
var dialogue_label: Label
var request_title_label: Label
var request_meta_label: Label
var request_progress: ProgressBar
var forecast_label: Label
var request_action_button: Button
var vital_cards: Dictionary = {}
var allocation_label: Label
var allocation_buttons: Dictionary = {}
var screen_title_label: Label
var screen_content: VBoxContainer
var nav_buttons: Dictionary = {}
var feedback_label: Label
var modal_overlay: ColorRect
var modal_title: Label
var modal_content: VBoxContainer
var feedback_audio: FeedbackAudio


func _ready() -> void:
	_build_interface()
	feedback_audio = FeedbackAudio.new()
	feedback_audio.name = "FeedbackAudio"
	add_child(feedback_audio)
	var content_db := get_node_or_null("/root/ContentDB")
	if content_db == null or not bool(content_db.call("is_loaded")):
		_show_content_error()
		return
	var repository: ContentRepository = content_db.get("repository")
	if not session.configure(repository):
		_show_content_error()
		return
	var bootstrap_result: Dictionary = {"ok": true, "status": "disabled"}
	var persistence_disabled := bool(ProjectSettings.get_setting("one_more_watt/testing/disable_persistence", false)) or "--smoke-test" in OS.get_cmdline_user_args()
	if not persistence_disabled:
		persistence = PersistenceController.new()
		persistence.configure(session, SaveManager.new("user://", repository.get_content_version()))
		bootstrap_result = persistence.bootstrap(int(Time.get_unix_time_from_system()))
	view_model = MainViewModel.new(session)
	session.feedback.feedback_requested.connect(_on_feedback)
	select_tab("grid")
	_refresh_all(true)
	if bootstrap_result.get("status") == "corrupt_all":
		call_deferred("_open_corrupt_save_modal")
	elif bootstrap_result.get("offline_report") is OfflineReport:
		var recovery_note := "Recovered from %s." % persistence.last_load_result.source if bool(bootstrap_result.get("recovered", false)) else ""
		call_deferred("open_offline_report", bootstrap_result["offline_report"], recovery_note)
	set_process(true)
	print("ONE MORE WATT Phase 08 playtest build ready")
	if "--smoke-test" in OS.get_cmdline_user_args():
		get_tree().quit(0)


func _process(delta: float) -> void:
	var simulation_delta := minf(delta, 0.25)
	if session.requests.get_active_state() != null and navigation.modal_depth() == 0:
		session.advance_time(simulation_delta)
	elif session.requests.get_active_state() == null and view_model != null:
		session.advance_idle_time(simulation_delta)
	_refresh_accumulator += delta
	if _refresh_accumulator >= 0.2:
		_refresh_accumulator = 0.0
		_refresh_all(false)
	if persistence != null:
		persistence.tick(delta, int(Time.get_unix_time_from_system()))
	if not session.last_report_id.is_empty() and session.last_report_id != _last_report_modal_id and navigation.modal_depth() == 0:
		open_report_modal(session.last_report_id)
	elif not session.economy.state.pending_era_transition_id.is_empty() and session.economy.state.pending_era_transition_id != _last_era_transition_modal_id and navigation.modal_depth() == 0:
		open_era_transition_modal(session.economy.state.pending_era_transition_id)


func select_tab(tab: String) -> bool:
	if not navigation.select_tab(tab):
		return false
	for key: Variant in nav_buttons:
		(nav_buttons[key] as Button).button_pressed = str(key) == tab
	_apply_tab_density()
	_rebuild_screen()
	return true


func handle_back() -> bool:
	if navigation.modal_depth() > 0:
		close_top_modal()
		return true
	if navigation.current_tab != "grid":
		select_tab("grid")
		return true
	return false


func open_request_modal() -> void:
	var request := view_model.request_snapshot()
	if request.get("status") == RequestRunState.COMPLETED:
		open_report_modal(str(request["id"]))
		return
	if request.get("status") != RequestRunState.ANNOUNCED:
		return
	_open_modal("request_detail", "REQUEST FORECAST")
	_add_modal_label(str(request["title"]), 24, Color(1.0, 0.89, 0.35))
	_add_modal_label(str(request["dialogue"]), 18, Color(0.84, 0.92, 1.0))
	if not str(request.get("tutorial", "")).is_empty():
		_add_modal_label("TUTORIAL  •  %s" % request["tutorial"], 16, Color(0.62, 0.94, 0.72))
	var forecast_text := "LOAD %s  •  PEAK %s\nESTIMATE %s  •  BOTTLENECK %s\nREWARD %s" % [
		NumberFormatter.format_power(float(request["continuous_demand"]), session.settings.number_notation),
		NumberFormatter.format_power(float(request["peak"]), session.settings.number_notation),
		NumberFormatter.format_duration(float(request["estimated_seconds"])),
		str(request["bottleneck"]).to_upper(),
		NumberFormatter.format_energy(float(request["reward"]), session.settings.number_notation),
	]
	if bool(request.get("reserve_forecast_unlocked", false)):
		forecast_text += "\nRESERVE %s" % NumberFormatter.format_energy(float(request["recommended_reserve"]), session.settings.number_notation)
	if bool(request.get("detailed_forecast_unlocked", false)):
		forecast_text += "  •  PREDICTED SERVICE %.0f%%" % (float(request["service_ratio"]) * 100.0)
	_add_modal_label(forecast_text, 17, Color.WHITE)
	var authorize := _button("Authorize Request", "AuthorizeButton")
	authorize.pressed.connect(_authorize_from_modal)
	modal_content.add_child(authorize)
	if bool(request["underprepared"]):
		_add_modal_label("! %s\nAuthorization remains available." % request["warning"], 17, Color(1.0, 0.62, 0.3))
	_add_modal_label("BEST NEXT STEP  •  %s" % _recommendation(str(request["bottleneck"])), 16, Color(0.62, 0.94, 0.72))
	if not bool(request.get("required", true)):
		var skip := _button("Skip Optional Request", "SkipRequestButton")
		skip.pressed.connect(_skip_optional_from_modal)
		modal_content.add_child(skip)
	_add_modal_back_button()


func open_report_modal(request_id: String) -> void:
	var report := session.requests.get_report(request_id)
	if report == null:
		return
	_last_report_modal_id = request_id
	_open_modal("performance_report", "PERFORMANCE REPORT")
	var data := view_model.report_snapshot(report)
	_add_modal_label("GRADE %s  •  %.1f" % [data["grade"], data["score"]], 32, Color(1.0, 0.89, 0.35))
	_add_modal_label(str(data["title"]), 22, Color(0.3, 0.78, 1.0))
	_add_modal_label("TIME %s  •  SERVICE %.1f%%\nPEAK %s / %s SERVED\nBROWNOUT %s  •  EARNED %s\nUNLOCKS %s" % [
		NumberFormatter.format_duration(float(data["completion_seconds"])),
		float(data["service_ratio"]) * 100.0,
		NumberFormatter.format_power(float(data["peak_demand"]), session.settings.number_notation),
		NumberFormatter.format_power(float(data["peak_served"]), session.settings.number_notation),
		NumberFormatter.format_duration(float(data["brownout_seconds"])),
		NumberFormatter.format_energy(float(data["stored_energy"]), session.settings.number_notation),
		"None" if (data["unlock_ids"] as Array).is_empty() else ", ".join(data["unlock_ids"]),
	], 17, Color.WHITE)
	_add_modal_label(str(data["completion"]), 18, Color(0.75, 0.9, 1.0))
	_add_modal_label("NEXT TIME  •  %s" % data["suggestion"], 16, Color(0.62, 0.94, 0.72))
	var report_state := session.requests.get_request_state(request_id)
	var acknowledge := _button("Continue" if report_state.status == RequestRunState.COMPLETED else "Back to Reports", "AcknowledgeButton")
	acknowledge.pressed.connect(func() -> void:
		if report_state.status == RequestRunState.COMPLETED:
			session.acknowledge_report(request_id)
		close_top_modal()
		_refresh_all(true)
	)
	modal_content.add_child(acknowledge)


func open_settings_modal() -> void:
	_open_modal("settings", "SETTINGS + ACCESSIBILITY")
	var reduced := CheckButton.new()
	reduced.name = "ReducedMotionCheck"
	reduced.custom_minimum_size.y = 48
	reduced.add_theme_font_size_override("font_size", 18)
	reduced.text = "Reduced motion"
	reduced.button_pressed = session.settings.reduced_motion
	reduced.toggled.connect(func(value: bool) -> void: session.settings.reduced_motion = value; _settings_changed())
	modal_content.add_child(reduced)
	var text_size := _button(_text_size_label(), "TextSizeButton")
	text_size.pressed.connect(_cycle_text_size)
	modal_content.add_child(text_size)
	var notation := _button(_notation_label(), "NotationButton")
	notation.pressed.connect(_toggle_notation)
	modal_content.add_child(notation)
	var haptics := CheckButton.new()
	haptics.name = "HapticsCheck"
	haptics.custom_minimum_size.y = 48
	haptics.add_theme_font_size_override("font_size", 18)
	haptics.text = "Haptics"
	haptics.button_pressed = session.settings.haptics_enabled
	haptics.toggled.connect(func(value: bool) -> void: session.settings.haptics_enabled = value; _settings_changed())
	modal_content.add_child(haptics)
	var confirm := CheckButton.new()
	confirm.name = "ConfirmLargeCheck"
	confirm.custom_minimum_size.y = 48
	confirm.add_theme_font_size_override("font_size", 18)
	confirm.text = "Confirm large purchases"
	confirm.button_pressed = session.settings.confirm_large_purchases
	confirm.toggled.connect(func(value: bool) -> void: session.settings.confirm_large_purchases = value; _settings_changed())
	modal_content.add_child(confirm)
	for volume_data: Dictionary in [
		{"label": "Master", "field": "master_volume"},
		{"label": "Music", "field": "music_volume"},
		{"label": "Effects", "field": "effects_volume"},
		{"label": "Text sound", "field": "text_sound_volume"},
	]:
		var volume_button := _button("%s volume • %.0f%%" % [volume_data["label"], float(session.settings.get(volume_data["field"])) * 100.0], "%sVolumeButton" % volume_data["label"].replace(" ", ""))
		volume_button.pressed.connect(_cycle_volume.bind(volume_button, str(volume_data["field"]), str(volume_data["label"])))
		modal_content.add_child(volume_button)
	var diagnostic := _button("Show diagnostic summary", "DiagnosticButton")
	diagnostic.pressed.connect(func() -> void:
		if persistence == null:
			diagnostic.text = "Test session • persistence disabled"
		else:
			var details := persistence.manager.diagnostics()
			diagnostic.text = "Save sequence %d • main %s • B1 %s • B2 %s" % [details["sequence"], details["main_exists"], details["backup_1_exists"], details["backup_2_exists"]]
	)
	modal_content.add_child(diagnostic)
	_add_modal_label("ONE MORE WATT • v%s\nPrototype by Ferro AI" % ProjectSettings.get_setting("application/config/version", "unknown"), 15, Color(0.6, 0.68, 0.8))
	_add_modal_back_button("Close Settings")


func close_top_modal() -> void:
	if navigation.pop_modal().is_empty():
		return
	modal_overlay.visible = false
	_clear_children(modal_content)


func refresh_now(rebuild_screen: bool = false) -> void:
	_refresh_all(rebuild_screen)


func open_offline_report(report: OfflineReport, recovery_note: String = "") -> void:
	_open_modal("offline_report", "OFFLINE RETURN")
	var earned := report.stored_energy_after - report.stored_energy_before
	_add_modal_label("WELCOME BACK", 26, Color(0.3, 0.78, 1.0))
	_add_modal_label("AWAY %s  •  RECOGNIZED %s\nEFFICIENCY %.0f%%  •  EFFECTIVE %s\nCAP %s%s\nSTORED ENERGY %+.1f  •  BROWNOUT %s" % [
		NumberFormatter.format_duration(maxf(report.raw_elapsed, 0.0)),
		NumberFormatter.format_duration(report.recognized_elapsed),
		report.efficiency * 100.0,
		NumberFormatter.format_duration(report.effective_elapsed),
		NumberFormatter.format_duration(report.cap_seconds),
		" • CAP APPLIED" if report.capped else "",
		earned,
		NumberFormatter.format_duration(report.brownout_seconds),
	], 17, Color.WHITE)
	if report.feature_locked:
		_add_modal_label("Offline progress unlocks during Bedroom Assistant. No away-time progress was applied yet.", 16, Color(1.0, 0.72, 0.36))
	if not report.request_id.is_empty():
		_add_modal_label("REQUEST %.1f%% → %.1f%%\nCOMPLETED %s" % [report.progress_before * 100.0, report.progress_after * 100.0, "None" if report.completed_request_ids.is_empty() else ", ".join(report.completed_request_ids)], 17, Color(0.62, 0.94, 0.72))
	if report.clock_backward:
		_add_modal_label("Clock moved backward. No negative progress was applied.", 16, Color(1.0, 0.72, 0.36))
	elif report.far_forward:
		_add_modal_label("Large clock jump detected. The normal offline cap was applied.", 16, Color(1.0, 0.72, 0.36))
	if report.stopped_for_input:
		_add_modal_label("Offline progress paused because WATT is waiting for your authorization.", 16, Color(1.0, 0.72, 0.36))
	if not recovery_note.is_empty():
		_add_modal_label(recovery_note, 16, Color(1.0, 0.89, 0.35))
	var continue_button := _button("Continue", "OfflineContinueButton")
	continue_button.pressed.connect(close_top_modal)
	modal_content.add_child(continue_button)


func open_era_transition_modal(era_id: String) -> void:
	var era := session.repository.get_era(era_id)
	if era == null:
		return
	_last_era_transition_modal_id = era_id
	_open_modal("era_transition", "ERA %d UNLOCKED" % era.get_number())
	_add_modal_label(session.repository.localize(str(era.get_value("name_key", ""))), 28, Color(1.0, 0.89, 0.35))
	_add_modal_label(session.repository.localize(str(era.get_value("description_key", ""))), 18, Color(0.84, 0.92, 1.0))
	_add_modal_label(session.repository.localize("dialogue.era.%02d.transition" % era.get_number()), 18, Color(0.62, 0.94, 0.72))
	var continue_button := _button("Enter %s" % session.repository.localize(str(era.get_value("scale_key", ""))), "EraContinueButton")
	continue_button.pressed.connect(func() -> void:
		session.acknowledge_era_transition()
		close_top_modal()
		_refresh_all(true)
	)
	modal_content.add_child(continue_button)


func _open_corrupt_save_modal() -> void:
	_open_modal("save_recovery", "SAVE RECOVERY REQUIRED")
	_add_modal_label("The main save and both backups could not be validated. The files were preserved for diagnostics. Start a new local game only if you want to continue.", 18, Color(1.0, 0.72, 0.36))
	var confirm := _button("Start New Game", "ConfirmNewGameButton")
	confirm.pressed.connect(func() -> void:
		if persistence.confirm_new_game(int(Time.get_unix_time_from_system())).get("ok", false):
			close_top_modal()
	)
	modal_content.add_child(confirm)


func _build_interface() -> void:
	set_process(false)
	var shell := get_node("SafeArea/AppShell") as PanelContainer
	var layout := VBoxContainer.new()
	layout.name = "MainLayout"
	layout.add_theme_constant_override("separation", 4)
	shell.add_child(layout)

	var status := HBoxContainer.new()
	status.name = "StatusBand"
	status.custom_minimum_size.y = 42
	layout.add_child(status)
	status_era_label = _label("COLD BOOT", 14, Color(0.3, 0.78, 1.0))
	status_era_label.name = "EraLabel"
	status_era_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(status_era_label)
	status_energy_label = _label("0 SE", 16, Color(1.0, 0.89, 0.35))
	status_energy_label.name = "StoredEnergyLabel"
	status_energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_energy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(status_energy_label)
	status_power_label = _label("5 W", 14, Color(0.74, 0.9, 1.0))
	status_power_label.name = "AggregatePowerLabel"
	status_power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_power_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(status_power_label)
	var settings_button := _button("⚙", "SettingsButton")
	settings_button.custom_minimum_size = Vector2(48, 48)
	settings_button.add_theme_font_size_override("font_size", 18)
	settings_button.tooltip_text = "Settings"
	settings_button.pressed.connect(open_settings_modal)
	status.add_child(settings_button)

	focal_panel = PanelContainer.new()
	focal_panel.name = "WattRequestPanel"
	focal_panel.custom_minimum_size.y = 154
	focal_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.105, 0.16), Color(0.19, 0.73, 1.0), 12, 10))
	layout.add_child(focal_panel)
	var focal_row := HBoxContainer.new()
	focal_row.add_theme_constant_override("separation", 10)
	focal_panel.add_child(focal_row)
	var watt_column := VBoxContainer.new()
	watt_column.custom_minimum_size.x = 76
	focal_row.add_child(watt_column)
	watt_core = _label("◉‿◉", 26, Color(0.25, 0.88, 1.0))
	watt_core.name = "WattCore"
	watt_core.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	watt_column.add_child(watt_core)
	environment_label = _label("OLD MONITOR\n1 OUTLET", 11, Color(0.58, 0.67, 0.78))
	environment_label.name = "EnvironmentLabel"
	environment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	watt_column.add_child(environment_label)
	var request_column := VBoxContainer.new()
	request_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	request_column.add_theme_constant_override("separation", 2)
	focal_row.add_child(request_column)
	dialogue_label = _label("WATT is booting.", 16, Color(0.84, 0.92, 1.0))
	dialogue_label.name = "DialogueLabel"
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.max_lines_visible = 2
	request_column.add_child(dialogue_label)
	request_title_label = _label("Finish Booting", 19, Color(1.0, 0.89, 0.35))
	request_title_label.name = "RequestTitleLabel"
	request_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	request_column.add_child(request_title_label)
	request_meta_label = _label("CAPACITY • ANNOUNCED", 12, Color(0.55, 0.75, 0.92))
	request_meta_label.name = "RequestMetaLabel"
	request_column.add_child(request_meta_label)
	request_progress = ProgressBar.new()
	request_progress.name = "RequestProgress"
	request_progress.custom_minimum_size.y = 12
	request_progress.show_percentage = false
	request_column.add_child(request_progress)
	forecast_label = _label("Forecast ready", 12, Color(0.65, 0.75, 0.86))
	forecast_label.name = "ForecastLabel"
	forecast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	request_column.add_child(forecast_label)
	request_action_button = _button("Review Request", "RequestActionButton")
	request_action_button.custom_minimum_size.y = 48
	request_action_button.add_theme_font_size_override("font_size", 16)
	request_action_button.pressed.connect(open_request_modal)
	request_column.add_child(request_action_button)

	var vital_grid := HBoxContainer.new()
	vital_grid.name = "VitalCards"
	vital_grid.add_theme_constant_override("separation", 5)
	layout.add_child(vital_grid)
	for vital_id: String in ["generation", "transmission", "reserve"]:
		var card := VITAL_CARD_SCENE.instantiate() as VitalCard
		card.name = "%sVitalCard" % vital_id.capitalize()
		vital_grid.add_child(card)
		vital_cards[vital_id] = card

	var allocation_box := VBoxContainer.new()
	allocation_box.name = "AllocationControl"
	allocation_box.add_theme_constant_override("separation", 1)
	layout.add_child(allocation_box)
	var allocation_row := HBoxContainer.new()
	allocation_box.add_child(allocation_row)
	for data: Dictionary in [
		{"id": "expand_grid", "label": "Expand Grid"},
		{"id": "balanced", "label": "Balanced"},
		{"id": "feed_watt", "label": "Feed WATT"},
	]:
		var button := _button(str(data["label"]), "%sAllocationButton" % str(data["id"]).to_pascal_case())
		button.toggle_mode = true
		button.custom_minimum_size.y = 48
		button.add_theme_font_size_override("font_size", 13)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_set_allocation.bind(str(data["id"])))
		allocation_row.add_child(button)
		allocation_buttons[data["id"]] = button
	allocation_label = _label("Balanced", 12, Color(0.62, 0.82, 0.94))
	allocation_label.name = "AllocationSummaryLabel"
	allocation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	allocation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	allocation_box.add_child(allocation_label)

	var screen_panel := PanelContainer.new()
	screen_panel.name = "ScreenPanel"
	screen_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.055, 0.09), Color(0.14, 0.24, 0.36), 10, 7))
	layout.add_child(screen_panel)
	var screen_layout := VBoxContainer.new()
	screen_panel.add_child(screen_layout)
	screen_title_label = _label("GRID", 14, Color(0.3, 0.78, 1.0))
	screen_title_label.name = "ScreenTitleLabel"
	screen_layout.add_child(screen_title_label)
	var scroll := ScrollContainer.new()
	scroll.name = "ScreenScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen_layout.add_child(scroll)
	screen_content = VBoxContainer.new()
	screen_content.name = "ScreenContent"
	screen_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	screen_content.add_theme_constant_override("separation", 7)
	scroll.add_child(screen_content)

	var navigation_bar := HBoxContainer.new()
	navigation_bar.name = "PrimaryNavigation"
	layout.add_child(navigation_bar)
	for tab: String in NavigationState.TABS:
		var nav := _button(tab.capitalize(), "%sTabButton" % tab.capitalize())
		nav.toggle_mode = true
		nav.custom_minimum_size.y = 48
		nav.add_theme_font_size_override("font_size", 14)
		nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nav.pressed.connect(select_tab.bind(tab))
		navigation_bar.add_child(nav)
		nav_buttons[tab] = nav
	feedback_label = _label("GRID ONLINE", 11, Color(0.5, 0.62, 0.76))
	feedback_label.name = "FeedbackLabel"
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(feedback_label)

	_build_modal_layer()


func _build_modal_layer() -> void:
	modal_overlay = ColorRect.new()
	modal_overlay.name = "ModalOverlay"
	modal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_overlay.color = Color(0.01, 0.015, 0.025, 0.92)
	modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_overlay.visible = false
	add_child(modal_overlay)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 36)
	modal_overlay.add_child(margin)
	var panel := PanelContainer.new()
	panel.name = "ModalPanel"
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.075, 0.12), Color(0.19, 0.73, 1.0), 16, 14))
	margin.add_child(panel)
	var modal_layout := VBoxContainer.new()
	panel.add_child(modal_layout)
	modal_title = _label("MODAL", 18, Color(0.3, 0.78, 1.0))
	modal_title.name = "ModalTitle"
	modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_layout.add_child(modal_title)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_layout.add_child(scroll)
	modal_content = VBoxContainer.new()
	modal_content.name = "ModalContent"
	modal_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_content.add_theme_constant_override("separation", 8)
	scroll.add_child(modal_content)


func _refresh_all(rebuild_screen: bool) -> void:
	if view_model == null:
		return
	var status := view_model.status_snapshot()
	var notation := session.settings.number_notation
	status_era_label.text = "%s\n%s" % [str(status["era"]).to_upper(), str(status["scale"]).to_upper()]
	status_energy_label.text = NumberFormatter.format_energy(float(status["stored_energy"]), notation)
	status_power_label.text = NumberFormatter.format_power(float(status["deliverable_power"]), notation)
	var request := view_model.request_snapshot()
	dialogue_label.text = str(request["dialogue"])
	request_title_label.text = str(request["title"])
	request_meta_label.text = "%s  •  %s" % [str(request.get("kind", "idle")).to_upper(), str(request["status"]).to_upper()]
	request_progress.value = float(request.get("progress", 0.0)) * 100.0
	if request["status"] == "prototype_complete":
		forecast_label.text = "ERAS 1–3 COMPLETE  •  MORE COMING"
	else:
		forecast_label.text = "%s PEAK  •  %s LIMITS  •  %s\nNEXT  •  %s" % [
			NumberFormatter.format_power(float(request.get("peak", 0.0)), notation),
			str(request.get("bottleneck", "none")).to_upper(),
			NumberFormatter.format_duration(float(request.get("estimated_seconds", INF))),
			_recommendation_short(str(request.get("bottleneck", "none"))),
		]
	_update_request_action(str(request["status"]))
	var limiting := str(request.get("bottleneck", "none"))
	var live_result := session.requests.grid.get_last_result()
	(vital_cards["generation"] as VitalCard).configure("Generation", NumberFormatter.format_power(float(status["generation"]), notation), "PRODUCING", limiting == "generation")
	(vital_cards["transmission"] as VitalCard).configure("Transmission", NumberFormatter.format_power(float(status["transmission"]), notation), "CAPACITY", limiting == "transmission")
	var reserve_detail := "SUPPORTING ↓" if live_result.reserve_discharge_power > 0.000001 else ("CHARGING ↑" if live_result.reserve_charge_power > 0.000001 else "READY")
	(vital_cards["reserve"] as VitalCard).configure("Reserve", "%s/%s" % [NumberFormatter.format_number(float(status["reserve_stored"]), notation), NumberFormatter.format_number(float(status["reserve_capacity"]), notation)], reserve_detail, limiting == "reserve")
	var mode := session.requests.grid.state.allocation_mode
	var allocation_unlocked := session.has_feature("allocation_modes")
	for key: Variant in allocation_buttons:
		(allocation_buttons[key] as Button).button_pressed = str(key) == mode
		(allocation_buttons[key] as Button).disabled = not allocation_unlocked
	allocation_label.text = "%s  •  %s/s Stored Energy" % [mode.replace("_", " ").capitalize(), NumberFormatter.format_number(live_result.stored_energy_rate, notation)] if allocation_unlocked else "Routing controls unlock after WATT's language experiment"
	var environment := view_model.environment_snapshot()
	environment_label.text = str(environment["badge"])
	watt_core.text = str(environment["core"])
	watt_core.add_theme_color_override("font_color", environment["accent"])
	if rebuild_screen:
		_rebuild_screen()


func _update_request_action(status: String) -> void:
	match status:
		RequestRunState.ANNOUNCED:
			request_action_button.text = "Review + Authorize"
			request_action_button.disabled = false
		RequestRunState.RUNNING:
			request_action_button.text = "Request Running"
			request_action_button.disabled = true
		RequestRunState.COMPLETED:
			request_action_button.text = "View Report"
			request_action_button.disabled = false
		"prototype_complete":
			request_action_button.text = "Prototype Complete"
			request_action_button.disabled = true
		_:
			request_action_button.text = "Waiting for WATT"
			request_action_button.disabled = true


func _rebuild_screen() -> void:
	if screen_content == null or view_model == null:
		return
	_clear_children(screen_content)
	screen_title_label.text = navigation.current_tab.to_upper()
	match navigation.current_tab:
		"grid": _build_grid_screen()
		"build": _build_shop_screen(view_model.infrastructure_cards())
		"upgrades": _build_shop_screen(view_model.upgrade_cards())
		"reports": _build_reports_screen()


func _build_grid_screen() -> void:
	var request := view_model.request_snapshot()
	var environment_data := view_model.environment_snapshot()
	var environment := _label(str(environment_data["summary"]), 15, Color(0.74, 0.84, 0.94))
	environment.name = "EnvironmentSummary"
	environment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	screen_content.add_child(environment)
	var action_text := "PROTOTYPE COMPLETE  •  WATT's larger network is not part of this build yet." if request["status"] == "prototype_complete" else "RECOMMENDED  •  %s" % _recommendation(str(request.get("bottleneck", "none")))
	var action := _label(action_text, 15, Color(0.62, 0.94, 0.72))
	action.name = "RecommendedActionLabel"
	action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	screen_content.add_child(action)
	if not str(request.get("tutorial", "")).is_empty():
		var tutorial := _label("TUTORIAL  •  %s" % request["tutorial"], 15, Color(1.0, 0.89, 0.35))
		tutorial.name = "TutorialPrompt"
		tutorial.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		screen_content.add_child(tutorial)
	if session.has_feature("reserve_thresholds"):
		var automation := CheckButton.new()
		automation.name = "ReserveAutomationCheck"
		automation.text = "Protect Reserve below %.0f%%" % (session.economy.state.reserve_threshold_ratio * 100.0)
		automation.custom_minimum_size.y = 48
		automation.add_theme_font_size_override("font_size", 18)
		automation.button_pressed = session.economy.state.reserve_automation_enabled
		automation.toggled.connect(func(enabled: bool) -> void:
			session.configure_reserve_automation(enabled, session.economy.state.reserve_threshold_ratio)
			_refresh_all(true)
		)
		screen_content.add_child(automation)
	for optional: Dictionary in view_model.optional_requests():
		if optional["id"] == request.get("id", ""):
			continue
		var optional_button := _button("OPTIONAL  •  %s\n%s" % [optional["title"], optional["summary"]], "%sOptionalButton" % str(optional["id"]).to_pascal_case())
		optional_button.custom_minimum_size.y = 68
		optional_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		optional_button.pressed.connect(_choose_optional_request.bind(str(optional["id"])))
		screen_content.add_child(optional_button)


func _build_shop_screen(cards: Array[Dictionary]) -> void:
	for data: Dictionary in cards:
		var card := SHOP_CARD_SCENE.instantiate() as ShopItemCard
		card.name = "%sCard" % str(data["id"]).to_pascal_case()
		screen_content.add_child(card)
		card.configure(data, session.settings.number_notation)
		card.purchase_requested.connect(_request_purchase)


func _build_reports_screen() -> void:
	var reports := view_model.reports()
	if reports.is_empty():
		var empty := _label("Completed request reports will appear here. WATT has not filed any paperwork yet.", 16, Color(0.68, 0.76, 0.86))
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		screen_content.add_child(empty)
		return
	for data: Dictionary in reports:
		var button := _button("GRADE %s  •  %s\n%.1f%% served  •  %s" % [data["grade"], data["title"], float(data["service_ratio"]) * 100.0, NumberFormatter.format_duration(float(data["completion_seconds"]))], "%sReportButton" % str(data["id"]).to_pascal_case())
		button.custom_minimum_size.y = 72
		button.add_theme_font_size_override("font_size", 14)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(open_report_modal.bind(str(data["id"])))
		screen_content.add_child(button)


func _request_purchase(content_id: String, family: String) -> void:
	var preview := session.preview_infrastructure(content_id) if family == "infrastructure" else session.preview_upgrade(content_id)
	if not preview.can_purchase():
		return
	if session.settings.confirm_large_purchases and preview.cost >= session.requests.grid.state.stored_energy * 0.5:
		_pending_purchase = {"id": content_id, "family": family}
		_open_modal("purchase_confirmation", "CONFIRM PURCHASE")
		_add_modal_label("Spend %s?\nThe predicted effect shown on the card will be applied immediately." % NumberFormatter.format_energy(preview.cost, session.settings.number_notation), 18, Color.WHITE)
		var confirm := _button("Confirm Purchase", "ConfirmPurchaseButton")
		confirm.pressed.connect(_confirm_pending_purchase)
		modal_content.add_child(confirm)
		_add_modal_back_button("Cancel")
		return
	_apply_purchase(content_id, family)


func _confirm_pending_purchase() -> void:
	var pending := _pending_purchase.duplicate()
	_pending_purchase.clear()
	close_top_modal()
	_apply_purchase(str(pending.get("id", "")), str(pending.get("family", "")))


func _apply_purchase(content_id: String, family: String) -> void:
	var accepted := session.purchase_infrastructure(content_id) if family == "infrastructure" else session.purchase_upgrade(content_id)
	feedback_label.text = "BUILT  •  %s" % content_id.replace("_", " ").to_upper() if accepted else "PURCHASE NOT AVAILABLE"
	_refresh_all(true)


func _authorize_from_modal() -> void:
	if session.authorize_current_request():
		close_top_modal()
		_refresh_all(true)


func _skip_optional_from_modal() -> void:
	if session.skip_current_optional_request():
		close_top_modal()
		_refresh_all(true)


func _choose_optional_request(request_id: String) -> void:
	if session.choose_request(request_id):
		_refresh_all(true)


func _set_allocation(mode: String) -> void:
	session.set_allocation_mode(mode)
	_refresh_all(false)


func _open_modal(modal_id: String, title: String) -> void:
	if navigation.modal_depth() > 0:
		close_top_modal()
	navigation.push_modal(modal_id)
	_clear_children(modal_content)
	modal_title.text = title
	modal_overlay.visible = true


func _add_modal_label(text: String, font_size: int, color: Color) -> void:
	var label := _label(text, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_content.add_child(label)


func _add_modal_back_button(text: String = "Back") -> void:
	var back := _button(text, "ModalBackButton")
	back.pressed.connect(close_top_modal)
	modal_content.add_child(back)


func _cycle_text_size() -> void:
	var next := (session.settings.text_scale_index + 1) % RuntimeSettings.TEXT_SCALES.size()
	session.settings.set_text_scale_index(next)
	var base_theme := theme.duplicate() as Theme
	base_theme.default_font_size = roundi(18.0 * session.settings.get_text_scale())
	theme = base_theme
	var button := modal_content.find_child("TextSizeButton", true, false) as Button
	if button != null:
		button.text = _text_size_label()
	_settings_changed()


func _toggle_notation() -> void:
	var target := RuntimeSettings.NOTATION_SCIENTIFIC if session.settings.number_notation == RuntimeSettings.NOTATION_ENGINEERING else RuntimeSettings.NOTATION_ENGINEERING
	session.settings.set_number_notation(target)
	var button := modal_content.find_child("NotationButton", true, false) as Button
	if button != null:
		button.text = _notation_label()
	_refresh_all(true)
	_settings_changed()


func _cycle_volume(button: Button, field: String, label: String) -> void:
	var current := float(session.settings.get(field))
	var next := 0.5 if current > 0.75 else (0.0 if current > 0.25 else 1.0)
	session.settings.set(field, next)
	var bus_name := {"master_volume": "Master", "music_volume": "Music", "effects_volume": "SFX", "text_sound_volume": "UI"}.get(field, "") as String
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, is_zero_approx(next))
		if next > 0.0:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(next))
	button.text = "%s volume • %.0f%%" % [label, next * 100.0]
	_settings_changed()


func _on_feedback(kind: String) -> void:
	if feedback_audio != null:
		feedback_audio.play(kind)
	feedback_label.text = kind.replace("_", " ").to_upper()
	if session.settings.reduced_motion or watt_core == null or focal_panel == null:
		return
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	var accent := Color(0.72, 0.48, 0.48) if kind == "brownout" else (Color(0.66, 0.9, 0.74) if kind in ["request_complete", "era_transition"] else Color(1.0, 0.9, 0.55))
	_feedback_tween = create_tween()
	_feedback_tween.set_parallel(true)
	_feedback_tween.tween_property(watt_core, "modulate", accent, 0.08)
	_feedback_tween.tween_property(focal_panel, "modulate", accent, 0.08)
	_feedback_tween.chain().set_parallel(true)
	_feedback_tween.tween_property(watt_core, "modulate", Color.WHITE, 0.18)
	_feedback_tween.tween_property(focal_panel, "modulate", Color.WHITE, 0.18)


func _apply_tab_density() -> void:
	if focal_panel == null:
		return
	var compact := navigation.current_tab != "grid"
	focal_panel.custom_minimum_size.y = 72.0 if compact else 154.0
	dialogue_label.visible = not compact
	request_meta_label.visible = not compact
	request_progress.visible = not compact
	forecast_label.visible = not compact
	request_action_button.visible = not compact


func _show_content_error() -> void:
	set_process(false)
	if dialogue_label != null:
		dialogue_label.text = "Content unavailable. Validation details were printed for development."
	if request_action_button != null:
		request_action_button.disabled = true
	if "--smoke-test" in OS.get_cmdline_user_args():
		get_tree().quit(1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("app_back"):
		if handle_back():
			get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if persistence == null:
		return
	var now := int(Time.get_unix_time_from_system())
	if what == NOTIFICATION_APPLICATION_PAUSED:
		persistence.background(now)
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		open_offline_report(persistence.resume(now))
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		persistence.save_now("clean_quit", now)


func _settings_changed() -> void:
	if persistence != null:
		persistence.mark_dirty("settings")


func _text_size_label() -> String:
	return "Text size • %d%%" % roundi(session.settings.get_text_scale() * 100.0)


func _notation_label() -> String:
	return "Number notation • %s" % session.settings.number_notation.capitalize()


static func _recommendation(bottleneck: String) -> String:
	match bottleneck:
		"generation": return "Build Generation so WATT receives more power."
		"transmission": return "Build Transmission so generated power can reach WATT."
		"reserve": return "Build Reserve before the next demand peak."
		_: return "The grid is ready. Review WATT's request forecast."


static func _recommendation_short(bottleneck: String) -> String:
	match bottleneck:
		"generation": return "ADD GENERATION"
		"transmission": return "ADD TRANSMISSION"
		"reserve": return "CHARGE OR BUILD RESERVE"
		_: return "AUTHORIZE WHEN READY"


static func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


static func _button(text: String, name: String) -> Button:
	var button := Button.new()
	button.name = name
	button.text = text
	button.custom_minimum_size.y = 48
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


static func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


static func _panel_style(background: Color, border: Color, radius: int, margin: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin
	style.content_margin_top = margin
	style.content_margin_right = margin
	style.content_margin_bottom = margin
	return style
