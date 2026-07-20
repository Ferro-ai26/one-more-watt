class_name EconomyState
extends RefCounted

var stored_energy := 0.0
var owned: Dictionary = {}
var upgrade_levels: Dictionary = {}
var completed_requests: Dictionary = {}
var unlocked_eras: Dictionary = {}
var unlocked_content: Dictionary = {}
var awarded_milestones: Dictionary = {}
var unlocked_features: Dictionary = {}
var current_era_id := "era_01_cold_boot"
var best_stability_service_ratio := 0.0
var pending_era_transition_id := ""
var prototype_complete := false
var reserve_automation_enabled := false
var reserve_threshold_ratio := 0.25
var predictive_reserve_guard_enabled := false
var predictive_reserve_target_ratio := 0.75
var maintenance_choices: Dictionary = {}
var pending_maintenance_id := ""
var temporary_effects: Array = []
var temporary_effect_request_id := ""
var completed_eras: Dictionary = {}


func snapshot() -> Dictionary:
	return {
		"stored_energy": stored_energy,
		"owned": owned.duplicate(true),
		"upgrade_levels": upgrade_levels.duplicate(true),
		"completed_requests": completed_requests.duplicate(true),
		"unlocked_eras": unlocked_eras.duplicate(true),
		"unlocked_content": unlocked_content.duplicate(true),
		"awarded_milestones": awarded_milestones.duplicate(true),
		"unlocked_features": unlocked_features.duplicate(true),
		"current_era_id": current_era_id,
		"best_stability_service_ratio": best_stability_service_ratio,
		"pending_era_transition_id": pending_era_transition_id,
		"prototype_complete": prototype_complete,
		"reserve_automation_enabled": reserve_automation_enabled,
		"reserve_threshold_ratio": reserve_threshold_ratio,
		"predictive_reserve_guard_enabled": predictive_reserve_guard_enabled,
		"predictive_reserve_target_ratio": predictive_reserve_target_ratio,
		"maintenance_choices": maintenance_choices.duplicate(true),
		"pending_maintenance_id": pending_maintenance_id,
		"temporary_effects": temporary_effects.duplicate(true),
		"temporary_effect_request_id": temporary_effect_request_id,
		"completed_eras": completed_eras.duplicate(true),
	}


func restore(data: Dictionary) -> bool:
	var currency := float(data.get("stored_energy", 0.0))
	var threshold := float(data.get("reserve_threshold_ratio", 0.25))
	var predictive_target := float(data.get("predictive_reserve_target_ratio", 0.75))
	if not is_finite(currency) or currency < 0.0 or not is_finite(threshold) or threshold < 0.0 or threshold > 1.0 or not is_finite(predictive_target) or predictive_target < 0.0 or predictive_target > 1.0:
		return false
	stored_energy = currency
	owned.clear()
	for key: Variant in (data.get("owned", {}) as Dictionary):
		owned[str(key)] = int(data["owned"][key])
	upgrade_levels.clear()
	for key: Variant in (data.get("upgrade_levels", {}) as Dictionary):
		upgrade_levels[str(key)] = int(data["upgrade_levels"][key])
	completed_requests = (data.get("completed_requests", {}) as Dictionary).duplicate(true)
	unlocked_eras = (data.get("unlocked_eras", {}) as Dictionary).duplicate(true)
	unlocked_content = (data.get("unlocked_content", {}) as Dictionary).duplicate(true)
	awarded_milestones = (data.get("awarded_milestones", {}) as Dictionary).duplicate(true)
	unlocked_features = (data.get("unlocked_features", {}) as Dictionary).duplicate(true)
	current_era_id = str(data.get("current_era_id", "era_01_cold_boot"))
	best_stability_service_ratio = clampf(float(data.get("best_stability_service_ratio", 0.0)), 0.0, 1.0)
	pending_era_transition_id = str(data.get("pending_era_transition_id", ""))
	prototype_complete = bool(data.get("prototype_complete", false))
	reserve_automation_enabled = bool(data.get("reserve_automation_enabled", false))
	reserve_threshold_ratio = threshold
	predictive_reserve_guard_enabled = bool(data.get("predictive_reserve_guard_enabled", false))
	predictive_reserve_target_ratio = predictive_target
	maintenance_choices = (data.get("maintenance_choices", {}) as Dictionary).duplicate(true)
	pending_maintenance_id = str(data.get("pending_maintenance_id", ""))
	temporary_effects = (data.get("temporary_effects", []) as Array).duplicate(true)
	temporary_effect_request_id = str(data.get("temporary_effect_request_id", ""))
	completed_eras = (data.get("completed_eras", {}) as Dictionary).duplicate(true)
	for value: Variant in owned.values():
		if int(value) < 0:
			return false
	for value: Variant in upgrade_levels.values():
		if int(value) < 0:
			return false
	for maintenance_id: Variant in maintenance_choices:
		if not maintenance_id is String or not maintenance_choices[maintenance_id] is String:
			return false
	for effect_value: Variant in temporary_effects:
		if not effect_value is Dictionary:
			return false
	return true
