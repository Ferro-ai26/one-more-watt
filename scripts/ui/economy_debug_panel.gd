class_name EconomyDebugPanel
extends VBoxContainer

@onready var summary_label: Label = %SummaryLabel
@onready var selection_label: Label = %SelectionLabel
@onready var description_label: Label = %DescriptionLabel
@onready var preview_label: Label = %PreviewLabel
@onready var transaction_label: Label = %TransactionLabel
@onready var automation_label: Label = %AutomationLabel
@onready var events_label: Label = %EventsLabel

var economy := EconomySimulation.new()
var selected_family := "infrastructure"
var selected_id := "wall_outlet"
var selected_amount := 1
var _repository: ContentRepository


func _ready() -> void:
	var content_db := get_node_or_null("/root/ContentDB")
	if content_db == null or not bool(content_db.call("is_loaded")):
		selection_label.text = "Economy content unavailable"
		return
	_repository = content_db.get("repository")
	_connect_controls()
	reset_funded()


func reset_funded() -> void:
	economy.configure(_repository)
	economy.set_stored_energy(1000000.0)
	selected_family = "infrastructure"
	selected_id = "wall_outlet"
	selected_amount = 1
	economy.drain_events()
	transaction_label.text = "TRANSACTION: ready"
	_refresh()


func clear_funds() -> void:
	economy.set_stored_energy(0.0)
	_refresh()


func unlock_prerequisites() -> void:
	economy.unlock_era("era_02_bedroom_assistant")
	economy.unlock_era("era_03_home_server_closet")
	for request_id: String in ["era01_finish_booting", "era01_basic_arithmetic", "era01_understand_tuesdays", "era01_friendlier_thanks"]:
		economy.mark_request_completed(request_id)
	_refresh()


func prepare_milestone() -> void:
	economy.configure(_repository)
	economy.set_stored_energy(1000000.0)
	economy.purchase_infrastructure("wall_outlet", 8)
	economy.drain_events()
	selected_family = "infrastructure"
	selected_id = "wall_outlet"
	selected_amount = 1
	transaction_label.text = "MILESTONE SETUP: 9 owned; next purchase crosses 10"
	_refresh()


func select_infrastructure(id: String, amount: int = 1) -> void:
	selected_family = "infrastructure"
	selected_id = id
	selected_amount = amount
	_refresh()


func select_upgrade(id: String) -> void:
	selected_family = "upgrade"
	selected_id = id
	selected_amount = 1
	_refresh()


func purchase_selected() -> bool:
	var preview := _current_preview()
	if not preview.can_purchase():
		transaction_label.text = "TRANSACTION REJECTED: %s" % preview.status.to_upper()
		_refresh(false)
		return false
	var accepted := economy.purchase_infrastructure(selected_id, selected_amount) if selected_family == "infrastructure" else economy.purchase_upgrade(selected_id)
	if accepted:
		var resulting := economy.get_derived_values()
		var matched := true
		for key: Variant in preview.resulting_values:
			if not is_equal_approx(float(resulting.get(key, 0.0)), float(preview.resulting_values[key])):
				matched = false
		transaction_label.text = "TRANSACTION: preview %s resulting grid" % ("MATCHED" if matched else "DID NOT MATCH")
	_refresh(false)
	return accepted


func configure_automation(enabled: bool) -> bool:
	var accepted := economy.configure_reserve_automation(enabled, 0.5)
	_refresh()
	return accepted


func test_throttle() -> Dictionary:
	economy.grid.state.reserve_stored = economy.grid.state.reserve_capacity * 0.1
	var result := economy.apply_safe_throttle(1000000.0)
	automation_label.text = "AUTOMATION: requested 1000000.0  •  applied %.1f  •  %s" % [result["demand_rate"], "THROTTLED" if result["throttled"] else "UNCHANGED"]
	_refresh(false)
	return result


func _current_preview() -> EconomyPreview:
	return economy.preview_infrastructure(selected_id, selected_amount) if selected_family == "infrastructure" else economy.preview_upgrade(selected_id)


func _refresh(overwrite_automation: bool = true) -> void:
	var preview := _current_preview()
	var definition_family := "upgrades" if selected_family == "upgrade" else "infrastructure"
	var definition: ContentDefinition = _repository.get_definition(definition_family, selected_id)
	var name_key := str(definition.get_value("name_key", "")) if definition != null else ""
	var description_key := str(definition.get_value("description_key", "")) if definition != null else ""
	var owned_text := ""
	if selected_family == "infrastructure":
		owned_text = "OWNED %d  •  BUY %d" % [int(economy.state.owned.get(selected_id, 0)), selected_amount]
	else:
		owned_text = "LEVEL %d/%d" % [preview.current_level, int(definition.get_value("max_level", 1))]
	selection_label.text = "%s  •  %s\n%s  •  %s" % [_repository.localize(name_key), selected_family.to_upper(), owned_text, preview.status.to_upper()]
	description_label.text = _repository.localize(description_key)
	var condition_text := "NONE" if preview.unmet_conditions.is_empty() else ", ".join(preview.unmet_conditions)
	var delta_parts: PackedStringArray = []
	for key: Variant in preview.deltas:
		var delta := float(preview.deltas[key])
		if absf(delta) > 0.000001:
			delta_parts.append("%s %+.1f" % [str(key).to_upper(), delta])
	preview_label.text = "COST %.1f  •  MISSING %.1f  •  UNMET %s\nPREDICTED: %s" % [
		preview.cost, preview.missing_currency, condition_text,
		("NO GRID CHANGE" if delta_parts.is_empty() else "  •  ".join(delta_parts)),
	]
	var derived := economy.get_derived_values()
	summary_label.text = "STORED %.1f  •  GEN %.1f  •  TRANS %.1f\nRESERVE %.1f CAP / %.1f DISCHARGE  •  REQUEST EFF +%.1f%%" % [
		economy.state.stored_energy,
		float(derived.get("generation_rate", 0.0)),
		float(derived.get("transmission_capacity", 0.0)),
		float(derived.get("reserve_capacity", 0.0)),
		float(derived.get("reserve_discharge_rate", 0.0)),
		float(derived.get("request_efficiency", 0.0)) * 100.0,
	]
	if overwrite_automation:
		automation_label.text = "AUTOMATION: %s  •  RESERVE THRESHOLD %.0f%%" % ["ENABLED" if economy.state.reserve_automation_enabled else "DISABLED", economy.state.reserve_threshold_ratio * 100.0]
	var parts: PackedStringArray = []
	for event: EconomyEvent in economy.drain_events():
		var detail := str(event.payload.get("owned", event.payload.get("level", event.payload.get("content_id", ""))))
		parts.append(event.type + ("=" + detail if not detail.is_empty() else ""))
	if not parts.is_empty():
		events_label.text = "EVENTS: " + "  •  ".join(parts)


func _connect_controls() -> void:
	%GenerationButton.pressed.connect(func() -> void: select_infrastructure("wall_outlet"))
	%TransmissionButton.pressed.connect(func() -> void: select_infrastructure("questionable_power_strip"))
	%ReserveButton.pressed.connect(func() -> void: select_infrastructure("laptop_battery"))
	%SupportButton.pressed.connect(func() -> void: select_infrastructure("tiny_desk_fan"))
	%AutomationButton.pressed.connect(func() -> void: select_infrastructure("smart_meter"))
	%LockedButton.pressed.connect(func() -> void: select_infrastructure("extension_cord"))
	%LeveledUpgradeButton.pressed.connect(func() -> void: select_upgrade("outlet_calibration"))
	%OneTimeUpgradeButton.pressed.connect(func() -> void: select_upgrade("dedicated_circuit_research"))
	%BuyOneButton.pressed.connect(func() -> void: selected_amount = 1; purchase_selected())
	%BuyTenButton.pressed.connect(func() -> void: selected_amount = 10; purchase_selected())
	%SeedFundsButton.pressed.connect(reset_funded)
	%ClearFundsButton.pressed.connect(clear_funds)
	%UnlockButton.pressed.connect(unlock_prerequisites)
	%MilestoneButton.pressed.connect(prepare_milestone)
	%EnableAutomationButton.pressed.connect(func() -> void: configure_automation(true))
	%DisableAutomationButton.pressed.connect(func() -> void: configure_automation(false))
	%TestThrottleButton.pressed.connect(test_throttle)
