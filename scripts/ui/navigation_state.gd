class_name NavigationState
extends RefCounted

const TABS := ["grid", "build", "upgrades", "reports"]

var current_tab := "grid"
var _modal_stack: Array[String] = []


func select_tab(tab: String) -> bool:
	if tab not in TABS:
		return false
	current_tab = tab
	return true


func push_modal(modal_id: String) -> bool:
	if modal_id.is_empty() or modal_id in _modal_stack:
		return false
	_modal_stack.append(modal_id)
	return true


func pop_modal() -> String:
	return "" if _modal_stack.is_empty() else _modal_stack.pop_back()


func top_modal() -> String:
	return "" if _modal_stack.is_empty() else _modal_stack.back()


func modal_depth() -> int:
	return _modal_stack.size()


func clear_modals() -> void:
	_modal_stack.clear()
