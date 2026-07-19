class_name GridEvent
extends RefCounted

const BROWNOUT_STARTED := "brownout_started"
const BROWNOUT_ENDED := "brownout_ended"
const ALLOCATION_CHANGED := "allocation_changed"

var type: String
var elapsed_seconds: float
var data: Dictionary


func _init(event_type: String, event_time: float, event_data: Dictionary = {}) -> void:
	type = event_type
	elapsed_seconds = event_time
	data = ContentDefinition._deep_read_only(event_data)
