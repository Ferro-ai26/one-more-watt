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
