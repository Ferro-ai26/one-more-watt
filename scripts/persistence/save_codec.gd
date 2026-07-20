class_name SaveCodec
extends RefCounted


static func encode(envelope_without_checksum: Dictionary) -> String:
	# Normalize through JSON before hashing so typed Godot arrays and their
	# decoded Array equivalents produce the same portable checksum.
	var normalized_value: Variant = JSON.parse_string(JSON.stringify(_canonicalize(envelope_without_checksum)))
	var envelope: Dictionary = normalized_value if normalized_value is Dictionary else envelope_without_checksum.duplicate(true)
	envelope["checksum"] = checksum_for(envelope)
	return JSON.stringify(_canonicalize(envelope), "  ")


static func decode(text: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {"ok": false, "error": "invalid_json"}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {"ok": false, "error": "invalid_json"}
	var envelope: Dictionary = parsed
	var supplied := str(envelope.get("checksum", ""))
	var unsigned := envelope.duplicate(true)
	unsigned.erase("checksum")
	if supplied.is_empty() or supplied != checksum_for(unsigned):
		return {"ok": false, "error": "checksum_mismatch"}
	return {"ok": true, "envelope": envelope}


static func checksum_for(value: Dictionary) -> String:
	var bytes := JSON.stringify(_canonicalize(value)).to_utf8_buffer()
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


static func _canonicalize(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		var keys: Array = value.keys()
		keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a) < str(b))
		for key: Variant in keys:
			result[str(key)] = _canonicalize(value[key])
		return result
	if value is Array:
		var result: Array = []
		for child: Variant in value:
			result.append(_canonicalize(child))
		return result
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		return float(value)
	return value
