class_name MaintenanceDefinition
extends ContentDefinition


func get_trigger_request_id() -> String:
	return str(get_value("trigger_request_id", ""))


func is_routine() -> bool:
	return str(get_value("kind", "strategic")) == "routine"


func is_automation_eligible() -> bool:
	return is_routine() and bool(get_value("automation_eligible", false))


func get_safe_option_id() -> String:
	return str(get_value("safe_option_id", "service" if is_routine() else "repair"))


func get_option(option_id: String) -> Dictionary:
	for option_value: Variant in get_value("options", []):
		if option_value is Dictionary and str(option_value.get("id", "")) == option_id:
			return (option_value as Dictionary).duplicate(true)
	return {}
