class_name RequestDebugPanel
extends VBoxContainer

const REQUEST_IDS := [
	"era01_finish_booting",
	"era01_basic_arithmetic",
	"era01_understand_tuesdays",
	"era01_friendlier_thanks",
]
const ERA_01_PATH := [
	"era01_finish_booting",
	"era01_remember_name",
	"era01_identify_cat",
	"era01_basic_arithmetic",
	"era01_friendlier_thanks",
	"era01_understand_tuesdays",
]

@onready var watt_dialogue_label: Label = %WattDialogueLabel
@onready var request_label: Label = %RequestLabel
@onready var progress_label: Label = %ProgressLabel
@onready var preview_label: Label = %PreviewLabel
@onready var grid_label: Label = %GridLabel
@onready var report_label: Label = %ReportLabel
@onready var events_label: Label = %EventsLabel

var simulation := RequestSimulation.new()
var current_request_id := REQUEST_IDS[0]
var _repository: ContentRepository


func _ready() -> void:
	var content_db := get_node_or_null("/root/ContentDB")
	if content_db == null or not bool(content_db.call("is_loaded")):
		request_label.text = "Request content unavailable"
		return
	_repository = content_db.get("repository")
	_connect_controls()
	prepare_target(REQUEST_IDS[0])


func prepare_target(request_id: String) -> bool:
	if _repository == null or request_id not in REQUEST_IDS or not simulation.configure(_repository, "prototype_balance", 303):
		return false
	var progression := EconomyState.new()
	progression.owned["laptop_battery"] = 1
	progression.unlocked_eras["era_01_cold_boot"] = true
	simulation.refresh_availability(progression)
	_set_rich_grid()
	for prior_id: String in ERA_01_PATH:
		if prior_id == request_id:
			break
		simulation.announce_request(prior_id)
		simulation.authorize_request(prior_id)
		simulation.start_request(prior_id)
		simulation.advance_time(120.0)
		simulation.acknowledge_report(prior_id)
	current_request_id = request_id
	match request_id:
		"era01_basic_arithmetic":
			simulation.grid.set_grid_values(_grid(8, 8, 10, 4, 8, simulation.grid.state.stored_energy, 10))
		"era01_understand_tuesdays":
			simulation.grid.set_grid_values(_grid(8, 8, 10, 4, 8, simulation.grid.state.stored_energy, 10))
		_:
			_set_rich_grid()
	simulation.drain_events()
	_refresh()
	return true


func announce_current() -> bool:
	var accepted := simulation.announce_request(current_request_id)
	_refresh()
	return accepted


func authorize_current() -> bool:
	var accepted := simulation.authorize_request(current_request_id)
	_refresh()
	return accepted


func start_current() -> bool:
	var accepted := simulation.start_request(current_request_id)
	_refresh()
	return accepted


func advance_current(seconds: float) -> bool:
	var accepted := simulation.advance_time(seconds)
	_refresh()
	return accepted


func acknowledge_current() -> bool:
	var accepted := simulation.acknowledge_report(current_request_id)
	_refresh()
	return accepted


func underprepare_grid() -> void:
	simulation.grid.set_grid_values(_grid(2, 2, 0, 0, 0, simulation.grid.state.stored_energy))
	_refresh()


func recover_grid() -> void:
	_set_rich_grid()
	_refresh()


func _set_rich_grid() -> void:
	simulation.grid.set_grid_values(_grid(30, 30, 20, 10, 10, maxf(simulation.grid.state.stored_energy, 50.0), 20))


func _connect_controls() -> void:
	%CapacityButton.pressed.connect(func() -> void: prepare_target(REQUEST_IDS[0]))
	%StabilityButton.pressed.connect(func() -> void: prepare_target(REQUEST_IDS[1]))
	%BurstButton.pressed.connect(func() -> void: prepare_target(REQUEST_IDS[2]))
	%ResearchButton.pressed.connect(func() -> void: prepare_target(REQUEST_IDS[3]))
	%AnnounceButton.pressed.connect(announce_current)
	%AuthorizeButton.pressed.connect(authorize_current)
	%StartButton.pressed.connect(start_current)
	%AdvanceOneButton.pressed.connect(func() -> void: advance_current(1.0))
	%AdvanceTenButton.pressed.connect(func() -> void: advance_current(10.0))
	%AcknowledgeButton.pressed.connect(acknowledge_current)
	%UnderprepareButton.pressed.connect(underprepare_grid)
	%RecoverButton.pressed.connect(recover_grid)
	%ExpandButton.pressed.connect(func() -> void: simulation.set_allocation_mode("expand_grid"); _refresh())
	%BalancedButton.pressed.connect(func() -> void: simulation.set_allocation_mode("balanced"); _refresh())
	%FeedButton.pressed.connect(func() -> void: simulation.set_allocation_mode("feed_watt"); _refresh())


func _refresh() -> void:
	var request := _repository.get_request(current_request_id)
	var state := simulation.get_request_state(current_request_id)
	var preview := simulation.build_preview(current_request_id)
	request_label.text = "%s  •  %s  •  %s" % [_repository.localize(request.get_title_key()), request.get_kind().to_upper(), state.status.to_upper()]
	progress_label.text = "PROGRESS %.1f%%  •  %.2fs  •  ALLOCATION %s" % [state.progress * 100.0, state.elapsed_seconds, simulation.grid.state.allocation_mode.to_upper()]
	preview_label.text = "LOAD %.1f  •  PEAK %.1f  •  RESERVE %.1f RECOMMENDED\nSERVICE %.0f%%  •  ETA %s  •  LIMIT %s%s\nREWARD %.1f STORED  •  UNLOCK %s%s" % [
		preview.continuous_demand,
		preview.predicted_peak,
		preview.recommended_reserve,
		preview.predicted_service_ratio * 100.0,
		("—" if is_inf(preview.estimated_seconds) else "%.1fs" % preview.estimated_seconds),
		preview.likely_bottleneck.to_upper(),
		("  •  UNDERPREPARED" if preview.underprepared else ""),
		preview.reward_stored_energy,
		("NONE" if preview.unlock_ids.is_empty() else ", ".join(preview.unlock_ids)),
		("  •  RESEARCH COST %.1f" % preview.research_cost if preview.research_cost > 0.0 else ""),
	]
	grid_label.text = "GEN %.1f  •  TRANS %.1f  •  RES %.1f/%.1f  •  STORED %.1f\nDEMAND %.1f  •  STABILITY %.1f  •  %s" % [
		simulation.grid.state.generation_rate,
		simulation.grid.state.transmission_capacity,
		simulation.grid.state.reserve_stored,
		simulation.grid.state.reserve_capacity,
		simulation.grid.state.stored_energy,
		simulation.grid.state.demand_rate,
		simulation.grid.state.stability,
		("BROWNOUT" if simulation.grid.state.brownout_active else "GRID STABLE"),
	]
	watt_dialogue_label.text = simulation.current_dialogue if not simulation.current_dialogue.is_empty() else "WATT is waiting for the request announcement."
	var report := simulation.get_report(current_request_id)
	if report == null:
		report_label.text = "REPORT: pending"
	else:
		report_label.text = "REPORT %s  •  SERVICE %.1f%%  •  BROWNOUT %.2fs\nPEAK %.1f/%.1f  •  GRID EARNED %.1f  •  REWARD %.1f\n%s" % [
			report.grade, report.demand_served_ratio * 100.0, report.brownout_seconds,
			report.peak_served, report.peak_demand, report.stored_energy_earned,
			report.reward_stored_energy, _repository.localize(report.suggestion_key),
		]
	var event_parts: PackedStringArray = []
	for event: RequestEvent in simulation.drain_events():
		var detail := str(event.payload.get("to", event.payload.get("content_id", event.payload.get("incident_id", ""))))
		event_parts.append(event.type + ("=" + detail if not detail.is_empty() else ""))
	if not event_parts.is_empty():
		events_label.text = "EVENTS: " + "  •  ".join(event_parts)


func _grid(generation: float, transmission: float, reserve_capacity: float, charge_rate: float, discharge_rate: float, stored_energy: float, reserve_stored: float = 0.0) -> Dictionary:
	return {
		"generation_rate": generation,
		"transmission_capacity": transmission,
		"reserve_capacity": reserve_capacity,
		"reserve_charge_rate": charge_rate,
		"reserve_discharge_rate": discharge_rate,
		"stored_energy": stored_energy,
		"reserve_stored": reserve_stored,
	}
