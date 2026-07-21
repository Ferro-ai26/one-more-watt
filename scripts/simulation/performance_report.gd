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
var safe_throttle_seconds := 0.0
var safe_throttle_events := 0
var automation_actions: Array = []


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
		"safe_throttle_seconds": safe_throttle_seconds,
		"safe_throttle_events": safe_throttle_events,
		"automation_actions": automation_actions.duplicate(true),
	}


func restore(data: Dictionary) -> bool:
	request_id = str(data.get("request_id", ""))
	if request_id.is_empty():
		return false
	kind = str(data.get("kind", ""))
	grade = str(data.get("grade", "D"))
	stability_score = clampf(float(data.get("stability_score", 0.0)), 0.0, 100.0)
	completion_seconds = maxf(float(data.get("completion_seconds", 0.0)), 0.0)
	demand_served_ratio = clampf(float(data.get("demand_served_ratio", 1.0)), 0.0, 1.0)
	demanded_energy = maxf(float(data.get("demanded_energy", 0.0)), 0.0)
	served_energy = clampf(float(data.get("served_energy", 0.0)), 0.0, demanded_energy)
	peak_demand = maxf(float(data.get("peak_demand", 0.0)), 0.0)
	peak_served = clampf(float(data.get("peak_served", 0.0)), 0.0, peak_demand)
	brownout_seconds = clampf(float(data.get("brownout_seconds", 0.0)), 0.0, completion_seconds)
	stored_energy_earned = maxf(float(data.get("stored_energy_earned", 0.0)), 0.0)
	reward_stored_energy = maxf(float(data.get("reward_stored_energy", 0.0)), 0.0)
	ending_reserve = maxf(float(data.get("ending_reserve", 0.0)), 0.0)
	ending_reserve_capacity = maxf(float(data.get("ending_reserve_capacity", 0.0)), 0.0)
	allocation_changes = maxi(int(data.get("allocation_changes", 0)), 0)
	incident_ids.assign(data.get("incident_ids", []))
	unlock_ids.assign(data.get("unlock_ids", []))
	completion_key = str(data.get("completion_key", ""))
	suggestion_key = str(data.get("suggestion_key", ""))
	safe_throttle_seconds = clampf(float(data.get("safe_throttle_seconds", 0.0)), 0.0, completion_seconds)
	safe_throttle_events = maxi(int(data.get("safe_throttle_events", 0)), 0)
	automation_actions = (data.get("automation_actions", []) as Array).duplicate(true)
	for action_value: Variant in automation_actions:
		if not action_value is Dictionary:
			return false
	return true
