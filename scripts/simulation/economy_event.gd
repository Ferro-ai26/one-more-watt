class_name EconomyEvent
extends RefCounted

const CURRENCY_CHANGED := "currency_changed"
const INFRASTRUCTURE_PURCHASED := "infrastructure_purchased"
const UPGRADE_PURCHASED := "upgrade_purchased"
const GRID_REBUILT := "grid_rebuilt"
const MILESTONE_REACHED := "milestone_reached"
const CONTENT_UNLOCKED := "content_unlocked"
const AUTOMATION_CHANGED := "automation_changed"
const DEMAND_THROTTLED := "demand_throttled"

var type := ""
var content_id := ""
var payload: Dictionary = {}


func _init(event_type: String = "", id: String = "", data: Dictionary = {}) -> void:
	type = event_type
	content_id = id
	payload = ContentDefinition._deep_read_only(data)
