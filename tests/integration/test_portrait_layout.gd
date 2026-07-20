extends SceneTree

var _portrait_sizes: Array[Vector2i] = [Vector2i(320, 568), Vector2i(360, 640), Vector2i(393, 873), Vector2i(480, 800), Vector2i(720, 1280)]
var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	var packed_scene := load("res://scenes/app/Main.tscn") as PackedScene
	var capture_layouts := "--capture-layouts" in OS.get_cmdline_user_args()
	if packed_scene == null:
		printerr("PORTRAIT LAYOUT FAILED: Main.tscn did not load")
		quit(1)
		return
	for test_size: Vector2i in _portrait_sizes:
		var viewport := SubViewport.new()
		viewport.size = test_size
		viewport.disable_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		get_root().add_child(viewport)
		var main := packed_scene.instantiate() as MainUI
		viewport.add_child(main)
		await process_frame
		await process_frame
		var shell := main.get_node("SafeArea/AppShell") as Control
		var minimum := shell.get_combined_minimum_size()
		_check(main.size.is_equal_approx(Vector2(test_size)), "%s root was %s" % [test_size, main.size])
		_check(minimum.x <= test_size.x, "%s minimum shell width was %.1f" % [test_size, minimum.x])
		_check(shell.size.x <= test_size.x and shell.size.y <= test_size.y, "%s shell was %s" % [test_size, shell.size])
		_check(main.watt_core.is_visible_in_tree(), "%s WATT focal element is visible" % test_size)
		_check(main.request_title_label.text == "Finish Booting", "%s initial request is readable" % test_size)
		_check(main.request_action_button.custom_minimum_size.y >= 48.0, "%s request action keeps touch target" % test_size)
		print("PORTRAIT LAYOUT: %s passed (shell %s, minimum %s)" % [test_size, shell.size, minimum])
		if capture_layouts:
			var capture_path := "user://portrait_%dx%d.png" % [test_size.x, test_size.y]
			var capture_error := viewport.get_texture().get_image().save_png(capture_path)
			_check(capture_error == OK, "%s capture failed with error %s" % [test_size, capture_error])
			print("PORTRAIT CAPTURE: %s" % ProjectSettings.globalize_path(capture_path))
		viewport.queue_free()
		await process_frame
	if _failures.is_empty():
		print("PORTRAIT LAYOUT PASSED: %d sizes" % _portrait_sizes.size())
		quit(0)
		return
	for failure: String in _failures:
		printerr("PORTRAIT LAYOUT FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	if not value:
		_failures.append(failure)
