class_name DialogueSelector
extends RefCounted

const RECENT_LIMIT := 10
const BROWNOUT_COOLDOWN_SECONDS := 60.0

var _seen: Dictionary = {}
var _last_shown: Dictionary = {}
var _recent: Array[String] = []
var _context_last_time: Dictionary = {}


func select(candidates: Array, context: String, now_seconds: float, required_id: String = "") -> DialogueDefinition:
	if not required_id.is_empty():
		for candidate_value: Variant in candidates:
			var required := candidate_value as DialogueDefinition
			if required != null and required.get_id() == required_id:
				_record(required.get_id(), context, now_seconds)
				return required
		return null
	if context == "brownout" and now_seconds - float(_context_last_time.get(context, -BROWNOUT_COOLDOWN_SECONDS)) < BROWNOUT_COOLDOWN_SECONDS:
		return null
	var eligible: Array[DialogueDefinition] = []
	for candidate_value: Variant in candidates:
		var candidate := candidate_value as DialogueDefinition
		if candidate == null or str(candidate.get_value("context", "")) != context:
			continue
		if candidate.get_id() in _recent:
			continue
		eligible.append(candidate)
	if eligible.is_empty():
		return null
	eligible.sort_custom(_less_preferred)
	var selected := eligible[0]
	_record(selected.get_id(), context, now_seconds)
	return selected


func was_seen(id: String) -> bool:
	return _seen.has(id)


func recent_ids() -> Array[String]:
	return _recent.duplicate()


func _less_preferred(first: DialogueDefinition, second: DialogueDefinition) -> bool:
	var first_seen := _seen.has(first.get_id())
	var second_seen := _seen.has(second.get_id())
	if first_seen != second_seen:
		return not first_seen
	var first_time := float(_last_shown.get(first.get_id(), -INF))
	var second_time := float(_last_shown.get(second.get_id(), -INF))
	if first_time != second_time:
		return first_time < second_time
	return first.get_id() < second.get_id()


func _record(id: String, context: String, now_seconds: float) -> void:
	_seen[id] = true
	_last_shown[id] = now_seconds
	_context_last_time[context] = now_seconds
	_recent.append(id)
	while _recent.size() > RECENT_LIMIT:
		_recent.pop_front()
