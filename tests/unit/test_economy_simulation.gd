extends SceneTree

const TOLERANCE := 0.000001

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_repository = ContentRepository.new()
	var load_result := _repository.load_from_manifest("res://tests/fixtures/content/valid_manifest.json")
	_check(load_result.is_ok(), "content fixture loads before economy tests")
	if load_result.is_ok():
		_test_all_definitions_interpretable()
		_test_single_and_bulk_costs()
		_test_atomic_purchase_and_preview()
		_test_locked_and_unaffordable_states()
		_test_milestone_threshold_and_event_once()
		_test_upgrade_levels_and_multiplier_stacking()
		_test_tag_multiplier_and_cross_era_rebuild()
		_test_derived_rebuild_equivalence()
		_test_reserve_automation()

	if _failures.is_empty():
		print("ECONOMY SIMULATION TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ECONOMY SIMULATION TEST FAILED: %s" % failure)
	quit(1)


func _test_all_definitions_interpretable() -> void:
	var owned: Dictionary = {}
	for definition_value: Variant in _repository.get_all("infrastructure"):
		var definition := definition_value as InfrastructureDefinition
		owned[definition.get_id()] = 1
	var levels: Dictionary = {}
	for upgrade_value: Variant in _repository.get_all("upgrades"):
		var upgrade := upgrade_value as UpgradeDefinition
		levels[upgrade.get_id()] = int(upgrade.get_value("max_level", 1))
	var result := InfrastructureAggregator.rebuild(owned, _repository, {}, _repository.get_balance("prototype_balance"), levels)
	_check(_repository.get_counts()["infrastructure"] == 32, "all thirty-two Eras 1-5 infrastructure definitions load")
	_check(bool(result["ok"]), "all Eras 1-5 infrastructure and upgrade effects are interpretable")
	_check(float(result["values"]["generation_rate"]) > 0.0, "cross-era rebuild produces Generation")
	_check(float(result["values"]["transmission_capacity"]) > 0.0, "cross-era rebuild produces Transmission")
	_check(float(result["values"]["reserve_capacity"]) > 0.0, "cross-era rebuild produces Reserve")
	_check(not is_equal_approx(float(result["values"]["request_demand_multiplier"]), 1.0), "stacked request-demand modifiers are interpreted")


func _test_single_and_bulk_costs() -> void:
	var outlet := _repository.get_infrastructure("wall_outlet")
	_check_near(EconomyCalculator.infrastructure_cost(outlet, 1, 1), 11.0, "single cost uses documented floor")
	_check_near(EconomyCalculator.infrastructure_cost(outlet, 1, 3), 39.0, "bulk cost sums individually floored sequential costs")
	var sequential := 0.0
	for owned_count: int in range(1, 4):
		sequential += EconomyCalculator.infrastructure_cost(outlet, owned_count, 1)
	_check_near(EconomyCalculator.infrastructure_cost(outlet, 1, 3), sequential, "bulk and sequential totals are exact")
	_check(EconomyCalculator.infrastructure_cost(outlet, 1, 0) < 0.0, "zero-sized bulk request is invalid")


func _test_atomic_purchase_and_preview() -> void:
	var economy := _new_economy()
	_check(int(economy.state.owned.get("wall_outlet", 0)) == 1, "starting Wall Outlet is explicit ownership")
	_check_near(economy.grid.state.generation_rate, 5.0, "starting ownership is not double counted")
	economy.set_stored_energy(1000.0)
	var cases := [
		{"id": "wall_outlet", "key": "generation_rate", "delta": 5.0},
		{"id": "questionable_power_strip", "key": "transmission_capacity", "delta": 18.0},
		{"id": "laptop_battery", "key": "reserve_capacity", "delta": 30.0},
	]
	for case: Dictionary in cases:
		var preview := economy.preview_infrastructure(case["id"])
		_check(preview.status == EconomyPreview.AFFORDABLE, "%s preview is affordable" % case["id"])
		_check_near(float(preview.deltas[case["key"]]), case["delta"], "%s preview predicts its primary effect" % case["id"])
		var expected_currency := economy.state.stored_energy - preview.cost
		var expected_value := float(preview.resulting_values[case["key"]])
		_check(economy.purchase_infrastructure(case["id"]), "%s purchase succeeds atomically" % case["id"])
		_check_near(economy.state.stored_energy, expected_currency, "%s subtracts exact preview cost" % case["id"])
		_check_near(float(economy.get_derived_values()[case["key"]]), expected_value, "%s resulting grid matches preview" % case["id"])
	_check(int(economy.state.owned["wall_outlet"]) == 2, "purchase increments ownership")
	_check_near(economy.grid.state.stored_energy, economy.state.stored_energy, "grid and economy currency remain synchronized")


func _test_locked_and_unaffordable_states() -> void:
	var economy := _new_economy()
	var locked := economy.preview_infrastructure("tiny_desk_fan")
	_check(locked.status == EconomyPreview.LOCKED and not locked.unmet_conditions.is_empty(), "locked item explains unmet condition")
	var era_locked := economy.preview_infrastructure("portable_generator")
	_check(era_locked.status == EconomyPreview.LOCKED and "era_unlocked:era_02_bedroom_assistant" in era_locked.unmet_conditions, "era lock is distinct and explicit")
	var unavailable_before := economy.state.snapshot()
	_check(not economy.purchase_infrastructure("tiny_desk_fan"), "locked purchase is rejected")
	_check(economy.state.snapshot() == unavailable_before, "locked rejection makes no mutation")
	var unaffordable := economy.preview_infrastructure("wall_outlet")
	_check(unaffordable.status == EconomyPreview.UNAFFORDABLE and unaffordable.missing_currency > 0.0, "unaffordable state is distinct from locked")
	var before := economy.state.snapshot()
	_check(not economy.purchase_infrastructure("wall_outlet"), "insufficient funds reject purchase")
	_check(economy.state.snapshot() == before, "insufficient funds make no mutation")
	economy.set_stored_energy(100.0)
	_check(economy.purchase_infrastructure("wall_outlet"), "prerequisite infrastructure purchase succeeds")
	_check(economy.preview_infrastructure("tiny_desk_fan").status == EconomyPreview.UNAFFORDABLE, "ownership dependency unlocks immediately and exposes affordability")
	economy.mark_request_completed("era01_understand_tuesdays")
	_check(economy.preview_infrastructure("extension_cord").status in [EconomyPreview.AFFORDABLE, EconomyPreview.UNAFFORDABLE], "request dependency evaluator unlocks stable ID")


func _test_milestone_threshold_and_event_once() -> void:
	var economy := _new_economy()
	economy.set_stored_energy(100000.0)
	economy.drain_events()
	_check(economy.purchase_infrastructure("wall_outlet", 8), "bulk purchase reaches nine owned")
	_check(int(economy.state.owned["wall_outlet"]) == 9, "bulk purchase stops immediately before milestone")
	_check_near(economy.grid.state.generation_rate, 45.0, "no milestone multiplier before exact threshold")
	_check(not _has_event(economy.drain_events(), EconomyEvent.MILESTONE_REACHED), "no early milestone event")
	var preview := economy.preview_infrastructure("wall_outlet")
	_check_near(float(preview.resulting_values["generation_rate"]), 100.0, "threshold preview includes cumulative milestone multiplier")
	_check(economy.purchase_infrastructure("wall_outlet"), "tenth item crosses milestone")
	_check_near(economy.grid.state.generation_rate, 100.0, "milestone effect occurs at exact threshold")
	var events := economy.drain_events()
	_check(_event_count(events, EconomyEvent.MILESTONE_REACHED) == 1, "milestone event occurs once on crossing")
	_check(economy.purchase_infrastructure("wall_outlet"), "post-milestone purchase succeeds")
	_check(_event_count(economy.drain_events(), EconomyEvent.MILESTONE_REACHED) == 0, "milestone event does not repeat")


func _test_upgrade_levels_and_multiplier_stacking() -> void:
	var economy := _new_economy()
	economy.set_stored_energy(100000.0)
	economy.purchase_infrastructure("wall_outlet", 9)
	economy.unlock_era("era_02_bedroom_assistant")
	economy.mark_request_completed("era02_organize_photographs")
	var direct_preview := economy.preview_upgrade("outlet_calibration")
	_check_near(direct_preview.cost, 50.0, "leveled upgrade first cost uses authored base")
	_check_near(float(direct_preview.resulting_values["generation_rate"]), 110.0, "direct multiplier stacks after milestone")
	_check(economy.purchase_upgrade("outlet_calibration"), "first leveled upgrade purchases")
	var category_preview := economy.preview_upgrade("generator_coordination")
	_check_near(float(category_preview.resulting_values["generation_rate"]), 132.0, "category and direct multiplier groups multiply")
	_check(economy.purchase_upgrade("generator_coordination"), "category upgrade purchases")
	_check_near(economy.grid.state.generation_rate, 132.0, "stacked preview equals resulting grid")
	_check(economy.purchase_upgrade("outlet_calibration"), "second leveled upgrade purchases")
	_check(economy.purchase_upgrade("outlet_calibration"), "third leveled upgrade purchases")
	var before := economy.state.snapshot()
	_check(economy.preview_upgrade("outlet_calibration").status == EconomyPreview.MAXED, "upgrade reports max level")
	_check(not economy.purchase_upgrade("outlet_calibration"), "upgrade max level rejects purchase")
	_check(economy.state.snapshot() == before, "max-level rejection makes no mutation")
	economy.mark_request_completed("era02_improve_loading_animation")
	_check(economy.purchase_upgrade("dedicated_circuit_research"), "one-time upgrade purchases")
	_check(economy.preview_upgrade("dedicated_circuit_research").status == EconomyPreview.MAXED, "one-time upgrade becomes completed")


func _test_tag_multiplier_and_cross_era_rebuild() -> void:
	var economy := _new_economy()
	economy.set_stored_energy(1000000.0)
	economy.unlock_era("era_03_home_server_closet")
	_check(economy.purchase_infrastructure("server_rack"), "Era 3 Compute infrastructure purchases")
	var before_cooling := economy.grid.state.generation_rate
	var preview := economy.preview_infrastructure("dedicated_cooling")
	_check_near(float(preview.resulting_values["generation_rate"]) - before_cooling, 500.0, "tag multiplier preview boosts existing Compute output by 20 percent")
	_check(economy.purchase_infrastructure("dedicated_cooling"), "tag support infrastructure purchases")
	_check_near(economy.grid.state.generation_rate, float(preview.resulting_values["generation_rate"]), "tag multiplier result matches preview")


func _test_derived_rebuild_equivalence() -> void:
	var economy := _new_economy()
	economy.set_stored_energy(50000.0)
	economy.purchase_infrastructure("wall_outlet", 3)
	economy.purchase_infrastructure("questionable_power_strip", 2)
	economy.purchase_upgrade("outlet_calibration")
	var expected := economy.get_derived_values()
	economy.grid.state.generation_rate = 999999.0
	economy.grid.state.transmission_capacity = 1.0
	_check(economy.rebuild_derived_state(), "derived state rebuild succeeds")
	var rebuilt := economy.get_derived_values()
	for key: Variant in expected:
		_check_near(float(rebuilt[key]), float(expected[key]), "rebuild equivalence for %s" % key)
	_check_near(economy.grid.state.generation_rate, float(expected["generation_rate"]), "grid cache is restored from ownership truth")


func _test_reserve_automation() -> void:
	var economy := _new_economy()
	_check(not economy.configure_reserve_automation(true, 0.5), "automation cannot enable without automation infrastructure")
	economy.set_stored_energy(100000.0)
	economy.unlock_era("era_03_home_server_closet")
	_check(economy.purchase_infrastructure("smart_meter"), "automation infrastructure purchases")
	_check(economy.configure_reserve_automation(false, 0.5), "automation can remain disabled with threshold configured")
	var disabled := economy.apply_safe_throttle(20.0)
	_check(bool(disabled["ok"]) and not bool(disabled["throttled"]) and is_equal_approx(disabled["demand_rate"], 20.0), "disabled automation never throttles")
	_check(economy.configure_reserve_automation(true, 0.5), "owned automation enables safely")
	economy.grid.state.reserve_stored = economy.grid.state.reserve_capacity * 0.1
	var enabled := economy.apply_safe_throttle(20.0)
	var deliverable := minf(economy.grid.state.generation_rate, economy.grid.state.transmission_capacity)
	_check(bool(enabled["throttled"]), "enabled automation throttles below threshold")
	_check_near(float(enabled["demand_rate"]), minf(20.0, deliverable), "safe throttle caps demand at deliverable power")
	economy.grid.state.reserve_stored = economy.grid.state.reserve_capacity
	var healthy := economy.apply_safe_throttle(20.0)
	_check(not bool(healthy["throttled"]) and is_equal_approx(healthy["demand_rate"], 20.0), "healthy Reserve bypasses throttle")
	_check(not economy.configure_reserve_automation(true, 1.1), "invalid automation threshold is rejected")


func _new_economy() -> EconomySimulation:
	var economy := EconomySimulation.new()
	_check(economy.configure(_repository), "economy configures from canonical content")
	economy.drain_events()
	return economy


func _has_event(events: Array[EconomyEvent], type: String) -> bool:
	return _event_count(events, type) > 0


func _event_count(events: Array[EconomyEvent], type: String) -> int:
	var count := 0
	for event: EconomyEvent in events:
		if event.type == type:
			count += 1
	return count


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= TOLERANCE, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
