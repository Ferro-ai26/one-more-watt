class_name GridSimulation
extends RefCounted

const MAX_ACTIVE_ADVANCE_SECONDS := 3600.0
const STEP_EPSILON := 0.000000001

var state := GridState.new()
var fixed_step_seconds := 0.25
var conversion_efficiency := 1.0
var seed := 0

var _allocation_modes: Dictionary = {}
var _accumulator_seconds := 0.0
var _events: Array[GridEvent] = []
var _last_result := GridStepResult.new()
var _allocation_override := ""


func configure(balance: BalanceDefinition, era_id: String = "era_01_cold_boot", simulation_seed: int = 0) -> bool:
	if balance == null:
		return false
	fixed_step_seconds = float(balance.get_value("simulation_step_seconds", 0.25))
	if fixed_step_seconds <= 0.0 or not is_finite(fixed_step_seconds):
		return false
	_allocation_modes = balance.get_value("allocation_modes", {}).duplicate(true)
	if not _allocation_modes.has("balanced"):
		return false
	var efficiencies: Dictionary = balance.get_value("stored_energy_efficiency", {})
	conversion_efficiency = clampf(float(efficiencies.get(era_id, 1.0)), 0.0, 1.0)
	seed = simulation_seed
	state = GridState.new()
	state.apply_grid_values(balance.get_value("starting_grid", {}))
	state.allocation_mode = "balanced"
	state.reset_statistics()
	_accumulator_seconds = 0.0
	_events.clear()
	_last_result = GridStepResult.new()
	return true


func set_grid_values(values: Dictionary) -> bool:
	for key: Variant in values:
		var value: Variant = values[key]
		if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)) or float(value) < 0.0:
			return false
	state.apply_grid_values(values)
	return true


func set_demand_rate(demand_rate: float) -> bool:
	if not is_finite(demand_rate) or demand_rate < 0.0:
		return false
	state.demand_rate = demand_rate
	state.sanitize()
	return true


func set_allocation_mode(mode: String) -> bool:
	if not _allocation_modes.has(mode):
		return false
	if state.allocation_mode == mode:
		return true
	state.allocation_mode = mode
	_events.append(GridEvent.new(GridEvent.ALLOCATION_CHANGED, state.elapsed_seconds, {"mode": mode}))
	return true


func set_allocation_override(mode: String = "") -> bool:
	if not mode.is_empty() and not _allocation_modes.has(mode):
		return false
	_allocation_override = mode
	return true


func reset_scenario(grid_values: Dictionary, demand_rate: float, reserve_stored: float = 0.0) -> bool:
	if not set_grid_values(grid_values) or not set_demand_rate(demand_rate):
		return false
	if not is_finite(reserve_stored) or reserve_stored < 0.0:
		return false
	state.reserve_stored = reserve_stored
	state.stored_energy = 0.0
	state.reset_statistics()
	state.sanitize()
	_accumulator_seconds = 0.0
	_events.clear()
	_last_result = GridStepResult.new()
	return true


func rebuild_aggregates(owned: Dictionary, repository: ContentRepository, base_values: Dictionary = {}) -> Dictionary:
	var aggregate := InfrastructureAggregator.rebuild(owned, repository, base_values)
	if bool(aggregate["ok"]):
		state.apply_grid_values(aggregate["values"])
	return aggregate


func advance_time(delta_seconds: float) -> bool:
	if not is_finite(delta_seconds) or delta_seconds < 0.0 or delta_seconds > MAX_ACTIVE_ADVANCE_SECONDS:
		return false
	_accumulator_seconds += delta_seconds
	while _accumulator_seconds + STEP_EPSILON >= fixed_step_seconds:
		_last_result = GridCalculator.step(state, _current_allocation(), conversion_efficiency, fixed_step_seconds)
		_accumulator_seconds -= fixed_step_seconds
		if _accumulator_seconds < STEP_EPSILON:
			_accumulator_seconds = 0.0
		if _last_result.brownout_started:
			_events.append(GridEvent.new(GridEvent.BROWNOUT_STARTED, state.elapsed_seconds, {"unmet_power": _last_result.unmet_power}))
		if _last_result.brownout_ended:
			_events.append(GridEvent.new(GridEvent.BROWNOUT_ENDED, state.elapsed_seconds))
	return true


func get_last_result() -> GridStepResult:
	return _last_result


func get_accumulator_seconds() -> float:
	return _accumulator_seconds


func get_allocation() -> Dictionary:
	return _current_allocation().duplicate(true)


func drain_events() -> Array[GridEvent]:
	var drained := _events.duplicate()
	_events.clear()
	return drained


func _current_allocation() -> Dictionary:
	if not _allocation_override.is_empty():
		return _allocation_modes.get(_allocation_override, _allocation_modes.get("balanced", {}))
	return _allocation_modes.get(state.allocation_mode, _allocation_modes.get("balanced", {}))
