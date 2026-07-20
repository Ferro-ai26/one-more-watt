class_name RequestEvent
extends RefCounted

const STATE_CHANGED := "request_state_changed"
const REWARD_GRANTED := "reward_granted"
const CONTENT_UNLOCKED := "content_unlocked"
const REPORT_READY := "report_ready"
const DIALOGUE_SHOWN := "dialogue_shown"
const INCIDENT_STARTED := "incident_started"
const INCIDENT_ENDED := "incident_ended"

var type := ""
var request_id := ""
var time_seconds := 0.0
var payload: Dictionary = {}


func _init(event_type: String = "", id: String = "", event_time: float = 0.0, data: Dictionary = {}) -> void:
	type = event_type
	request_id = id
	time_seconds = event_time
	payload = ContentDefinition._deep_read_only(data)
