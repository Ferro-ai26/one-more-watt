class_name EraDefinition
extends ContentDefinition


func get_number() -> int:
	return int(get_value("number", 0))


func get_request_ids() -> Array:
	return get_value("request_ids", [])
