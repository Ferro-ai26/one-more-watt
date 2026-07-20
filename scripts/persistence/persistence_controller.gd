class_name PersistenceController
extends RefCounted

const PERIODIC_SECONDS := 30.0
const PURCHASE_DEBOUNCE_SECONDS := 1.0

var session: GameSession
var manager: SaveManager
var last_trusted_utc := 0
var last_load_result: SaveLoadResult
var pending_offline_report: OfflineReport
var dirty := false
var _dirty_elapsed := 0.0
var _save_after := PERIODIC_SECONDS


func configure(game_session: GameSession, save_manager: SaveManager) -> void:
	session = game_session
	manager = save_manager
	session.mutation_committed.connect(_on_mutation)


func bootstrap(current_utc: int) -> Dictionary:
	last_load_result = manager.load()
	if last_load_result.ok:
		if not session.restore(last_load_result.envelope.get("payload", {}).get("session", {}), session.repository):
			return {"ok": false, "status": "invalid_payload"}
		last_trusted_utc = int(last_load_result.envelope.get("last_trusted_utc", current_utc))
		pending_offline_report = OfflineSimulator.simulate(session, last_trusted_utc, current_utc)
		if not pending_offline_report.clock_backward:
			last_trusted_utc = current_utc
		var saved := save_now("offline_applied", current_utc)
		return {"ok": bool(saved.get("ok", false)), "status": last_load_result.status, "offline_report": pending_offline_report, "recovered": last_load_result.recovered}
	if last_load_result.status == "corrupt_all":
		return {"ok": false, "status": "corrupt_all", "requires_confirmation": true}
	last_trusted_utc = current_utc
	var created := save_now("new_game", current_utc)
	return {"ok": bool(created.get("ok", false)), "status": "new_game"}


func save_now(trigger: String, current_utc: int) -> Dictionary:
	if last_trusted_utc <= 0:
		last_trusted_utc = current_utc
	var payload := {"session": session.snapshot()}
	var verifier := GameSession.new()
	if not verifier.configure(session.repository) or not verifier.restore(payload["session"], session.repository):
		return {"ok": false, "error": "invalid_session_snapshot"}
	if current_utc >= last_trusted_utc:
		last_trusted_utc = current_utc
	var result := manager.save(payload, current_utc, last_trusted_utc, trigger)
	if bool(result.get("ok", false)):
		dirty = false
		_dirty_elapsed = 0.0
		_save_after = PERIODIC_SECONDS
	return result


func tick(delta_seconds: float, current_utc: int) -> bool:
	if not dirty or not is_finite(delta_seconds) or delta_seconds < 0.0:
		return false
	_dirty_elapsed += delta_seconds
	if _dirty_elapsed + 0.000001 < _save_after:
		return false
	return bool(save_now("autosave", current_utc).get("ok", false))


func mark_dirty(trigger: String = "state_changed") -> void:
	dirty = true
	_dirty_elapsed = 0.0
	_save_after = minf(_save_after, PURCHASE_DEBOUNCE_SECONDS if trigger == "purchase" else PERIODIC_SECONDS)


func background(current_utc: int) -> Dictionary:
	last_trusted_utc = current_utc
	return save_now("background", current_utc)


func resume(current_utc: int) -> OfflineReport:
	pending_offline_report = OfflineSimulator.simulate(session, last_trusted_utc, current_utc)
	if not pending_offline_report.clock_backward:
		last_trusted_utc = current_utc
	save_now("offline_applied", current_utc)
	return pending_offline_report


func confirm_new_game(current_utc: int) -> Dictionary:
	last_trusted_utc = current_utc
	return save_now("confirmed_new_game", current_utc)


func _on_mutation(trigger: String) -> void:
	if trigger in ["request_completed", "report_acknowledged"]:
		dirty = true
		_save_after = 0.0
		_dirty_elapsed = 0.0
	else:
		mark_dirty(trigger)
