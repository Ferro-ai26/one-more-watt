class_name TouchScrollContainer
extends ScrollContainer

var _active_touch := -1
var _drag_origin := Vector2.ZERO
var _drag_origin_scroll := 0
var _dragging := false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _active_touch < 0 and is_visible_in_tree() and get_global_rect().has_point(touch.position):
				_active_touch = touch.index
				_drag_origin = touch.position
				_drag_origin_scroll = scroll_vertical
				_dragging = false
		elif touch.index == _active_touch:
			if _dragging:
				get_viewport().set_input_as_handled()
			_active_touch = -1
			_dragging = false
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index != _active_touch:
			return
		var vertical_distance := drag.position.y - _drag_origin.y
		if not _dragging and absf(vertical_distance) < float(scroll_deadzone):
			return
		_dragging = true
		scroll_vertical = _drag_origin_scroll - roundi(vertical_distance)
		get_viewport().set_input_as_handled()
