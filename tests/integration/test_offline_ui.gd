extends SceneTree

var _failures: Array[String] = []
var _checks := 0
var _root := ""


func _init() -> void:
	ProjectSettings.set_setting("one_more_watt/testing/disable_persistence", true)
	_root = "user://phase06_ui_%d" % Time.get_ticks_usec()
	call_deferred("_run")


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(393, 873)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var packed := load("res://scenes/app/Main.tscn") as PackedScene
	var main := packed.instantiate() as MainUI
	viewport.add_child(main)
	await process_frame
	await process_frame
	var manager := SaveManager.new(_root, main.session.repository.get_content_version())
	main.session.economy.state.unlocked_features["offline_progress"] = true
	var controller := PersistenceController.new()
	controller.configure(main.session, manager)
	main.persistence = controller
	_check(controller.bootstrap(10000).get("ok", false), "controlled new game save succeeds")

	main.open_request_modal()
	await process_frame
	(main.modal_content.find_child("AuthorizeButton", true, false) as Button).emit_signal("pressed")
	await process_frame
	main.session.advance_time(2.0)
	var progress_before := main.session.requests.get_active_state().progress
	_check(controller.background(10002).get("ok", false), "background trigger writes a complete snapshot")
	var report := controller.resume(10012)
	_check_near(report.recognized_elapsed, 10.0, "resume recognizes controlled elapsed time")
	_check_near(report.effective_elapsed, 8.0, "offline report discloses 80% effective time")
	_check(report.progress_after > progress_before, "active request advances offline")
	main.open_offline_report(report)
	await process_frame
	_check(main.modal_title.text == "OFFLINE RETURN", "offline return modal opens")
	var text := _modal_text(main)
	_check("RECOGNIZED 10.0s" in text and "EFFICIENCY 80%" in text and "CAP 2m 00s" not in text, "offline modal discloses timing, efficiency, and full cap")
	_check("CAP 120m 00s" in text, "offline modal discloses two-hour cap")
	if "--capture-layouts" in OS.get_cmdline_user_args():
		await _capture(viewport, "offline_progress")
	main.close_top_modal()

	controller.background(10012)
	var completion_report := controller.resume(10032)
	_check("era01_finish_booting" in completion_report.completed_request_ids, "request completes across offline boundary")
	var currency := main.session.requests.grid.state.stored_energy
	_check(main.session.requests.get_request_state("era01_finish_booting").reward_granted, "offline completion grants reward once")

	_write_text("%s/%s" % [_root, SaveManager.MAIN_NAME], "invalid main for recovery exercise")
	var recovered_session := GameSession.new()
	recovered_session.configure(main.session.repository)
	var recovery_controller := PersistenceController.new()
	recovery_controller.configure(recovered_session, SaveManager.new(_root, main.session.repository.get_content_version()))
	var recovery := recovery_controller.bootstrap(10032)
	_check(recovery.get("ok", false) and recovery.get("recovered", false), "invalid main restores Backup 1 through bootstrap")
	_check(not recovery_controller.last_load_result.preserved_corrupt_path.is_empty(), "recovery preserves invalid main evidence")
	_check(recovered_session.requests.grid.state.stored_energy <= currency + 0.000001, "recovery cannot duplicate more currency than completed state")
	main.open_offline_report(recovery["offline_report"], "Recovered from %s." % recovery_controller.last_load_result.source)
	await process_frame
	_check("Recovered from save_backup_1.json." in _modal_text(main), "recovery source is explained in UI")
	if "--capture-layouts" in OS.get_cmdline_user_args():
		await _capture(viewport, "backup_recovery")

	_cleanup_tree(_root)
	viewport.queue_free()
	await process_frame
	if _failures.is_empty():
		print("OFFLINE UI TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("OFFLINE UI TEST FAILED: %s" % failure)
	quit(1)


func _modal_text(main: MainUI) -> String:
	var parts: PackedStringArray = [main.modal_title.text]
	for value: Variant in main.modal_content.find_children("*", "Label", true, false):
		parts.append((value as Label).text)
	return "\n".join(parts)


func _capture(viewport: SubViewport, name: String) -> void:
	await process_frame
	await process_frame
	var path := "user://phase06_%s.png" % name
	var error := viewport.get_texture().get_image().save_png(path)
	_check(error == OK, "%s capture saves" % name)
	print("OFFLINE UI CAPTURE: %s" % ProjectSettings.globalize_path(path))


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


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


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= 0.000001, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
