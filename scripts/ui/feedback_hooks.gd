class_name FeedbackHooks
extends RefCounted

signal feedback_requested(kind: String)

var settings: RuntimeSettings
var last_feedback := ""


func _init(runtime_settings: RuntimeSettings = null) -> void:
	settings = runtime_settings if runtime_settings != null else RuntimeSettings.new()


func request(kind: String, allow_haptic: bool = false) -> void:
	last_feedback = kind
	feedback_requested.emit(kind)
	if allow_haptic and settings.haptics_enabled and OS.has_feature("mobile"):
		Input.vibrate_handheld(35)
