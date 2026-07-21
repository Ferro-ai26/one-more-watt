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
var reserve_policy_preset := "balanced"
var request_start_target_ratio := 0.70
var routine_automation_enabled := false
var routine_automation_max_cost := 1000000.0
var scheduled_request_id := ""
var scheduled_start_rule := ""
var scheduled_target_ratio := 0.70
var automation_action_sequence := 0
var automation_history: Array = []


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
		"reserve_policy_preset": reserve_policy_preset,
		"request_start_target_ratio": request_start_target_ratio,
		"routine_automation_enabled": routine_automation_enabled,
		"routine_automation_max_cost": routine_automation_max_cost,
		"scheduled_request_id": scheduled_request_id,
		"scheduled_start_rule": scheduled_start_rule,
		"scheduled_target_ratio": scheduled_target_ratio,
		"automation_action_sequence": automation_action_sequence,
		"automation_history": automation_history.duplicate(true),
	}


func restore(data: Dictionary) -> bool:
	var currency := float(data.get("stored_energy", 0.0))
	var threshold := float(data.get("reserve_threshold_ratio", 0.25))
	var predictive_target := float(data.get("predictive_reserve_target_ratio", 0.75))
	var start_target := float(data.get("request_start_target_ratio", 0.70))
	var scheduled_target := float(data.get("scheduled_target_ratio", start_target))
	var routine_cost := float(data.get("routine_automation_max_cost", 1000000.0))
	if not is_finite(currency) or currency < 0.0 or not is_finite(threshold) or threshold < 0.0 or threshold > 1.0 or not is_finite(predictive_target) or predictive_target < 0.0 or predictive_target > 1.0 or not is_finite(start_target) or start_target < 0.0 or start_target > 1.0 or not is_finite(scheduled_target) or scheduled_target < 0.0 or scheduled_target > 1.0 or not is_finite(routine_cost) or routine_cost < 0.0:
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
	reserve_policy_preset = str(data.get("reserve_policy_preset", "balanced"))
	request_start_target_ratio = start_target
	routine_automation_enabled = bool(data.get("routine_automation_enabled", false))
	routine_automation_max_cost = routine_cost
	scheduled_request_id = str(data.get("scheduled_request_id", ""))
	scheduled_start_rule = str(data.get("scheduled_start_rule", ""))
	scheduled_target_ratio = scheduled_target
	automation_action_sequence = maxi(int(data.get("automation_action_sequence", 0)), 0)
	automation_history = (data.get("automation_history", []) as Array).duplicate(true)
	if reserve_policy_preset not in ["conservative", "balanced", "max_throughput", "custom"]:
		return false
	if scheduled_start_rule not in ["", "reserve_target", "next_return_safe"]:
		return false
	if scheduled_request_id.is_empty() != scheduled_start_rule.is_empty():
		return false
	for action_value: Variant in automation_history:
		if not action_value is Dictionary:
			return false
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


func record_automation_action(action_type: String, target_id: String, outcome: String, details: Dictionary = {}) -> Dictionary:
	automation_action_sequence += 1
	var action := {
		"sequence": automation_action_sequence,
		"type": action_type,
		"target_id": target_id,
		"outcome": outcome,
	}
	for key: Variant in details:
		action[str(key)] = details[key]
	automation_history.append(action)
	while automation_history.size() > 50:
		automation_history.pop_front()
	return action.duplicate(true)


func automation_actions_since(sequence: int) -> Array:
	var result: Array = []
	for action_value: Variant in automation_history:
		if action_value is Dictionary and int(action_value.get("sequence", 0)) > sequence:
			result.append((action_value as Dictionary).duplicate(true))
	return result
