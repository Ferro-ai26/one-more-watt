extends SceneTree

const REQUEST_IDS := [
	"era01_finish_booting",
	"era01_basic_arithmetic",
	"era01_understand_tuesdays",
	"era01_friendlier_thanks",
]
const BUTTON_NAMES := ["CapacityButton", "StabilityButton", "BurstButton", "ResearchButton"]

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
	var packed := load("res://scenes/app/Main.tscn") as PackedScene
	_check(packed != null, "main scene loads")
	if packed == null:
		_finish(viewport)
		return
	var main := packed.instantiate() as Control
	viewport.add_child(main)
	await process_frame
	await process_frame
	var panel := main.get_node("SafeArea/DevelopmentShell/ContentScroll/Content/RequestDebugPanel") as RequestDebugPanel
	_check(panel != null, "request debug panel instantiates")
	if panel == null:
		_finish(viewport)
		return
	var capture_layouts := "--capture-layouts" in OS.get_cmdline_user_args()
	for index: int in REQUEST_IDS.size():
		await _run_sample(panel, index)
		if capture_layouts:
			var scroll := main.get_node("SafeArea/DevelopmentShell/ContentScroll") as ScrollContainer
			scroll.scroll_vertical = 100000
			await process_frame
			scroll.scroll_vertical = maxi(scroll.scroll_vertical - 100, 0)
			await process_frame
			var kind := _kind_for(index)
			var path := "user://request_debug_%s.png" % kind
			var error := viewport.get_texture().get_image().save_png(path)
			_check(error == OK, "%s lifecycle capture saves" % kind)
			print("REQUEST DEBUG CAPTURE: %s" % ProjectSettings.globalize_path(path))
		_button(panel, BUTTON_NAMES[index]).emit_signal("pressed")
		await process_frame

	_finish(viewport)


func _run_sample(panel: RequestDebugPanel, index: int) -> void:
	var request_id: String = REQUEST_IDS[index]
	var scenario_button := _button(panel, BUTTON_NAMES[index])
	scenario_button.emit_signal("pressed")
	await process_frame
	_check(panel.current_request_id == request_id, "%s scenario control selects stable request ID" % request_id)
	_check(panel.simulation.get_request_state(request_id).status == RequestRunState.AVAILABLE, "%s target is available" % request_id)
	if index == 1:
		_button(panel, "UnderprepareButton").emit_signal("pressed")
		await process_frame
	_button(panel, "AnnounceButton").emit_signal("pressed")
	await process_frame
	_check(panel.simulation.get_request_state(request_id).status == RequestRunState.ANNOUNCED, "%s announces through button signal" % request_id)
	_check(panel.watt_dialogue_label.text == panel._repository.localize(str(panel._repository.get_request(request_id).get_value("announcement_key", ""))), "%s announcement is data-driven" % request_id)
	_check("REWARD" in panel.preview_label.text and "UNLOCK" in panel.preview_label.text, "%s preview displays rewards and unlocks" % request_id)
	if index == 1:
		_check("UNDERPREPARED" in panel.preview_label.text, "underprepared warning is visible before authorization")
	_button(panel, "AuthorizeButton").emit_signal("pressed")
	await process_frame
	_check(panel.simulation.get_request_state(request_id).status == RequestRunState.AUTHORIZED, "%s authorizes through button signal" % request_id)
	_button(panel, "StartButton").emit_signal("pressed")
	await process_frame
	_check(panel.simulation.get_request_state(request_id).status == RequestRunState.RUNNING, "%s starts through button signal" % request_id)
	var reserve_before := panel.simulation.grid.state.reserve_stored
	if index == 1:
		_button(panel, "FeedButton").emit_signal("pressed")
		_button(panel, "AdvanceOneButton").emit_signal("pressed")
		await process_frame
		var brownout_state := panel.simulation.get_request_state(request_id)
		_check(brownout_state.progress > 0.0 and brownout_state.brownout_seconds > 0.0, "underprepared request progresses during brownout")
		_button(panel, "RecoverButton").emit_signal("pressed")
		_button(panel, "BalancedButton").emit_signal("pressed")
		_button(panel, "AdvanceOneButton").emit_signal("pressed")
		await process_frame
		_check(not panel.simulation.grid.state.brownout_active, "grid recovers after explicit recovery control")
	var guard := 0
	while panel.simulation.get_request_state(request_id).status == RequestRunState.RUNNING and guard < 20:
		_button(panel, "AdvanceTenButton").emit_signal("pressed")
		await process_frame
		guard += 1
	var state := panel.simulation.get_request_state(request_id)
	_check(state.status == RequestRunState.COMPLETED, "%s reaches completed state" % request_id)
	var report := panel.simulation.get_report(request_id)
	_check(report != null and report.request_id == request_id, "%s report matches the observed run" % request_id)
	_check("REPORT %s" % report.grade in panel.report_label.text, "%s report grade is displayed" % request_id)
	_check(panel.watt_dialogue_label.text == panel._repository.localize(report.completion_key), "%s completion line cannot be replaced by ambient dialogue" % request_id)
	if index == 1:
		_check(report.brownout_seconds > 0.0 and report.allocation_changes >= 2, "report summarizes brownout and mid-request allocation changes")
	if index == 2:
		_check(panel.simulation.grid.state.reserve_stored < reserve_before, "burst peak uses Reserve")
	_button(panel, "AcknowledgeButton").emit_signal("pressed")
	await process_frame
	_check(state.status == RequestRunState.REPORTED, "%s report acknowledgement completes lifecycle" % request_id)
	if index + 1 < REQUEST_IDS.size():
		_check(panel.simulation.get_next_available_request_id() == REQUEST_IDS[index + 1], "%s acknowledgement identifies next request" % request_id)


func _kind_for(index: int) -> String:
	return ["capacity", "stability", "burst", "research"][index]


func _button(panel: RequestDebugPanel, name: String) -> Button:
	return panel.find_child(name, true, false) as Button


func _finish(viewport: SubViewport) -> void:
	viewport.queue_free()
	if _failures.is_empty():
		print("REQUEST DEBUG PANEL TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("REQUEST DEBUG PANEL TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
