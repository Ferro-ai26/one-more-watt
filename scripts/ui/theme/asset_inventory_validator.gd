class_name AssetInventoryValidator
extends RefCounted

const INVENTORY_PATH := "res://assets/asset_inventory.json"


static func validate(release_scope: bool = false) -> Dictionary:
	var errors := PackedStringArray()
	var warnings := PackedStringArray()
	if not FileAccess.file_exists(INVENTORY_PATH):
		return {"ok": false, "errors": PackedStringArray(["asset inventory is missing"]), "warnings": warnings, "entries": 0}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY_PATH))
	if not parsed is Dictionary or not (parsed as Dictionary).get("assets") is Array:
		return {"ok": false, "errors": PackedStringArray(["asset inventory JSON is invalid"]), "warnings": warnings, "entries": 0}
	var assets := (parsed as Dictionary)["assets"] as Array
	for entry_value: Variant in assets:
		if not entry_value is Dictionary:
			errors.append("asset entry must be an object")
			continue
		var entry := entry_value as Dictionary
		var asset_path := str(entry.get("path", ""))
		var status := str(entry.get("phase12_status", ""))
		var required := bool(entry.get("release_required", false))
		if str(entry.get("id", "")).is_empty() or asset_path.is_empty() or status not in ["integrated", "fallback"]:
			errors.append("asset entry has invalid required fields")
			continue
		if status == "integrated" and not ResourceLoader.exists(asset_path):
			errors.append("integrated asset missing: %s" % asset_path)
		elif status == "fallback" and release_scope and required:
			errors.append("release-required asset still uses fallback: %s" % asset_path)
		elif status == "fallback":
			warnings.append("development fallback active: %s" % asset_path)
	return {"ok": errors.is_empty(), "errors": errors, "warnings": warnings, "entries": assets.size()}
