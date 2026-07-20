class_name ShopItemCard
extends PanelContainer

signal purchase_requested(content_id: String, family: String)

var content_id := ""
var family := ""
var can_purchase := false
var visual_state := "default"
var reduced_motion := false
var _resting_state := "default"

@onready var name_label: Label = %NameLabel
@onready var glyph: InfrastructureGlyph = %InfrastructureGlyph
@onready var status_label: Label = %StatusLabel
@onready var description_label: Label = %DescriptionLabel
@onready var effect_label: Label = %EffectLabel
@onready var reason_label: Label = %ReasonLabel
@onready var buy_button: Button = %BuyButton


func _ready() -> void:
	# Decorative card surfaces must not swallow a phone drag before the parent
	# ScrollContainer sees it. The buy control remains tappable and passes the
	# gesture upward when the movement becomes a scroll.
	mouse_filter = Control.MOUSE_FILTER_PASS
	for child_value: Variant in find_children("*", "Control", true, false):
		var child := child_value as Control
		child.mouse_filter = Control.MOUSE_FILTER_PASS if child is BaseButton else Control.MOUSE_FILTER_IGNORE
	buy_button.pressed.connect(func() -> void: purchase_requested.emit(content_id, family))
	buy_button.button_down.connect(func() -> void: set_visual_state("pressed"))
	buy_button.button_up.connect(func() -> void: set_visual_state(_resting_state))
	set_visual_state("default")


func configure(data: Dictionary, notation: String) -> void:
	content_id = str(data.get("id", ""))
	family = str(data.get("family", ""))
	can_purchase = bool(data.get("can_purchase", false))
	glyph.set_category(str(data.get("category", "support")))
	name_label.text = str(data.get("name", "Unknown"))
	status_label.text = "%s  •  %s" % [str(data.get("ownership", "")), str(data.get("status", "invalid")).to_upper()]
	description_label.text = str(data.get("description", ""))
	description_label.tooltip_text = description_label.text
	description_label.visible = false
	effect_label.text = "PREDICTED  %s" % data.get("effect", "")
	var locked_reason := str(data.get("locked_reason", ""))
	var missing := float(data.get("missing", 0.0))
	if not locked_reason.is_empty():
		reason_label.text = "LOCKED  •  %s" % locked_reason
		set_visual_state("locked")
	elif missing > 0.0:
		var wait_seconds := float(data.get("wait_seconds", INF))
		reason_label.text = "NEED %s%s" % [
			NumberFormatter.format_energy(missing, notation),
			"  •  ABOUT %s" % NumberFormatter.format_duration(wait_seconds) if is_finite(wait_seconds) else "",
		]
		set_visual_state("unaffordable")
	else:
		reason_label.text = "Ready to build"
		set_visual_state("affordable")
	match str(data.get("status", "invalid")):
		EconomyPreview.LOCKED:
			buy_button.text = "Locked"
		EconomyPreview.MAXED:
			buy_button.text = "Completed"
		_:
			buy_button.text = "Buy • %s" % NumberFormatter.format_energy(float(data.get("cost", 0.0)), notation)
	buy_button.disabled = not can_purchase


func set_visual_state(state: String) -> void:
	visual_state = state
	if state != "pressed":
		_resting_state = state
	add_theme_stylebox_override("panel", SkinTokens.component_style(state))
	name_label.add_theme_color_override("font_color", SkinTokens.state_color(state))
	reason_label.add_theme_color_override("font_color", SkinTokens.state_color(state))
	set_meta("skin_state", state)


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)


func set_text_scale(scale: float) -> void:
	custom_minimum_size.y = 160.0 if scale >= 1.3 else (146.0 if scale > 1.0 else 136.0)
