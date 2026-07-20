class_name InfrastructureGlyph
extends Control

static var _icon_cache: Dictionary = {}

var category := "support"
var scene_variant := ""
var icon_texture: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(SkinTokens.TOUCH_MINIMUM, SkinTokens.TOUCH_MINIMUM)
	queue_redraw()


func set_category(next_category: String) -> void:
	category = next_category
	tooltip_text = "%s infrastructure" % category.capitalize()
	queue_redraw()


func set_asset(icon_path: String, next_scene_variant: String = "") -> void:
	scene_variant = next_scene_variant
	if icon_path.is_empty():
		icon_texture = null
	elif _icon_cache.has(icon_path):
		icon_texture = _icon_cache[icon_path] as Texture2D
	else:
		icon_texture = load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null
		_icon_cache[icon_path] = icon_texture
	tooltip_text = "%s • %s" % [scene_variant.replace("_", " ").capitalize(), category.capitalize()]
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var color := _category_color()
	draw_circle(center, minf(size.x, size.y) * 0.40, SkinTokens.COLOR_GRAPHITE_RAISED)
	draw_arc(center, minf(size.x, size.y) * 0.40, 0.0, TAU, 24, color, 2.0)
	if icon_texture != null:
		var icon_size := minf(size.x, size.y) * 0.68
		draw_texture_rect(icon_texture, Rect2(center - Vector2(icon_size, icon_size) * 0.5, Vector2(icon_size, icon_size)), false)
		return
	match category:
		"generation":
			draw_line(center + Vector2(-5.0, -13.0), center + Vector2(4.0, -2.0), color, 3.0)
			draw_line(center + Vector2(4.0, -2.0), center + Vector2(-2.0, -2.0), color, 3.0)
			draw_line(center + Vector2(-2.0, -2.0), center + Vector2(6.0, 13.0), color, 3.0)
		"transmission":
			draw_circle(center + Vector2(-9.0, 0.0), 4.0, color)
			draw_circle(center + Vector2(9.0, 0.0), 4.0, color)
			draw_line(center + Vector2(-5.0, 0.0), center + Vector2(5.0, 0.0), color, 3.0)
		"reserve":
			var battery := Rect2(center - Vector2(11.0, 8.0), Vector2(22.0, 16.0))
			draw_rect(battery, color, false, 3.0)
			draw_rect(Rect2(center + Vector2(11.0, -3.0), Vector2(3.0, 6.0)), color)
		"upgrade":
			draw_arc(center, 9.0, 0.0, TAU, 12, color, 3.0)
			for angle_index: int in 6:
				var direction := Vector2.from_angle(float(angle_index) * TAU / 6.0)
				draw_line(center + direction * 9.0, center + direction * 14.0, color, 3.0)
		_:
			draw_arc(center, 12.0, 0.0, TAU, 16, color, 3.0)
			draw_line(center + Vector2(0.0, -12.0), center + Vector2(0.0, 12.0), color, 2.0)
			draw_line(center + Vector2(-12.0, 0.0), center + Vector2(12.0, 0.0), color, 2.0)


func _category_color() -> Color:
	match category:
		"generation": return SkinTokens.COLOR_GENERATION
		"transmission": return SkinTokens.COLOR_TRANSMISSION
		"reserve": return SkinTokens.COLOR_RESERVE
		"upgrade": return SkinTokens.COLOR_WATT
		_: return SkinTokens.COLOR_IVORY_DIM
