class_name RequestRunState
extends RefCounted

const LOCKED := "locked"
const AVAILABLE := "available"
const ANNOUNCED := "announced"
const AUTHORIZED := "authorized"
const RUNNING := "running"
const COMPLETED := "completed"
const REPORTED := "reported"
const SKIPPED := "skipped"

var request_id := ""
var status := LOCKED
var progress := 0.0
var elapsed_seconds := 0.0
var demanded_energy := 0.0
var served_energy := 0.0
var brownout_seconds := 0.0
var peak_demand := 0.0
var peak_served := 0.0
var starting_stored_energy := 0.0
var allocation_changes := 0
var underprepared_warning := false
var reward_granted := false
var research_cost_paid := false
var incident_ids: Array[String] = []
var safe_throttle_seconds := 0.0
var safe_throttle_events := 0
var automation_sequence_at_start := 0


func _init(id: String = "") -> void:
	request_id = id


func snapshot() -> Dictionary:
	return {
		"request_id": request_id,
		"status": status,
		"progress": progress,
		"elapsed_seconds": elapsed_seconds,
		"demanded_energy": demanded_energy,
		"served_energy": served_energy,
		"brownout_seconds": brownout_seconds,
		"peak_demand": peak_demand,
		"peak_served": peak_served,
		"starting_stored_energy": starting_stored_energy,
		"allocation_changes": allocation_changes,
		"underprepared_warning": underprepared_warning,
		"reward_granted": reward_granted,
		"research_cost_paid": research_cost_paid,
		"incident_ids": incident_ids.duplicate(),
		"safe_throttle_seconds": safe_throttle_seconds,
		"safe_throttle_events": safe_throttle_events,
		"automation_sequence_at_start": automation_sequence_at_start,
	}


func restore(data: Dictionary) -> bool:
	var restored_status := str(data.get("status", LOCKED))
	if restored_status not in [LOCKED, AVAILABLE, ANNOUNCED, AUTHORIZED, RUNNING, COMPLETED, REPORTED, SKIPPED]:
		return false
	status = restored_status
	progress = clampf(float(data.get("progress", 0.0)), 0.0, 1.0)
	elapsed_seconds = maxf(float(data.get("elapsed_seconds", 0.0)), 0.0)
	demanded_energy = maxf(float(data.get("demanded_energy", 0.0)), 0.0)
	served_energy = clampf(float(data.get("served_energy", 0.0)), 0.0, demanded_energy)
	brownout_seconds = clampf(float(data.get("brownout_seconds", 0.0)), 0.0, elapsed_seconds)
	peak_demand = maxf(float(data.get("peak_demand", 0.0)), 0.0)
	peak_served = clampf(float(data.get("peak_served", 0.0)), 0.0, peak_demand)
	starting_stored_energy = maxf(float(data.get("starting_stored_energy", 0.0)), 0.0)
	allocation_changes = maxi(int(data.get("allocation_changes", 0)), 0)
	underprepared_warning = bool(data.get("underprepared_warning", false))
	reward_granted = bool(data.get("reward_granted", false))
	research_cost_paid = bool(data.get("research_cost_paid", false))
	incident_ids.clear()
	for value: Variant in data.get("incident_ids", []):
		incident_ids.append(str(value))
	safe_throttle_seconds = clampf(float(data.get("safe_throttle_seconds", 0.0)), 0.0, elapsed_seconds)
	safe_throttle_events = maxi(int(data.get("safe_throttle_events", 0)), 0)
	automation_sequence_at_start = maxi(int(data.get("automation_sequence_at_start", 0)), 0)
	return true
