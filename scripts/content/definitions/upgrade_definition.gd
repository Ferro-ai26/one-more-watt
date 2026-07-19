class_name UpgradeDefinition
extends ContentDefinition


func get_effects() -> Array:
	return get_value("effects", [])
