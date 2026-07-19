extends Control

## Minimal application bootstrap for the Phase 00 development shell.
## The project setting is the single source for the displayed build version.

@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	var version := str(ProjectSettings.get_setting("application/config/version", "unknown"))
	_version_label.text = "Development shell  •  v%s" % version
	print("ONE MORE WATT %s development shell ready" % version)

	if "--smoke-test" in OS.get_cmdline_user_args():
		get_tree().quit(0)
