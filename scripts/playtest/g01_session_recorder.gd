class_name G01SessionRecorder
extends RefCounted

const RECORD_SCHEMA := "g01_session_v1"
const SUMMARY_SCHEMA := "g01_summary_v1"
const SAMPLE_SECONDS := 1.0
const WRITE_SECONDS := 15.0
const CHECKPOINT_SECONDS := [600.0, 1800.0, 3600.0]
const REPORT_DIALOGUE_SURFACES := ["request_detail", "performance_report", "offline_report"]
const COMPACT_MAX_BYTES := 8192

var session: GameSession
var session_id := ""
var root_path := ""
var status := "inactive"
var started_utc := 0
var finalized_utc := 0
var foreground_seconds := 0.0
var background_offline_seconds := 0.0
var forced_stall_seconds := 0.0
var report_dialogue_seconds := 0.0
var unknown_inactivity_seconds := 0.0
var events: Array = []
var interaction_gaps: Array = []
var checkpoints: Dictionary = {}
var objective_counts: Dictionary = {}

var _sequence := 0
var _sample_accumulator := 0.0
var _write_accumulator := 0.0
var _background_started_utc := 0
var _last_action_foreground := 0.0
var _gap_forced := 0.0
var _gap_report_dialogue := 0.0
var _gap_unknown := 0.0
var _previous_owned: Dictionary = {}
var _previous_upgrades: Dictionary = {}
var _previous_maintenance: Dictionary = {}
var _previous_reported: Dictionary = {}
var _previous_brownout := false
var _previous_reserve_support := false
var _last_request_id := ""


func start_new(game_session: GameSession, id: String, directory: String) -> bool:
	if game_session == null or id.is_empty() or directory.is_empty():
		return false
	session = game_session
	session_id = id
	root_path = directory.trim_suffix("/")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(root_path))
	status = "active"
	started_utc = int(Time.get_unix_time_from_system())
	_attach()
	_append_event("session_started", {}, false)
	return write_record()


func resume(game_session: GameSession, id: String, directory: String) -> bool:
	if game_session == null or id.is_empty() or directory.is_empty():
		return false
	var path := "%s/g01_record.json" % directory.trim_suffix("/")
	if not FileAccess.file_exists(path):
		return start_new(game_session, id, directory)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or str((parsed as Dictionary).get("schema", "")) != RECORD_SCHEMA:
		return false
	var record: Dictionary = parsed
	session = game_session
	session_id = id
	root_path = directory.trim_suffix("/")
	status = str(record.get("status", "active"))
	started_utc = int(record.get("started_utc", 0))
	finalized_utc = int(record.get("finalized_utc", 0))
	var timing: Dictionary = record.get("timing", {})
	foreground_seconds = float(timing.get("foreground_seconds", 0.0))
	background_offline_seconds = float(timing.get("background_offline_seconds", 0.0))
	forced_stall_seconds = float(timing.get("forced_stall_seconds", 0.0))
	report_dialogue_seconds = float(timing.get("report_dialogue_seconds", 0.0))
	unknown_inactivity_seconds = float(timing.get("unknown_inactivity_seconds", 0.0))
	events = (record.get("events", []) as Array).duplicate(true)
	interaction_gaps = (record.get("interaction_gaps", []) as Array).duplicate(true)
	checkpoints = (record.get("checkpoints", {}) as Dictionary).duplicate(true)
	objective_counts = (record.get("objective_counts", {}) as Dictionary).duplicate(true)
	_sequence = int(record.get("last_sequence", events.size()))
	_last_action_foreground = float(record.get("last_action_foreground", foreground_seconds))
	_gap_forced = float(record.get("open_gap", {}).get("forced_stall_seconds", 0.0))
	_gap_report_dialogue = float(record.get("open_gap", {}).get("report_dialogue_seconds", 0.0))
	_gap_unknown = float(record.get("open_gap", {}).get("unknown_inactivity_seconds", 0.0))
	_background_started_utc = int(record.get("background_started_utc", 0))
	if _background_started_utc > 0:
		background_offline_seconds += maxf(float(Time.get_unix_time_from_system() - _background_started_utc), 0.0)
		_background_started_utc = 0
	_attach()
	_append_event("session_resumed", {}, false)
	return write_record()


func _attach() -> void:
	_previous_owned = session.economy.state.owned.duplicate(true)
	_previous_upgrades = session.economy.state.upgrade_levels.duplicate(true)
	_previous_maintenance = session.economy.state.maintenance_choices.duplicate(true)
	_previous_reported = _reported_states()
	_previous_brownout = session.requests.grid.state.brownout_active
	_previous_reserve_support = session.requests.grid.get_last_result().reserve_discharge_power > 0.000001
	_last_request_id = session.current_request_id()
	if not session.mutation_committed.is_connected(_on_mutation):
		session.mutation_committed.connect(_on_mutation)


func tick(delta_seconds: float, surface_id: String) -> void:
	if status != "active" or not is_finite(delta_seconds) or delta_seconds <= 0.0:
		return
	_sample_accumulator += delta_seconds
	_write_accumulator += delta_seconds
	while _sample_accumulator + 0.000001 >= SAMPLE_SECONDS:
		_sample_accumulator -= SAMPLE_SECONDS
		foreground_seconds += SAMPLE_SECONDS
		var category := _classify_foreground(surface_id)
		match category:
			"report_dialogue":
				report_dialogue_seconds += SAMPLE_SECONDS
				_gap_report_dialogue += SAMPLE_SECONDS
			"forced_stall":
				forced_stall_seconds += SAMPLE_SECONDS
				_gap_forced += SAMPLE_SECONDS
			_:
				unknown_inactivity_seconds += SAMPLE_SECONDS
				_gap_unknown += SAMPLE_SECONDS
		_capture_due_checkpoints()
		_detect_system_transitions()
	if _write_accumulator + 0.000001 >= WRITE_SECONDS:
		_write_accumulator = 0.0
		write_record()


func record_report_view(request_id: String) -> void:
	if status == "active" and not request_id.is_empty():
		_record_objective("report_view", {"request_id": request_id})


func record_maintenance_deferral(maintenance_id: String) -> void:
	if status == "active" and not maintenance_id.is_empty():
		_record_objective("maintenance_deferred", {"maintenance_id": maintenance_id})


func background() -> void:
	if status != "active" or _background_started_utc > 0:
		return
	_background_started_utc = int(Time.get_unix_time_from_system())
	_append_event("background_started", {}, false)
	write_record()


func foreground() -> void:
	if status != "active" or _background_started_utc <= 0:
		return
	var elapsed := maxf(float(Time.get_unix_time_from_system() - _background_started_utc), 0.0)
	background_offline_seconds += elapsed
	_background_started_utc = 0
	_append_event("foreground_resumed", {"background_seconds": elapsed}, false)
	write_record()


func finalize() -> bool:
	if status != "active":
		return false
	_finalize_open_gap("session_finalized")
	status = "completed_60m" if foreground_seconds >= 3600.0 else "ended_early"
	finalized_utc = int(Time.get_unix_time_from_system())
	_append_event("session_finalized", {"status": status}, false)
	var wrote := write_record()
	if wrote:
		wrote = _write_text("%s/g01_compact.json" % root_path, compact_summary()) and _write_text("%s/g01_summary.txt" % root_path, human_summary())
	return wrote


func compact_summary() -> String:
	var summary := {
		"schema": SUMMARY_SCHEMA,
		"session_id": session_id,
		"status": status,
		"build": str(ProjectSettings.get_setting("application/config/build_commit", "unknown")),
		"content": session.repository.get_content_version() if session != null else "unknown",
		"foreground_s": snappedf(foreground_seconds, 0.1),
		"background_offline_s": snappedf(background_offline_seconds, 0.1),
		"forced_stall_s": snappedf(forced_stall_seconds, 0.1),
		"report_dialogue_s": snappedf(report_dialogue_seconds, 0.1),
		"unknown_inactivity_s": snappedf(unknown_inactivity_seconds, 0.1),
		"objective_counts": objective_counts.duplicate(true),
		"longest_interaction_gap_s": snappedf(_longest_gap(), 0.1),
		"checkpoint_snapshots": _compact_checkpoints(),
		"final_state": _mechanical_snapshot(),
	}
	var encoded := JSON.stringify(summary)
	if encoded.to_utf8_buffer().size() > COMPACT_MAX_BYTES:
		summary.erase("checkpoint_snapshots")
		encoded = JSON.stringify(summary)
	return encoded


func human_summary() -> String:
	return "\n".join([
		"G01 SESSION %s" % session_id,
		"Status: %s" % status,
		"Foreground: %s" % _duration(foreground_seconds),
		"Background/offline: %s" % _duration(background_offline_seconds),
		"System-imposed forced stalls: %s" % _duration(forced_stall_seconds),
		"Report/dialogue viewing: %s" % _duration(report_dialogue_seconds),
		"Unknown inactivity: %s" % _duration(unknown_inactivity_seconds),
		"Longest foreground interaction gap: %s" % _duration(_longest_gap()),
		"Objective actions: %s" % JSON.stringify(objective_counts),
		"No inactivity category is interpreted as boredom or perceived agency.",
	])


func write_record() -> bool:
	if root_path.is_empty() or session == null:
		return false
	var record := {
		"schema": RECORD_SCHEMA,
		"session_id": session_id,
		"status": status,
		"started_utc": started_utc,
		"finalized_utc": finalized_utc,
		"build": str(ProjectSettings.get_setting("application/config/build_commit", "unknown")),
		"content": session.repository.get_content_version(),
		"platform": OS.get_name(),
		"model": OS.get_model_name(),
		"timing": {
			"foreground_seconds": foreground_seconds,
			"background_offline_seconds": background_offline_seconds,
			"forced_stall_seconds": forced_stall_seconds,
			"report_dialogue_seconds": report_dialogue_seconds,
			"unknown_inactivity_seconds": unknown_inactivity_seconds,
		},
		"objective_counts": objective_counts.duplicate(true),
		"events": events.duplicate(true),
		"interaction_gaps": interaction_gaps.duplicate(true),
		"checkpoints": checkpoints.duplicate(true),
		"last_sequence": _sequence,
		"last_action_foreground": _last_action_foreground,
		"open_gap": {"forced_stall_seconds": _gap_forced, "report_dialogue_seconds": _gap_report_dialogue, "unknown_inactivity_seconds": _gap_unknown},
		"background_started_utc": _background_started_utc,
		"current_state": _mechanical_snapshot(),
	}
	return _write_json_atomic("%s/g01_record.json" % root_path, record)


func _on_mutation(trigger: String) -> void:
	if status != "active":
		return
	match trigger:
		"request_started":
			var active := session.requests.get_active_state()
			_record_objective("authorization", {"request_id": active.request_id if active != null else session.current_request_id()})
		"purchase":
			_record_purchase_differences()
		"allocation_changed":
			_record_objective("allocation_change", {"mode": session.requests.grid.state.allocation_mode})
		"maintenance_choice":
			_record_maintenance_difference()
		"automation_changed":
			_record_objective("automation_configuration", {})
		"request_selected":
			_record_objective("request_selection", {"request_id": session.current_request_id()})
		"request_skipped":
			_record_objective("request_skip", {})
		"request_completed":
			_append_event("request_completed", {"request_id": session.last_report_id}, false)
		"report_acknowledged":
			_record_reported_difference()
	_detect_system_transitions()
	write_record()


func _record_purchase_differences() -> void:
	for id_value: Variant in session.economy.state.owned:
		var id := str(id_value)
		var previous := int(_previous_owned.get(id, 0))
		var current := int(session.economy.state.owned[id])
		if current <= previous:
			continue
		var definition := session.repository.get_infrastructure(id)
		var cost := EconomyCalculator.infrastructure_cost(definition, previous, current - previous) if definition != null else 0.0
		_record_objective("purchase", {"content_id": id, "family": "infrastructure", "amount": current - previous, "cost": cost, "category": str(definition.get_value("category", "unknown")) if definition != null else "unknown"})
	for id_value: Variant in session.economy.state.upgrade_levels:
		var id := str(id_value)
		var previous := int(_previous_upgrades.get(id, 0))
		var current := int(session.economy.state.upgrade_levels[id])
		if current <= previous:
			continue
		var definition := session.repository.get_upgrade(id)
		var cost := EconomyCalculator.upgrade_cost(definition, previous) if definition != null else 0.0
		_record_objective("upgrade", {"content_id": id, "family": "upgrade", "level": current, "cost": cost})
	_previous_owned = session.economy.state.owned.duplicate(true)
	_previous_upgrades = session.economy.state.upgrade_levels.duplicate(true)


func _record_maintenance_difference() -> void:
	for id_value: Variant in session.economy.state.maintenance_choices:
		var id := str(id_value)
		if not _previous_maintenance.has(id):
			_record_objective("maintenance_choice", {"maintenance_id": id, "option_id": str(session.economy.state.maintenance_choices[id])})
	_previous_maintenance = session.economy.state.maintenance_choices.duplicate(true)


func _record_reported_difference() -> void:
	var current := _reported_states()
	for id_value: Variant in current:
		var id := str(id_value)
		if bool(current[id]) and not bool(_previous_reported.get(id, false)):
			_append_event("report_acknowledged", {"request_id": id}, false)
	_previous_reported = current


func _record_objective(type: String, payload: Dictionary) -> void:
	_finalize_open_gap(type)
	objective_counts[type] = int(objective_counts.get(type, 0)) + 1
	_append_event(type, payload, true)
	_last_action_foreground = foreground_seconds


func _append_event(type: String, payload: Dictionary, objective: bool) -> void:
	_sequence += 1
	events.append({"sequence": _sequence, "type": type, "foreground_seconds": foreground_seconds, "utc": int(Time.get_unix_time_from_system()), "objective": objective, "payload": payload.duplicate(true)})


func _finalize_open_gap(ended_by: String) -> void:
	var total := _gap_forced + _gap_report_dialogue + _gap_unknown
	if total > 0.0:
		interaction_gaps.append({"start_foreground_seconds": _last_action_foreground, "end_foreground_seconds": foreground_seconds, "duration_seconds": total, "forced_stall_seconds": _gap_forced, "report_dialogue_seconds": _gap_report_dialogue, "unknown_inactivity_seconds": _gap_unknown, "ended_by": ended_by})
	_gap_forced = 0.0
	_gap_report_dialogue = 0.0
	_gap_unknown = 0.0


func _classify_foreground(surface_id: String) -> String:
	if surface_id in REPORT_DIALOGUE_SURFACES:
		return "report_dialogue"
	return "forced_stall" if _is_forced_stall() else "unknown"


func _is_forced_stall() -> bool:
	if session.has_pending_maintenance() or not session.last_report_id.is_empty():
		return false
	if not session.available_optional_request_ids().is_empty():
		return false
	var current_id := session.current_request_id()
	if not current_id.is_empty():
		var state := session.requests.get_request_state(current_id)
		if state != null and state.status in [RequestRunState.ANNOUNCED, RequestRunState.AUTHORIZED, RequestRunState.COMPLETED]:
			return false
	for definition_value: Variant in session.repository.get_all("infrastructure"):
		if session.preview_infrastructure((definition_value as ContentDefinition).get_id()).can_purchase():
			return false
	for definition_value: Variant in session.repository.get_all("upgrades"):
		if session.preview_upgrade((definition_value as ContentDefinition).get_id()).can_purchase():
			return false
	return true


func _detect_system_transitions() -> void:
	var brownout := session.requests.grid.state.brownout_active
	if brownout != _previous_brownout:
		_append_event("brownout_started" if brownout else "brownout_recovered", {"request_id": session.current_request_id()}, false)
		_previous_brownout = brownout
	var reserve_support := session.requests.grid.get_last_result().reserve_discharge_power > 0.000001
	if reserve_support != _previous_reserve_support:
		_append_event("reserve_support_started" if reserve_support else "reserve_support_ended", {"request_id": session.current_request_id(), "reserve_stored": session.requests.grid.state.reserve_stored}, false)
		_previous_reserve_support = reserve_support
	var current_request := session.current_request_id()
	if current_request != _last_request_id:
		_append_event("current_request_changed", {"from": _last_request_id, "to": current_request}, false)
		_last_request_id = current_request


func _capture_due_checkpoints() -> void:
	for seconds: float in CHECKPOINT_SECONDS:
		var key := str(int(seconds))
		if foreground_seconds + 0.000001 >= seconds and not checkpoints.has(key):
			checkpoints[key] = _mechanical_snapshot()
			_append_event("checkpoint_%d_minutes" % int(seconds / 60.0), {"snapshot": checkpoints[key]}, false)


func _mechanical_snapshot() -> Dictionary:
	if session == null:
		return {}
	var request_id := session.current_request_id()
	var request_state := session.requests.get_request_state(request_id) if not request_id.is_empty() else null
	return {
		"era_id": session.economy.state.current_era_id,
		"request_id": request_id,
		"request_status": request_state.status if request_state != null else "none",
		"request_progress": request_state.progress if request_state != null else 0.0,
		"stored_energy": session.requests.grid.state.stored_energy,
		"generation": session.requests.grid.state.generation_rate,
		"transmission": session.requests.grid.state.transmission_capacity,
		"reserve_stored": session.requests.grid.state.reserve_stored,
		"reserve_capacity": session.requests.grid.state.reserve_capacity,
		"allocation_mode": session.requests.grid.state.allocation_mode,
		"owned_total": _sum_dictionary(session.economy.state.owned),
	}


func _compact_checkpoints() -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in checkpoints:
		var snapshot: Dictionary = checkpoints[key]
		result[str(key)] = {"era_id": snapshot.get("era_id", ""), "request_id": snapshot.get("request_id", ""), "request_progress": snapshot.get("request_progress", 0.0), "stored_energy": snapshot.get("stored_energy", 0.0)}
	return result


func _reported_states() -> Dictionary:
	var result: Dictionary = {}
	for definition_value: Variant in session.repository.get_all("requests"):
		var id := (definition_value as ContentDefinition).get_id()
		var state := session.requests.get_request_state(id)
		result[id] = state != null and state.status == RequestRunState.REPORTED
	return result


func _longest_gap() -> float:
	var longest := _gap_forced + _gap_report_dialogue + _gap_unknown
	for gap_value: Variant in interaction_gaps:
		longest = maxf(longest, float((gap_value as Dictionary).get("duration_seconds", 0.0)))
	return longest


static func _sum_dictionary(values: Dictionary) -> int:
	var total := 0
	for value: Variant in values.values():
		total += int(value)
	return total


static func _duration(seconds: float) -> String:
	return "%02d:%02d" % [floori(seconds / 60.0), floori(fmod(seconds, 60.0))]


static func _write_json_atomic(path: String, value: Dictionary) -> bool:
	var pending := "%s.pending" % path
	if not _write_text(pending, JSON.stringify(value, "  ")):
		return false
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(pending), ProjectSettings.globalize_path(path)) == OK


static func _write_text(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	file.close()
	return true
