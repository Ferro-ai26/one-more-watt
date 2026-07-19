extends MarginContainer

## Applies mobile cutout and system-bar insets without coupling child screens to
## platform APIs. Desktop/editor windows keep zero insets for resize testing.


func _ready() -> void:
	get_window().size_changed.connect(_apply_safe_area)
	_apply_safe_area()


func _apply_safe_area() -> void:
	var margins := Rect2i()
	if OS.has_feature("mobile"):
		margins = _scaled_safe_margins()

	add_theme_constant_override("margin_left", margins.position.x)
	add_theme_constant_override("margin_top", margins.position.y)
	add_theme_constant_override("margin_right", margins.size.x)
	add_theme_constant_override("margin_bottom", margins.size.y)


func _scaled_safe_margins() -> Rect2i:
	var screen_size := DisplayServer.screen_get_size()
	var safe_rect := DisplayServer.get_display_safe_area()
	if screen_size.x <= 0 or screen_size.y <= 0 or safe_rect.size.x <= 0 or safe_rect.size.y <= 0:
		return Rect2i()

	var scale := Vector2(size) / Vector2(screen_size)
	var left := roundi(maxi(safe_rect.position.x, 0) * scale.x)
	var top := roundi(maxi(safe_rect.position.y, 0) * scale.y)
	var right_pixels := maxi(screen_size.x - safe_rect.end.x, 0)
	var bottom_pixels := maxi(screen_size.y - safe_rect.end.y, 0)
	var right := roundi(right_pixels * scale.x)
	var bottom := roundi(bottom_pixels * scale.y)
	return Rect2i(left, top, right, bottom)
