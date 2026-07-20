extends SceneTree

var _repository: ContentRepository
var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_repository = ContentRepository.new()
	var result := _repository.load_from_manifest("res://tests/fixtures/content/valid_manifest.json")
	_check(result.is_ok(), "content loads for main UI system tests")
	if result.is_ok():
		_test_number_formatter()
		_test_navigation_and_runtime_settings()
		_test_mobile_ui_scaler()
		_test_session_and_view_model_parity()
	_finish()


func _test_number_formatter() -> void:
	_check(NumberFormatter.format_power(0.0) == "0 W", "zero power remains in watts")
	_check(NumberFormatter.format_power(999.0) == "999 W", "sub-boundary power remains in watts")
	_check(NumberFormatter.format_power(1000.0) == "1 kW", "one thousand watts promotes to kilowatts: %s" % NumberFormatter.format_power(1000.0))
	_check(NumberFormatter.format_power(1000000.0) == "1 MW", "one million watts promotes to megawatts: %s" % NumberFormatter.format_power(1000000.0))
	_check(NumberFormatter.format_power(1000.0, RuntimeSettings.NOTATION_SCIENTIFIC) == "1.00×10^3 W", "scientific notation keeps the canonical watt unit: %s" % NumberFormatter.format_power(1000.0, RuntimeSettings.NOTATION_SCIENTIFIC))
	_check(NumberFormatter.format_number(INF) == "—", "non-finite values use a safe placeholder")
	_check(NumberFormatter.format_duration(59.5) == "59.5s", "short durations retain tenths")
	_check(NumberFormatter.format_duration(61.0) == "1m 01s", "minute boundary formats readably")


func _test_navigation_and_runtime_settings() -> void:
	var navigation := NavigationState.new()
	_check(navigation.current_tab == "grid", "navigation starts on Grid")
	_check(navigation.select_tab("build") and navigation.current_tab == "build", "valid tab navigation persists")
	_check(not navigation.select_tab("debug") and navigation.current_tab == "build", "invalid tab cannot mutate navigation")
	_check(navigation.push_modal("request_detail"), "first modal enters stack")
	_check(navigation.push_modal("settings") and navigation.top_modal() == "settings", "modal stack preserves order")
	_check(navigation.pop_modal() == "settings" and navigation.top_modal() == "request_detail", "back pops only the top modal")
	_check(not navigation.push_modal("request_detail"), "duplicate modal is rejected")
	var settings := RuntimeSettings.new()
	settings.reduced_motion = true
	settings.haptics_enabled = false
	_check(settings.set_text_scale_index(2) and is_equal_approx(settings.get_text_scale(), 1.3), "large text setting persists in runtime state")
	_check(settings.set_number_notation(RuntimeSettings.NOTATION_SCIENTIFIC), "scientific notation setting is accepted")
	var snapshot := settings.snapshot()
	_check(snapshot["reduced_motion"] and not snapshot["haptics_enabled"] and snapshot["number_notation"] == "scientific", "accessibility snapshot preserves changed settings")
	_check(not settings.set_text_scale_index(99), "invalid text scale is rejected")
	var feedback := FeedbackHooks.new(settings)
	feedback.request("purchase", true)
	_check(feedback.last_feedback == "purchase", "feedback hook remains functional when haptics are disabled or unavailable")
	_check(FeedbackAudio.CUES.size() == 7, "essential purchase, request, brownout, allocation, transition, and error cues are authored")
	var tone := FeedbackAudio.build_tone(440.0, 660.0, 0.1)
	_check(tone.format == AudioStreamWAV.FORMAT_16_BITS and tone.mix_rate == 22050 and tone.data.size() > 4000, "procedural feedback cue is a bounded mono PCM stream")


func _test_mobile_ui_scaler() -> void:
	var factor_1080_xxhdpi := MobileUIScaler.calculate_content_scale_factor(Vector2i(1080, 2400), 480)
	_check_near(factor_1080_xxhdpi, 2.0, "1080×2400 xxhdpi display receives density-aware canvas scale")
	var logical_1080 := MobileUIScaler.effective_logical_size(Vector2i(1080, 2400), factor_1080_xxhdpi)
	_check(logical_1080.is_equal_approx(Vector2(360.0, 800.0)), "1080×2400 xxhdpi resolves to a comfortable 360×800 logical viewport")
	var factor_720_xhdpi := MobileUIScaler.calculate_content_scale_factor(Vector2i(720, 1600), 320)
	_check_near(factor_720_xhdpi, 2.0, "720×1600 xhdpi display receives density-aware canvas scale")
	var logical_720 := MobileUIScaler.effective_logical_size(Vector2i(720, 1600), factor_720_xhdpi)
	_check(logical_720.is_equal_approx(Vector2(360.0, 800.0)), "720×1600 xhdpi resolves to a comfortable 360×800 logical viewport")
	var constrained_factor := MobileUIScaler.calculate_content_scale_factor(Vector2i(720, 1280), 480)
	var constrained_logical := MobileUIScaler.effective_logical_size(Vector2i(720, 1280), constrained_factor)
	_check(constrained_logical.x >= 320.0 and constrained_logical.y >= 568.0, "small dense displays retain the verified minimum logical layout")
	_check_near(MobileUIScaler.calculate_content_scale_factor(Vector2i.ZERO, 480), 1.0, "invalid display dimensions fail safely")


func _test_session_and_view_model_parity() -> void:
	var session := GameSession.new()
	_check(session.configure(_repository), "online game session configures")
	var view_model := MainViewModel.new(session)
	var first_id := "era01_finish_booting"
	_check(session.current_request_id() == first_id, "session announces the first request")
	_check(session.requests.get_request_state(first_id).status == RequestRunState.ANNOUNCED, "initial announcement is visible without debug controls")
	var request_view := view_model.request_snapshot()
	var domain_preview := session.requests.build_preview(first_id)
	_check_near(float(request_view["peak"]), domain_preview.predicted_peak, "request view model uses domain peak prediction")
	_check_near(float(request_view["estimated_seconds"]), domain_preview.estimated_seconds, "request view model uses domain duration prediction")
	_check(session.authorize_current_request(), "session authorizes and starts current request")
	_check(session.advance_time(120.0), "session advances request to report")
	_check(session.requests.get_request_state(first_id).status == RequestRunState.COMPLETED, "request completes through online coordinator")
	_check_near(session.requests.grid.state.stored_energy, 12.0, "first completion funds the documented first purchase")
	_check(session.acknowledge_report(first_id), "report acknowledgement announces the next request")
	_check(session.current_request_id() == "era01_remember_name", "next authored request becomes current")
	var domain_economy_preview := session.preview_infrastructure("wall_outlet")
	var wall_card: Dictionary = {}
	for card: Dictionary in view_model.infrastructure_cards():
		if card["id"] == "wall_outlet":
			wall_card = card
			break
	_check(not wall_card.is_empty(), "view model exposes reusable Wall Outlet card")
	_check_near(float(wall_card["cost"]), domain_economy_preview.cost, "shop view model uses economy cost calculator")
	_check(str(wall_card["effect"]).contains("+5.0"), "shop view model exposes predicted effect before purchase")
	var predicted_generation := float(domain_economy_preview.resulting_values["generation_rate"])
	_check(session.purchase_infrastructure("wall_outlet"), "funded infrastructure purchase succeeds through session")
	_check_near(session.requests.grid.state.generation_rate, predicted_generation, "request grid receives the exact economy preview result")
	_check_near(session.requests.grid.state.stored_energy, 1.0, "shared currency subtracts the exact next cost")
	_check(session.economy.state.stored_energy == session.requests.grid.state.stored_energy, "economy and request domains share one visible currency balance")
	_check(session.feedback.last_feedback == "purchase", "purchase emits the essential feedback hook")


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN UI SYSTEM TESTS PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("MAIN UI SYSTEM TEST FAILED: %s" % failure)
	quit(1)


func _check_near(actual: float, expected: float, label: String) -> void:
	_check(absf(actual - expected) <= 0.000001, "%s: expected %.6f, got %.6f" % [label, expected, actual])


func _check(value: bool, failure: String) -> void:
	_checks += 1
	if not value:
		_failures.append(failure)
