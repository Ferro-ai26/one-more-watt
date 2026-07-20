class_name FeedbackAudio
extends Node

const SAMPLE_RATE := 22050
const CUES := {
	"purchase": {"start": 620.0, "end": 880.0, "duration": 0.12, "cooldown_ms": 60},
	"request_started": {"start": 440.0, "end": 660.0, "duration": 0.10, "cooldown_ms": 100},
	"request_complete": {"start": 660.0, "end": 990.0, "duration": 0.20, "cooldown_ms": 400},
	"brownout": {"start": 180.0, "end": 110.0, "duration": 0.24, "cooldown_ms": 2500},
	"allocation_changed": {"start": 360.0, "end": 520.0, "duration": 0.08, "cooldown_ms": 80},
	"drawer_open": {"start": 280.0, "end": 360.0, "duration": 0.07, "cooldown_ms": 70},
	"era_transition": {"start": 440.0, "end": 880.0, "duration": 0.32, "cooldown_ms": 500},
	"error": {"start": 150.0, "end": 120.0, "duration": 0.13, "cooldown_ms": 250},
}

var last_played := ""
var playback_count := 0

var _player: AudioStreamPlayer
var _streams: Dictionary = {}
var _last_played_msec: Dictionary = {}
var _variants: Dictionary = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "CuePlayer"
	_player.bus = "SFX"
	add_child(_player)


func _exit_tree() -> void:
	if _player != null:
		_player.stop()
		_player.stream = null


func set_application_paused(paused: bool) -> void:
	if _player == null:
		return
	_player.stream_paused = paused
	if paused:
		_player.stop()


func play(kind: String) -> bool:
	if not CUES.has(kind) or _player == null:
		return false
	var now := Time.get_ticks_msec()
	var cue: Dictionary = CUES[kind]
	if now - int(_last_played_msec.get(kind, -1000000)) < int(cue["cooldown_ms"]):
		return false
	var variant := int(_variants.get(kind, 0)) % 2
	_variants[kind] = variant + 1
	var stream_key := "%s_%d" % [kind, variant]
	if not _streams.has(stream_key):
		var pitch_scale := 1.0 if variant == 0 else 1.045
		_streams[stream_key] = build_tone(float(cue["start"]) * pitch_scale, float(cue["end"]) * pitch_scale, float(cue["duration"]))
	_player.stream = _streams[stream_key]
	if DisplayServer.get_name() != "headless":
		_player.play()
	_last_played_msec[kind] = now
	last_played = kind
	playback_count += 1
	return true


static func build_tone(start_hz: float, end_hz: float, duration: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	var sample_count := maxi(roundi(duration * SAMPLE_RATE), 1)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var phase := 0.0
	for index: int in sample_count:
		var position := float(index) / float(maxi(sample_count - 1, 1))
		var frequency := lerpf(start_hz, end_hz, position)
		phase += TAU * frequency / float(SAMPLE_RATE)
		var attack := minf(position / 0.08, 1.0)
		var release := minf((1.0 - position) / 0.22, 1.0)
		var envelope := attack * release
		var sample := clampi(roundi(sin(phase) * envelope * 0.22 * 32767.0), -32768, 32767)
		bytes[index * 2] = sample & 0xff
		bytes[index * 2 + 1] = (sample >> 8) & 0xff
	stream.data = bytes
	return stream
