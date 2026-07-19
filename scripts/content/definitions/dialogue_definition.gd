class_name DialogueDefinition
extends ContentDefinition


func get_text_key() -> String:
	return str(get_value("text_key", ""))
