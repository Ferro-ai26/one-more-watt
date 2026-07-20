class_name NumberFormatter
extends RefCounted

const POWER_UNITS := ["W", "kW", "MW", "GW", "TW", "PW"]


static func format_number(value: float, notation: String = RuntimeSettings.NOTATION_ENGINEERING) -> String:
	if not is_finite(value):
		return "—"
	var magnitude := absf(value)
	if notation == RuntimeSettings.NOTATION_SCIENTIFIC and magnitude >= 1000.0:
		return _scientific(value)
	if magnitude < 1000.0:
		return _plain(value)
	var exponent_group := mini(int(floor(log(magnitude) / log(1000.0))), POWER_UNITS.size() - 1)
	var scaled := value / pow(1000.0, exponent_group)
	return "%s%s" % [_compact(scaled), ["", "k", "M", "G", "T", "P"][exponent_group]]


static func format_power(value: float, notation: String = RuntimeSettings.NOTATION_ENGINEERING) -> String:
	if not is_finite(value):
		return "— W"
	if notation == RuntimeSettings.NOTATION_SCIENTIFIC and absf(value) >= 1000.0:
		return "%s W" % _scientific(value)
	var magnitude := absf(value)
	var unit_index := 0
	while magnitude >= 1000.0 and unit_index < POWER_UNITS.size() - 1:
		magnitude /= 1000.0
		value /= 1000.0
		unit_index += 1
	return "%s %s" % [_compact(value), POWER_UNITS[unit_index]]


static func format_energy(value: float, notation: String = RuntimeSettings.NOTATION_ENGINEERING) -> String:
	return "%s SE" % format_number(value, notation)


static func format_duration(seconds: float) -> String:
	if not is_finite(seconds) or seconds < 0.0:
		return "unknown"
	if seconds < 60.0:
		return "%.1fs" % seconds
	var whole_seconds := int(round(seconds))
	var minutes := whole_seconds / 60
	var remainder := whole_seconds % 60
	return "%dm %02ds" % [minutes, remainder]


static func _plain(value: float) -> String:
	return str(int(round(value))) if is_equal_approx(value, round(value)) else "%.1f" % value


static func _compact(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	var magnitude := absf(value)
	if magnitude >= 100.0:
		return "%.0f" % value
	if magnitude >= 10.0:
		return "%.1f" % value
	return "%.2f" % value


static func _scientific(value: float) -> String:
	if is_zero_approx(value):
		return "0"
	var exponent := int(floor(log(absf(value)) / log(10.0) + 0.000000000001))
	var mantissa := value / pow(10.0, exponent)
	return "%.2f×10^%d" % [mantissa, exponent]
