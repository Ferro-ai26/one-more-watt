class_name EraEnvironmentView
extends Control

const EXPRESSIONS := ["curious", "pleased", "thinking", "concerned", "complete"]

var skin: EraSkinDefinition
var reduced_motion := false
var power_online := true
var brownout_active := false
var authorization_ready := true
var reserve_state := "ready"
var expression := "curious"
var owned_counts: Dictionary = {}
var last_installation := ""
var _pulse := 0.0
var _installation_pulse := 0.0
var _transition_progress := -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if skin == null:
		set_skin(EraSkinRegistry.get_skin(EraSkinRegistry.ERA_01_ID))
	set_process(true)


func _process(delta: float) -> void:
	if reduced_motion:
		return
	_pulse = fmod(_pulse + delta * 0.42, 1.0)
	_installation_pulse = maxf(_installation_pulse - delta * 0.8, 0.0)
	if _transition_progress >= 0.0:
		_transition_progress = minf(_transition_progress + delta / 2.2, 1.0)
	queue_redraw()


func set_skin(next_skin: EraSkinDefinition) -> void:
	if next_skin == null:
		next_skin = EraSkinRegistry.get_skin(EraSkinRegistry.BASE_ID)
	if skin != null and skin.skin_id == next_skin.skin_id:
		return
	skin = next_skin
	queue_redraw()


func set_reduced_motion(enabled: bool) -> void:
	if reduced_motion == enabled:
		return
	reduced_motion = enabled
	_pulse = 0.45
	queue_redraw()


func set_runtime_state(counts: Dictionary, is_online: bool, can_authorize: bool, is_brownout: bool = false, next_reserve_state: String = "ready", next_expression: String = "curious") -> void:
	var resolved_expression := next_expression if next_expression in EXPRESSIONS else "curious"
	var unchanged := owned_counts == counts and power_online == is_online and authorization_ready == can_authorize and brownout_active == is_brownout and reserve_state == next_reserve_state and expression == resolved_expression
	if unchanged:
		return
	owned_counts = counts.duplicate()
	power_online = is_online
	authorization_ready = can_authorize
	brownout_active = is_brownout
	reserve_state = next_reserve_state
	expression = resolved_expression
	queue_redraw()


func cue_installation(content_id: String) -> void:
	last_installation = content_id
	_installation_pulse = 1.0
	queue_redraw()


func start_capstone_pullback() -> void:
	_transition_progress = 1.0 if reduced_motion else 0.0
	queue_redraw()


func finish_capstone_pullback() -> void:
	_transition_progress = -1.0
	queue_redraw()


func representative_state() -> String:
	var total := 0
	for value: Variant in owned_counts.values():
		total += maxi(int(value), 0)
	if total >= 20:
		return "facility"
	if total >= 10:
		return "bank"
	if total >= 4:
		return "cluster"
	return "single"


func _draw() -> void:
	if skin == null:
		return
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, skin.background_color)
	match skin.era_number:
		2: _draw_room(area)
		3: _draw_house(area)
		4: _draw_building(area)
		5: _draw_neighborhood(area)
		_: _draw_desk(area)
	_draw_power_paths(area)
	_draw_watt(area)
	_draw_operator_plate(area)
	_draw_state_beacons(area)
	_draw_transition(area)


func _draw_desk(area: Rect2) -> void:
	_draw_shell(area, 0.70)
	var pegboard := Rect2(area.size.x * 0.05, area.size.y * 0.10, area.size.x * 0.30, area.size.y * 0.28)
	draw_rect(pegboard, SkinTokens.COLOR_ERA_01_DESK)
	draw_rect(pegboard, SkinTokens.COLOR_AGED_METAL, false, 2.0)
	for x_index: int in 5:
		for y_index: int in 3:
			draw_circle(pegboard.position + Vector2(12.0 + x_index * pegboard.size.x / 5.5, 12.0 + y_index * pegboard.size.y / 3.5), 1.4, SkinTokens.COLOR_SHADOW)
	var monitor := Rect2(area.size.x * 0.08, area.size.y * 0.43, area.size.x * 0.22, area.size.y * 0.20)
	draw_rect(monitor, SkinTokens.COLOR_AGED_METAL)
	draw_rect(monitor.grow(-4.0), SkinTokens.COLOR_GLASS_DARK)
	draw_line(Vector2(monitor.get_center().x, monitor.end.y), Vector2(monitor.get_center().x, area.size.y * 0.70), SkinTokens.COLOR_SHADOW, 4.0)
	_draw_outlet(Rect2(area.size.x * 0.83, area.size.y * 0.24, area.size.x * 0.11, area.size.y * 0.18))
	_draw_battery_bank(area, Vector2(area.size.x * 0.10, area.size.y * 0.73), mini(int(owned_counts.get("laptop_battery", 0)), 3), 0.075)
	_draw_fan(area, Vector2(area.size.x * 0.76, area.size.y * 0.75), 0.065, int(owned_counts.get("tiny_desk_fan", 0)) > 0)
	_draw_warm_lamp(area, Vector2(area.size.x * 0.90, area.size.y * 0.12), power_online)


func _draw_room(area: Rect2) -> void:
	_draw_shell(area, 0.78)
	var nested_desk := Rect2(area.size.x * 0.34, area.size.y * 0.48, area.size.x * 0.34, area.size.y * 0.27)
	draw_rect(nested_desk, SkinTokens.COLOR_ERA_01_DESK)
	draw_rect(nested_desk, SkinTokens.COLOR_AGED_METAL, false, 2.0)
	var bed := Rect2(area.size.x * 0.03, area.size.y * 0.62, area.size.x * 0.25, area.size.y * 0.14)
	draw_rect(bed, SkinTokens.COLOR_IVORY_DIM)
	draw_rect(bed, SkinTokens.COLOR_SHADOW, false, 2.0)
	draw_rect(Rect2(bed.position + Vector2(5.0, 4.0), Vector2(bed.size.x * 0.28, bed.size.y * 0.45)), SkinTokens.COLOR_IVORY)
	var window := Rect2(area.size.x * 0.72, area.size.y * 0.10, area.size.x * 0.22, area.size.y * 0.27)
	draw_rect(window, SkinTokens.COLOR_GLASS_DARK)
	draw_rect(window, SkinTokens.COLOR_AGED_METAL, false, 3.0)
	draw_line(Vector2(window.get_center().x, window.position.y), Vector2(window.get_center().x, window.end.y), SkinTokens.COLOR_AGED_METAL, 2.0)
	_draw_generator(Rect2(area.size.x * 0.05, area.size.y * 0.35, area.size.x * 0.22, area.size.y * 0.20), int(owned_counts.get("portable_generator", 0)) > 0)
	_draw_battery_bank(area, Vector2(area.size.x * 0.73, area.size.y * 0.64), mini(int(owned_counts.get("home_battery", 0)), 3), 0.085)
	_draw_fan(area, Vector2(area.size.x * 0.84, area.size.y * 0.47), 0.055, int(owned_counts.get("gaming_gpu", 0)) > 0)
	_draw_warm_lamp(area, Vector2(area.size.x * 0.14, area.size.y * 0.13), not brownout_active)


func _draw_house(area: Rect2) -> void:
	draw_rect(Rect2(0.0, 0.0, area.size.x, area.size.y * 0.82), skin.wall_color)
	var roof := PackedVector2Array([Vector2(0.0, area.size.y * 0.20), Vector2(area.size.x * 0.50, area.size.y * 0.02), Vector2(area.size.x, area.size.y * 0.20)])
	draw_polyline(roof, SkinTokens.COLOR_AGED_METAL, 5.0)
	for x_fraction: float in [0.32, 0.67]:
		draw_line(Vector2(area.size.x * x_fraction, area.size.y * 0.20), Vector2(area.size.x * x_fraction, area.size.y * 0.82), SkinTokens.COLOR_SHADOW, 3.0)
	draw_line(Vector2(0.0, area.size.y * 0.52), Vector2(area.size.x, area.size.y * 0.52), SkinTokens.COLOR_SHADOW, 3.0)
	var fridge := Rect2(area.size.x * 0.04, area.size.y * 0.27, area.size.x * 0.13, area.size.y * 0.22)
	draw_rect(fridge, SkinTokens.COLOR_CERAMIC_SHADOW)
	draw_line(Vector2(fridge.position.x, fridge.position.y + fridge.size.y * 0.62), Vector2(fridge.end.x, fridge.position.y + fridge.size.y * 0.62), SkinTokens.COLOR_AGED_METAL, 1.0)
	draw_circle(Vector2(fridge.end.x - 6.0, fridge.position.y + 8.0), 1.5, SkinTokens.COLOR_DISABLED)
	draw_rect(Rect2(area.size.x * 0.19, area.size.y * 0.44, area.size.x * 0.04, area.size.y * 0.035), SkinTokens.COLOR_IVORY_DIM)
	_draw_server_bank(area, Rect2(area.size.x * 0.70, area.size.y * 0.23, area.size.x * 0.24, area.size.y * 0.54), mini(int(owned_counts.get("server_rack", 0)), 4))
	_draw_battery_bank(area, Vector2(area.size.x * 0.06, area.size.y * 0.59), mini(int(owned_counts.get("whole_home_battery", 0)), 3), 0.10)
	_draw_generator(Rect2(area.size.x * 0.72, area.size.y * 0.62, area.size.x * 0.22, area.size.y * 0.15), int(owned_counts.get("backup_generator", 0)) > 0)
	_draw_fan(area, Vector2(area.size.x * 0.57, area.size.y * 0.34), 0.07, int(owned_counts.get("dedicated_cooling", 0)) > 0)
	var transformer := Rect2(area.size.x * 0.02, area.size.y * 0.83, area.size.x * 0.18, area.size.y * 0.12)
	draw_rect(transformer, SkinTokens.COLOR_GRAPHITE_RAISED if int(owned_counts.get("outdoor_transformer", 0)) > 0 else SkinTokens.COLOR_SHADOW)
	draw_rect(transformer, SkinTokens.COLOR_TRANSMISSION, false, 2.0)


func _draw_building(area: Rect2) -> void:
	draw_rect(Rect2(area.size.x * 0.03, area.size.y * 0.04, area.size.x * 0.94, area.size.y * 0.84), skin.wall_color)
	draw_rect(Rect2(area.size.x * 0.05, area.size.y * 0.07, area.size.x * 0.90, area.size.y * 0.78), SkinTokens.COLOR_SHADOW, false, 3.0)
	var floor_height := area.size.y * 0.13
	for floor_index: int in 5:
		var y := area.size.y * 0.12 + floor_index * floor_height
		var floor_rect := Rect2(area.size.x * 0.07, y, area.size.x * 0.86, floor_height - 5.0)
		var ordinary_online := floor_index in [0, 3] and not brownout_active
		draw_rect(floor_rect, SkinTokens.COLOR_ERA_04_WARM_FLOOR if ordinary_online else SkinTokens.COLOR_ERA_04_DIM_FLOOR)
		draw_line(Vector2(floor_rect.position.x, floor_rect.end.y), Vector2(floor_rect.end.x, floor_rect.end.y), SkinTokens.COLOR_AGED_METAL, 2.0)
		for window_index: int in 4:
			var window := Rect2(floor_rect.position + Vector2(8.0 + window_index * floor_rect.size.x * 0.19, 8.0), Vector2(floor_rect.size.x * 0.11, floor_rect.size.y * 0.44))
			draw_rect(window, SkinTokens.COLOR_WARM_LIGHT if ordinary_online and window_index == 0 else SkinTokens.COLOR_GLASS_DARK)
	# Central cyan riser and dim elevator bank are the dominant scale contradiction.
	var riser := Rect2(area.size.x * 0.47, area.size.y * 0.08, area.size.x * 0.07, area.size.y * 0.78)
	draw_rect(riser, SkinTokens.COLOR_GRAPHITE_RAISED)
	draw_rect(riser, SkinTokens.COLOR_WATT if power_online else SkinTokens.COLOR_DISABLED, false, 3.0)
	for junction: int in 5:
		draw_circle(Vector2(riser.get_center().x, area.size.y * (0.17 + junction * 0.13)), 3.0, SkinTokens.COLOR_WATT_REBOOT if power_online else SkinTokens.COLOR_DISABLED)
	var elevator := Rect2(area.size.x * 0.73, area.size.y * 0.13, area.size.x * 0.14, area.size.y * 0.63)
	draw_rect(elevator, SkinTokens.COLOR_ERA_04_DIM_FLOOR)
	draw_rect(elevator, SkinTokens.COLOR_EMERGENCY_LIGHT, false, 2.0)
	for floor_index: int in 4:
		draw_line(Vector2(elevator.position.x + 5.0, elevator.position.y + 12.0 + floor_index * elevator.size.y / 4.4), Vector2(elevator.end.x - 5.0, elevator.position.y + 12.0 + floor_index * elevator.size.y / 4.4), SkinTokens.COLOR_DISABLED, 2.0)
	# Rooftop solar and cooling plant read as one representative cluster.
	var roof_y := area.size.y * 0.075
	draw_line(Vector2(area.size.x * 0.10, roof_y), Vector2(area.size.x * 0.36, roof_y - area.size.y * 0.05), SkinTokens.COLOR_GENERATION, 5.0)
	draw_line(Vector2(area.size.x * 0.12, roof_y + 3.0), Vector2(area.size.x * 0.37, roof_y - area.size.y * 0.047), SkinTokens.COLOR_WATT, 2.0)
	_draw_fan(area, Vector2(area.size.x * 0.66, area.size.y * 0.075), 0.045, int(owned_counts.get("central_cooling", 0)) > 0)
	_draw_fan(area, Vector2(area.size.x * 0.78, area.size.y * 0.075), 0.045, int(owned_counts.get("central_cooling", 0)) > 0)
	# Ground-level service masses keep infrastructure representative, not one-to-one.
	var transformer := Rect2(area.size.x * 0.06, area.size.y * 0.76, area.size.x * 0.20, area.size.y * 0.10)
	draw_rect(transformer, SkinTokens.COLOR_GRAPHITE_RAISED)
	draw_rect(transformer, SkinTokens.COLOR_TRANSMISSION, false, 3.0)
	for coil_x: float in [0.10, 0.16, 0.22]:
		draw_circle(Vector2(area.size.x * coil_x, area.size.y * 0.81), 5.0, SkinTokens.COLOR_CERAMIC_SHADOW)
	_draw_battery_bank(area, Vector2(area.size.x * 0.76, area.size.y * 0.77), mini(int(owned_counts.get("commercial_battery_room", 0)), 3), 0.055)
	# The approved absurd orange emergency extension route remains visibly separate from cyan power.
	var stair_points := PackedVector2Array([
		Vector2(area.size.x * 0.91, area.size.y * 0.72), Vector2(area.size.x * 0.84, area.size.y * 0.64),
		Vector2(area.size.x * 0.91, area.size.y * 0.56), Vector2(area.size.x * 0.84, area.size.y * 0.48),
		Vector2(area.size.x * 0.91, area.size.y * 0.40), Vector2(area.size.x * 0.84, area.size.y * 0.32),
	])
	draw_polyline(stair_points, SkinTokens.COLOR_EMERGENCY_LIGHT if int(owned_counts.get("emergency_extension_stairwell", 0)) > 0 else SkinTokens.COLOR_DISABLED, 4.0, true)
	# Distributed lobby face demonstrates reach while the physical core remains present.
	var lobby_screen := Rect2(area.size.x * 0.28, area.size.y * 0.69, area.size.x * 0.13, area.size.y * 0.075)
	draw_rect(lobby_screen, SkinTokens.COLOR_GLASS_DARK)
	draw_rect(lobby_screen, SkinTokens.COLOR_WATT, false, 2.0)
	for eye_x: float in [0.32, 0.37]:
		draw_circle(Vector2(area.size.x * eye_x, area.size.y * 0.727), 2.2, SkinTokens.COLOR_WATT_REBOOT)
	# One tiny bicycle/plant remnant prevents the scene from becoming abstract machinery.
	draw_circle(Vector2(area.size.x * 0.12, area.size.y * 0.70), 5.0, SkinTokens.COLOR_IVORY_DIM, false, 1.5)
	draw_circle(Vector2(area.size.x * 0.18, area.size.y * 0.70), 5.0, SkinTokens.COLOR_IVORY_DIM, false, 1.5)
	draw_line(Vector2(area.size.x * 0.12, area.size.y * 0.70), Vector2(area.size.x * 0.15, area.size.y * 0.66), SkinTokens.COLOR_IVORY_DIM, 1.5)
	draw_line(Vector2(area.size.x * 0.15, area.size.y * 0.66), Vector2(area.size.x * 0.18, area.size.y * 0.70), SkinTokens.COLOR_IVORY_DIM, 1.5)


func _draw_neighborhood(area: Rect2) -> void:
	# Blue-hour representative blocks; the earlier Building remains a nested node at left.
	draw_rect(Rect2(0.0, area.size.y * 0.68, area.size.x, area.size.y * 0.32), SkinTokens.COLOR_ERA_05_STREET)
	for block: Rect2 in [
		Rect2(area.size.x * 0.03, area.size.y * 0.12, area.size.x * 0.25, area.size.y * 0.48),
		Rect2(area.size.x * 0.31, area.size.y * 0.20, area.size.x * 0.20, area.size.y * 0.32),
		Rect2(area.size.x * 0.73, area.size.y * 0.18, area.size.x * 0.22, area.size.y * 0.36),
	]:
		draw_rect(block, SkinTokens.COLOR_ERA_05_BLOCK)
		draw_rect(block, SkinTokens.COLOR_AGED_METAL, false, 2.0)
		for row: int in 2:
			for column: int in 3:
				var window := Rect2(block.position + Vector2(7.0 + column * block.size.x * 0.27, 10.0 + row * block.size.y * 0.30), Vector2(block.size.x * 0.12, block.size.y * 0.12))
				var warm := row == 0 and column == 0 and not brownout_active
				draw_rect(window, SkinTokens.COLOR_WARM_LIGHT if warm else SkinTokens.COLOR_GLASS_DARK)
	# Nested Building Network: vertical cyan riser survives at the left edge.
	var nested := Rect2(area.size.x * 0.055, area.size.y * 0.17, area.size.x * 0.18, area.size.y * 0.39)
	for floor_index: int in 4:
		var y := nested.position.y + float(floor_index) * nested.size.y / 4.0
		draw_line(Vector2(nested.position.x, y), Vector2(nested.end.x, y), SkinTokens.COLOR_SHADOW, 2.0)
	draw_line(Vector2(nested.position.x + nested.size.x * 0.65, nested.position.y), Vector2(nested.position.x + nested.size.x * 0.65, nested.end.y), SkinTokens.COLOR_WATT, 3.0)
	# Dominant civic substation and distributed WATT terminal.
	var substation := Rect2(area.size.x * 0.42, area.size.y * 0.32, area.size.x * 0.24, area.size.y * 0.28)
	draw_rect(substation, SkinTokens.COLOR_GRAPHITE_RAISED)
	draw_rect(substation, SkinTokens.COLOR_TRANSMISSION, false, 3.0)
	for coil_x: float in [0.46, 0.52, 0.58]:
		draw_circle(Vector2(area.size.x * coil_x, area.size.y * 0.52), 6.0, SkinTokens.COLOR_CERAMIC_SHADOW)
	var civic_display := Rect2(area.size.x * 0.49, area.size.y * 0.35, area.size.x * 0.11, area.size.y * 0.09)
	draw_rect(civic_display, SkinTokens.COLOR_GLASS_DARK)
	draw_rect(civic_display, SkinTokens.COLOR_WATT, false, 2.0)
	for eye_x: float in [0.52, 0.57]:
		draw_circle(Vector2(area.size.x * eye_x, area.size.y * 0.395), 3.0, SkinTokens.COLOR_WATT_REBOOT)
	# Solar/generation and Reserve clusters stay readable without per-unit rendering.
	if int(owned_counts.get("community_solar_farm", 0)) > 0:
		for index: int in 3:
			var start := Vector2(area.size.x * (0.70 + index * 0.075), area.size.y * (0.20 + index * 0.008))
			draw_line(start, start + Vector2(area.size.x * 0.06, -area.size.y * 0.045), SkinTokens.COLOR_GENERATION, 5.0)
	if int(owned_counts.get("municipal_generator", 0)) > 0:
		_draw_generator(Rect2(area.size.x * 0.69, area.size.y * 0.55, area.size.x * 0.13, area.size.y * 0.12), true)
	if int(owned_counts.get("battery_warehouse", 0)) > 0:
		var warehouse := Rect2(area.size.x * 0.82, area.size.y * 0.56, area.size.x * 0.15, area.size.y * 0.12)
		draw_rect(warehouse, SkinTokens.COLOR_GRAPHITE)
		draw_rect(warehouse, SkinTokens.COLOR_RESERVE, false, 2.0)
		for bay: int in 3:
			draw_rect(Rect2(warehouse.position + Vector2(5.0 + bay * warehouse.size.x * 0.29, 6.0), Vector2(warehouse.size.x * 0.18, warehouse.size.y * 0.42)), SkinTokens.COLOR_WATT if power_online else SkinTokens.COLOR_DISABLED)
	# Underground authored path and edge water turbine.
	draw_line(Vector2(0.0, area.size.y * 0.80), Vector2(area.size.x, area.size.y * 0.80), SkinTokens.COLOR_AGED_METAL, 2.0)
	if int(owned_counts.get("underground_distribution", 0)) > 0:
		draw_line(Vector2(area.size.x * 0.12, area.size.y * 0.84), Vector2(area.size.x * 0.88, area.size.y * 0.84), SkinTokens.COLOR_WATT, 4.0)
	for node_x: float in [0.18, 0.48, 0.78]:
		draw_circle(Vector2(area.size.x * node_x, area.size.y * 0.84), 4.0, SkinTokens.COLOR_AGED_METAL)
	if int(owned_counts.get("small_hydroelectric_plant", 0)) > 0:
		draw_line(Vector2(area.size.x * 0.78, area.size.y * 0.92), Vector2(area.size.x, area.size.y * 0.90), SkinTokens.COLOR_TRANSMISSION, 7.0)
		_draw_fan(area, Vector2(area.size.x * 0.90, area.size.y * 0.86), 0.035, true)
	# Temporary-looking boundary clamp advertises the absurd external connection.
	if int(owned_counts.get("borrowed_utility_connection", 0)) > 0:
		draw_line(Vector2(area.size.x, area.size.y * 0.35), Vector2(area.size.x * 0.91, area.size.y * 0.35), SkinTokens.COLOR_WATT, 8.0)
		draw_rect(Rect2(area.size.x * 0.88, area.size.y * 0.31, area.size.x * 0.06, area.size.y * 0.08), SkinTokens.COLOR_EMERGENCY_LIGHT, false, 3.0)
	# Tiny ordinary-life remnants: bicycle and official porch priority label.
	draw_circle(Vector2(area.size.x * 0.32, area.size.y * 0.64), 4.0, SkinTokens.COLOR_IVORY_DIM, false, 1.5)
	draw_circle(Vector2(area.size.x * 0.37, area.size.y * 0.64), 4.0, SkinTokens.COLOR_IVORY_DIM, false, 1.5)
	draw_line(Vector2(area.size.x * 0.32, area.size.y * 0.64), Vector2(area.size.x * 0.345, area.size.y * 0.60), SkinTokens.COLOR_IVORY_DIM, 1.5)
	draw_string(get_theme_default_font(), Vector2(area.size.x * 0.67, area.size.y * 0.66), "PORCH PRIORITY 04", HORIZONTAL_ALIGNMENT_LEFT, area.size.x * 0.25, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_EMERGENCY_LIGHT)


func _draw_shell(area: Rect2, surface_y: float) -> void:
	draw_rect(Rect2(0.0, 0.0, area.size.x, area.size.y * surface_y), skin.wall_color)
	draw_rect(Rect2(0.0, area.size.y * surface_y, area.size.x, area.size.y * (1.0 - surface_y)), skin.surface_color)
	draw_line(Vector2(0.0, area.size.y * surface_y), Vector2(area.size.x, area.size.y * surface_y), SkinTokens.COLOR_SHADOW, 4.0)
	for point: Vector2 in [Vector2(8, 8), Vector2(area.size.x - 8, 8), Vector2(8, area.size.y - 8), Vector2(area.size.x - 8, area.size.y - 8)]:
		draw_circle(point, 2.0, SkinTokens.COLOR_AGED_METAL)


func _draw_outlet(rect: Rect2) -> void:
	draw_rect(rect, SkinTokens.COLOR_IVORY)
	draw_rect(rect, SkinTokens.COLOR_INK, false, 2.0)
	for x_fraction: float in [0.35, 0.65]:
		draw_circle(Vector2(rect.position.x + rect.size.x * x_fraction, rect.position.y + rect.size.y * 0.48), 2.5, SkinTokens.COLOR_INK)


func _draw_battery_bank(area: Rect2, origin: Vector2, count: int, width_fraction: float) -> void:
	for index: int in mini(maxi(count, 1), 3):
		var battery := Rect2(origin + Vector2(index * area.size.x * (width_fraction + 0.015), 0.0), Vector2(area.size.x * width_fraction, area.size.y * 0.12))
		draw_rect(battery, SkinTokens.COLOR_GRAPHITE_RAISED if count > 0 else SkinTokens.COLOR_SHADOW)
		draw_rect(battery, SkinTokens.COLOR_RESERVE if count > 0 else SkinTokens.COLOR_DISABLED, false, 2.0)
		draw_rect(Rect2(battery.position + Vector2(battery.size.x * 0.25, -2.0), Vector2(battery.size.x * 0.50, 3.0)), SkinTokens.COLOR_AGED_METAL)


func _draw_fan(area: Rect2, center: Vector2, radius_fraction: float, installed: bool) -> void:
	var radius := area.size.y * radius_fraction
	draw_circle(center, radius, SkinTokens.COLOR_GRAPHITE)
	draw_arc(center, radius, 0.0, TAU, 24, SkinTokens.COLOR_AGED_METAL, 2.0)
	for angle_index: int in 4:
		var angle := float(angle_index) * PI * 0.5 + (_pulse * TAU if installed and not reduced_motion else 0.0)
		draw_line(center, center + Vector2.from_angle(angle) * radius * 0.76, SkinTokens.COLOR_IVORY_DIM if installed else SkinTokens.COLOR_DISABLED, 3.0)


func _draw_generator(rect: Rect2, installed: bool) -> void:
	draw_rect(rect, SkinTokens.COLOR_GRAPHITE_RAISED if installed else SkinTokens.COLOR_SHADOW)
	draw_rect(rect, SkinTokens.COLOR_GENERATION if installed else SkinTokens.COLOR_DISABLED, false, 2.0)
	draw_circle(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.22, SkinTokens.COLOR_AGED_METAL)
	draw_circle(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.10, SkinTokens.COLOR_INK)


func _draw_server_bank(area: Rect2, rect: Rect2, count: int) -> void:
	for index: int in clampi(count, 1, 3):
		var rack := Rect2(rect.position + Vector2(index * rect.size.x / 3.0, 0.0), Vector2(rect.size.x / 3.4, rect.size.y))
		draw_rect(rack, SkinTokens.COLOR_GRAPHITE)
		draw_rect(rack, SkinTokens.COLOR_AGED_METAL, false, 2.0)
		for unit: int in 5:
			var y := rack.position.y + 8.0 + unit * (rack.size.y - 14.0) / 5.0
			draw_line(Vector2(rack.position.x + 4.0, y), Vector2(rack.end.x - 4.0, y), SkinTokens.COLOR_WATT if power_online and count > 0 else SkinTokens.COLOR_DISABLED, 1.0)
			draw_circle(Vector2(rack.end.x - 6.0, y - 2.0), 1.5, SkinTokens.COLOR_WATT_REBOOT if power_online and count > 0 else SkinTokens.COLOR_DISABLED)
	if count <= 0:
		draw_string(get_theme_default_font(), rect.position + Vector2(3.0, area.size.y * 0.05), "AUTHORIZED RACK BAY", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_DISABLED)


func _draw_warm_lamp(area: Rect2, anchor: Vector2, enabled: bool) -> void:
	draw_line(anchor, anchor + Vector2(0.0, area.size.y * 0.10), SkinTokens.COLOR_AGED_METAL, 3.0)
	var shade := PackedVector2Array([anchor + Vector2(-12.0, area.size.y * 0.10), anchor + Vector2(12.0, area.size.y * 0.10), anchor + Vector2(7.0, area.size.y * 0.15), anchor + Vector2(-7.0, area.size.y * 0.15)])
	draw_colored_polygon(shade, SkinTokens.COLOR_WARNING if enabled else SkinTokens.COLOR_DISABLED)
	if enabled:
		draw_circle(anchor + Vector2(0.0, area.size.y * 0.16), 3.0, SkinTokens.COLOR_WARM_LIGHT)


func _draw_power_paths(area: Rect2) -> void:
	for normalized_path: PackedVector2Array in skin.power_flow_paths:
		var points := PackedVector2Array()
		for point: Vector2 in normalized_path:
			points.append(Vector2(point.x * area.size.x, point.y * area.size.y))
		draw_polyline(points, SkinTokens.COLOR_SHADOW, 8.0, true)
		var path_color := SkinTokens.COLOR_CRITICAL if brownout_active else (SkinTokens.COLOR_WATT if power_online else SkinTokens.COLOR_DISABLED)
		draw_polyline(points, path_color, 3.0, true)
		if power_online and not brownout_active and not reduced_motion and points.size() > 1:
			var segment := mini(int(_pulse * float(points.size() - 1)), points.size() - 2)
			var local_t := fmod(_pulse * float(points.size() - 1), 1.0)
			draw_circle(points[segment].lerp(points[segment + 1], local_t), 4.0, SkinTokens.COLOR_WATT_REBOOT)


func _draw_watt(area: Rect2) -> void:
	var scale_factor := 0.16 if skin.era_number >= 4 else (0.23 if skin.era_number < 3 else 0.19)
	var core_size := Vector2(area.size.x * scale_factor, area.size.y * (0.24 if skin.era_number >= 4 else (0.34 if skin.era_number < 3 else 0.30)))
	var core_center := Vector2(area.size.x * (0.38 if skin.era_number >= 4 else 0.52), area.size.y * (0.81 if skin.era_number >= 4 else (0.52 if skin.era_number < 3 else 0.48)))
	var core := Rect2(core_center - core_size * 0.5, core_size)
	draw_rect(core, SkinTokens.COLOR_GRAPHITE_RAISED)
	draw_rect(core, SkinTokens.COLOR_AGED_METAL, false, 3.0)
	draw_rect(Rect2(core.position + Vector2(-4.0, core.size.y * 0.22), Vector2(5.0, core.size.y * 0.47)), SkinTokens.COLOR_AGED_METAL)
	var display := core.grow(-core.size.y * 0.19)
	draw_rect(display, SkinTokens.COLOR_INK)
	var eye_color := SkinTokens.COLOR_WATT if brownout_active else (SkinTokens.COLOR_WATT_REBOOT if power_online else SkinTokens.COLOR_DISABLED)
	var eye_y := display.position.y + display.size.y * 0.43
	var eye_spread := display.size.x * (0.25 if expression == "concerned" else 0.31)
	var eye_radius := 5.0 if expression in ["pleased", "complete"] else 4.0
	for direction: float in [-1.0, 1.0]:
		var eye := Vector2(display.get_center().x + direction * eye_spread, eye_y)
		if expression == "thinking" and direction > 0.0:
			draw_line(eye + Vector2(-4.0, 0.0), eye + Vector2(4.0, -2.0), eye_color, 3.0)
		else:
			draw_circle(eye, eye_radius, eye_color)
	if expression in ["pleased", "complete"]:
		draw_arc(Vector2(display.get_center().x, display.position.y + display.size.y * 0.62), display.size.x * 0.16, 0.15, PI - 0.15, 12, eye_color, 2.0)
	draw_line(core.position + Vector2(core.size.x * 0.14, core.size.y * 0.17), core.position + Vector2(core.size.x * 0.31, core.size.y * 0.11), SkinTokens.COLOR_IVORY_DIM, 1.0)
	draw_line(core.position + Vector2(core.size.x * 0.72, core.size.y * 0.87), core.position + Vector2(core.size.x * 0.88, core.size.y * 0.76), SkinTokens.COLOR_IVORY_DIM, 1.0)
	draw_line(core.position + Vector2(core.size.x * 0.82, core.size.y * 0.18), core.position + Vector2(core.size.x * 0.91, core.size.y * 0.24), SkinTokens.COLOR_IVORY_DIM, 1.0)
	if _installation_pulse > 0.0:
		draw_arc(core.get_center(), maxf(core.size.x, core.size.y) * (0.55 + 0.12 * _installation_pulse), 0.0, TAU, 32, SkinTokens.COLOR_WATT_REBOOT, 2.0)


func _draw_operator_plate(area: Rect2) -> void:
	var plate := Rect2(area.size.x * 0.035, area.size.y * 0.895, area.size.x * 0.93, area.size.y * 0.075)
	draw_rect(plate, SkinTokens.COLOR_INK)
	draw_rect(plate, SkinTokens.COLOR_WATT if authorization_ready else SkinTokens.COLOR_DISABLED, false, 1.0)
	var state_text := "OPERATOR READY" if authorization_ready else "OPERATOR HOLD"
	var scale_text: String = str({1: "DESK", 2: "ROOM", 3: "HOUSE", 4: "BUILDING", 5: "NEIGHBORHOOD"}.get(skin.era_number, "WORKSHOP"))
	var copy := "%s  •  %s  •  %s" % [scale_text, representative_state().to_upper(), state_text]
	draw_string(get_theme_default_font(), plate.position + Vector2(8.0, plate.size.y * 0.68), copy, HORIZONTAL_ALIGNMENT_LEFT, plate.size.x - 16.0, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_IVORY)


func _draw_state_beacons(area: Rect2) -> void:
	var label := "BROWNOUT • PATH ISOLATED" if brownout_active else ("RESERVE %s" % reserve_state.to_upper())
	var color := SkinTokens.COLOR_CRITICAL if brownout_active else SkinTokens.COLOR_RESERVE
	draw_circle(Vector2(area.size.x * 0.04, area.size.y * 0.055), 4.0, color)
	draw_string(get_theme_default_font(), Vector2(area.size.x * 0.06, area.size.y * 0.07), label, HORIZONTAL_ALIGNMENT_LEFT, area.size.x * 0.48, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_IVORY)


func _draw_transition(area: Rect2) -> void:
	if _transition_progress < 0.0:
		return
	if reduced_motion:
		draw_rect(area.grow(-6.0), SkinTokens.COLOR_WATT, false, 3.0)
		draw_string(get_theme_default_font(), Vector2(area.size.x * 0.20, area.size.y * 0.10), _transition_label(), HORIZONTAL_ALIGNMENT_CENTER, area.size.x * 0.60, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_WATT_REBOOT)
		return
	if _transition_progress < 0.22:
		draw_rect(area.grow(-4.0), SkinTokens.COLOR_EMERGENCY_LIGHT, false, 5.0)
	elif _transition_progress < 0.46:
		draw_rect(area, SkinTokens.COLOR_BLACKOUT_OVERLAY)
	elif _transition_progress < 0.60:
		draw_rect(area, SkinTokens.COLOR_BLACKOUT_OVERLAY)
		for offset: float in [-10.0, 10.0]:
			draw_circle(area.get_center() + Vector2(offset, 0.0), 4.0, SkinTokens.COLOR_WATT_REBOOT)
	else:
		var reveal := inverse_lerp(0.60, 1.0, _transition_progress)
		var inset := lerpf(minf(area.size.x, area.size.y) * 0.22, 5.0, reveal)
		draw_rect(area.grow(-inset), SkinTokens.COLOR_WATT, false, 3.0)
		if skin.era_number == 4:
			for x_fraction: float in [0.03, 0.80]:
				draw_rect(Rect2(area.size.x * x_fraction, area.size.y * 0.20, area.size.x * 0.17, area.size.y * 0.60), SkinTokens.COLOR_ERA_04_DIM_FLOOR, false, 3.0)
		elif skin.era_number == 5:
			for x_fraction: float in [0.05, 0.28, 0.52, 0.75]:
				draw_rect(Rect2(area.size.x * x_fraction, area.size.y * 0.20, area.size.x * 0.16, area.size.y * 0.55), SkinTokens.COLOR_ERA_05_DIM_HOME, false, 3.0)
			draw_rect(Rect2(area.size.x * 0.64, area.size.y * 0.10, area.size.x * 0.28, area.size.y * 0.22), SkinTokens.COLOR_WATT, false, 3.0)
		draw_string(get_theme_default_font(), Vector2(area.size.x * 0.20, area.size.y * 0.10), _transition_label(), HORIZONTAL_ALIGNMENT_CENTER, area.size.x * 0.60, SkinTokens.TYPE_CAPTION, SkinTokens.COLOR_WATT_REBOOT)


func _transition_label() -> String:
	if skin != null and skin.era_number == 4:
		return "NEIGHBORHOOD MICROGRID • OPERATOR LINK 05"
	if skin != null and skin.era_number == 5:
		return "CITY DATA CENTER • ERA 6 LOCKED"
	return "SCALE REVEAL"
