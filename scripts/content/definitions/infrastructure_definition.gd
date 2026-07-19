class_name InfrastructureDefinition
extends ContentDefinition


func get_category() -> String:
	return str(get_value("category", ""))
