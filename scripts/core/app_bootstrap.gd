extends Control

## Minimal application bootstrap for the Phase 00 development shell.
## The project setting is the single source for the displayed build version.

@onready var _version_label: Label = %VersionLabel
@onready var _content_version_label: Label = %ContentVersionLabel
@onready var _content_counts_label: Label = %ContentCountsLabel
@onready var _sample_request_label: Label = %SampleRequestLabel


func _ready() -> void:
	var version := str(ProjectSettings.get_setting("application/config/version", "unknown"))
	_version_label.text = "Development shell  •  v%s" % version
	print("ONE MORE WATT %s development shell ready" % version)
	var content_db := get_node_or_null("/root/ContentDB")
	_display_content_status(content_db)

	if "--smoke-test" in OS.get_cmdline_user_args():
		get_tree().quit(0 if content_db != null and bool(content_db.call("is_loaded")) else 1)


func _display_content_status(content_db: Node) -> void:
	if content_db == null or not bool(content_db.call("is_loaded")):
		_content_version_label.text = "Content unavailable"
		_content_counts_label.text = "Validation errors were reported"
		_sample_request_label.text = "No sample request loaded"
		return

	var repository: ContentRepository = content_db.get("repository")
	var counts := repository.get_counts()
	_content_version_label.text = "Content v%s  •  schema %d" % [repository.get_content_version(), repository.get_schema_version()]
	_content_counts_label.text = "%d eras  •  %d infrastructure  •  %d upgrade  •  %d request" % [
		counts.get("eras", 0), counts.get("infrastructure", 0), counts.get("upgrades", 0), counts.get("requests", 0)
	]
	var requests := repository.get_all("requests")
	if requests.is_empty():
		_sample_request_label.text = "No sample request loaded"
		return
	var sample := requests[0] as RequestDefinition
	_sample_request_label.text = "%s  •  %.0f energy" % [repository.localize(sample.get_title_key()), sample.get_required_energy()]
