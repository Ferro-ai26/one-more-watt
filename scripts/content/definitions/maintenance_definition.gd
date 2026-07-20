class_name MaintenanceDefinition
extends ContentDefinition


func get_trigger_request_id() -> String:
	return str(get_value("trigger_request_id", ""))


func get_option(option_id: String) -> Dictionary:
	for option_value: Variant in get_value("options", []):
		if option_value is Dictionary and str(option_value.get("id", "")) == option_id:
			return (option_value as Dictionary).duplicate(true)
	return {}
