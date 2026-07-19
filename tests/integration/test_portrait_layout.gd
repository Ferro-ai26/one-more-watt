extends SceneTree

var _portrait_sizes: Array[Vector2i] = [
	Vector2i(360, 640),
	Vector2i(393, 873),
	Vector2i(480, 800),
]

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load("res://scenes/app/Main.tscn") as PackedScene
	var capture_layouts := "--capture-layouts" in OS.get_cmdline_user_args()
	if packed_scene == null:
		printerr("PORTRAIT LAYOUT FAILED: Main.tscn did not load")
		quit(1)
		return

	for test_size in _portrait_sizes:
		var viewport := SubViewport.new()
		viewport.size = test_size
		viewport.disable_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		get_root().add_child(viewport)

		var main := packed_scene.instantiate() as Control
		viewport.add_child(main)
		await process_frame
		await process_frame

		var shell := main.get_node("SafeArea/DevelopmentShell") as Control
		var minimum := shell.get_combined_minimum_size()
		var content_version_label := main.get_node("SafeArea/DevelopmentShell/ContentScroll/Content/ContentVersionLabel") as Label
		var content_counts_label := main.get_node("SafeArea/DevelopmentShell/ContentScroll/Content/ContentCountsLabel") as Label
		var sample_request_label := main.get_node("SafeArea/DevelopmentShell/ContentScroll/Content/SampleRequestLabel") as Label
		_check(main.size.is_equal_approx(Vector2(test_size)), "%s root was %s" % [test_size, main.size])
		_check(minimum.x <= test_size.x and minimum.y <= test_size.y, "%s minimum shell was %s" % [test_size, minimum])
		_check(shell.size.x <= test_size.x and shell.size.y <= test_size.y, "%s shell was %s" % [test_size, shell.size])
		_check("Content v0.2.0" in content_version_label.text and "schema 1" in content_version_label.text, "%s content version label was '%s'" % [test_size, content_version_label.text])
		_check("2 eras" in content_counts_label.text and "1 infrastructure" in content_counts_label.text and "1 upgrade" in content_counts_label.text and "1 request" in content_counts_label.text, "%s content counts label was '%s'" % [test_size, content_counts_label.text])
		_check(sample_request_label.text == "Finish Booting  •  75 energy", "%s sample request label was '%s'" % [test_size, sample_request_label.text])
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

	for failure in _failures:
		printerr("PORTRAIT LAYOUT FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	if not value:
		_failures.append(failure)
