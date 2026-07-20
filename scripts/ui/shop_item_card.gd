class_name ShopItemCard
extends PanelContainer

signal purchase_requested(content_id: String, family: String)

var content_id := ""
var family := ""
var can_purchase := false

@onready var name_label: Label = %NameLabel
@onready var status_label: Label = %StatusLabel
@onready var description_label: Label = %DescriptionLabel
@onready var effect_label: Label = %EffectLabel
@onready var reason_label: Label = %ReasonLabel
@onready var buy_button: Button = %BuyButton


func _ready() -> void:
	buy_button.pressed.connect(func() -> void: purchase_requested.emit(content_id, family))


func configure(data: Dictionary, notation: String) -> void:
	content_id = str(data.get("id", ""))
	family = str(data.get("family", ""))
	can_purchase = bool(data.get("can_purchase", false))
	name_label.text = str(data.get("name", "Unknown"))
	status_label.text = "%s  •  %s" % [str(data.get("ownership", "")), str(data.get("status", "invalid")).to_upper()]
	description_label.text = str(data.get("description", ""))
	effect_label.text = "PREDICTED  %s" % data.get("effect", "")
	var locked_reason := str(data.get("locked_reason", ""))
	var missing := float(data.get("missing", 0.0))
	if not locked_reason.is_empty():
		reason_label.text = "LOCKED  •  %s" % locked_reason
	elif missing > 0.0:
		reason_label.text = "NEED %s MORE" % NumberFormatter.format_energy(missing, notation)
	else:
		reason_label.text = "Ready to build"
	match str(data.get("status", "invalid")):
		EconomyPreview.LOCKED:
			buy_button.text = "Locked"
		EconomyPreview.MAXED:
			buy_button.text = "Completed"
		_:
			buy_button.text = "Buy • %s" % NumberFormatter.format_energy(float(data.get("cost", 0.0)), notation)
	buy_button.disabled = not can_purchase
