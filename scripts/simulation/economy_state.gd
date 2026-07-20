class_name EconomyState
extends RefCounted

var stored_energy := 0.0
var owned: Dictionary = {}
var upgrade_levels: Dictionary = {}
var completed_requests: Dictionary = {}
var unlocked_eras: Dictionary = {}
var unlocked_content: Dictionary = {}
var awarded_milestones: Dictionary = {}
var reserve_automation_enabled := false
var reserve_threshold_ratio := 0.25


func snapshot() -> Dictionary:
	return {
		"stored_energy": stored_energy,
		"owned": owned.duplicate(true),
		"upgrade_levels": upgrade_levels.duplicate(true),
		"completed_requests": completed_requests.duplicate(true),
		"unlocked_eras": unlocked_eras.duplicate(true),
		"unlocked_content": unlocked_content.duplicate(true),
		"awarded_milestones": awarded_milestones.duplicate(true),
		"reserve_automation_enabled": reserve_automation_enabled,
		"reserve_threshold_ratio": reserve_threshold_ratio,
	}


func restore(data: Dictionary) -> bool:
	var currency := float(data.get("stored_energy", 0.0))
	var threshold := float(data.get("reserve_threshold_ratio", 0.25))
	if not is_finite(currency) or currency < 0.0 or not is_finite(threshold) or threshold < 0.0 or threshold > 1.0:
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
	reserve_automation_enabled = bool(data.get("reserve_automation_enabled", false))
	reserve_threshold_ratio = threshold
	for value: Variant in owned.values():
		if int(value) < 0:
			return false
	for value: Variant in upgrade_levels.values():
		if int(value) < 0:
			return false
	return true
