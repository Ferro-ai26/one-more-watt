extends SceneTree

var _failures: Array[String] = []
var _checks := 0
var _root := ""


func _init() -> void:
	_root = "user://g01_ui_test_%d" % Time.get_ticks_usec()
	ProjectSettings.set_setting("one_more_watt/testing/g01_mode", true)
	ProjectSettings.set_setting("one_more_watt/testing/g01_root", "%s/playtests" % _root)
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/app/Main.tscn") as PackedScene
	var main := packed.instantiate() as MainUI
	root.add_child(main)
	await process_frame
	await process_frame
	_check(main.navigation.top_modal() == "g01_start", "explicit G01 build opens only its consent surface")
	_check(main.persistence == null and main.g01_recorder == null, "G01 consent does not initialize any save manager")
	main._start_g01_session(false)
	await process_frame
	_check(main.g01_recorder != null and main.g01_recorder.status == "active", "explicit begin starts local recording")
	_check(main.persistence != null and main.persistence.manager.root_path.begins_with("%s/playtests/" % _root), "G01 persistence uses only the isolated profile root")
	_check(main.navigation.top_modal().is_empty(), "fresh G01 session enters unchanged onboarding")
	main.open_settings_modal()
	_check(main.modal_content.find_child("G01CopyCompactButton", true, false) is Button, "Diagnostics exposes compact summary copy")
	_check(main.modal_content.find_child("G01HumanSummaryButton", true, false) is Button, "Diagnostics exposes human-readable summary")
	_check(main.modal_content.find_child("G01FinalizeButton", true, false) is Button, "Diagnostics exposes explicit finalization")
	main.g01_recorder.foreground_seconds = 3600.0
	main._finalize_g01_session()
	_check(main.g01_recorder.status == "completed_60m", "sixty-minute session finalizes with the correct status")
	_check(not main.is_processing(), "finalization stops gameplay and recording")
	main.queue_free()
	await process_frame
	ProjectSettings.set_setting("one_more_watt/testing/g01_mode", false)
	ProjectSettings.set_setting("one_more_watt/testing/g01_root", "")
	_cleanup_tree(_root)
	_finish()


func _cleanup_tree(path: String) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	var directory := DirAccess.open(absolute)
	if directory == null:
		return
	directory.list_dir_begin()
	var name := directory.get_next()
	while not name.is_empty():
		var child := "%s/%s" % [absolute, name]
		if directory.current_is_dir():
			_cleanup_tree(child)
		else:
			DirAccess.remove_absolute(child)
		name = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(absolute)


func _check(value: bool, message: String) -> void:
	_checks += 1
	if not value:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("G01 PLAYTEST UI TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("G01 PLAYTEST UI TEST FAILED: %s" % failure)
	quit(1)
