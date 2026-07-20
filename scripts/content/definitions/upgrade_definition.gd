class_name UpgradeDefinition
extends ContentDefinition


func get_effects() -> Array:
	return get_value("effects", [])


func get_max_level() -> int:
	return int(get_value("max_level", 1))
