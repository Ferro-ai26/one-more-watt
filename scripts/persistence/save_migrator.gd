class_name SaveMigrator
extends RefCounted

const CURRENT_VERSION := 2
const MINIMUM_VERSION := 1
const ID_RENAMES := {"starter_outlet": "wall_outlet"}


static func migrate(envelope: Dictionary) -> Dictionary:
	var version := int(envelope.get("format_version", 0))
	if version < MINIMUM_VERSION:
		return {"ok": false, "error": "unsupported_old_version"}
	if version > CURRENT_VERSION:
		return {"ok": false, "error": "unknown_future_version"}
	var migrated := envelope.duplicate(true)
	var did_migrate := false
	while version < CURRENT_VERSION:
		match version:
			1:
				var payload: Dictionary = migrated.get("payload", {})
				var session: Dictionary = payload.get("session", {})
				_apply_id_renames(session)
				if not session.has("prestige"):
					session["prestige"] = {"model_weights": 0, "permanent_upgrade_ids": []}
				payload["session"] = session
				migrated["payload"] = payload
				version = 2
				did_migrate = true
			_:
				return {"ok": false, "error": "missing_migration"}
		migrated["format_version"] = version
	return {"ok": true, "envelope": migrated, "migrated": did_migrate}


static func _apply_id_renames(session: Dictionary) -> void:
	var economy: Dictionary = session.get("economy", {})
	for field: String in ["owned", "upgrade_levels", "completed_requests", "unlocked_content"]:
		var values: Dictionary = economy.get(field, {})
		for old_id: String in ID_RENAMES:
			if values.has(old_id) and not values.has(ID_RENAMES[old_id]):
				values[ID_RENAMES[old_id]] = values[old_id]
				values.erase(old_id)
		economy[field] = values
	session["economy"] = economy
