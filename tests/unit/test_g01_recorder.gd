extends SceneTree

var _failures: Array[String] = []
var _checks := 0
var _root := ""


func _init() -> void:
	_root = "user://g01_recorder_test_%d" % Time.get_ticks_usec()
	var normal_root := "%s/normal" % _root
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(normal_root))
	var sentinel_path := "%s/save_main.json" % normal_root
	var sentinel := FileAccess.open(sentinel_path, FileAccess.WRITE)
	sentinel.store_string("ordinary-save-sentinel")
	sentinel.close()
	var before := FileAccess.get_file_as_string(sentinel_path)

	var repository := ContentRepository.new()
	_check(repository.load_from_manifest().is_ok(), "canonical content loads")
	var profile := G01PlaytestProfile.new("%s/g01" % _root)
	var session_id := profile.create_fresh_session()
	_check(not session_id.is_empty(), "isolated profile creates a session ID")
	_check(profile.active_session_id() == session_id, "isolated profile records only its active session")
	_check(profile.save_root(session_id).begins_with("%s/g01/" % _root), "G01 save root stays under the isolated base")

	var session := GameSession.new()
	_check(session.configure(repository), "fresh G01 domain session configures")
	var recorder := G01SessionRecorder.new()
	_check(recorder.start_new(session, session_id, profile.session_root(session_id)), "minimal local recorder starts")
	recorder.tick(1.0, "")
	_check(is_equal_approx(recorder.unknown_inactivity_seconds, 1.0), "available foreground time remains unknown inactivity")
	recorder.record_report_view("era01_finish_booting")
	recorder.tick(1.0, "request_detail")
	_check(is_equal_approx(recorder.report_dialogue_seconds, 1.0), "focused request/report time is separate")

	session.economy.state.stored_energy = 1000.0
	session.requests.grid.state.stored_energy = 1000.0
	_check(session.purchase_infrastructure("wall_outlet"), "test purchase succeeds through the public session")
	_check(int(recorder.objective_counts.get("purchase", 0)) == 1, "purchase is recorded as an objective action")
	session.economy.state.unlocked_features["allocation_modes"] = true
	_check(session.set_allocation_mode("feed_watt"), "test allocation change succeeds")
	_check(int(recorder.objective_counts.get("allocation_change", 0)) == 1, "allocation change is recorded objectively")
	session.economy.state.stored_energy = 0.0
	session.requests.grid.state.stored_energy = 0.0
	_check(session.authorize_current_request(), "first request authorizes")
	_check(int(recorder.objective_counts.get("authorization", 0)) == 1, "authorization is recorded objectively")
	recorder.tick(1.0, "")
	_check(recorder.forced_stall_seconds >= 1.0, "running with no affordable action is a system-imposed forced stall")

	recorder.foreground_seconds = 599.0
	recorder.tick(1.0, "")
	_check(recorder.checkpoints.has("600"), "ten-minute mechanical checkpoint is captured")
	recorder.background()
	recorder._background_started_utc = int(Time.get_unix_time_from_system()) - 5
	recorder.foreground()
	_check(recorder.background_offline_seconds >= 5.0, "background/offline time remains separate")
	recorder.record_maintenance_deferral("fixture_maintenance")
	_check(int(recorder.objective_counts.get("maintenance_deferred", 0)) == 1, "explicit maintenance deferral is recorded")

	_check(recorder.write_record(), "complete local JSON record writes atomically")
	var resumed := G01SessionRecorder.new()
	_check(resumed.resume(session, session_id, profile.session_root(session_id)), "active local record resumes")
	_check(resumed.events.size() >= recorder.events.size(), "resume retains ordered event history")
	var compact := resumed.compact_summary()
	_check(compact.to_utf8_buffer().size() <= G01SessionRecorder.COMPACT_MAX_BYTES, "compact summary remains clipboard safe")
	_check(JSON.parse_string(compact) is Dictionary, "compact summary is valid JSON")
	_check("No inactivity category is interpreted as boredom" in resumed.human_summary(), "human summary rejects behavioral inference")
	_check(resumed.finalize(), "session finalizes honestly before sixty minutes")
	_check(resumed.status == "ended_early", "early finalization is labeled truthfully")
	_check(FileAccess.file_exists("%s/g01_record.json" % profile.session_root(session_id)), "full record remains local")
	_check(FileAccess.file_exists("%s/g01_compact.json" % profile.session_root(session_id)), "compact summary is saved locally")
	_check(FileAccess.file_exists("%s/g01_summary.txt" % profile.session_root(session_id)), "human-readable summary is saved locally")
	_check(FileAccess.get_file_as_string(sentinel_path) == before, "ordinary save sentinel remains byte-for-byte unchanged")
	_check(profile.clear_active(session_id), "finalized isolated profile clears only its pointer")
	_check(FileAccess.get_file_as_string(sentinel_path) == before, "clearing G01 pointer cannot touch the ordinary save")

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
		print("G01 RECORDER TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("G01 RECORDER TEST FAILED: %s" % failure)
	quit(1)
