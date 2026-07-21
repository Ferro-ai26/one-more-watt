class_name RequestPreview
extends RefCounted

var request_id := ""
var valid := false
var continuous_demand := 0.0
var predicted_peak := 0.0
var recommended_reserve := 0.0
var predicted_service_ratio := 0.0
var estimated_seconds := INF
var likely_bottleneck := "none"
var underprepared := false
var warning_key := ""
var research_cost := 0.0
var reward_stored_energy := 0.0
var unlock_ids: Array[String] = []
var forecast_confidence := "limited"
var forecast_reason := "missing_model"
var estimated_seconds_low := INF
var estimated_seconds_high := INF
var seconds_until_peak := INF
var projected_minimum_reserve := 0.0


func snapshot() -> Dictionary:
	return {
		"request_id": request_id,
		"valid": valid,
		"continuous_demand": continuous_demand,
		"predicted_peak": predicted_peak,
		"recommended_reserve": recommended_reserve,
		"predicted_service_ratio": predicted_service_ratio,
		"estimated_seconds": estimated_seconds,
		"likely_bottleneck": likely_bottleneck,
		"underprepared": underprepared,
		"warning_key": warning_key,
		"research_cost": research_cost,
		"reward_stored_energy": reward_stored_energy,
		"unlock_ids": unlock_ids.duplicate(),
		"forecast_confidence": forecast_confidence,
		"forecast_reason": forecast_reason,
		"estimated_seconds_low": estimated_seconds_low,
		"estimated_seconds_high": estimated_seconds_high,
		"seconds_until_peak": seconds_until_peak,
		"projected_minimum_reserve": projected_minimum_reserve,
	}
