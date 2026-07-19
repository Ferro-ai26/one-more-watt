class_name IncidentDefinition
extends ContentDefinition


func is_offline_allowed() -> bool:
	return bool(get_value("offline_allowed", false))
