extends SceneTree

const TOLERANCE := 0.000001

var _repository: ContentRepository
var _balance: BalanceDefinition
var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_repository = ContentRepository.new()
	var load_result := _repository.load_from_manifest("res://tests/fixtures/content/valid_manifest.json")
	_check(load_result.is_ok(), "content fixture must load before simulation tests")
	_balance = _repository.get_balance("prototype_balance")
	_check(_balance != null, "prototype balance must be available")
	if _balance != null:
		_test_generation_limit()
		_test_transmission_limit()
		_test_reserve_charge()
		_test_reserve_discharge_and_brownout()
		_test_stored_energy_and_allocation()
		_test_stability_and_invariants()
		_test_fixed_step_equivalence()
		_test_seeded_repeatability()
		_test_infrastructure_aggregation()

	if _failures.is_empty():
		print("GRID SIMULATION TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("GRID SIMULATION TEST FAILED: %s" % failure)
	quit(1)


func _test_generation_limit() -> void:
	var simulation := _new_simulation()
	_check(simulation.reset_scenario(_grid(5, 12), 0), "generation scenario reset")
	_check(simulation.advance_time(0.25), "generation scenario advances")
	var result := simulation.get_last_result()
	_check_near(result.deliverable_power, 5.0, "generation limits deliverable power")
	_check(result.limiting_constraint == "generation", "generation is identified as limiting")
	_check(result.deliverable_power <= simulation.state.generation_rate and result.deliverable_power <= simulation.state.transmission_capacity, "delivered power respects both caps")


func _test_transmission_limit() -> void:
	var simulation := _new_simulation()
	simulation.reset_scenario(_grid(15, 6), 0)
	simulation.advance_time(0.25)
	var result := simulation.get_last_result()
	_check_near(result.deliverable_power, 6.0, "transmission limits deliverable power")
	_check(result.limiting_constraint == "transmission", "transmission is identified as limiting")


func _test_reserve_charge() -> void:
	var simulation := _new_simulation()
	simulation.reset_scenario(_grid(10, 10, 10, 3, 5), 2, 0)
	simulation.set_allocation_mode("balanced")
	simulation.advance_time(1.0)
	var result := simulation.get_last_result()
	_check_near(result.surplus_power, 8.0, "surplus is deliverable minus demand")
	_check_near(result.grid_power, 4.0, "balanced grid share receives half of surplus")
	_check_near(result.reserve_charge_power, 3.0, "reserve charge obeys charge-rate limit")
	_check_near(simulation.state.reserve_stored, 3.0, "reserve stores eligible charge energy")
	_check_near(simulation.state.stored_energy, 1.0, "grid power remaining after charge becomes Stored Energy")

	var no_surplus := _new_simulation()
	no_surplus.reset_scenario(_grid(10, 10, 10, 5, 5), 10, 0)
	no_surplus.advance_time(1.0)
	_check_near(no_surplus.state.reserve_stored, 0.0, "reserve does not charge without eligible surplus")


func _test_reserve_discharge_and_brownout() -> void:
	var protected := _new_simulation()
	protected.reset_scenario(_grid(10, 10, 10, 5, 5), 14, 10)
	protected.advance_time(1.0)
	var protected_result := protected.get_last_result()
	_check_near(protected_result.reserve_discharge_power, 4.0, "reserve covers a peak within discharge limit")
	_check_near(protected_result.unmet_power, 0.0, "covered peak has no deficit")
	_check(not protected_result.brownout_active, "covered peak does not brown out")

	var brownout := _new_simulation()
	brownout.reset_scenario(_grid(10, 10, 10, 5, 5), 20, 10)
	brownout.state.stored_energy = 42.0
	brownout.advance_time(0.25)
	var result := brownout.get_last_result()
	_check_near(result.reserve_discharge_power, 5.0, "reserve discharge obeys power limit")
	_check_near(result.unmet_power, 5.0, "remaining deficit is reported")
	_check(result.brownout_active, "remaining deficit starts brownout")
	_check(_has_event(brownout.drain_events(), GridEvent.BROWNOUT_STARTED), "brownout start event fires once")
	brownout.advance_time(0.25)
	_check(not _has_event(brownout.drain_events(), GridEvent.BROWNOUT_STARTED), "ongoing brownout does not repeat start event")
	_check_near(brownout.state.stored_energy, 42.0, "brownout does not remove Stored Energy")
	_check_near(brownout.state.generation_rate, 10.0, "brownout does not remove infrastructure aggregates")
	brownout.set_demand_rate(5)
	brownout.advance_time(0.25)
	_check(_has_event(brownout.drain_events(), GridEvent.BROWNOUT_ENDED), "brownout recovery fires end event")
	_check(not brownout.state.brownout_active, "brownout state clears after recovery")


func _test_stored_energy_and_allocation() -> void:
	var expand := _new_simulation()
	expand.reset_scenario(_grid(10, 10, 10, 5, 5), 0, 10)
	expand.set_allocation_mode("expand_grid")
	expand.advance_time(1.0)
	var expand_result := expand.get_last_result()
	_check_near(expand_result.watt_power, 2.0, "Expand Grid sends 20 percent to WATT")
	_check_near(expand_result.stored_energy_rate, 8.0, "Expand Grid converts 80 percent at Era 1 efficiency")

	var feed := _new_simulation()
	feed.reset_scenario(_grid(10, 10, 10, 5, 5), 0, 10)
	feed.set_allocation_mode("feed_watt")
	feed.advance_time(1.0)
	var feed_result := feed.get_last_result()
	_check_near(feed_result.watt_power, 9.0, "Feed WATT sends 90 percent to WATT")
	_check_near(feed_result.stored_energy_rate, 1.0, "Feed WATT leaves 10 percent for Stored Energy")
	_check(expand_result.stored_energy_rate > feed_result.stored_energy_rate, "allocation changes expected Stored Energy rate")
	_check(feed_result.watt_power > expand_result.watt_power, "allocation changes expected WATT rate")
	_check(not feed.set_allocation_mode("unsupported"), "unsupported allocation mode is rejected")


func _test_stability_and_invariants() -> void:
	var simulation := _new_simulation()
	simulation.reset_scenario(_grid(1, 1, 2, 1, 1), 100, 0)
	simulation.advance_time(5.0)
	_check(simulation.state.stability >= 0.0 and simulation.state.stability <= 100.0, "stability stays within 0 to 100")
	_check(simulation.state.reserve_stored >= 0.0 and simulation.state.reserve_stored <= simulation.state.reserve_capacity, "reserve remains within capacity")
	_check(simulation.state.stored_energy >= 0.0, "Stored Energy remains nonnegative")
	_check(not simulation.set_demand_rate(-1), "negative demand command is rejected")
	_check(not simulation.set_grid_values({"generation_rate": -1}), "negative grid command is rejected")
	_check(not simulation.set_grid_values({"generation_rate": INF}), "infinite grid command is rejected")
	_check(not simulation.advance_time(-1), "negative time advancement is rejected")
	_check(not simulation.advance_time(INF), "infinite time advancement is rejected")
	_check(not simulation.advance_time(GridSimulation.MAX_ACTIVE_ADVANCE_SECONDS + 1), "overflow-sized active advancement is rejected")
	simulation.state.reserve_stored = INF
	simulation.state.stored_energy = NAN
	simulation.state.sanitize()
	_check(is_finite(simulation.state.reserve_stored) and simulation.state.reserve_stored <= simulation.state.reserve_capacity, "non-finite Reserve is sanitized")
	_check(is_finite(simulation.state.stored_energy) and simulation.state.stored_energy >= 0.0, "non-finite Stored Energy is sanitized")


func _test_fixed_step_equivalence() -> void:
	var large := _new_simulation(77)
	var small := _new_simulation(77)
	var values := _grid(18, 15, 20, 4, 6)
	large.reset_scenario(values, 12, 3)
	small.reset_scenario(values, 12, 3)
	large.set_allocation_mode("expand_grid")
	small.set_allocation_mode("expand_grid")
	_check(large.advance_time(20.0), "large delta is accepted")
	for index: int in 80:
		_check(small.advance_time(0.25), "small delta %d is accepted" % index)
	_compare_states(large.state, small.state, "large and equivalent small deltas")

	var accumulated := _new_simulation()
	accumulated.reset_scenario(values, 12, 3)
	accumulated.advance_time(0.1)
	_check_near(accumulated.state.elapsed_seconds, 0.0, "partial delta waits in accumulator")
	accumulated.advance_time(0.15)
	_check_near(accumulated.state.elapsed_seconds, 0.25, "partial deltas produce one fixed step")


func _test_seeded_repeatability() -> void:
	var first := _new_simulation(12345)
	var second := _new_simulation(12345)
	first.reset_scenario(_grid(9, 7, 8, 2, 3), 11, 6)
	second.reset_scenario(_grid(9, 7, 8, 2, 3), 11, 6)
	for delta: float in [0.25, 1.0, 2.5, 0.5]:
		first.advance_time(delta)
		second.advance_time(delta)
	_compare_states(first.state, second.state, "repeated seeded runs")
	_check(first.seed == second.seed, "simulation seed is retained")


func _test_infrastructure_aggregation() -> void:
	var aggregate := InfrastructureAggregator.rebuild(
		{"wall_outlet": 3},
		_repository,
		{"transmission_capacity": 8, "reserve_capacity": 10, "reserve_charge_rate": 5, "reserve_discharge_rate": 5}
	)
	_check(bool(aggregate["ok"]), "valid owned infrastructure aggregates")
	_check_near(float(aggregate["values"]["generation_rate"]), 15.0, "owned definitions rebuild Generation")
	_check_near(float(aggregate["values"]["transmission_capacity"]), 8.0, "base Transmission survives rebuild")
	var invalid := InfrastructureAggregator.rebuild({"unknown_item": 1}, _repository)
	_check(not bool(invalid["ok"]), "unknown owned infrastructure fails rebuild")
	var negative := InfrastructureAggregator.rebuild({"wall_outlet": -1}, _repository)
	_check(not bool(negative["ok"]), "negative owned count fails rebuild")


func _new_simulation(simulation_seed: int = 1) -> GridSimulation:
	var simulation := GridSimulation.new()
	_check(simulation.configure(_balance, "era_01_cold_boot", simulation_seed), "simulation configures from balance data")
	return simulation


func _grid(generation: float, transmission: float, reserve_capacity: float = 0.0, charge_rate: float = 0.0, discharge_rate: float = 0.0) -> Dictionary:
	return {
		"generation_rate": generation,
		"transmission_capacity": transmission,
		"reserve_capacity": reserve_capacity,
		"reserve_charge_rate": charge_rate,
		"reserve_discharge_rate": discharge_rate,
		"stored_energy": 0,
	}


func _compare_states(first: GridState, second: GridState, label: String) -> void:
	var first_snapshot := first.snapshot()
	var second_snapshot := second.snapshot()
	for key: Variant in first_snapshot:
		if first_snapshot[key] is bool or first_snapshot[key] is String:
			_check(first_snapshot[key] == second_snapshot[key], "%s: %s matches" % [label, key])
		else:
			_check_near(float(first_snapshot[key]), float(second_snapshot[key]), "%s: %s matches" % [label, key])


func _has_event(events: Array[GridEvent], type: String) -> bool:
	for event: GridEvent in events:
		if event.type == type:
			return true
	return false


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= TOLERANCE, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
