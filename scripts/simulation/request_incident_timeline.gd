class_name RequestIncidentTimeline
extends RefCounted

var _scheduled: Array[Dictionary] = []
var _started: Dictionary = {}
var _ended: Dictionary = {}


func configure(request_id: String, incidents: Array, seed: int) -> void:
	_scheduled.clear()
	_started.clear()
	_ended.clear()
	var eligible: Array[IncidentDefinition] = []
	for incident_value: Variant in incidents:
		var incident := incident_value as IncidentDefinition
		if incident == null:
			continue
		var trigger: Dictionary = incident.get_value("trigger", {})
		if str(trigger.get("type", "")) != "request_elapsed":
			continue
		var target_id := str(trigger.get("target_id", ""))
		if not target_id.is_empty() and target_id != request_id:
			continue
		eligible.append(incident)
	eligible.sort_custom(func(a: IncidentDefinition, b: IncidentDefinition) -> bool: return a.get_id() < b.get_id())
	var random := RandomNumberGenerator.new()
	random.seed = _mixed_seed(seed, request_id)
	for incident: IncidentDefinition in eligible:
		var trigger: Dictionary = incident.get_value("trigger", {})
		var chance := clampf(float(trigger.get("chance", 1.0)), 0.0, 1.0)
		if random.randf() > chance:
			continue
		_scheduled.append({
			"definition": incident,
			"start": float(trigger.get("at_seconds", 0.0)),
			"end": float(trigger.get("at_seconds", 0.0)) + float(incident.get_value("duration_seconds", 0.0)),
		})


func events_between(previous_seconds: float, current_seconds: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for scheduled: Dictionary in _scheduled:
		var incident: IncidentDefinition = scheduled["definition"]
		var id := incident.get_id()
		var start := float(scheduled["start"])
		var end := float(scheduled["end"])
		if not _started.has(id) and previous_seconds <= start and current_seconds >= start:
			_started[id] = true
			events.append({"type": RequestEvent.INCIDENT_STARTED, "definition": incident})
		if _started.has(id) and not _ended.has(id) and previous_seconds <= end and current_seconds >= end:
			_ended[id] = true
			events.append({"type": RequestEvent.INCIDENT_ENDED, "definition": incident})
	return events


func request_efficiency_at(elapsed_seconds: float, offline: bool = false) -> float:
	var multiplier := 1.0
	for scheduled: Dictionary in _scheduled:
		if elapsed_seconds < float(scheduled["start"]) or elapsed_seconds >= float(scheduled["end"]):
			continue
		var incident: IncidentDefinition = scheduled["definition"]
		if offline and not bool(incident.get_value("offline_allowed", false)):
			continue
		for modifier_value: Variant in incident.get_value("modifiers", []):
			if not modifier_value is Dictionary:
				continue
			var modifier: Dictionary = modifier_value
			if str(modifier.get("target", "")) != "request_efficiency":
				continue
			if str(modifier.get("operation", "")) == "multiply":
				multiplier *= float(modifier.get("value", 1.0))
			elif str(modifier.get("operation", "")) == "add":
				multiplier += float(modifier.get("value", 0.0))
	return maxf(multiplier, 0.0)


func scheduled_ids() -> Array[String]:
	var ids: Array[String] = []
	for scheduled: Dictionary in _scheduled:
		var incident: IncidentDefinition = scheduled["definition"]
		ids.append(incident.get_id())
	return ids


func seek(elapsed_seconds: float) -> void:
	_started.clear()
	_ended.clear()
	for scheduled: Dictionary in _scheduled:
		var incident: IncidentDefinition = scheduled["definition"]
		if elapsed_seconds >= float(scheduled["start"]):
			_started[incident.get_id()] = true
		if elapsed_seconds >= float(scheduled["end"]):
			_ended[incident.get_id()] = true


static func _mixed_seed(seed: int, value: String) -> int:
	var mixed := seed
	for byte: int in value.to_utf8_buffer():
		mixed = int((mixed * 33 + byte) & 0x7fffffff)
	return mixed
