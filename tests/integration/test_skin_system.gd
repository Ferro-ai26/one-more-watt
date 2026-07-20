extends SceneTree

const MIGRATED_LITERAL_SCOPE := [
	"res://scenes/app/Main.tscn",
	"res://scenes/components/EraEnvironmentView.tscn",
	"res://scenes/components/ShopItemCard.tscn",
	"res://scenes/components/VitalCard.tscn",
	"res://scripts/ui/main_ui.gd",
	"res://scripts/ui/main_view_model.gd",
	"res://scripts/ui/era_environment_view.gd",
	"res://scripts/ui/theme/era_skin_definition.gd",
	"res://scripts/ui/theme/era_skin_registry.gd",
	"res://scripts/ui/shop_item_card.gd",
	"res://scripts/ui/vital_card.gd",
]

var _failures: Array[String] = []
var _checks := 0
var _capture := false


func _init() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	_capture = "--capture-skin" in OS.get_cmdline_user_args()
	call_deferred("_run")


func _run() -> void:
	_test_tokens_and_resources()
	_test_asset_inventory()
	_test_literal_audit()
	await _test_components_and_environment()
	await _test_live_sample()
	_finish()


func _test_tokens_and_resources() -> void:
	var theme := load("res://assets/themes/one_more_watt_theme.tres") as Theme
	_check(theme != null, "base Theme resource loads")
	_check(load("res://assets/fonts/AtkinsonHyperlegibleNext-Variable.ttf") is FontFile, "Atkinson Hyperlegible Next packages")
	_check(load("res://assets/fonts/AtkinsonHyperlegibleMono-Variable.ttf") is FontFile, "Atkinson Hyperlegible Mono packages")
	_check(theme != null and theme.default_font != null, "Theme declares the licensed UI font")
	_check(SkinTokens.COLOR_WATT.to_html(false) == "24b8c7", "approved WATT cyan token is exact")
	_check(SkinTokens.COLOR_IVORY.to_html(false) == "f2e8d2", "approved warm ivory token is exact")
	_check(SkinTokens.TOUCH_MINIMUM == 48, "touch-target token preserves 48 logical pixels")
	_check(SkinTokens.REDUCED_MOTION_FADE < SkinTokens.MOTION_REVEAL, "reduced-motion substitution is shorter than full reveal")
	for baseline_path: String in ["res://docs/phase_12/evidence/phase12_main_grid_393x873.png", "res://docs/phase_12/evidence/phase12_build_393x873.png"]:
		var baseline_texture := load(baseline_path) as Texture2D
		var baseline := baseline_texture.get_image() if baseline_texture != null else null
		_check(baseline != null and not baseline.is_empty() and baseline.get_size() == Vector2i(393, 873), "scene-regression baseline loads at reference size: %s" % baseline_path)
	for state: String in ["default", "focused", "pressed", "disabled", "locked", "affordable", "unaffordable", "warning", "loading", "progress"]:
		_check(state in SkinTokens.COMPONENT_STATES, "required semantic component state exists: %s" % state)


func _test_asset_inventory() -> void:
	var development := AssetInventoryValidator.validate(false)
	_check(bool(development["ok"]), "development inventory accepts explicit fallbacks")
	_check(int(development["entries"]) >= 10, "asset inventory covers integrated and pending production assets")
	_check((development["warnings"] as PackedStringArray).size() == 5, "development inventory reports every visible fallback")
	var release := AssetInventoryValidator.validate(true)
	_check(not bool(release["ok"]), "release audit rejects required production fallbacks")


func _test_literal_audit() -> void:
	for path: String in MIGRATED_LITERAL_SCOPE:
		var source := FileAccess.get_file_as_string(path)
		_check(not source.is_empty(), "literal audit reads %s" % path)
		_check(not source.contains("Color("), "migrated scope has no unauthorized raw Color literal: %s" % path)
	var main_source := FileAccess.get_file_as_string("res://scripts/ui/main_ui.gd")
	var migrated_start := main_source.find("func _build_interface()")
	var migrated_end := main_source.find("func _build_modal_layer()")
	var main_grid_source := main_source.substr(migrated_start, migrated_end - migrated_start)
	_check(RegEx.create_from_string("add_theme_font_size_override\\(\"font_size\",\\s*[0-9]").search(main_grid_source) == null, "migrated Main Grid uses semantic typography tokens")


func _test_components_and_environment() -> void:
	var host := Control.new()
	get_root().add_child(host)
	var vital := (load("res://scenes/components/VitalCard.tscn") as PackedScene).instantiate() as VitalCard
	host.add_child(vital)
	var shop := (load("res://scenes/components/ShopItemCard.tscn") as PackedScene).instantiate() as ShopItemCard
	host.add_child(shop)
	await process_frame
	for state: String in SkinTokens.COMPONENT_STATES:
		vital.set_visual_state(state)
		shop.set_visual_state(state)
		_check(vital.get_meta("skin_state") == state and shop.get_meta("skin_state") == state, "reusable components instantiate state: %s" % state)
	vital.set_reduced_motion(true)
	shop.set_reduced_motion(true)
	_check(vital.reduced_motion and shop.reduced_motion, "reusable components expose reduced-motion state")
	vital.value_label.add_theme_font_size_override("font_size", roundi(SkinTokens.TYPE_NUMERIC * 1.3))
	shop.name_label.add_theme_font_size_override("font_size", roundi(SkinTokens.TYPE_HEADING * 1.3))
	_check(vital.value_label.get_theme_font_size("font_size") >= 23 and shop.name_label.get_theme_font_size("font_size") >= 26, "reusable components accept 130% larger text")
	var environment := (load("res://scenes/components/EraEnvironmentView.tscn") as PackedScene).instantiate() as EraEnvironmentView
	host.add_child(environment)
	var repository := ContentRepository.new()
	var load_result := repository.load_from_manifest("res://data/manifest.json")
	_check(load_result.is_ok(), "production content loads for state-preservation proof")
	var session := GameSession.new()
	_check(session.configure(repository), "session configures for environment swap proof")
	var before := session.economy.state.snapshot()
	for skin_id: String in EraSkinRegistry.required_sample_ids():
		var skin := EraSkinRegistry.get_skin(skin_id)
		_check(skin.validate().is_empty(), "environment contract validates: %s" % skin_id)
		environment.set_skin(skin)
		environment.set_runtime_state(session.economy.state.owned, true, true)
		_check(environment.skin.skin_id == skin_id, "environment variant swaps: %s" % skin_id)
	_check(session.economy.state.snapshot() == before, "era skin swaps preserve gameplay state")
	environment.set_reduced_motion(true)
	_check(environment.reduced_motion, "environment exposes blackout-safe reduced motion")
	host.queue_free()
	await process_frame


func _test_live_sample() -> void:
	var memory_before := Performance.get_monitor(Performance.MEMORY_STATIC)
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
	_check(main.environment_view != null and main.environment_view.skin.skin_id == EraSkinRegistry.ERA_01_ID, "live Main Grid uses the Era 1 environment skin")
	_check(main.environment_frame.size.y > main.status_era_label.size.y, "environment remains the primary live composition region")
	_check(main.watt_core.text == "◉‿◉", "recognizable original WATT core remains accessible")
	_check(main.request_action_button.text == "Review + Authorize", "human-operator authorization remains the focal action")
	_check((main.theme as Theme).default_font != null, "live sample inherits the production font Theme")
	if _capture:
		await _save_capture(viewport, "phase12_main_grid_393x873.png")
	main.select_tab("build")
	await process_frame
	var wall_card := main.screen_content.find_child("WallOutletCard", true, false) as ShopItemCard
	_check(wall_card != null and wall_card.get_meta("skin_state") in ["affordable", "unaffordable", "locked"], "Build sample uses the reusable stateful card")
	if _capture:
		await _save_capture(viewport, "phase12_build_393x873.png")
	var memory_after := Performance.get_monitor(Performance.MEMORY_STATIC)
	var memory_delta_kib := maxf(memory_after - memory_before, 0.0) / 1024.0
	var nodes := main.find_children("*", "Node", true, false).size()
	_check(nodes < 500, "representative skinned UI remains below 500 nodes")
	_check(memory_delta_kib < 32768.0, "representative skin adds less than 32 MiB static memory (%.1f KiB)" % memory_delta_kib)
	print("PHASE 12 SKIN COST: %.1f KiB static-memory delta, %d live UI nodes, %d KiB declared environment budget" % [memory_delta_kib, nodes, main.environment_view.skin.estimated_memory_kib])
	viewport.queue_free()
	await process_frame


func _save_capture(viewport: SubViewport, filename: String) -> void:
	await process_frame
	await process_frame
	var path := "user://%s" % filename
	var rendered := viewport.get_texture().get_image()
	if rendered == null:
		_check(false, "scene regression capture requires a graphical renderer: %s" % filename)
		return
	var result := rendered.save_png(path)
	_check(result == OK, "scene regression capture saves: %s" % filename)
	print("PHASE 12 CAPTURE: %s" % ProjectSettings.globalize_path(path))


func _finish() -> void:
	if _failures.is_empty():
		print("PHASE 12 SKIN SYSTEM TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PHASE 12 SKIN SYSTEM TEST FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
