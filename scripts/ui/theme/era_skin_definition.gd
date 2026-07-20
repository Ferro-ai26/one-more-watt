class_name EraSkinDefinition
extends Resource

@export var skin_id := "base"
@export var era_number := 0
@export var scale_label := "DEVELOPMENT FALLBACK"
@export var environment_label := "WORKSHOP"
@export var background_color := SkinTokens.COLOR_ENVIRONMENT_DEEP
@export var wall_color := SkinTokens.COLOR_GRAPHITE
@export var surface_color := SkinTokens.COLOR_AGED_METAL
@export var ambient_color := SkinTokens.COLOR_GENERATION
@export var watt_variant := "scratched_core"
@export var infrastructure_slots: PackedStringArray = ["generation_left", "transmission_wall", "reserve_right"]
@export var power_flow_paths: Array[PackedVector2Array] = []
@export var ambient_animation := "workshop_hum"
@export var lighting_treatment := "warm_practical_cyan_spill"
@export var transition_in := "operator_handshake"
@export var transition_out := "blackout_pullback"
@export var estimated_memory_kib := 24
@export var release_complete := false


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if skin_id.is_empty(): errors.append("skin_id is required")
	if scale_label.is_empty(): errors.append("scale_label is required")
	if watt_variant != "scratched_core": errors.append("WATT must retain the scratched_core variant")
	if infrastructure_slots.is_empty(): errors.append("at least one infrastructure slot is required")
	if power_flow_paths.is_empty(): errors.append("at least one authored power-flow path is required")
	if estimated_memory_kib <= 0: errors.append("estimated_memory_kib must be positive")
	return errors
