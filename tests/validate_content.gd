extends SceneTree

var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	var repository := ContentRepository.new()
	var result := repository.load_from_manifest("res://tests/fixtures/content/valid_manifest.json")
	_check(result.is_ok(), "valid fixture should load: %s" % _format_issues(result.issues))
	_check(repository.is_loaded(), "repository should report loaded")
	_check(repository.get_content_version() == "fixture-valid-1", "fixture content version should be exposed")
	_check(repository.get_schema_version() == 1, "schema version should be exposed")

	var counts := repository.get_counts()
	var expected_counts := {
		"balance": 1, "eras": 5, "infrastructure": 32, "upgrades": 13,
		"requests": 32, "demand_profiles": 16, "dialogue": 17, "maintenance": 4,
		"incidents": 2, "achievements": 1, "localization": 1,
	}
	for family: String in expected_counts:
		_check(counts.get(family) == expected_counts[family], "%s count should be %d" % [family, expected_counts[family]])

	var era := repository.get_era("era_01_cold_boot")
	var infrastructure := repository.get_infrastructure("wall_outlet")
	var upgrade := repository.get_upgrade("dedicated_circuit_research")
	var request := repository.get_request("era01_finish_booting")
	var profile := repository.get_demand_profile("steady_boot")
	_check(era is EraDefinition and era.get_number() == 1, "typed era lookup should work")
	_check(infrastructure is InfrastructureDefinition and infrastructure.get_category() == "generation", "typed infrastructure lookup should work")
	_check(upgrade is UpgradeDefinition and upgrade.get_effects().size() == 1, "typed upgrade lookup should work")
	_check(repository.get_upgrade("outlet_calibration") is UpgradeDefinition, "leveled upgrade lookup should work")
	_check(request is RequestDefinition and request.get_required_energy() == 125.0, "typed request lookup should work")
	_check(profile is DemandProfileDefinition and profile.get_duration_seconds() == 15.0, "typed demand profile lookup should work")
	_check(repository.get_dialogue("content_ready") is DialogueDefinition, "typed dialogue lookup should work")
	_check(repository.get_incident("helpful_cool_breeze") is IncidentDefinition, "typed incident lookup should work")
	_check(repository.get_achievement("first_boot") is AchievementDefinition, "typed achievement lookup should work")
	_check(repository.get_balance("prototype_balance") is BalanceDefinition, "typed balance lookup should work")
	_check(repository.get_maintenance("era04_transformer_thermal_review") is MaintenanceDefinition, "typed maintenance lookup should work")
	_check(repository.get_localization() is LocalizationDefinition, "typed localization lookup should work")
	_check(repository.localize(request.get_title_key()) == "Finish Booting", "localized request title should match source")
	_check(repository.localize("dialogue.system.content_ready", {"content_version": "fixture-valid-1"}) == "Content database fixture-valid-1 is ready.", "named localization replacements should resolve")
	_check(repository.localize("dialogue.system.content_ready") == "[format-error:dialogue.system.content_ready]", "missing replacements should fail safely")

	var exported := request.to_dictionary()
	exported["required_energy"] = 999
	_check(request.get_required_energy() == 125.0, "exported dictionaries must not mutate definitions")
	var request_list := repository.get_all("requests")
	request_list.clear()
	_check(repository.get_counts()["requests"] == 32, "returned arrays must not mutate repository indices")

	if _failures.is_empty():
		print("CONTENT VALIDATION PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("CONTENT VALIDATION FAILED: %s" % failure)
	quit(1)


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)


func _format_issues(issues: Array[ContentValidationIssue]) -> String:
	var formatted: PackedStringArray = []
	for issue: ContentValidationIssue in issues:
		formatted.append(issue.format())
	return "; ".join(formatted)
