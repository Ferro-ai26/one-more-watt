extends Node

var repository := ContentRepository.new()
var load_result := ContentLoadResult.new()


func _ready() -> void:
	load_result = repository.load_from_manifest()
	if load_result.is_ok():
		print("CONTENT: loaded version %s" % repository.get_content_version())
		return
	for issue: ContentValidationIssue in load_result.issues:
		push_error("CONTENT: %s" % issue.format())


func is_loaded() -> bool:
	return repository.is_loaded()
