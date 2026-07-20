class_name DemandProfileSampler
extends RefCounted


static func multiplier_at(profile: DemandProfileDefinition, elapsed_seconds: float) -> float:
	if profile == null:
		return 1.0
	var duration := profile.get_duration_seconds()
	var sample_time := maxf(elapsed_seconds, 0.0)
	if bool(profile.get_value("loop", false)) and duration > 0.0:
		sample_time = fmod(sample_time, duration)
	else:
		sample_time = minf(sample_time, duration)
	var keyframes: Array = profile.get_value("keyframes", [])
	if keyframes.is_empty():
		return 1.0
	if sample_time <= float(keyframes[0].get("time_seconds", 0.0)):
		return maxf(float(keyframes[0].get("multiplier", 1.0)), 0.0)
	for index: int in range(1, keyframes.size()):
		var left: Dictionary = keyframes[index - 1]
		var right: Dictionary = keyframes[index]
		var right_time := float(right.get("time_seconds", duration))
		if sample_time <= right_time:
			var left_time := float(left.get("time_seconds", 0.0))
			var span := right_time - left_time
			if span <= 0.0:
				return maxf(float(right.get("multiplier", 1.0)), 0.0)
			var weight := (sample_time - left_time) / span
			return maxf(lerpf(float(left.get("multiplier", 1.0)), float(right.get("multiplier", 1.0)), weight), 0.0)
	return maxf(float(keyframes[-1].get("multiplier", 1.0)), 0.0)


static func peak_multiplier(profile: DemandProfileDefinition) -> float:
	if profile == null:
		return 1.0
	var peak := 0.0
	for keyframe_value: Variant in profile.get_value("keyframes", []):
		if keyframe_value is Dictionary:
			peak = maxf(peak, float(keyframe_value.get("multiplier", 0.0)))
	return peak


static func seconds_until_next_peak(profile: DemandProfileDefinition, elapsed_seconds: float) -> float:
	if profile == null:
		return INF
	var duration := profile.get_duration_seconds()
	if duration <= 0.0:
		return INF
	var keyframes: Array = profile.get_value("keyframes", [])
	var peak := peak_multiplier(profile)
	var sample_time := maxf(elapsed_seconds, 0.0)
	if bool(profile.get_value("loop", false)):
		sample_time = fmod(sample_time, duration)
	for keyframe_value: Variant in keyframes:
		if not keyframe_value is Dictionary or float(keyframe_value.get("multiplier", 0.0)) + 0.000000001 < peak:
			continue
		var peak_time := float(keyframe_value.get("time_seconds", 0.0))
		if peak_time + 0.000000001 >= sample_time:
			return peak_time - sample_time
	if bool(profile.get_value("loop", false)):
		for keyframe_value: Variant in keyframes:
			if keyframe_value is Dictionary and float(keyframe_value.get("multiplier", 0.0)) + 0.000000001 >= peak:
				return duration - sample_time + float(keyframe_value.get("time_seconds", 0.0))
	return INF
