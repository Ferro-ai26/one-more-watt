class_name RequestDefinition
extends ContentDefinition


func get_title_key() -> String:
	return str(get_value("title_key", ""))


func get_required_energy() -> float:
	return float(get_value("required_energy", 0.0))
