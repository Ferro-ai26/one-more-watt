class_name GridCalculator
extends RefCounted

const EPSILON := 0.000000001


static func step(state: GridState, allocation: Dictionary, conversion_efficiency: float, delta_seconds: float) -> GridStepResult:
	state.sanitize()
	var result := GridStepResult.new()
	result.delta_seconds = delta_seconds
	result.demand_rate = state.demand_rate
	if delta_seconds <= 0.0 or not is_finite(delta_seconds):
		result.stability = state.stability
		result.brownout_active = state.brownout_active
		return result

	result.deliverable_power = minf(state.generation_rate, state.transmission_capacity)
	result.direct_served_power = minf(result.deliverable_power, state.demand_rate)
	var deficit_power := maxf(state.demand_rate - result.direct_served_power, 0.0)
	var discharge_energy := minf(
		deficit_power * delta_seconds,
		minf(state.reserve_discharge_rate * delta_seconds, state.reserve_stored)
	)
	result.reserve_discharge_power = discharge_energy / delta_seconds
	state.reserve_stored -= discharge_energy
	result.served_power = minf(state.demand_rate, result.direct_served_power + result.reserve_discharge_power)
	result.unmet_power = maxf(state.demand_rate - result.served_power, 0.0)

	result.surplus_power = maxf(result.deliverable_power - result.direct_served_power, 0.0)
	var watt_share := clampf(float(allocation.get("watt_share", 0.5)), 0.0, 1.0)
	result.watt_power = result.surplus_power * watt_share
	result.grid_power = maxf(result.surplus_power - result.watt_power, 0.0)

	var reserve_room := maxf(state.reserve_capacity - state.reserve_stored, 0.0)
	var charge_energy := minf(
		result.grid_power * delta_seconds,
		minf(state.reserve_charge_rate * delta_seconds, reserve_room)
	)
	result.reserve_charge_power = charge_energy / delta_seconds
	state.reserve_stored += charge_energy
	var stored_energy_power := maxf(result.grid_power - result.reserve_charge_power, 0.0)
	result.stored_energy_rate = stored_energy_power * clampf(conversion_efficiency, 0.0, 1.0)
	state.stored_energy += result.stored_energy_rate * delta_seconds

	state.elapsed_seconds += delta_seconds
	state.demanded_energy += state.demand_rate * delta_seconds
	state.served_energy += result.served_power * delta_seconds
	var was_brownout := state.brownout_active
	state.brownout_active = result.unmet_power > EPSILON
	if state.brownout_active:
		state.brownout_seconds += delta_seconds
	result.brownout_started = state.brownout_active and not was_brownout
	result.brownout_ended = was_brownout and not state.brownout_active
	state.stability = _calculate_stability(state)
	result.stability = state.stability
	result.brownout_active = state.brownout_active
	result.limiting_constraint = _limiting_constraint(state, result)
	state.sanitize()
	return result


static func _calculate_stability(state: GridState) -> float:
	var served_ratio := 1.0
	if state.demanded_energy > EPSILON:
		served_ratio = clampf(state.served_energy / state.demanded_energy, 0.0, 1.0)
	var brownout_penalty := 0.0
	if state.elapsed_seconds > EPSILON:
		brownout_penalty = minf(20.0, state.brownout_seconds / state.elapsed_seconds * 40.0)
	var reserve_ratio := 0.0
	if state.reserve_capacity > EPSILON:
		reserve_ratio = clampf(state.reserve_stored / state.reserve_capacity, 0.0, 1.0)
	var reserve_bonus := minf(5.0, reserve_ratio * 5.0)
	return clampf(100.0 * served_ratio - brownout_penalty + reserve_bonus, 0.0, 100.0)


static func _limiting_constraint(state: GridState, result: GridStepResult) -> String:
	if result.reserve_discharge_power > EPSILON or result.unmet_power > EPSILON:
		return "reserve"
	if state.generation_rate + EPSILON < state.transmission_capacity:
		return "generation"
	if state.transmission_capacity + EPSILON < state.generation_rate:
		return "transmission"
	return "none"
