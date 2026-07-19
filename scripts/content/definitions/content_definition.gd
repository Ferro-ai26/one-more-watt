class_name ContentDefinition
extends RefCounted

var _data: Dictionary


func _init(source: Dictionary = {}) -> void:
	_data = _deep_read_only(source)


func get_id() -> String:
	return str(_data.get("id", ""))


func get_value(key: StringName, default_value: Variant = null) -> Variant:
	return _data.get(key, default_value)


func to_dictionary() -> Dictionary:
	return _data.duplicate(true)


static func _deep_read_only(value: Variant) -> Variant:
	if value is Dictionary:
		var frozen_dictionary: Dictionary = {}
		for key: Variant in value:
			frozen_dictionary[key] = _deep_read_only(value[key])
		frozen_dictionary.make_read_only()
		return frozen_dictionary
	if value is Array:
		var frozen_array: Array = []
		for item: Variant in value:
			frozen_array.append(_deep_read_only(item))
		frozen_array.make_read_only()
		return frozen_array
	return value
