class_name InfrastructureDefinition
extends ContentDefinition


func get_category() -> String:
	return str(get_value("category", ""))


func get_base_cost() -> float:
	return float(get_value("base_cost", 0.0))


func get_base_effects() -> Dictionary:
	return get_value("base_effects", {})
