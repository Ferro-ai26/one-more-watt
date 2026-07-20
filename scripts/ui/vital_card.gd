class_name VitalCard
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var value_label: Label = %ValueLabel
@onready var state_label: Label = %StateLabel
var visual_state := "default"
var reduced_motion := false


func _ready() -> void:
	set_visual_state("default")


func configure(title: String, value: String, detail: String, limiting: bool) -> void:
	title_label.text = {"Generation": "GEN.", "Transmission": "TRANS."}.get(title, title.to_upper())
	title_label.tooltip_text = title
	value_label.text = value
	state_label.text = "! LIMITING" if limiting else detail
	set_visual_state("limiting" if limiting else "default")


func set_visual_state(state: String) -> void:
	visual_state = state
	add_theme_stylebox_override("panel", SkinTokens.component_style(state, SkinTokens.COLOR_INK))
	var color := SkinTokens.state_color(state)
	value_label.add_theme_color_override("font_color", color)
	state_label.add_theme_color_override("font_color", color)
	set_meta("skin_state", state)


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)
