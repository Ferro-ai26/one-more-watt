extends SceneTree

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0
var _root := ""


func _init() -> void:
	_root = "user://phase06_test_%d" % Time.get_ticks_usec()
	_repository = ContentRepository.new()
	var loaded := _repository.load_from_manifest("res://tests/fixtures/content/valid_manifest.json")
	_check(loaded.is_ok(), "content loads for persistence tests")
	if loaded.is_ok():
		_test_new_game_and_mid_request_round_trip()
		_test_completion_reward_idempotency()
		_test_purchase_boundary_round_trip()
		_test_backup_recovery_and_all_failure()
		_test_migration()
		_test_offline_boundaries_and_equivalence()
		_test_autosave_debounce()
	_cleanup_tree(_root)
	_finish()


func _test_new_game_and_mid_request_round_trip() -> void:
	var path := _case_path("roundtrip")
	var session := _session()
	session.settings.reduced_motion = true
	session.settings.set_text_scale_index(2)
	var manager := SaveManager.new(path, _repository.get_content_version())
	var saved := manager.save({"session": session.snapshot()}, 1000, 1000, "new_game")
	_check(saved.get("ok", false) and saved.get("sequence", 0) == 1, "new game writes sequence one: %s" % saved)
	var loaded := manager.load()
	_check(loaded.ok and loaded.source == SaveManager.MAIN_NAME, "new game loads from main: %s" % loaded.diagnostics)
	if not loaded.ok:
		return
	var restored := _session()
	_check(restored.restore(loaded.envelope["payload"]["session"], _repository), "new-game snapshot restores")
	_check(restored.settings.reduced_motion and restored.settings.text_scale_index == 2, "runtime settings survive round trip")
	_check(restored.economy.state.owned == session.economy.state.owned, "ownership survives new-game round trip")

	_check(session.authorize_current_request(), "mid-request fixture starts")
	session.advance_time(3.5)
	manager.save({"session": session.snapshot()}, 1010, 1010, "periodic")
	loaded = manager.load()
	restored = _session()
	_check(restored.restore(loaded.envelope["payload"]["session"], _repository), "mid-request snapshot restores")
	var original_state := session.requests.get_active_state()
	var restored_state := restored.requests.get_active_state()
	_check(restored_state != null and restored_state.request_id == original_state.request_id, "active request ID survives")
	_check_near(restored_state.progress, original_state.progress, "mid-request progress survives")
	_check_near(restored.requests.grid.state.reserve_stored, session.requests.grid.state.reserve_stored, "Reserve survives")
	_check(restored.requests.grid.state.allocation_mode == session.requests.grid.state.allocation_mode, "allocation survives")
	session.advance_time(4.0)
	restored.advance_time(4.0)
	_check_near(restored_state.progress, original_state.progress, "restored deterministic request continues equivalently")


func _test_completion_reward_idempotency() -> void:
	var path := _case_path("completion")
	var session := _session()
	session.authorize_current_request()
	session.advance_time(120.0)
	var currency := session.requests.grid.state.stored_energy
	var manager := SaveManager.new(path, _repository.get_content_version())
	manager.save({"session": session.snapshot()}, 2000, 2000, "request_completed")
	var loaded := manager.load()
	if not loaded.ok:
		_check(false, "completion save reloads: %s" % loaded.diagnostics)
		return
	var restored := _session()
	_check(restored.restore(loaded.envelope["payload"]["session"], _repository), "post-completion/pre-report state restores")
	var state := restored.requests.get_request_state("era01_finish_booting")
	_check(state.status == RequestRunState.COMPLETED and state.reward_granted, "completed unacknowledged report and reward flag survive")
	_check_near(restored.requests.grid.state.stored_energy, currency, "completion currency survives")
	_check(not restored.requests.grant_completion_rewards("era01_finish_booting"), "reward cannot duplicate after reload")
	_check_near(restored.requests.grid.state.stored_energy, currency, "duplicate reward attempt cannot mutate currency")


func _test_purchase_boundary_round_trip() -> void:
	var path := _case_path("purchase")
	var session := _session()
	session.requests.grid.state.stored_energy = 100.0
	var preview := session.preview_infrastructure("wall_outlet")
	_check(session.purchase_infrastructure("wall_outlet"), "purchase commits before close fixture")
	var manager := SaveManager.new(path, _repository.get_content_version())
	manager.save({"session": session.snapshot()}, 2500, 2500, "purchase")
	var loaded := manager.load()
	var restored := _session()
	_check(loaded.ok and restored.restore(loaded.envelope["payload"]["session"], _repository), "post-purchase snapshot restores")
	_check(int(restored.economy.state.owned["wall_outlet"]) == 2, "close after purchase preserves committed ownership")
	_check_near(restored.requests.grid.state.stored_energy, 100.0 - preview.cost, "close after purchase preserves exact atomic currency")
	_check_near(restored.requests.grid.state.generation_rate, float(preview.resulting_values["generation_rate"]), "derived grid rebuild matches pre-close preview")


func _test_backup_recovery_and_all_failure() -> void:
	var path := _case_path("recovery")
	var manager := SaveManager.new(path, _repository.get_content_version())
	var session := _session()
	manager.save({"session": session.snapshot()}, 3000, 3000, "first")
	session.set_allocation_mode("feed_watt")
	manager.save({"session": session.snapshot()}, 3001, 3001, "second")
	_write_text("%s/%s" % [path, SaveManager.MAIN_NAME], "deliberately invalid main")
	var recovered := manager.load()
	_check(recovered.ok and recovered.recovered and recovered.source == SaveManager.BACKUP_1_NAME, "corrupt main recovers Backup 1: %s" % recovered.diagnostics)
	if not recovered.ok:
		return
	_check(not recovered.preserved_corrupt_path.is_empty() and FileAccess.file_exists(recovered.preserved_corrupt_path), "corrupt main is preserved for diagnostics")
	var recovered_session := _session()
	_check(recovered_session.restore(recovered.envelope["payload"]["session"], _repository), "recovered backup payload restores")
	_check(recovered_session.requests.grid.state.allocation_mode == "balanced", "Backup 1 contains prior known-good state")
	_write_text("%s/%s" % [path, SaveManager.MAIN_NAME], "bad main")
	_write_text("%s/%s" % [path, SaveManager.BACKUP_1_NAME], "bad backup one")
	_write_text("%s/%s" % [path, SaveManager.BACKUP_2_NAME], "bad backup two")
	var failed := manager.load()
	_check(not failed.ok and failed.status == "corrupt_all", "all corrupt saves fail safely without auto-new-game")


func _test_migration() -> void:
	var path := _case_path("migration")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	var session_data := _session().snapshot()
	session_data.erase("prestige")
	var old_owned: Dictionary = session_data["economy"]["owned"]
	old_owned["starter_outlet"] = old_owned["wall_outlet"]
	old_owned.erase("wall_outlet")
	var old := {"format_version": 1, "game_build_version": "old", "content_version": _repository.get_content_version(), "sequence": 7, "created_utc": 10, "updated_utc": 20, "last_trusted_utc": 20, "trigger": "fixture", "payload": {"session": session_data}}
	_write_text("%s/%s" % [path, SaveManager.MAIN_NAME], SaveCodec.encode(old))
	var loaded := SaveManager.new(path, _repository.get_content_version()).load()
	_check(loaded.ok and loaded.migrated and loaded.envelope["format_version"] == SaveMigrator.CURRENT_VERSION, "schema 1 migrates sequentially to current")
	if not loaded.ok:
		return
	_check((loaded.envelope["payload"]["session"] as Dictionary).has("prestige"), "migration adds extensible prestige space")
	_check(loaded.envelope["payload"]["session"]["economy"]["owned"].has("wall_outlet") and not loaded.envelope["payload"]["session"]["economy"]["owned"].has("starter_outlet"), "migration maps an explicit retired stable ID")
	var future := old.duplicate(true)
	future["format_version"] = 99
	_write_text("%s/%s" % [path, SaveManager.MAIN_NAME], SaveCodec.encode(future))
	loaded = SaveManager.new(path, _repository.get_content_version()).load()
	_check(not loaded.ok, "unknown future schema fails safely")


func _test_offline_boundaries_and_equivalence() -> void:
	var zero := _session()
	zero.authorize_current_request()
	var zero_report := OfflineSimulator.simulate(zero, 4000, 4000)
	_check(zero_report.recognized_elapsed == 0.0 and zero_report.effective_elapsed == 0.0, "zero offline duration grants zero")
	var backward := _session()
	backward.authorize_current_request()
	var backward_report := OfflineSimulator.simulate(backward, 5000, 4900)
	_check(backward_report.clock_backward and backward_report.effective_elapsed == 0.0, "backward clock grants no negative progress")
	var one_second := _session()
	one_second.authorize_current_request()
	var one_report := OfflineSimulator.simulate(one_second, 5500, 5501)
	_check_near(one_report.recognized_elapsed, 1.0, "one-second offline duration is recognized exactly")
	_check_near(one_report.effective_elapsed, 0.8, "one-second duration applies efficiency without display rounding")

	var online := _session()
	var offline := _session()
	online.authorize_current_request()
	offline.authorize_current_request()
	online.advance_time(8.0, true)
	var short_report := OfflineSimulator.simulate(offline, 6000, 6010)
	_check_near(short_report.effective_elapsed, 8.0, "ten wall-clock seconds apply authored 80% efficiency")
	_check_near(offline.requests.get_request_state("era01_finish_booting").progress, online.requests.get_request_state("era01_finish_booting").progress, "offline and equivalent seeded online simulation match")
	var ten_minutes := _session()
	ten_minutes.authorize_current_request()
	var ten_report := OfflineSimulator.simulate(ten_minutes, 6500, 7100)
	_check_near(ten_report.recognized_elapsed, 600.0, "ten-minute offline duration is recognized")
	_check_near(ten_report.effective_elapsed, 480.0, "ten-minute duration applies authored efficiency")

	var capped := _session()
	capped.authorize_current_request()
	var cap_started := Time.get_ticks_msec()
	var cap_report := OfflineSimulator.simulate(capped, 7000, 7000 + 7200)
	_check(cap_report.recognized_elapsed == 7200.0 and cap_report.effective_elapsed == 5760.0 and not cap_report.capped, "exact cap is fully recognized and disclosed")
	_check("era01_finish_booting" in cap_report.completed_request_ids, "active request completes offline")
	_check(capped.requests.get_active_state() == null, "queue-disabled offline completion does not start another request")
	_check(capped.requests.get_request_state("era01_basic_arithmetic").status == RequestRunState.AVAILABLE, "next request unlocks without auto-start")
	_check_near(cap_report.stored_energy_after - cap_report.stored_energy_before, capped.requests.grid.state.stored_energy, "offline report reconciles Stored Energy state change")
	_check(Time.get_ticks_msec() - cap_started < 2000, "maximum offline simulation remains under the prototype performance budget")

	var over := _session()
	over.authorize_current_request()
	var over_report := OfflineSimulator.simulate(over, 8000, 8000 + 900000)
	_check(over_report.capped and over_report.far_forward and over_report.recognized_elapsed == 7200.0, "far-forward clock uses normal cap and diagnostic flag")
	_check_near(over_report.effective_elapsed, cap_report.effective_elapsed, "over-cap duration cannot exceed exact-cap effective time")

	var interaction := _session()
	var interaction_report := OfflineSimulator.simulate(interaction, 9000, 9600)
	_check(interaction_report.stopped_for_input and interaction_report.effective_elapsed == 0.0, "unacknowledged tutorial pauses offline chaining")


func _test_autosave_debounce() -> void:
	var session := _session()
	var manager := SaveManager.new(_case_path("autosave"), _repository.get_content_version())
	var controller := PersistenceController.new()
	controller.configure(session, manager)
	var boot := controller.bootstrap(10000)
	_check(boot["status"] == "new_game" and boot.get("ok", false), "controller creates initial save: %s" % boot)
	controller.mark_dirty("purchase")
	_check(not controller.tick(0.5, 10001), "purchase autosave is debounced")
	_check(controller.tick(0.5, 10001) and manager.last_sequence == 2, "purchase autosave commits after debounce")
	controller.mark_dirty("progress")
	_check(not controller.tick(29.0, 10030), "periodic progress save waits thirty seconds")
	_check(controller.tick(1.0, 10031) and manager.last_sequence == 3, "dirty active progress saves periodically")


func _session() -> GameSession:
	var session := GameSession.new()
	_check(session.configure(_repository), "test session configures")
	return session


func _case_path(name: String) -> String:
	return "%s/%s" % [_root, name]


func _write_text(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
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


func _finish() -> void:
	if _failures.is_empty():
		print("PERSISTENCE AND OFFLINE TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("PERSISTENCE TEST FAILED: %s" % failure)
	quit(1)


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= 0.000001, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
