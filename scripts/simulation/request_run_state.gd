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
		"allocation_changes": allocation_changes,
		"underprepared_warning": underprepared_warning,
		"reward_granted": reward_granted,
		"research_cost_paid": research_cost_paid,
		"incident_ids": incident_ids.duplicate(),
	}
