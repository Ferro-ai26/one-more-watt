class_name ContentLoadResult
extends RefCounted

var issues: Array[ContentValidationIssue]


func _init(validation_issues: Array[ContentValidationIssue] = []) -> void:
	issues = validation_issues.duplicate()


func is_ok() -> bool:
	return issues.is_empty()


func has_code(code: String) -> bool:
	for issue: ContentValidationIssue in issues:
		if issue.code == code:
			return true
	return false
