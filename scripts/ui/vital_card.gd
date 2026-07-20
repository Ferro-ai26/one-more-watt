class_name VitalCard
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var value_label: Label = %ValueLabel
@onready var state_label: Label = %StateLabel


func configure(title: String, value: String, detail: String, limiting: bool) -> void:
	title_label.text = title.to_upper()
	value_label.text = value
	state_label.text = "! LIMITING" if limiting else detail
	state_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35) if limiting else Color(0.55, 0.75, 0.92))

