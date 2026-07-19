class_name GridDebugPanel
extends VBoxContainer

@onready var _metrics_label: Label = %MetricsLabel
@onready var _flow_label: Label = %FlowLabel
@onready var _status_label: Label = %GridStatusLabel
@onready var _event_label: Label = %GridEventLabel

var simulation := GridSimulation.new()
var ready_for_debug := false


func _ready() -> void:
	%GenerationLimitedButton.pressed.connect(load_scenario.bind("generation_limited"))
	%TransmissionLimitedButton.pressed.connect(load_scenario.bind("transmission_limited"))
	%ReserveProtectedButton.pressed.connect(load_scenario.bind("reserve_protected"))
	%BrownoutButton.pressed.connect(load_scenario.bind("brownout"))
	%ExpandGridButton.pressed.connect(set_allocation.bind("expand_grid"))
	%BalancedButton.pressed.connect(set_allocation.bind("balanced"))
	%FeedWattButton.pressed.connect(set_allocation.bind("feed_watt"))
	%AdvanceOneButton.pressed.connect(advance_time.bind(1.0))
	%AdvanceTenButton.pressed.connect(advance_time.bind(10.0))
	%RecoverButton.pressed.connect(recover_from_brownout)

	var content_db := get_node_or_null("/root/ContentDB")
	if content_db == null or not bool(content_db.call("is_loaded")):
		_status_label.text = "SIMULATION UNAVAILABLE"
		return
	var repository: ContentRepository = content_db.get("repository")
	if not simulation.configure(repository.get_balance("prototype_balance"), "era_01_cold_boot", 20260719):
		_status_label.text = "SIMULATION CONFIG ERROR"
		return
	ready_for_debug = true
	load_scenario("generation_limited")


func load_scenario(scenario_id: String) -> void:
	if not ready_for_debug:
		return
	var configured := true
	match scenario_id:
		"generation_limited":
			configured = simulation.reset_scenario(_grid(5, 12, 10, 5, 5), 3, 5)
		"transmission_limited":
			configured = simulation.reset_scenario(_grid(15, 6, 10, 5, 5), 3, 5)
		"reserve_protected":
			configured = simulation.reset_scenario(_grid(10, 10, 10, 5, 5), 14, 10)
		"brownout":
			configured = simulation.reset_scenario(_grid(10, 10, 10, 5, 5), 20, 0)
		_:
			configured = false
	if not configured:
		_event_label.text = "Rejected scenario: %s" % scenario_id
		return
	simulation.set_allocation_mode("balanced")
	simulation.advance_time(simulation.fixed_step_seconds)
	_update_readout("Scenario: %s" % scenario_id.replace("_", " ").capitalize())


func set_allocation(mode: String) -> void:
	if not ready_for_debug:
		return
	if simulation.set_allocation_mode(mode):
		simulation.advance_time(simulation.fixed_step_seconds)
		_update_readout("Allocation: %s" % mode.replace("_", " ").capitalize())


func advance_time(seconds: float) -> void:
	if not ready_for_debug:
		return
	if simulation.advance_time(seconds):
		_update_readout("Advanced %.2f seconds" % seconds)


func recover_from_brownout() -> void:
	if not ready_for_debug:
		return
	simulation.set_demand_rate(5)
	simulation.advance_time(simulation.fixed_step_seconds)
	_update_readout("Demand reduced to 5.00")


func _update_readout(action: String) -> void:
	var result := simulation.get_last_result()
	var state := simulation.state
	_metrics_label.text = "GEN %.2f  |  TRANS %.2f  |  LOAD %.2f\nDELIVERED %.2f  |  RESERVE %.2f / %.2f" % [
		state.generation_rate,
		state.transmission_capacity,
		state.demand_rate,
		result.served_power,
		state.reserve_stored,
		state.reserve_capacity,
	]
	_flow_label.text = "RES %+.2f  |  GRID %.2f  |  WATT %.2f\nENERGY %.2f  |  STABILITY %.1f" % [
		result.reserve_charge_power - result.reserve_discharge_power,
		result.grid_power,
		result.watt_power,
		state.stored_energy,
		state.stability,
	]
	_status_label.text = "%s  •  LIMITING: %s" % [
		"BROWNOUT" if state.brownout_active else "GRID STABLE",
		result.limiting_constraint.to_upper(),
	]
	var event_names: PackedStringArray = []
	for event: GridEvent in simulation.drain_events():
		event_names.append(event.type)
	_event_label.text = "%s%s" % [action, "  •  %s" % ", ".join(event_names) if not event_names.is_empty() else ""]


func _grid(generation: float, transmission: float, reserve_capacity: float, charge_rate: float, discharge_rate: float) -> Dictionary:
	return {
		"generation_rate": generation,
		"transmission_capacity": transmission,
		"reserve_capacity": reserve_capacity,
		"reserve_charge_rate": charge_rate,
		"reserve_discharge_rate": discharge_rate,
		"stored_energy": 0,
	}
