class_name AchievementDefinition
extends ContentDefinition


func is_hidden() -> bool:
	return bool(get_value("hidden", false))
