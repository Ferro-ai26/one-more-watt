class_name EraSkinRegistry
extends RefCounted

const BASE_ID := "base_workshop"
const ERA_01_ID := "era_01_desk"
const ERA_02_ID := "era_02_room"
const ERA_03_ID := "era_03_house"
const ERA_04_ID := "era_04_building"
const ERA_05_ID := "era_05_neighborhood"


static func get_skin(skin_id: String) -> EraSkinDefinition:
	match skin_id:
		ERA_01_ID: return _desk()
		ERA_02_ID: return _room()
		ERA_03_ID: return _house()
		ERA_04_ID: return _building()
		ERA_05_ID: return _neighborhood()
		_: return _base()


static func skin_for_era(era_number: int) -> EraSkinDefinition:
	if era_number >= 5:
		return get_skin(ERA_05_ID)
	if era_number == 4:
		return get_skin(ERA_04_ID)
	if era_number == 3:
		return get_skin(ERA_03_ID)
	return get_skin(ERA_02_ID if era_number == 2 else ERA_01_ID)


static func required_sample_ids() -> PackedStringArray:
	return PackedStringArray([BASE_ID, ERA_01_ID, ERA_02_ID, ERA_03_ID, ERA_04_ID, ERA_05_ID])


static func _base() -> EraSkinDefinition:
	var skin := EraSkinDefinition.new()
	skin.skin_id = BASE_ID
	skin.scale_label = "FALLBACK WORKSHOP"
	skin.power_flow_paths = [_path([Vector2(0.08, 0.72), Vector2(0.40, 0.72), Vector2(0.55, 0.53)])]
	return skin


static func _desk() -> EraSkinDefinition:
	var skin := EraSkinDefinition.new()
	skin.skin_id = ERA_01_ID
	skin.era_number = 1
	skin.scale_label = "DESK GRID • OPERATOR LINK 01"
	skin.environment_label = "BEDROOM / GARAGE WORKSHOP"
	skin.background_color = SkinTokens.COLOR_ERA_01_BACKGROUND
	skin.wall_color = SkinTokens.COLOR_ERA_01_WALL
	skin.surface_color = SkinTokens.COLOR_ERA_01_DESK
	skin.ambient_color = SkinTokens.COLOR_GENERATION
	skin.power_flow_paths = [
		_path([Vector2(0.03, 0.68), Vector2(0.18, 0.68), Vector2(0.31, 0.77), Vector2(0.54, 0.58)]),
		_path([Vector2(0.54, 0.58), Vector2(0.72, 0.58), Vector2(0.92, 0.42)]),
	]
	skin.estimated_memory_kib = 28
	return skin


static func _room() -> EraSkinDefinition:
	var skin := EraSkinDefinition.new()
	skin.skin_id = ERA_02_ID
	skin.era_number = 2
	skin.scale_label = "ROOM GRID • OPERATOR LINK 02"
	skin.environment_label = "WORKSHOP CIRCUIT EXPANSION"
	skin.background_color = SkinTokens.COLOR_ERA_02_BACKGROUND
	skin.wall_color = SkinTokens.COLOR_ERA_02_WALL
	skin.surface_color = SkinTokens.COLOR_ERA_02_DESK
	skin.ambient_color = SkinTokens.COLOR_WARNING
	skin.power_flow_paths = [
		_path([Vector2(0.02, 0.69), Vector2(0.22, 0.69), Vector2(0.36, 0.80), Vector2(0.54, 0.58)]),
		_path([Vector2(0.54, 0.58), Vector2(0.74, 0.58), Vector2(0.94, 0.28)]),
		_path([Vector2(0.62, 0.58), Vector2(0.74, 0.75), Vector2(0.96, 0.75)]),
	]
	skin.ambient_animation = "cyan_grid_spread"
	skin.lighting_treatment = "failing_warm_practicals_cyan_priority"
	skin.estimated_memory_kib = 32
	return skin


static func _house() -> EraSkinDefinition:
	var skin := EraSkinDefinition.new()
	skin.skin_id = ERA_03_ID
	skin.era_number = 3
	skin.scale_label = "HOUSE GRID • OPERATOR LINK 03"
	skin.environment_label = "HOME SERVER CLOSET / SERVICE YARD"
	skin.background_color = SkinTokens.COLOR_ERA_03_BACKGROUND
	skin.wall_color = SkinTokens.COLOR_ERA_03_WALL
	skin.surface_color = SkinTokens.COLOR_ERA_03_DESK
	skin.ambient_color = SkinTokens.COLOR_EMERGENCY_LIGHT
	skin.infrastructure_slots = PackedStringArray(["server_closet", "house_battery", "service_yard", "cooling_wall"])
	skin.power_flow_paths = [
		_path([Vector2(0.02, 0.72), Vector2(0.16, 0.72), Vector2(0.31, 0.61), Vector2(0.52, 0.56)]),
		_path([Vector2(0.52, 0.56), Vector2(0.70, 0.56), Vector2(0.82, 0.30), Vector2(0.98, 0.30)]),
		_path([Vector2(0.52, 0.56), Vector2(0.68, 0.76), Vector2(0.86, 0.76), Vector2(0.98, 0.66)]),
		_path([Vector2(0.36, 0.61), Vector2(0.28, 0.30), Vector2(0.12, 0.30)]),
	]
	skin.ambient_animation = "server_bank_cooling_cycle"
	skin.lighting_treatment = "dim_house_cyan_service_priority_amber_warning"
	skin.estimated_memory_kib = 40
	return skin


static func _building() -> EraSkinDefinition:
	var skin := EraSkinDefinition.new()
	skin.skin_id = ERA_04_ID
	skin.era_number = 4
	skin.scale_label = "BUILDING GRID • OPERATOR LINK 04"
	skin.environment_label = "BUILDING CUTAWAY / SHARED SERVICE RISER"
	skin.background_color = SkinTokens.COLOR_ERA_04_BACKGROUND
	skin.wall_color = SkinTokens.COLOR_ERA_04_WALL
	skin.surface_color = SkinTokens.COLOR_ERA_04_SERVICE
	skin.ambient_color = SkinTokens.COLOR_EMERGENCY_LIGHT
	skin.infrastructure_slots = PackedStringArray(["roof_plant", "vertical_riser", "service_room", "parking_canopy", "stairwell"])
	skin.power_flow_paths = [
		_path([Vector2(0.50, 0.88), Vector2(0.50, 0.69), Vector2(0.50, 0.49), Vector2(0.50, 0.27), Vector2(0.50, 0.08)]),
		_path([Vector2(0.50, 0.69), Vector2(0.25, 0.69), Vector2(0.08, 0.69)]),
		_path([Vector2(0.50, 0.49), Vector2(0.75, 0.49), Vector2(0.93, 0.49)]),
		_path([Vector2(0.50, 0.27), Vector2(0.29, 0.27), Vector2(0.10, 0.27)]),
	]
	skin.ambient_animation = "building_riser_load_cycle"
	skin.lighting_treatment = "dim_shared_floors_cyan_riser_amber_emergency"
	skin.estimated_memory_kib = 48
	return skin


static func _neighborhood() -> EraSkinDefinition:
	var skin := EraSkinDefinition.new()
	skin.skin_id = ERA_05_ID
	skin.era_number = 5
	skin.scale_label = "NEIGHBORHOOD GRID • OPERATOR LINK 05"
	skin.environment_label = "BLUE-HOUR MICROGRID / LATERAL ANNEXATION"
	skin.background_color = SkinTokens.COLOR_ERA_05_BACKGROUND
	skin.wall_color = SkinTokens.COLOR_ERA_05_BLOCK
	skin.surface_color = SkinTokens.COLOR_ERA_05_STREET
	skin.ambient_color = SkinTokens.COLOR_EMERGENCY_LIGHT
	skin.infrastructure_slots = PackedStringArray(["nested_building", "substation", "solar_field", "battery_warehouse", "water_channel", "underground_route", "boundary_link"])
	skin.power_flow_paths = [
		_path([Vector2(0.05, 0.62), Vector2(0.23, 0.62), Vector2(0.42, 0.53), Vector2(0.58, 0.53), Vector2(0.78, 0.35), Vector2(0.97, 0.35)]),
		_path([Vector2(0.42, 0.53), Vector2(0.42, 0.76), Vector2(0.68, 0.76), Vector2(0.90, 0.83)]),
		_path([Vector2(0.58, 0.53), Vector2(0.70, 0.20), Vector2(0.88, 0.12)]),
	]
	skin.ambient_animation = "neighborhood_feeder_cycle"
	skin.lighting_treatment = "dim_homes_bright_substation_cyan_routes_amber_service"
	skin.estimated_memory_kib = 56
	return skin


static func _path(points: Array[Vector2]) -> PackedVector2Array:
	return PackedVector2Array(points)
