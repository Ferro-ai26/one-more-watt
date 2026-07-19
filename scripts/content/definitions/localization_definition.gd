class_name LocalizationDefinition
extends ContentDefinition


func get_locale() -> String:
	return get_id()


func has_key(key: String) -> bool:
	var strings: Dictionary = get_value("strings", {})
	return strings.has(key)


func get_text(key: String) -> String:
	var strings: Dictionary = get_value("strings", {})
	return str(strings.get(key, ""))
