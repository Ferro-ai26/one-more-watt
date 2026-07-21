class_name OfflineSimulator
extends RefCounted


static func simulate(session: GameSession, saved_utc: int, current_utc: int) -> OfflineReport:
	var report := OfflineReport.new()
	var balance := session.repository.get_balance("prototype_balance")
	var policy: Dictionary = balance.get_value("offline_progress", {})
	report.cap_seconds = maxf(float(policy.get("cap_seconds", 7200.0)), 0.0)
	report.efficiency = clampf(float(policy.get("efficiency", 0.8)), 0.0, 1.0)
	report.raw_elapsed = float(current_utc - saved_utc)
	report.clock_backward = report.raw_elapsed < 0.0
	var nonnegative := maxf(report.raw_elapsed, 0.0)
	report.recognized_elapsed = minf(nonnegative, report.cap_seconds)
	report.capped = nonnegative > report.cap_seconds
	report.far_forward = nonnegative > maxf(float(policy.get("far_forward_seconds", report.cap_seconds * 4.0)), report.cap_seconds)
	report.effective_elapsed = report.recognized_elapsed * report.efficiency
	report.stored_energy_before = session.requests.grid.state.stored_energy
	var action_sequence_before := session.economy.state.automation_action_sequence
	if not session.has_feature("offline_progress"):
		report.feature_locked = true
		report.effective_elapsed = 0.0
		report.stored_energy_after = report.stored_energy_before
		return report
	if session.has_pending_maintenance():
		if not session.try_resolve_routine_maintenance():
			report.stopped_for_input = true
			report.stop_reason = "operator_input_required"
			report.effective_elapsed = 0.0
			report.stored_energy_after = report.stored_energy_before
			return report
	var current_id := session.current_request_id()
	report.request_id = current_id
	var initial_state := session.requests.get_request_state(current_id)
	if initial_state != null:
		report.progress_before = initial_state.progress
		var definition := session.repository.get_request(current_id)
		if initial_state.status in [RequestRunState.ANNOUNCED, RequestRunState.AUTHORIZED] and definition != null and "tutorial" in definition.get_value("tags", []):
			report.stopped_for_input = true
			report.effective_elapsed = 0.0
			report.stored_energy_after = report.stored_energy_before
			report.progress_after = report.progress_before
			return report
	var remaining := report.effective_elapsed
	var brownout_before := 0.0 if initial_state == null else initial_state.brownout_seconds
	while remaining > 0.000000001:
		var active := session.requests.get_active_state()
		if active == null:
			if session.has_pending_maintenance():
				if session.try_resolve_routine_maintenance():
					continue
				report.stopped_for_input = true
				report.stop_reason = "operator_input_required"
				break
			if not session.economy.state.scheduled_request_id.is_empty():
				if session.try_start_scheduled_request():
					continue
				var idle_chunk := minf(remaining, 60.0)
				if not session.advance_idle_time(idle_chunk):
					break
				remaining -= idle_chunk
				continue
			session.advance_idle_time(remaining)
			remaining = 0.0
			break
		var active_id := active.request_id
		var elapsed_before := active.elapsed_seconds
		var chunk := minf(remaining, 60.0)
		if not session.advance_time(chunk, true):
			break
		var restored_state := session.requests.get_request_state(active_id)
		var consumed := maxf(restored_state.elapsed_seconds - elapsed_before, 0.0)
		remaining -= minf(consumed, remaining)
		if restored_state.status == RequestRunState.COMPLETED:
			report.completed_request_ids.append(active_id)
			report.stopped_for_input = true
			report.stop_reason = "completion_report_ready"
			if consumed <= 0.0:
				break
			break
	var final_state := session.requests.get_request_state(current_id)
	if final_state != null:
		report.progress_after = final_state.progress
		report.brownout_seconds = maxf(final_state.brownout_seconds - brownout_before, 0.0)
	report.stored_energy_after = session.requests.grid.state.stored_energy
	report.automation_actions = session.automation_actions_since(action_sequence_before)
	return report
