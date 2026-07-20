class_name RuntimeSettings
extends RefCounted

const NOTATION_ENGINEERING := "engineering"
const NOTATION_SCIENTIFIC := "scientific"
const TEXT_SCALES := [1.0, 1.15, 1.3]

var reduced_motion := false
var number_notation := NOTATION_ENGINEERING
var text_scale_index := 0
var haptics_enabled := true
var confirm_large_purchases := true
var master_volume := 1.0
var music_volume := 0.8
var effects_volume := 1.0
var text_sound_volume := 0.8


func set_number_notation(value: String) -> bool:
	if value not in [NOTATION_ENGINEERING, NOTATION_SCIENTIFIC]:
		return false
	number_notation = value
	return true


func set_text_scale_index(value: int) -> bool:
	if value < 0 or value >= TEXT_SCALES.size():
		return false
	text_scale_index = value
	return true


func get_text_scale() -> float:
	return float(TEXT_SCALES[text_scale_index])


func snapshot() -> Dictionary:
	return {
		"reduced_motion": reduced_motion,
		"number_notation": number_notation,
		"text_scale_index": text_scale_index,
		"haptics_enabled": haptics_enabled,
		"confirm_large_purchases": confirm_large_purchases,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"effects_volume": effects_volume,
		"text_sound_volume": text_sound_volume,
	}
