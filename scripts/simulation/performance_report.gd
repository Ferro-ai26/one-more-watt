class_name PerformanceReport
extends RefCounted

var request_id := ""
var kind := ""
var grade := "D"
var stability_score := 0.0
var completion_seconds := 0.0
var demand_served_ratio := 1.0
var demanded_energy := 0.0
var served_energy := 0.0
var peak_demand := 0.0
var peak_served := 0.0
var brownout_seconds := 0.0
var stored_energy_earned := 0.0
var reward_stored_energy := 0.0
var ending_reserve := 0.0
var ending_reserve_capacity := 0.0
var allocation_changes := 0
var incident_ids: Array[String] = []
var unlock_ids: Array[String] = []
var completion_key := ""
var suggestion_key := ""


func snapshot() -> Dictionary:
	return {
		"request_id": request_id,
		"kind": kind,
		"grade": grade,
		"stability_score": stability_score,
		"completion_seconds": completion_seconds,
		"demand_served_ratio": demand_served_ratio,
		"demanded_energy": demanded_energy,
		"served_energy": served_energy,
		"peak_demand": peak_demand,
		"peak_served": peak_served,
		"brownout_seconds": brownout_seconds,
		"stored_energy_earned": stored_energy_earned,
		"reward_stored_energy": reward_stored_energy,
		"ending_reserve": ending_reserve,
		"ending_reserve_capacity": ending_reserve_capacity,
		"allocation_changes": allocation_changes,
		"incident_ids": incident_ids.duplicate(),
		"unlock_ids": unlock_ids.duplicate(),
		"completion_key": completion_key,
		"suggestion_key": suggestion_key,
	}
