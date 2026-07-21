class_name OfflineReport
extends RefCounted

var raw_elapsed := 0.0
var recognized_elapsed := 0.0
var effective_elapsed := 0.0
var cap_seconds := 0.0
var efficiency := 0.0
var capped := false
var clock_backward := false
var far_forward := false
var stopped_for_input := false
var feature_locked := false
var stored_energy_before := 0.0
var stored_energy_after := 0.0
var request_id := ""
var progress_before := 0.0
var progress_after := 0.0
var brownout_seconds := 0.0
var completed_request_ids: Array[String] = []
var automation_actions: Array = []
var stop_reason := ""


func snapshot() -> Dictionary:
	return {"raw_elapsed": raw_elapsed, "recognized_elapsed": recognized_elapsed, "effective_elapsed": effective_elapsed, "cap_seconds": cap_seconds, "efficiency": efficiency, "capped": capped, "clock_backward": clock_backward, "far_forward": far_forward, "stopped_for_input": stopped_for_input, "feature_locked": feature_locked, "stored_energy_before": stored_energy_before, "stored_energy_after": stored_energy_after, "request_id": request_id, "progress_before": progress_before, "progress_after": progress_after, "brownout_seconds": brownout_seconds, "completed_request_ids": completed_request_ids.duplicate(), "automation_actions": automation_actions.duplicate(true), "stop_reason": stop_reason}
