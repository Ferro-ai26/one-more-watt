class_name GridState
extends RefCounted

const MAX_SAFE_VALUE := 1.0e100

var generation_rate := 0.0
var transmission_capacity := 0.0
var reserve_capacity := 0.0
var reserve_stored := 0.0
var reserve_charge_rate := 0.0
var reserve_discharge_rate := 0.0
var stored_energy := 0.0
var demand_rate := 0.0
var allocation_mode := "balanced"

var elapsed_seconds := 0.0
var demanded_energy := 0.0
var served_energy := 0.0
var brownout_seconds := 0.0
var stability := 100.0
var brownout_active := false


func apply_grid_values(values: Dictionary) -> void:
	generation_rate = float(values.get("generation_rate", generation_rate))
	transmission_capacity = float(values.get("transmission_capacity", transmission_capacity))
	reserve_capacity = float(values.get("reserve_capacity", reserve_capacity))
	reserve_charge_rate = float(values.get("reserve_charge_rate", reserve_charge_rate))
	reserve_discharge_rate = float(values.get("reserve_discharge_rate", reserve_discharge_rate))
	stored_energy = float(values.get("stored_energy", stored_energy))
	reserve_stored = float(values.get("reserve_stored", reserve_stored))
	sanitize()


func reset_statistics() -> void:
	elapsed_seconds = 0.0
	demanded_energy = 0.0
	served_energy = 0.0
	brownout_seconds = 0.0
	stability = 100.0
	brownout_active = false


func sanitize() -> void:
	generation_rate = _safe_nonnegative(generation_rate)
	transmission_capacity = _safe_nonnegative(transmission_capacity)
	reserve_capacity = _safe_nonnegative(reserve_capacity)
	reserve_charge_rate = _safe_nonnegative(reserve_charge_rate)
	reserve_discharge_rate = _safe_nonnegative(reserve_discharge_rate)
	stored_energy = _safe_nonnegative(stored_energy)
	demand_rate = _safe_nonnegative(demand_rate)
	reserve_stored = clampf(_safe_nonnegative(reserve_stored), 0.0, reserve_capacity)
	elapsed_seconds = _safe_nonnegative(elapsed_seconds)
	demanded_energy = _safe_nonnegative(demanded_energy)
	served_energy = clampf(_safe_nonnegative(served_energy), 0.0, demanded_energy)
	brownout_seconds = clampf(_safe_nonnegative(brownout_seconds), 0.0, elapsed_seconds)
	stability = clampf(_safe_nonnegative(stability), 0.0, 100.0)


func snapshot() -> Dictionary:
	return {
		"generation_rate": generation_rate,
		"transmission_capacity": transmission_capacity,
		"reserve_capacity": reserve_capacity,
		"reserve_stored": reserve_stored,
		"reserve_charge_rate": reserve_charge_rate,
		"reserve_discharge_rate": reserve_discharge_rate,
		"stored_energy": stored_energy,
		"demand_rate": demand_rate,
		"allocation_mode": allocation_mode,
		"elapsed_seconds": elapsed_seconds,
		"demanded_energy": demanded_energy,
		"served_energy": served_energy,
		"brownout_seconds": brownout_seconds,
		"stability": stability,
		"brownout_active": brownout_active,
	}


func restore(data: Dictionary) -> bool:
	for key: String in ["generation_rate", "transmission_capacity", "reserve_capacity", "reserve_stored", "reserve_charge_rate", "reserve_discharge_rate", "stored_energy", "demand_rate", "elapsed_seconds", "demanded_energy", "served_energy", "brownout_seconds", "stability"]:
		var value: Variant = data.get(key, 0.0)
		if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)) or float(value) < 0.0:
			return false
	generation_rate = float(data.get("generation_rate", 0.0))
	transmission_capacity = float(data.get("transmission_capacity", 0.0))
	reserve_capacity = float(data.get("reserve_capacity", 0.0))
	reserve_stored = float(data.get("reserve_stored", 0.0))
	reserve_charge_rate = float(data.get("reserve_charge_rate", 0.0))
	reserve_discharge_rate = float(data.get("reserve_discharge_rate", 0.0))
	stored_energy = float(data.get("stored_energy", 0.0))
	demand_rate = float(data.get("demand_rate", 0.0))
	allocation_mode = str(data.get("allocation_mode", "balanced"))
	elapsed_seconds = float(data.get("elapsed_seconds", 0.0))
	demanded_energy = float(data.get("demanded_energy", 0.0))
	served_energy = float(data.get("served_energy", 0.0))
	brownout_seconds = float(data.get("brownout_seconds", 0.0))
	stability = float(data.get("stability", 100.0))
	brownout_active = bool(data.get("brownout_active", false))
	sanitize()
	return true


static func _safe_nonnegative(value: float) -> float:
	if not is_finite(value):
		return 0.0
	return clampf(value, 0.0, MAX_SAFE_VALUE)
