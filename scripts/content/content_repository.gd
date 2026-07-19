class_name ContentRepository
extends RefCounted

const DEFINITION_SCRIPTS := {
	"balance": preload("res://scripts/content/definitions/balance_definition.gd"),
	"eras": preload("res://scripts/content/definitions/era_definition.gd"),
	"infrastructure": preload("res://scripts/content/definitions/infrastructure_definition.gd"),
	"upgrades": preload("res://scripts/content/definitions/upgrade_definition.gd"),
	"requests": preload("res://scripts/content/definitions/request_definition.gd"),
	"demand_profiles": preload("res://scripts/content/definitions/demand_profile_definition.gd"),
	"dialogue": preload("res://scripts/content/definitions/dialogue_definition.gd"),
	"incidents": preload("res://scripts/content/definitions/incident_definition.gd"),
	"achievements": preload("res://scripts/content/definitions/achievement_definition.gd"),
	"localization": preload("res://scripts/content/definitions/localization_definition.gd"),
}

var _content_version := ""
var _schema_version := 0
var _loaded := false
var _records: Dictionary = {}


func load_from_manifest(manifest_path: String = "res://data/manifest.json", path_redirects: Dictionary = {}) -> ContentLoadResult:
	_clear()
	var payload := ContentValidator.new().validate_manifest(manifest_path, path_redirects)
	var result := ContentLoadResult.new(payload.get("issues", []))
	if not result.is_ok():
		return result

	var manifest: Dictionary = payload["manifest"]
	_content_version = str(manifest.get("content_version", ""))
	_schema_version = int(manifest.get("schema_version", 0))
	for family: String in DEFINITION_SCRIPTS:
		_records[family] = {}
		var definition_script: Script = DEFINITION_SCRIPTS[family]
		for wrapper_value: Variant in payload["records"][family]:
			var source: Dictionary = wrapper_value["data"]
			var definition: ContentDefinition = definition_script.new(source)
			(_records[family] as Dictionary)[definition.get_id()] = definition
	_loaded = true
	return result


func is_loaded() -> bool:
	return _loaded


func get_content_version() -> String:
	return _content_version


func get_schema_version() -> int:
	return _schema_version


func get_definition(family: String, id: String) -> ContentDefinition:
	if not _records.has(family):
		return null
	return (_records[family] as Dictionary).get(id) as ContentDefinition


func get_era(id: String) -> EraDefinition:
	return get_definition("eras", id) as EraDefinition


func get_infrastructure(id: String) -> InfrastructureDefinition:
	return get_definition("infrastructure", id) as InfrastructureDefinition


func get_upgrade(id: String) -> UpgradeDefinition:
	return get_definition("upgrades", id) as UpgradeDefinition


func get_request(id: String) -> RequestDefinition:
	return get_definition("requests", id) as RequestDefinition


func get_demand_profile(id: String) -> DemandProfileDefinition:
	return get_definition("demand_profiles", id) as DemandProfileDefinition


func get_dialogue(id: String) -> DialogueDefinition:
	return get_definition("dialogue", id) as DialogueDefinition


func get_incident(id: String) -> IncidentDefinition:
	return get_definition("incidents", id) as IncidentDefinition


func get_achievement(id: String) -> AchievementDefinition:
	return get_definition("achievements", id) as AchievementDefinition


func get_balance(id: String) -> BalanceDefinition:
	return get_definition("balance", id) as BalanceDefinition


func get_localization(locale: String = "en") -> LocalizationDefinition:
	return get_definition("localization", locale) as LocalizationDefinition


func get_all(family: String) -> Array:
	if not _records.has(family):
		return []
	return (_records[family] as Dictionary).values().duplicate()


func get_counts() -> Dictionary:
	var counts: Dictionary = {}
	for family: String in DEFINITION_SCRIPTS:
		counts[family] = (_records.get(family, {}) as Dictionary).size()
	counts.make_read_only()
	return counts


func localize(key: String, replacements: Dictionary = {}, locale: String = "en") -> String:
	var localization := get_localization(locale)
	if localization == null or not localization.has_key(key):
		return "[missing:%s]" % key
	var text := localization.get_text(key)
	for replacement_key: Variant in replacements:
		text = text.replace("{%s}" % replacement_key, str(replacements[replacement_key]))
	var placeholder_regex := RegEx.new()
	placeholder_regex.compile("\\{[a-z][a-z0-9_]*\\}")
	if placeholder_regex.search(text) != null:
		return "[format-error:%s]" % key
	return text


func _clear() -> void:
	_content_version = ""
	_schema_version = 0
	_loaded = false
	_records.clear()
