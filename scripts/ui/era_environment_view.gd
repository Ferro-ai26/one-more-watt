class_name EraEnvironmentView
extends Control

var skin: EraSkinDefinition
var reduced_motion := false
var power_online := true
var authorization_ready := true
var owned_counts: Dictionary = {}
var _pulse := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if skin == null:
		set_skin(EraSkinRegistry.get_skin(EraSkinRegistry.ERA_01_ID))
	set_process(true)


func _process(delta: float) -> void:
	if reduced_motion:
		return
	_pulse = fmod(_pulse + delta * 0.55, 1.0)
	queue_redraw()


func set_skin(next_skin: EraSkinDefinition) -> void:
	if next_skin == null:
		next_skin = EraSkinRegistry.get_skin(EraSkinRegistry.BASE_ID)
	skin = next_skin
	queue_redraw()


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	_pulse = 0.45
	queue_redraw()


func set_runtime_state(counts: Dictionary, is_online: bool, can_authorize: bool) -> void:
	owned_counts = counts.duplicate()
	power_online = is_online
	authorization_ready = can_authorize
	queue_redraw()


func _draw() -> void:
	if skin == null:
		return
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, skin.background_color)
	_draw_wall_and_desk(area)
	_draw_infrastructure(area)
	_draw_power_paths(area)
	_draw_watt(area)
	_draw_operator_plate(area)


func _draw_wall_and_desk(area: Rect2) -> void:
	draw_rect(Rect2(0.0, 0.0, area.size.x, area.size.y * 0.72), skin.wall_color)
	draw_rect(Rect2(0.0, area.size.y * 0.72, area.size.x, area.size.y * 0.28), skin.surface_color)
	draw_line(Vector2(0.0, area.size.y * 0.72), Vector2(area.size.x, area.size.y * 0.72), SkinTokens.COLOR_SHADOW, 4.0)
	# Old wall label and fasteners establish the practical, painted workshop.
	draw_rect(Rect2(area.size.x * 0.06, area.size.y * 0.12, area.size.x * 0.28, area.size.y * 0.16), SkinTokens.COLOR_IVORY_DIM)
	draw_string(get_theme_default_font(), Vector2(area.size.x * 0.08, area.size.y * 0.22), "AUTHORIZED LOAD", HORIZONTAL_ALIGNMENT_LEFT, -1.0, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_INK)
	for point: Vector2 in [Vector2(8, 8), Vector2(area.size.x - 8, 8), Vector2(8, area.size.y - 8), Vector2(area.size.x - 8, area.size.y - 8)]:
		draw_circle(point, 2.0, SkinTokens.COLOR_AGED_METAL)


func _draw_infrastructure(area: Rect2) -> void:
	var outlet := Rect2(area.size.x * 0.82, area.size.y * 0.25, area.size.x * 0.12, area.size.y * 0.22)
	draw_rect(outlet, SkinTokens.COLOR_IVORY)
	draw_rect(outlet, SkinTokens.COLOR_INK, false, 2.0)
	draw_circle(Vector2(outlet.position.x + outlet.size.x * 0.35, outlet.position.y + outlet.size.y * 0.48), 2.5, SkinTokens.COLOR_INK)
	draw_circle(Vector2(outlet.position.x + outlet.size.x * 0.65, outlet.position.y + outlet.size.y * 0.48), 2.5, SkinTokens.COLOR_INK)
	var battery_count := mini(int(owned_counts.get("portable_battery", 1)), 3)
	for index: int in battery_count:
		var battery := Rect2(area.size.x * (0.08 + index * 0.09), area.size.y * 0.76, area.size.x * 0.07, area.size.y * 0.13)
		draw_rect(battery, SkinTokens.COLOR_GRAPHITE_RAISED)
		draw_rect(battery, SkinTokens.COLOR_GENERATION, false, 2.0)
	var fan_center := Vector2(area.size.x * 0.72, area.size.y * 0.77)
	draw_circle(fan_center, area.size.y * 0.085, SkinTokens.COLOR_GRAPHITE)
	for angle_index: int in 4:
		var angle := float(angle_index) * PI * 0.5 + (_pulse * TAU if not reduced_motion else 0.0)
		draw_line(fan_center, fan_center + Vector2.from_angle(angle) * area.size.y * 0.065, SkinTokens.COLOR_IVORY_DIM, 3.0)


func _draw_power_paths(area: Rect2) -> void:
	for normalized_path: PackedVector2Array in skin.power_flow_paths:
		var points := PackedVector2Array()
		for point: Vector2 in normalized_path:
			points.append(Vector2(point.x * area.size.x, point.y * area.size.y))
		draw_polyline(points, SkinTokens.COLOR_SHADOW, 7.0, true)
		draw_polyline(points, SkinTokens.COLOR_WATT if power_online else SkinTokens.COLOR_DISABLED, 3.0, true)
		if power_online and not reduced_motion and points.size() > 1:
			var segment := mini(int(_pulse * float(points.size() - 1)), points.size() - 2)
			var local_t := fmod(_pulse * float(points.size() - 1), 1.0)
			draw_circle(points[segment].lerp(points[segment + 1], local_t), 4.0, SkinTokens.COLOR_WATT_REBOOT)


func _draw_watt(area: Rect2) -> void:
	var core_size := Vector2(area.size.x * 0.25, area.size.y * 0.38)
	var core := Rect2(Vector2(area.size.x * 0.50 - core_size.x * 0.5, area.size.y * 0.36), core_size)
	draw_rect(core, SkinTokens.COLOR_GRAPHITE_RAISED)
	draw_rect(core, SkinTokens.COLOR_AGED_METAL, false, 3.0)
	var display := core.grow(-core.size.y * 0.19)
	draw_rect(display, SkinTokens.COLOR_INK)
	var eye_color := SkinTokens.COLOR_WATT_REBOOT if power_online else SkinTokens.COLOR_DISABLED
	var eye_y := display.position.y + display.size.y * 0.43
	draw_circle(Vector2(display.position.x + display.size.x * 0.31, eye_y), 4.0, eye_color)
	draw_circle(Vector2(display.position.x + display.size.x * 0.69, eye_y), 4.0, eye_color)
	draw_arc(Vector2(display.get_center().x, display.position.y + display.size.y * 0.59), display.size.x * 0.16, 0.15, PI - 0.15, 12, eye_color, 2.0)
	# Persistent scratches keep WATT's original core recognizable at every scale.
	draw_line(core.position + Vector2(core.size.x * 0.14, core.size.y * 0.17), core.position + Vector2(core.size.x * 0.31, core.size.y * 0.11), SkinTokens.COLOR_IVORY_DIM, 1.0)
	draw_line(core.position + Vector2(core.size.x * 0.72, core.size.y * 0.87), core.position + Vector2(core.size.x * 0.88, core.size.y * 0.76), SkinTokens.COLOR_IVORY_DIM, 1.0)


func _draw_operator_plate(area: Rect2) -> void:
	var plate := Rect2(area.size.x * 0.04, area.size.y * 0.89, area.size.x * 0.92, area.size.y * 0.085)
	draw_rect(plate, SkinTokens.COLOR_INK)
	draw_rect(plate, SkinTokens.COLOR_WATT if authorization_ready else SkinTokens.COLOR_DISABLED, false, 1.0)
	var state_text := "OPERATOR HANDSHAKE READY" if authorization_ready else "OPERATOR LINK HOLD"
	draw_string(get_theme_default_font(), plate.position + Vector2(8.0, plate.size.y * 0.68), "%s  •  %s" % [skin.scale_label, state_text], HORIZONTAL_ALIGNMENT_LEFT, plate.size.x - 16.0, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_IVORY)
