class_name ContentValidator
extends RefCounted

const REQUIRED_FAMILIES := [
	"balance", "eras", "infrastructure", "upgrades", "requests",
	"demand_profiles", "dialogue", "incidents", "achievements", "localization",
]
const ID_PATTERN := "^[a-z][a-z0-9_]*$"
const CATEGORIES := ["generation", "transmission", "reserve", "support", "automation", "special"]
const REQUEST_KINDS := ["capacity", "stability", "burst", "research", "vanity"]
const EFFECT_OPERATIONS := ["add", "multiply"]
const EFFECT_TARGETS := [
	"generation_rate", "transmission_capacity", "reserve_capacity",
	"reserve_charge_rate", "reserve_discharge_rate", "request_efficiency",
	"automation_capacity", "request_demand_multiplier", "category_output",
	"tag_output", "global_output",
]
const BASE_EFFECT_TARGETS := [
	"generation_rate", "transmission_capacity", "reserve_capacity",
	"reserve_charge_rate", "reserve_discharge_rate", "request_efficiency",
	"automation_capacity",
]
const INCIDENT_SEVERITIES := ["cosmetic", "minor", "major"]
const CONDITION_TYPES := ["default", "request_completed", "infrastructure_owned", "upgrade_owned", "era_unlocked"]

var _id_regex := RegEx.new()


func _init() -> void:
	_id_regex.compile(ID_PATTERN)


func validate_manifest(manifest_path: String, path_redirects: Dictionary = {}) -> Dictionary:
	var issues: Array[ContentValidationIssue] = []
	var manifest_value: Variant = _parse_json(manifest_path, path_redirects, issues)
	var records: Dictionary = {}
	for family: String in REQUIRED_FAMILIES:
		records[family] = []

	if not manifest_value is Dictionary:
		return {"issues": issues, "manifest": {}, "records": records}

	var manifest: Dictionary = manifest_value
	_require_fields(manifest, {"schema_version": "integer", "content_version": "string", "files": "array", "placeholder_assets": "array"}, manifest_path, "", issues)
	var schema_version := int(manifest.get("schema_version", 0))
	if schema_version <= 0:
		_add_issue(issues, "INVALID_VALUE", manifest_path, "", "schema_version must be positive")
	if str(manifest.get("content_version", "")).is_empty():
		_add_issue(issues, "INVALID_VALUE", manifest_path, "", "content_version must not be empty")

	var seen_families: Dictionary = {}
	var files_value: Variant = manifest.get("files", [])
	if files_value is Array:
		for file_value: Variant in files_value:
			if not file_value is Dictionary:
				_add_issue(issues, "INVALID_TYPE", manifest_path, "", "manifest file entries must be objects")
				continue
			var file_entry: Dictionary = file_value
			_require_fields(file_entry, {"family": "string", "path": "string", "root": "string"}, manifest_path, "", issues)
			var family := str(file_entry.get("family", ""))
			var file_path := str(file_entry.get("path", ""))
			var root_key := str(file_entry.get("root", ""))
			if family not in REQUIRED_FAMILIES:
				_add_issue(issues, "UNSUPPORTED_FAMILY", manifest_path, "", "unsupported family '%s'" % family)
				continue
			seen_families[family] = true
			var document_value: Variant = _parse_json(file_path, path_redirects, issues)
			if not document_value is Dictionary:
				continue
			var document: Dictionary = document_value
			if int(document.get("schema_version", -1)) != schema_version:
				_add_issue(issues, "SCHEMA_VERSION_MISMATCH", file_path, "", "expected schema_version %d" % schema_version)
			if family == "localization":
				_load_localization_record(document, str(path_redirects.get(file_path, file_path)), root_key, records, issues)
				continue
			var root_value: Variant = document.get(root_key)
			if not root_value is Array:
				_add_issue(issues, "INVALID_TYPE", file_path, "", "root '%s' must be an array" % root_key)
				continue
			for record_value: Variant in root_value:
				if not record_value is Dictionary:
					_add_issue(issues, "INVALID_TYPE", file_path, "", "%s records must be objects" % family)
					continue
				(records[family] as Array).append({"data": record_value, "path": str(path_redirects.get(file_path, file_path))})

	for family: String in REQUIRED_FAMILIES:
		if not seen_families.has(family):
			_add_issue(issues, "MISSING_FAMILY", manifest_path, "", "manifest does not declare family '%s'" % family)

	var placeholder_assets := _validate_placeholder_assets(manifest.get("placeholder_assets", []), manifest_path, issues)
	var indices := _validate_records(records, placeholder_assets, issues)
	_validate_cross_references(records, indices, placeholder_assets, issues)
	_validate_localization(records, issues)
	_validate_required_request_graph(records, indices, issues)

	return {"issues": issues, "manifest": manifest, "records": records}


func _parse_json(path: String, redirects: Dictionary, issues: Array[ContentValidationIssue]) -> Variant:
	var source_path := str(redirects.get(path, path))
	if not FileAccess.file_exists(source_path):
		_add_issue(issues, "FILE_NOT_FOUND", source_path, "", "JSON file does not exist")
		return null
	var parser := JSON.new()
	var error := parser.parse(FileAccess.get_file_as_string(source_path))
	if error != OK:
		_add_issue(issues, "INVALID_JSON", source_path, "", "line %d: %s" % [parser.get_error_line(), parser.get_error_message()])
		return null
	return parser.data


func _load_localization_record(document: Dictionary, path: String, root_key: String, records: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	_require_fields(document, {"locale": "string", root_key: "dictionary"}, path, "", issues)
	if not document.get(root_key, {}) is Dictionary:
		return
	var record := {"id": str(document.get("locale", "")), "strings": document.get(root_key, {})}
	(records["localization"] as Array).append({"data": record, "path": path})


func _validate_placeholder_assets(value: Variant, path: String, issues: Array[ContentValidationIssue]) -> Dictionary:
	var placeholders: Dictionary = {}
	if not value is Array:
		return placeholders
	for exception_value: Variant in value:
		if not exception_value is Dictionary:
			_add_issue(issues, "INVALID_TYPE", path, "", "placeholder asset entries must be objects")
			continue
		var exception: Dictionary = exception_value
		_require_fields(exception, {"path": "string", "reason": "string"}, path, "", issues)
		var asset_path := str(exception.get("path", ""))
		if placeholders.has(asset_path):
			_add_issue(issues, "DUPLICATE_ASSET_EXCEPTION", path, "", "duplicate placeholder asset '%s'" % asset_path)
		placeholders[asset_path] = false
		if str(exception.get("reason", "")).strip_edges().is_empty():
			_add_issue(issues, "INVALID_VALUE", path, "", "placeholder asset '%s' requires a reason" % asset_path)
	return placeholders


func _validate_records(records: Dictionary, placeholder_assets: Dictionary, issues: Array[ContentValidationIssue]) -> Dictionary:
	var indices: Dictionary = {}
	var global_ids: Dictionary = {}
	for family: String in REQUIRED_FAMILIES:
		indices[family] = {}
		for wrapper_value: Variant in records[family]:
			var wrapper: Dictionary = wrapper_value
			var record: Dictionary = wrapper["data"]
			var path := str(wrapper["path"])
			_require_fields(record, {"id": "string"}, path, "", issues)
			var record_id := str(record.get("id", ""))
			if _id_regex.search(record_id) == null:
				_add_issue(issues, "INVALID_ID", path, record_id, "ID must match %s" % ID_PATTERN)
			if global_ids.has(record_id):
				_add_issue(issues, "DUPLICATE_ID", path, record_id, "ID was already declared in %s" % global_ids[record_id])
			else:
				global_ids[record_id] = family
			(indices[family] as Dictionary)[record_id] = wrapper
			_validate_family_record(family, record, path, record_id, placeholder_assets, issues)
	indices["_global_ids"] = global_ids
	return indices


func _validate_family_record(family: String, record: Dictionary, path: String, record_id: String, placeholder_assets: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	match family:
		"balance":
			_require_fields(record, {"simulation_step_seconds": "number", "underpower_efficiency_floor": "number", "starting_grid": "dictionary", "starting_owned": "dictionary", "allocation_modes": "dictionary", "stored_energy_efficiency": "dictionary", "offline_progress": "dictionary", "milestone_sets": "dictionary"}, path, record_id, issues)
			_validate_nonnegative_tree(record, path, record_id, issues)
			_validate_allocation_modes(record.get("allocation_modes", {}), path, record_id, issues)
		"eras":
			_require_fields(record, {"number": "integer", "name_key": "string", "scale_key": "string", "description_key": "string", "unlock_conditions": "array", "infrastructure_ids": "array", "request_ids": "array", "visual_state_id": "string", "unit_display_floor": "string"}, path, record_id, issues)
			if int(record.get("number", 0)) <= 0:
				_add_issue(issues, "INVALID_VALUE", path, record_id, "era number must be positive")
		"infrastructure":
			_require_fields(record, {"era_id": "string", "name_key": "string", "description_key": "string", "category": "string", "tags": "array", "base_cost": "number", "cost_growth": "number", "base_effects": "dictionary", "unlock_conditions": "array", "milestone_set": "string", "icon_path": "string", "scene_variant": "string"}, path, record_id, issues)
			_validate_enum(record.get("category"), CATEGORIES, "UNSUPPORTED_CATEGORY", path, record_id, "category", issues)
			_validate_nonnegative(record, ["base_cost"], path, record_id, issues)
			if float(record.get("cost_growth", 0.0)) < 1.0:
				_add_issue(issues, "INVALID_VALUE", path, record_id, "cost_growth must be at least 1")
			_validate_base_effects(record.get("base_effects", {}), path, record_id, issues)
			if record.has("passive_effects"):
				_validate_effects(record.get("passive_effects", []), path, record_id, issues)
			_validate_asset(str(record.get("icon_path", "")), path, record_id, placeholder_assets, issues)
			if record.has("max_owned") and record["max_owned"] != null and (not _is_integer(record["max_owned"]) or int(record["max_owned"]) <= 0):
				_add_issue(issues, "INVALID_VALUE", path, record_id, "max_owned must be null or a positive integer")
		"upgrades":
			_require_fields(record, {"era_id": "string", "name_key": "string", "description_key": "string", "cost": "dictionary", "unlock_conditions": "array", "effects": "array", "permanent": "boolean", "max_level": "integer"}, path, record_id, issues)
			_validate_nonnegative_tree(record.get("cost", {}), path, record_id, issues)
			if record.has("cost_growth") and (not _is_number(record["cost_growth"]) or float(record["cost_growth"]) < 1.0):
				_add_issue(issues, "INVALID_VALUE", path, record_id, "upgrade cost_growth must be at least 1")
			_validate_effects(record.get("effects", []), path, record_id, issues)
			if int(record.get("max_level", 0)) <= 0:
				_add_issue(issues, "INVALID_VALUE", path, record_id, "max_level must be positive")
		"requests":
			_require_fields(record, {"era_id": "string", "sequence": "integer", "kind": "string", "required": "boolean", "title_key": "string", "summary_key": "string", "announcement_key": "string", "completion_key": "string", "required_energy": "number", "continuous_demand": "number", "max_useful_power": "number", "demand_profile_id": "string", "recommended_reserve": "number", "unlock_conditions": "array", "rewards": "dictionary", "repeatable": "boolean", "tags": "array"}, path, record_id, issues)
			_validate_enum(record.get("kind"), REQUEST_KINDS, "UNSUPPORTED_REQUEST_KIND", path, record_id, "kind", issues)
			_validate_nonnegative(record, ["required_energy", "continuous_demand", "max_useful_power", "recommended_reserve"], path, record_id, issues)
			if record.has("research_cost"):
				if not _is_number(record["research_cost"]) or float(record["research_cost"]) < 0.0:
					_add_issue(issues, "INVALID_VALUE", path, record_id, "research_cost must be nonnegative")
				if str(record.get("kind", "")) != "research":
					_add_issue(issues, "INVALID_VALUE", path, record_id, "research_cost is only valid for research requests")
			if int(record.get("sequence", 0)) <= 0:
				_add_issue(issues, "INVALID_VALUE", path, record_id, "sequence must be positive")
			if record.get("tutorial_action") != null and not record.get("tutorial_action") is String:
				_add_issue(issues, "INVALID_TYPE", path, record_id, "tutorial_action must be null or a string")
			var rewards: Variant = record.get("rewards", {})
			if rewards is Dictionary:
				_require_fields(rewards, {"stored_energy": "number", "unlock_ids": "array"}, path, record_id, issues)
				_validate_nonnegative(rewards, ["stored_energy"], path, record_id, issues)
		"demand_profiles":
			_require_fields(record, {"duration_seconds": "number", "loop": "boolean", "keyframes": "array"}, path, record_id, issues)
			_validate_demand_profile(record, path, record_id, issues)
		"dialogue":
			_require_fields(record, {"context": "string", "era_id": "string", "text_key": "string", "required_placeholders": "array", "tags": "array"}, path, record_id, issues)
		"incidents":
			_require_fields(record, {"trigger": "dictionary", "duration_seconds": "number", "modifiers": "array", "dialogue_keys": "array", "severity": "string", "offline_allowed": "boolean"}, path, record_id, issues)
			_validate_nonnegative(record, ["duration_seconds"], path, record_id, issues)
			_validate_enum(record.get("severity"), INCIDENT_SEVERITIES, "UNSUPPORTED_INCIDENT_SEVERITY", path, record_id, "severity", issues)
			_validate_effects(record.get("modifiers", []), path, record_id, issues)
			if bool(record.get("offline_allowed", false)) and str(record.get("severity", "")) != "cosmetic":
				_add_issue(issues, "UNSAFE_OFFLINE_INCIDENT", path, record_id, "only cosmetic prototype incidents may be allowed offline")
		"achievements":
			_require_fields(record, {"name_key": "string", "description_key": "string", "condition": "dictionary", "reward_unlock_ids": "array", "hidden": "boolean"}, path, record_id, issues)
		"localization":
			_require_fields(record, {"strings": "dictionary"}, path, record_id, issues)
			var strings: Variant = record.get("strings", {})
			if strings is Dictionary:
				for key: Variant in strings:
					if not key is String or str(key).is_empty() or not strings[key] is String or str(strings[key]).is_empty():
						_add_issue(issues, "INVALID_LOCALIZATION_ENTRY", path, record_id, "localization keys and values must be non-empty strings")


func _validate_cross_references(records: Dictionary, indices: Dictionary, placeholder_assets: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	for wrapper_value: Variant in records["eras"]:
		var wrapper: Dictionary = wrapper_value
		var era: Dictionary = wrapper["data"]
		_validate_id_list(era.get("infrastructure_ids", []), "infrastructure", indices, wrapper, issues)
		_validate_id_list(era.get("request_ids", []), "requests", indices, wrapper, issues)
		_validate_conditions(era.get("unlock_conditions", []), indices, wrapper, issues)

	for family: String in ["infrastructure", "upgrades", "requests"]:
		for wrapper_value: Variant in records[family]:
			var wrapper: Dictionary = wrapper_value
			var record: Dictionary = wrapper["data"]
			_validate_reference(str(record.get("era_id", "")), "eras", indices, wrapper, "era_id", issues)
			_validate_conditions(record.get("unlock_conditions", []), indices, wrapper, issues)
			var era_wrapper: Variant = (indices["eras"] as Dictionary).get(str(record.get("era_id", "")))
			if era_wrapper is Dictionary and family in ["infrastructure", "requests"]:
				var membership_field := "infrastructure_ids" if family == "infrastructure" else "request_ids"
				if record.get("id", "") not in era_wrapper["data"].get(membership_field, []):
					_add_issue(issues, "ERA_MEMBERSHIP_MISMATCH", wrapper["path"], record.get("id", ""), "record is not listed in its era's %s" % membership_field)

	for wrapper_value: Variant in records["requests"]:
		var wrapper: Dictionary = wrapper_value
		var request: Dictionary = wrapper["data"]
		_validate_reference(str(request.get("demand_profile_id", "")), "demand_profiles", indices, wrapper, "demand_profile_id", issues)
		var rewards: Variant = request.get("rewards", {})
		if rewards is Dictionary:
			for unlock_id: Variant in rewards.get("unlock_ids", []):
				if not (indices["_global_ids"] as Dictionary).has(str(unlock_id)):
					_add_issue(issues, "UNKNOWN_REWARD_TARGET", wrapper["path"], request.get("id", ""), "unknown reward unlock ID '%s'" % unlock_id)

	for wrapper_value: Variant in records["dialogue"]:
		var wrapper: Dictionary = wrapper_value
		_validate_reference(str(wrapper["data"].get("era_id", "")), "eras", indices, wrapper, "era_id", issues)

	for wrapper_value: Variant in records["incidents"]:
		_validate_trigger(wrapper_value, indices, issues)
	for wrapper_value: Variant in records["achievements"]:
		_validate_trigger(wrapper_value, indices, issues, "condition")
		var achievement: Dictionary = wrapper_value["data"]
		for unlock_id: Variant in achievement.get("reward_unlock_ids", []):
			if not (indices["_global_ids"] as Dictionary).has(str(unlock_id)):
				_add_issue(issues, "UNKNOWN_REWARD_TARGET", wrapper_value["path"], achievement.get("id", ""), "unknown reward unlock ID '%s'" % unlock_id)

	var balance_ids: Dictionary = indices["balance"]
	for wrapper_value: Variant in records["infrastructure"]:
		var infrastructure: Dictionary = wrapper_value["data"]
		var found_milestone := false
		for balance_wrapper: Variant in balance_ids.values():
			var milestone_sets: Dictionary = balance_wrapper["data"].get("milestone_sets", {})
			if milestone_sets.has(str(infrastructure.get("milestone_set", ""))):
				found_milestone = true
		if not found_milestone:
			_add_issue(issues, "BROKEN_REFERENCE", wrapper_value["path"], infrastructure.get("id", ""), "unknown milestone_set '%s'" % infrastructure.get("milestone_set", ""))

	for wrapper_value: Variant in records["balance"]:
		var balance: Dictionary = wrapper_value["data"]
		var starting_owned: Variant = balance.get("starting_owned", {})
		if starting_owned is Dictionary:
			for infrastructure_id: Variant in starting_owned:
				_validate_reference(str(infrastructure_id), "infrastructure", indices, wrapper_value, "starting_owned", issues)
				if not _is_integer(starting_owned[infrastructure_id]) or int(starting_owned[infrastructure_id]) < 0:
					_add_issue(issues, "INVALID_VALUE", wrapper_value["path"], balance.get("id", ""), "starting_owned counts must be nonnegative integers")
		var efficiencies: Variant = balance.get("stored_energy_efficiency", {})
		if efficiencies is Dictionary:
			for era_id: Variant in efficiencies:
				_validate_reference(str(era_id), "eras", indices, wrapper_value, "stored_energy_efficiency", issues)
		var offline: Variant = balance.get("offline_progress", {})
		if offline is Dictionary:
			for field: String in ["cap_seconds", "efficiency", "far_forward_seconds"]:
				if not offline.has(field) or typeof(offline[field]) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(offline[field])) or float(offline[field]) < 0.0:
					_add_issue(issues, "INVALID_VALUE", wrapper_value["path"], balance.get("id", ""), "offline_progress.%s must be nonnegative" % field)
			if float(offline.get("efficiency", 0.0)) > 1.0:
				_add_issue(issues, "INVALID_VALUE", wrapper_value["path"], balance.get("id", ""), "offline_progress.efficiency cannot exceed 1")

	for asset_path: Variant in placeholder_assets:
		if not bool(placeholder_assets[asset_path]):
			_add_issue(issues, "UNUSED_ASSET_EXCEPTION", "res://data/manifest.json", "", "placeholder asset '%s' is not referenced" % asset_path)


func _validate_localization(records: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	var english: Dictionary = {}
	for wrapper_value: Variant in records["localization"]:
		if wrapper_value["data"].get("id") == "en":
			english = wrapper_value["data"].get("strings", {})
	if english.is_empty():
		_add_issue(issues, "MISSING_LOCALIZATION", "res://data/localization/en.json", "en", "English localization catalog is required")
		return

	var key_fields := {
		"eras": ["name_key", "scale_key", "description_key"],
		"infrastructure": ["name_key", "description_key"],
		"upgrades": ["name_key", "description_key"],
		"requests": ["title_key", "summary_key", "announcement_key", "completion_key"],
		"dialogue": ["text_key"],
		"achievements": ["name_key", "description_key"],
	}
	for family: Variant in key_fields:
		for wrapper_value: Variant in records[family]:
			for field: Variant in key_fields[family]:
				_validate_localization_key(str(wrapper_value["data"].get(field, "")), english, wrapper_value, issues)
	for wrapper_value: Variant in records["incidents"]:
		for key: Variant in wrapper_value["data"].get("dialogue_keys", []):
			_validate_localization_key(str(key), english, wrapper_value, issues)

	var placeholder_regex := RegEx.new()
	placeholder_regex.compile("\\{([a-z][a-z0-9_]*)\\}")
	for wrapper_value: Variant in records["dialogue"]:
		var dialogue: Dictionary = wrapper_value["data"]
		var expected: Array = dialogue.get("required_placeholders", []).duplicate()
		expected.sort()
		var actual: Array = []
		var text := str(english.get(dialogue.get("text_key", ""), ""))
		for match_value: RegExMatch in placeholder_regex.search_all(text):
			actual.append(match_value.get_string(1))
		actual.sort()
		if expected != actual:
			_add_issue(issues, "PLACEHOLDER_MISMATCH", wrapper_value["path"], dialogue.get("id", ""), "required_placeholders must match localized placeholders")


func _validate_required_request_graph(records: Dictionary, indices: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	var graph: Dictionary = {}
	for wrapper_value: Variant in records["requests"]:
		var request: Dictionary = wrapper_value["data"]
		if not bool(request.get("required", false)):
			continue
		var dependencies: Array = []
		for condition_value: Variant in request.get("unlock_conditions", []):
			if condition_value is Dictionary and condition_value.get("type") == "request_completed":
				dependencies.append(str(condition_value.get("request_id", "")))
		graph[request.get("id", "")] = dependencies

	var colors: Dictionary = {}
	for request_id: Variant in graph:
		_visit_required_request(str(request_id), graph, colors, indices["requests"], issues)

	for era_wrapper_value: Variant in records["eras"]:
		var era_wrapper: Dictionary = era_wrapper_value
		var era: Dictionary = era_wrapper["data"]
		var required_wrappers: Array = []
		for request_id: Variant in era.get("request_ids", []):
			var request_wrapper: Variant = (indices["requests"] as Dictionary).get(str(request_id))
			if request_wrapper is Dictionary and bool(request_wrapper["data"].get("required", false)):
				required_wrappers.append(request_wrapper)
		required_wrappers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["data"].get("sequence", 0)) < int(b["data"].get("sequence", 0)))
		var era_required_ids: Dictionary = {}
		for request_wrapper: Dictionary in required_wrappers:
			era_required_ids[request_wrapper["data"].get("id", "")] = true
		var reachable: Dictionary = {}
		for request_wrapper: Dictionary in required_wrappers:
			var request: Dictionary = request_wrapper["data"]
			var blocked := false
			for condition_value: Variant in request.get("unlock_conditions", []):
				if condition_value is Dictionary and condition_value.get("type") == "request_completed":
					var dependency := str(condition_value.get("request_id", ""))
					if era_required_ids.has(dependency) and not reachable.has(dependency):
						blocked = true
			if blocked:
				_add_issue(issues, "UNREACHABLE_MAIN_PATH", request_wrapper["path"], request.get("id", ""), "required request is not reachable in era sequence")
			else:
				reachable[request.get("id", "")] = true


func _visit_required_request(request_id: String, graph: Dictionary, colors: Dictionary, wrappers: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	var color := int(colors.get(request_id, 0))
	if color == 2:
		return
	if color == 1:
		var wrapper: Dictionary = wrappers.get(request_id, {"path": "res://data", "data": {"id": request_id}})
		_add_issue(issues, "CIRCULAR_REQUIRED_UNLOCK", wrapper["path"], request_id, "required request dependency cycle detected")
		return
	colors[request_id] = 1
	for dependency: Variant in graph.get(request_id, []):
		if graph.has(str(dependency)):
			_visit_required_request(str(dependency), graph, colors, wrappers, issues)
	colors[request_id] = 2


func _validate_conditions(value: Variant, indices: Dictionary, wrapper: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	if not value is Array:
		return
	for condition_value: Variant in value:
		if not condition_value is Dictionary:
			_add_issue(issues, "INVALID_TYPE", wrapper["path"], wrapper["data"].get("id", ""), "unlock conditions must be objects")
			continue
		var condition: Dictionary = condition_value
		var condition_type := str(condition.get("type", ""))
		if condition_type not in CONDITION_TYPES:
			_add_issue(issues, "UNSUPPORTED_CONDITION", wrapper["path"], wrapper["data"].get("id", ""), "unsupported unlock condition '%s'" % condition_type)
			continue
		match condition_type:
			"request_completed":
				_validate_reference(str(condition.get("request_id", "")), "requests", indices, wrapper, "unlock request_id", issues)
			"infrastructure_owned":
				_validate_reference(str(condition.get("infrastructure_id", "")), "infrastructure", indices, wrapper, "unlock infrastructure_id", issues)
				if int(condition.get("amount", 0)) <= 0:
					_add_issue(issues, "IMPOSSIBLE_UNLOCK", wrapper["path"], wrapper["data"].get("id", ""), "infrastructure amount must be positive")
			"upgrade_owned":
				_validate_reference(str(condition.get("upgrade_id", "")), "upgrades", indices, wrapper, "unlock upgrade_id", issues)
				if int(condition.get("level", 0)) <= 0:
					_add_issue(issues, "IMPOSSIBLE_UNLOCK", wrapper["path"], wrapper["data"].get("id", ""), "upgrade level must be positive")
			"era_unlocked":
				_validate_reference(str(condition.get("era_id", "")), "eras", indices, wrapper, "unlock era_id", issues)


func _validate_trigger(wrapper: Dictionary, indices: Dictionary, issues: Array[ContentValidationIssue], field: String = "trigger") -> void:
	var record: Dictionary = wrapper["data"]
	var trigger_value: Variant = record.get(field, {})
	if not trigger_value is Dictionary:
		return
	var trigger: Dictionary = trigger_value
	var trigger_type := str(trigger.get("type", ""))
	if trigger_type == "request_completed":
		_validate_reference(str(trigger.get("target_id", "")), "requests", indices, wrapper, "%s target_id" % field, issues)
	elif trigger_type == "request_elapsed" and field == "trigger":
		_validate_reference(str(trigger.get("target_id", "")), "requests", indices, wrapper, "%s target_id" % field, issues)
		if not _is_number(trigger.get("at_seconds")) or float(trigger.get("at_seconds", -1.0)) < 0.0:
			_add_issue(issues, "INVALID_VALUE", wrapper["path"], record.get("id", ""), "request_elapsed at_seconds must be nonnegative")
		if not _is_number(trigger.get("chance")) or float(trigger.get("chance", -1.0)) < 0.0 or float(trigger.get("chance", 2.0)) > 1.0:
			_add_issue(issues, "INVALID_VALUE", wrapper["path"], record.get("id", ""), "request_elapsed chance must be between 0 and 1")
	else:
		_add_issue(issues, "UNSUPPORTED_TRIGGER", wrapper["path"], record.get("id", ""), "unsupported %s type '%s'" % [field, trigger_type])


func _validate_demand_profile(record: Dictionary, path: String, record_id: String, issues: Array[ContentValidationIssue]) -> void:
	var duration := float(record.get("duration_seconds", -1.0))
	if duration <= 0.0:
		_add_issue(issues, "INVALID_VALUE", path, record_id, "duration_seconds must be positive")
	var keyframes_value: Variant = record.get("keyframes", [])
	if not keyframes_value is Array or keyframes_value.is_empty():
		_add_issue(issues, "INVALID_DEMAND_PROFILE", path, record_id, "keyframes must not be empty")
		return
	var previous_time := -1.0
	for keyframe_value: Variant in keyframes_value:
		if not keyframe_value is Dictionary:
			_add_issue(issues, "INVALID_DEMAND_PROFILE", path, record_id, "keyframes must be objects")
			continue
		var keyframe: Dictionary = keyframe_value
		_require_fields(keyframe, {"time_seconds": "number", "multiplier": "number"}, path, record_id, issues)
		var time := float(keyframe.get("time_seconds", -1.0))
		if time < 0.0 or time <= previous_time or time > duration:
			_add_issue(issues, "INVALID_DEMAND_PROFILE", path, record_id, "keyframe times must be ordered, unique, and within duration")
		if float(keyframe.get("multiplier", -1.0)) < 0.0:
			_add_issue(issues, "INVALID_DEMAND_PROFILE", path, record_id, "keyframe multiplier must be nonnegative")
		previous_time = time
	if float(keyframes_value[0].get("time_seconds", -1.0)) != 0.0:
		_add_issue(issues, "INVALID_DEMAND_PROFILE", path, record_id, "first keyframe must start at zero")


func _validate_effects(value: Variant, path: String, record_id: String, issues: Array[ContentValidationIssue]) -> void:
	if not value is Array:
		return
	for effect_value: Variant in value:
		if not effect_value is Dictionary:
			_add_issue(issues, "INVALID_TYPE", path, record_id, "effects must be objects")
			continue
		var effect: Dictionary = effect_value
		_require_fields(effect, {"operation": "string", "target": "string", "value": "number"}, path, record_id, issues)
		_validate_enum(effect.get("operation"), EFFECT_OPERATIONS, "UNSUPPORTED_EFFECT_OPERATION", path, record_id, "effect operation", issues)
		_validate_enum(effect.get("target"), EFFECT_TARGETS, "UNSUPPORTED_EFFECT_TARGET", path, record_id, "effect target", issues)
		var target := str(effect.get("target", ""))
		if target == "category_output":
			if not effect.get("category") is String or str(effect.get("category", "")) not in CATEGORIES:
				_add_issue(issues, "INVALID_VALUE", path, record_id, "category_output requires a supported category")
		elif target == "tag_output":
			if not effect.get("tag") is String or str(effect.get("tag", "")).is_empty():
				_add_issue(issues, "INVALID_VALUE", path, record_id, "tag_output requires a non-empty tag")
		if target in ["category_output", "tag_output", "global_output"] and str(effect.get("operation", "")) != "multiply":
			_add_issue(issues, "INVALID_VALUE", path, record_id, "%s only supports multiply" % target)
		if _is_number(effect.get("value")) and float(effect.get("value")) < 0.0:
			_add_issue(issues, "NEGATIVE_VALUE", path, record_id, "effect value must be nonnegative")


func _validate_allocation_modes(value: Variant, path: String, record_id: String, issues: Array[ContentValidationIssue]) -> void:
	if not value is Dictionary:
		return
	for mode: String in ["expand_grid", "balanced", "feed_watt"]:
		if not value.has(mode) or not value[mode] is Dictionary:
			_add_issue(issues, "MISSING_ALLOCATION_MODE", path, record_id, "allocation mode '%s' is required" % mode)
			continue
		var shares: Dictionary = value[mode]
		_require_fields(shares, {"grid_share": "number", "watt_share": "number"}, path, record_id, issues)
		var grid_share := float(shares.get("grid_share", -1.0))
		var watt_share := float(shares.get("watt_share", -1.0))
		if grid_share < 0.0 or watt_share < 0.0 or not is_equal_approx(grid_share + watt_share, 1.0):
			_add_issue(issues, "INVALID_ALLOCATION_MODE", path, record_id, "allocation shares for '%s' must be nonnegative and total 1" % mode)


func _validate_base_effects(value: Variant, path: String, record_id: String, issues: Array[ContentValidationIssue]) -> void:
	if not value is Dictionary:
		return
	for target: Variant in value:
		if str(target) not in BASE_EFFECT_TARGETS:
			_add_issue(issues, "UNSUPPORTED_EFFECT_TARGET", path, record_id, "unsupported base effect target '%s'" % target)
		if not _is_number(value[target]) or float(value[target]) < 0.0:
			_add_issue(issues, "INVALID_VALUE", path, record_id, "base effect '%s' must be nonnegative" % target)


func _validate_asset(asset_path: String, path: String, record_id: String, placeholders: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	if FileAccess.file_exists(asset_path) or ResourceLoader.exists(asset_path):
		return
	if placeholders.has(asset_path):
		placeholders[asset_path] = true
		return
	_add_issue(issues, "MISSING_ASSET", path, record_id, "asset '%s' does not exist and has no explicit exception" % asset_path)


func _validate_id_list(value: Variant, family: String, indices: Dictionary, wrapper: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	if not value is Array:
		return
	var seen: Dictionary = {}
	for target_id: Variant in value:
		if seen.has(str(target_id)):
			_add_issue(issues, "DUPLICATE_REFERENCE", wrapper["path"], wrapper["data"].get("id", ""), "duplicate %s reference '%s'" % [family, target_id])
		seen[str(target_id)] = true
		_validate_reference(str(target_id), family, indices, wrapper, "%s ID" % family, issues)


func _validate_reference(target_id: String, family: String, indices: Dictionary, wrapper: Dictionary, field: String, issues: Array[ContentValidationIssue]) -> void:
	if target_id.is_empty() or not (indices[family] as Dictionary).has(target_id):
		_add_issue(issues, "BROKEN_REFERENCE", wrapper["path"], wrapper["data"].get("id", ""), "%s references unknown %s '%s'" % [field, family, target_id])


func _validate_localization_key(key: String, english: Dictionary, wrapper: Dictionary, issues: Array[ContentValidationIssue]) -> void:
	if key.is_empty() or not english.has(key):
		_add_issue(issues, "MISSING_LOCALIZATION_KEY", wrapper["path"], wrapper["data"].get("id", ""), "English key '%s' is missing" % key)


func _validate_enum(value: Variant, allowed: Array, code: String, path: String, record_id: String, label: String, issues: Array[ContentValidationIssue]) -> void:
	if value not in allowed:
		_add_issue(issues, code, path, record_id, "unsupported %s '%s'" % [label, value])


func _validate_nonnegative(record: Dictionary, fields: Array, path: String, record_id: String, issues: Array[ContentValidationIssue]) -> void:
	for field: Variant in fields:
		if not _is_number(record.get(field)) or float(record.get(field, -1.0)) < 0.0:
			_add_issue(issues, "NEGATIVE_VALUE", path, record_id, "%s must be nonnegative" % field)


func _validate_nonnegative_tree(value: Variant, path: String, record_id: String, issues: Array[ContentValidationIssue], field_path: String = "") -> void:
	if value is Dictionary:
		for key: Variant in value:
			if key == "id":
				continue
			_validate_nonnegative_tree(value[key], path, record_id, issues, "%s.%s" % [field_path, key])
	elif value is Array:
		for index: int in value.size():
			_validate_nonnegative_tree(value[index], path, record_id, issues, "%s[%d]" % [field_path, index])
	elif _is_number(value) and float(value) < 0.0:
		_add_issue(issues, "NEGATIVE_BALANCE_VALUE", path, record_id, "%s must be nonnegative" % field_path.trim_prefix("."))


func _require_fields(record: Dictionary, fields: Dictionary, path: String, record_id: String, issues: Array[ContentValidationIssue]) -> void:
	for field: Variant in fields:
		if not record.has(field):
			_add_issue(issues, "MISSING_FIELD", path, record_id, "required field '%s' is missing" % field)
			continue
		if not _matches_type(record[field], str(fields[field])):
			_add_issue(issues, "INVALID_TYPE", path, record_id, "field '%s' must be %s" % [field, fields[field]])


func _matches_type(value: Variant, expected: String) -> bool:
	match expected:
		"string": return value is String
		"integer": return _is_integer(value)
		"number": return _is_number(value)
		"boolean": return value is bool
		"array": return value is Array
		"dictionary": return value is Dictionary
	return false


func _is_integer(value: Variant) -> bool:
	if not _is_number(value):
		return false
	return is_equal_approx(float(value), floorf(float(value)))


func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _add_issue(issues: Array[ContentValidationIssue], code: String, path: String, record_id: Variant, message: String) -> void:
	issues.append(ContentValidationIssue.new(code, path, str(record_id), message))
