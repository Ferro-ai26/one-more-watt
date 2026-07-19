class_name GridStepResult
extends RefCounted

var delta_seconds := 0.0
var deliverable_power := 0.0
var demand_rate := 0.0
var direct_served_power := 0.0
var reserve_discharge_power := 0.0
var served_power := 0.0
var unmet_power := 0.0
var surplus_power := 0.0
var watt_power := 0.0
var grid_power := 0.0
var reserve_charge_power := 0.0
var stored_energy_rate := 0.0
var stability := 100.0
var limiting_constraint := "none"
var brownout_active := false
var brownout_started := false
var brownout_ended := false


func snapshot() -> Dictionary:
	return {
		"delta_seconds": delta_seconds,
		"deliverable_power": deliverable_power,
		"demand_rate": demand_rate,
		"direct_served_power": direct_served_power,
		"reserve_discharge_power": reserve_discharge_power,
		"served_power": served_power,
		"unmet_power": unmet_power,
		"surplus_power": surplus_power,
		"watt_power": watt_power,
		"grid_power": grid_power,
		"reserve_charge_power": reserve_charge_power,
		"stored_energy_rate": stored_energy_rate,
		"stability": stability,
		"limiting_constraint": limiting_constraint,
		"brownout_active": brownout_active,
	}
