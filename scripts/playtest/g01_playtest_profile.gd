class_name G01PlaytestProfile
extends RefCounted

const DEFAULT_ROOT := "user://g01_playtests"
const ACTIVE_NAME := "active.json"

var base_root := DEFAULT_ROOT


func _init(root_path: String = DEFAULT_ROOT) -> void:
	base_root = root_path.trim_suffix("/")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_root))


static func feature_enabled() -> bool:
	return OS.has_feature("g01_playtest") or "--g01-playtest" in OS.get_cmdline_user_args() or bool(ProjectSettings.get_setting("one_more_watt/testing/g01_mode", false))


func create_session_id() -> String:
	return "%d-%d" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec()]


func create_fresh_session() -> String:
	var session_id := create_session_id()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(session_root(session_id)))
	if not _write_json_atomic(active_path(), {"schema": "g01_active_v1", "session_id": session_id}):
		return ""
	return session_id


func active_session_id() -> String:
	if not FileAccess.file_exists(active_path()):
		return ""
	var file := FileAccess.open(active_path(), FileAccess.READ)
	if file == null:
		return ""
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return ""
	var session_id := str((parsed as Dictionary).get("session_id", ""))
	return session_id if not session_id.is_empty() and DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(session_root(session_id))) else ""


func clear_active(expected_session_id: String) -> bool:
	if active_session_id() != expected_session_id:
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(active_path())) == OK


func session_root(session_id: String) -> String:
	return "%s/%s" % [base_root, session_id]


func save_root(session_id: String) -> String:
	return "%s/save" % session_root(session_id)


func active_path() -> String:
	return "%s/%s" % [base_root, ACTIVE_NAME]


static func _write_json_atomic(path: String, value: Dictionary) -> bool:
	var pending := "%s.pending" % path
	var file := FileAccess.open(pending, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  "))
	file.flush()
	file.close()
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(pending), ProjectSettings.globalize_path(path))
	return error == OK
