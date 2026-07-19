class_name DemandProfileDefinition
extends ContentDefinition


func get_duration_seconds() -> float:
	return float(get_value("duration_seconds", 0.0))
