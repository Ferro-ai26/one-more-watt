class_name ContentValidationIssue
extends RefCounted

var code: String
var path: String
var record_id: String
var message: String


func _init(issue_code: String, source_path: String, source_record_id: String, detail: String) -> void:
	code = issue_code
	path = source_path
	record_id = source_record_id
	message = detail


func format() -> String:
	var record_suffix := ""
	if not record_id.is_empty():
		record_suffix = " (%s)" % record_id
	return "[%s] %s%s: %s" % [code, path, record_suffix, message]
