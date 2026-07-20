class_name SaveManager
extends RefCounted

const CONTENT_COMPATIBILITY := {"0.7.0": ["0.6.0"]}

const MAIN_NAME := "save_main.json"
const BACKUP_1_NAME := "save_backup_1.json"
const BACKUP_2_NAME := "save_backup_2.json"
const TEMP_NAME := "save_pending.tmp"

var root_path := "user://"
var content_version := ""
var build_version := ""
var last_sequence := 0
var created_utc := 0
var last_diagnostics: PackedStringArray = []


func _init(path: String = "user://", expected_content_version: String = "") -> void:
	root_path = path.trim_suffix("/")
	content_version = expected_content_version
	build_version = str(ProjectSettings.get_setting("application/config/version", "unknown"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(root_path))


func save(payload: Dictionary, current_utc: int, last_trusted_utc: int, trigger: String = "manual") -> Dictionary:
	last_diagnostics.clear()
	var next_sequence := last_sequence + 1
	var created := current_utc if created_utc <= 0 else created_utc
	var unsigned := {
		"format_version": SaveMigrator.CURRENT_VERSION,
		"game_build_version": build_version,
		"content_version": content_version,
		"sequence": next_sequence,
		"created_utc": created,
		"updated_utc": current_utc,
		"last_trusted_utc": last_trusted_utc,
		"trigger": trigger,
		"payload": payload.duplicate(true),
	}
	var encoded := SaveCodec.encode(unsigned)
	var verified := SaveCodec.decode(encoded)
	if not bool(verified.get("ok", false)):
		return {"ok": false, "error": "self_validation_failed"}
	var temp_path := _path(TEMP_NAME)
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "temp_open_failed"}
	file.store_string(encoded)
	file.flush()
	file.close()
	if not _rotate_known_good(current_utc):
		_remove(temp_path)
		return {"ok": false, "error": "backup_rotation_failed"}
	var main_path := _path(MAIN_NAME)
	_remove(main_path)
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(main_path))
	if rename_error != OK:
		return {"ok": false, "error": "atomic_replace_failed", "code": rename_error}
	last_sequence = next_sequence
	created_utc = created
	last_diagnostics.append("saved sequence %d (%s)" % [next_sequence, trigger])
	return {"ok": true, "sequence": next_sequence, "path": main_path}


func load() -> SaveLoadResult:
	last_diagnostics.clear()
	var result := SaveLoadResult.new()
	var candidates := [MAIN_NAME, BACKUP_1_NAME, BACKUP_2_NAME]
	var found_any := false
	for index: int in candidates.size():
		var name: String = candidates[index]
		var path := _path(name)
		if not FileAccess.file_exists(path):
			continue
		found_any = true
		var decoded := _read_valid(path)
		if not bool(decoded.get("ok", false)):
			var message := "%s: %s" % [name, decoded.get("error", "invalid")]
			result.diagnostics.append(message)
			last_diagnostics.append(message)
			if index == 0:
				result.preserved_corrupt_path = _preserve_corrupt_main()
			continue
		var envelope: Dictionary = decoded["envelope"]
		var migration := SaveMigrator.migrate(envelope)
		if not bool(migration.get("ok", false)):
			result.diagnostics.append("%s: %s" % [name, migration.get("error", "migration_failed")])
			continue
		envelope = migration["envelope"]
		if not _content_version_compatible(str(envelope.get("content_version", ""))):
			result.diagnostics.append("%s: incompatible_content_version" % name)
			continue
		result.ok = true
		result.status = "loaded" if index == 0 else "recovered"
		result.source = name
		result.recovered = index > 0
		result.migrated = bool(migration.get("migrated", false))
		result.sequence = int(envelope.get("sequence", 0))
		result.envelope = envelope
		last_sequence = result.sequence
		created_utc = int(envelope.get("created_utc", 0))
		return result
	result.status = "corrupt_all" if found_any else "no_save"
	return result


func _content_version_compatible(saved_version: String) -> bool:
	if content_version.is_empty() or saved_version == content_version:
		return true
	return saved_version in CONTENT_COMPATIBILITY.get(content_version, [])


func diagnostics() -> Dictionary:
	return {"root": root_path, "sequence": last_sequence, "messages": last_diagnostics.duplicate(), "main_exists": FileAccess.file_exists(_path(MAIN_NAME)), "backup_1_exists": FileAccess.file_exists(_path(BACKUP_1_NAME)), "backup_2_exists": FileAccess.file_exists(_path(BACKUP_2_NAME))}


func _read_valid(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "read_failed"}
	var decoded := SaveCodec.decode(file.get_as_text())
	file.close()
	return decoded


func _rotate_known_good(current_utc: int) -> bool:
	var main_path := _path(MAIN_NAME)
	var backup_1 := _path(BACKUP_1_NAME)
	var backup_2 := _path(BACKUP_2_NAME)
	if FileAccess.file_exists(backup_1) and bool(_read_valid(backup_1).get("ok", false)):
		_remove(backup_2)
		if not _copy(backup_1, backup_2):
			return false
	if FileAccess.file_exists(main_path):
		if bool(_read_valid(main_path).get("ok", false)):
			_remove(backup_1)
			if not _copy(main_path, backup_1):
				return false
		else:
			_preserve_corrupt_main(current_utc)
	return true


func _preserve_corrupt_main(timestamp: int = 0) -> String:
	var main_path := _path(MAIN_NAME)
	if not FileAccess.file_exists(main_path):
		return ""
	var stamp := timestamp if timestamp > 0 else int(Time.get_unix_time_from_system())
	var target := _path("save_main.corrupt.%d.json" % stamp)
	return target if _copy(main_path, target) else ""


func _path(name: String) -> String:
	return "%s/%s" % [root_path, name]


static func _copy(source: String, target: String) -> bool:
	return DirAccess.copy_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(target)) == OK


static func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
