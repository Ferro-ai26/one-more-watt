extends SceneTree

const MANIFEST := "res://data/manifest.json"
const CASES := [
	{"name": "invalid JSON", "source": "res://data/requests/era_01_requests.json", "fixture": "res://tests/fixtures/content/invalid_json.json", "code": "INVALID_JSON"},
	{"name": "duplicate ID", "source": "res://data/infrastructure/infrastructure.json", "fixture": "res://tests/fixtures/content/duplicate_id.json", "code": "DUPLICATE_ID"},
	{"name": "broken reference", "source": "res://data/requests/era_01_requests.json", "fixture": "res://tests/fixtures/content/broken_reference.json", "code": "BROKEN_REFERENCE"},
	{"name": "missing localization", "source": "res://data/localization/en.json", "fixture": "res://tests/fixtures/content/missing_localization.json", "code": "MISSING_LOCALIZATION_KEY"},
	{"name": "negative balance", "source": "res://data/balance/constants.json", "fixture": "res://tests/fixtures/content/negative_balance.json", "code": "NEGATIVE_BALANCE_VALUE"},
	{"name": "circular required unlock", "source": "res://data/requests/era_01_requests.json", "fixture": "res://tests/fixtures/content/circular_requests.json", "code": "CIRCULAR_REQUIRED_UNLOCK"},
	{"name": "unsupported effect", "source": "res://data/upgrades/upgrades.json", "fixture": "res://tests/fixtures/content/unsupported_effect.json", "code": "UNSUPPORTED_EFFECT_OPERATION"},
	{"name": "unsupported category", "source": "res://data/infrastructure/infrastructure.json", "fixture": "res://tests/fixtures/content/invalid_category.json", "code": "UNSUPPORTED_CATEGORY"},
	{"name": "unlisted missing asset", "source": "res://data/infrastructure/infrastructure.json", "fixture": "res://tests/fixtures/content/missing_asset.json", "code": "MISSING_ASSET"},
	{"name": "unknown reward", "source": "res://data/requests/era_01_requests.json", "fixture": "res://tests/fixtures/content/unknown_reward.json", "code": "UNKNOWN_REWARD_TARGET"},
	{"name": "invalid demand profile", "source": "res://data/requests/demand_profiles.json", "fixture": "res://tests/fixtures/content/invalid_demand_profile.json", "code": "INVALID_DEMAND_PROFILE"},
	{"name": "missing required field", "source": "res://data/dialogue/system_dialogue.json", "fixture": "res://tests/fixtures/content/missing_field.json", "code": "MISSING_FIELD"},
]

var _failures: Array[String] = []


func _init() -> void:
	for case: Dictionary in CASES:
		var repository := ContentRepository.new()
		var result := repository.load_from_manifest(MANIFEST, {case["source"]: case["fixture"]})
		if result.is_ok() or repository.is_loaded():
			_failures.append("%s fixture unexpectedly loaded" % case["name"])
			continue
		if not result.has_code(case["code"]):
			_failures.append("%s fixture did not report %s; got %s" % [case["name"], case["code"], _codes(result.issues)])
			continue
		var matching_issue := _find_issue(result.issues, case["code"])
		if matching_issue.path.is_empty() or (case["code"] != "INVALID_JSON" and matching_issue.record_id.is_empty()):
			_failures.append("%s fixture did not include a clear file and record location" % case["name"])
			continue
		print("INVALID CONTENT: %s passed with %s" % [case["name"], case["code"]])

	if _failures.is_empty():
		print("INVALID CONTENT TESTS PASSED: %d fixtures" % CASES.size())
		quit(0)
		return
	for failure: String in _failures:
		printerr("INVALID CONTENT TEST FAILED: %s" % failure)
	quit(1)


func _codes(issues: Array[ContentValidationIssue]) -> String:
	var codes: PackedStringArray = []
	for issue: ContentValidationIssue in issues:
		codes.append(issue.code)
	return ", ".join(codes)


func _find_issue(issues: Array[ContentValidationIssue], code: String) -> ContentValidationIssue:
	for issue: ContentValidationIssue in issues:
		if issue.code == code:
			return issue
	return null
