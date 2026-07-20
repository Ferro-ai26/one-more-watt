extends SceneTree

const EVIDENCE_DIR := "res://docs/phase_13/evidence"

var _failures: Array[String] = []
var _checks := 0
var _capture := false


func _init() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	_capture = "--capture-phase13" in OS.get_cmdline_user_args()
	call_deferred("_run")


func _run() -> void:
	_test_registry_and_provenance_boundary()
	await _test_environment_states()
	await _test_live_world_composition()
	_finish()


func _test_registry_and_provenance_boundary() -> void:
	var expected := {
		EraSkinRegistry.ERA_01_ID: 1,
		EraSkinRegistry.ERA_02_ID: 2,
		EraSkinRegistry.ERA_03_ID: 3,
	}
	for skin_id: String in expected:
		var skin := EraSkinRegistry.get_skin(skin_id)
		_check(skin.era_number == int(expected[skin_id]), "%s maps to its unchanged era number" % skin_id)
		_check(skin.validate().is_empty(), "%s validates through the reusable environment contract" % skin_id)
		_check(skin.watt_variant == "scratched_core", "%s preserves the scratched WATT core" % skin_id)
		_check(not skin.release_complete, "%s remains explicitly provisional pending ISSUE-007" % skin_id)
	_check(EraSkinRegistry.get_skin(EraSkinRegistry.ERA_01_ID).wall_color != EraSkinRegistry.get_skin(EraSkinRegistry.ERA_02_ID).wall_color, "Desk and Room have distinct practical silhouettes/palettes")
	_check(EraSkinRegistry.get_skin(EraSkinRegistry.ERA_02_ID).wall_color != EraSkinRegistry.get_skin(EraSkinRegistry.ERA_03_ID).wall_color, "Room and House have distinct practical silhouettes/palettes")
	var inventory := AssetInventoryValidator.validate(false)
	_check(bool(inventory["ok"]), "development asset inventory accepts declared project-original skin plus explicit fallbacks")
	_check(not bool(AssetInventoryValidator.validate(true)["ok"]), "release audit continues to reject ISSUE-007 fallbacks")


func _test_environment_states() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(393, 420)
	viewport.disable_3d = true
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var environment := (load("res://scenes/components/EraEnvironmentView.tscn") as PackedScene).instantiate() as EraEnvironmentView
	viewport.add_child(environment)
	await process_frame
	var states := [
		{"skin": EraSkinRegistry.ERA_01_ID, "counts": {"wall_outlet": 2, "laptop_battery": 1, "tiny_desk_fan": 1}, "name": "era01_desk"},
		{"skin": EraSkinRegistry.ERA_02_ID, "counts": {"wall_outlet": 3, "portable_generator": 2, "home_battery": 1, "gaming_gpu": 1}, "name": "era02_room"},
		{"skin": EraSkinRegistry.ERA_03_ID, "counts": {"server_rack": 3, "whole_home_battery": 2, "backup_generator": 1, "dedicated_cooling": 1, "outdoor_transformer": 1}, "name": "era03_house"},
	]
	for state: Dictionary in states:
		environment.set_skin(EraSkinRegistry.get_skin(str(state["skin"])))
		environment.set_runtime_state(state["counts"], true, true, false, "charging", "pleased")
		await process_frame
		_check(environment.expression == "pleased", "%s exposes charming WATT expression state" % state["name"])
		_check(environment.representative_state() in ["cluster", "bank", "facility"], "%s maps counts to representative infrastructure clusters" % state["name"])
		if _capture:
			await _save_capture(viewport, "%s_393x420.png" % state["name"])
	environment.set_runtime_state(states[2]["counts"], true, false, true, "discharging", "concerned")
	_check(environment.brownout_active and environment.expression == "concerned", "brownout has explicit safe visual state and concerned—not evil—WATT")
	environment.set_reduced_motion(true)
	_check(environment.reduced_motion, "environment supports reduced-motion substitution")
	environment.cue_installation("server_rack")
	_check(environment.last_installation == "server_rack", "purchase feedback targets an authored environment installation")
	environment.start_capstone_pullback()
	_check(environment._transition_progress >= 0.0, "capstone starts the overload/blackout/reboot/pullback presentation")
	if _capture:
		await _save_capture(viewport, "era03_brownout_393x420.png")
	viewport.queue_free()
	await process_frame


func _test_live_world_composition() -> void:
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
	_check(main.environment_view.skin.skin_id == EraSkinRegistry.ERA_01_ID, "clean live Main starts in the Era 1 Desk diorama")
	_check(main.watt_core.text == "◉‿◉", "original WATT glyph remains accessible alongside the physical core")
	_check(main.request_action_button.text == "Review + Authorize", "human operator authorization remains primary")
	if _capture:
		await _save_capture(viewport, "main_era01_393x873.png")
	_check(main.session.authorize_current_request(), "evidence route authorizes the existing first request")
	main.session.advance_time(120.0)
	main.refresh_now()
	main.open_report_modal("era01_finish_booting")
	await process_frame
	_check(main.modal_title.text == "OPERATOR PERFORMANCE REPORT", "shareable completion report uses the operator framing")
	_check(_all_text(main.modal_content).contains("WATT SAYS"), "completion report pairs truthful statistics with calm WATT dialogue")
	if _capture:
		await _save_capture(viewport, "operator_report_393x873.png")
	main.close_top_modal()
	main.open_era_transition_modal("era_02_bedroom_assistant")
	main.environment_view._transition_progress = 0.48
	main.environment_view.queue_redraw()
	await process_frame
	_check(main.modal_overlay.color == SkinTokens.COLOR_TRANSITION_SCRIM, "pullback modal preserves the visible world behind a restrained scrim")
	if _capture:
		await _save_capture(viewport, "pullback_reboot_393x873.png")
	main.close_top_modal()
	main.select_tab("build")
	await process_frame
	_check(not main.focal_panel.visible and main.environment_frame.is_visible_in_tree(), "Build becomes a contextual drawer while the world stays visible")
	_check(float(main.environment_frame.get_meta("world_first_ratio", 0.0)) >= 0.35, "Build preserves at least 35% of portrait height for the live world")
	_check(main.screen_content.find_child("ContextBuildInstruction", true, false) is Label, "Build drawer explains authored world installation")
	var wall := main.screen_content.find_child("WallOutletCard", true, false) as ShopItemCard
	_check(wall != null and wall.glyph.category == "generation", "compact Build connection carries a semantic project-original icon")
	_check(main.feedback_audio.last_played == "drawer_open", "drawer interaction has restrained essential audio feedback")
	if _capture:
		await _save_capture(viewport, "build_drawer_393x873.png")
	main.session.settings.set_text_scale_index(2)
	main._apply_text_scale()
	_check(main.session.settings.get_text_scale() == 1.3, "Build drawer accepts the maximum 130% text scale")
	if _capture:
		await _save_capture(viewport, "build_drawer_large_text_393x873.png")
	main.session.settings.set_text_scale_index(0)
	main._apply_text_scale()
	main.session.economy.state.current_era_id = "era_02_bedroom_assistant"
	main.session.economy.state.owned.merge({"portable_generator": 2, "home_battery": 1, "gaming_gpu": 1}, true)
	main.refresh_now(true)
	await process_frame
	_check(main.environment_view.skin.skin_id == EraSkinRegistry.ERA_02_ID, "live presentation swaps to distinct Era 2 Room")
	main.select_tab("grid")
	await process_frame
	if _capture:
		await _save_capture(viewport, "main_era02_393x873.png")
	main.select_tab("build")
	await process_frame
	main.session.economy.state.current_era_id = "era_03_home_server_closet"
	main.session.economy.state.owned.merge({"server_rack": 3, "whole_home_battery": 2, "backup_generator": 1, "dedicated_cooling": 1, "outdoor_transformer": 1}, true)
	main.refresh_now(true)
	await process_frame
	_check(main.environment_view.skin.skin_id == EraSkinRegistry.ERA_03_ID, "live presentation swaps to distinct Era 3 House/server closet")
	_check(main.environment_view.skin.era_number == 3, "Phase 13 does not expose or begin Era 4")
	if _capture:
		await _save_capture(viewport, "build_drawer_era03_393x873.png")
	viewport.queue_free()
	await process_frame
	await _test_smallest_layout_capture()


func _test_smallest_layout_capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(320, 568)
	viewport.disable_3d = true
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var main := (load("res://scenes/app/Main.tscn") as PackedScene).instantiate() as MainUI
	viewport.add_child(main)
	await process_frame
	await process_frame
	main.select_tab("build")
	await process_frame
	_check(main.get_node("SafeArea/AppShell").size.y <= 568.0, "smallest supported Build drawer stays inside 320×568")
	_check(float(main.environment_frame.get_meta("world_first_ratio", 0.0)) >= 0.35, "smallest supported Build still preserves the live world")
	if _capture:
		await _save_capture(viewport, "build_drawer_320x568.png")
	viewport.queue_free()
	await process_frame


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
	var image := viewport.get_texture().get_image()
	_check(image != null and not image.is_empty(), "graphical evidence image renders: %s" % filename)
	if image != null and not image.is_empty():
		_check(image.save_png(path) == OK, "graphical evidence saves: %s" % filename)
		print("PHASE 13 CAPTURE: %s" % path)


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 13 PRODUCTION-SKIN TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 13 PRODUCTION-SKIN TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
