class_name EconomyPreview
extends RefCounted

const INVALID := "invalid"
const LOCKED := "locked"
const UNAFFORDABLE := "unaffordable"
const AFFORDABLE := "affordable"
const MAXED := "maxed"

var content_id := ""
var family := ""
var amount := 0
var current_level := 0
var resulting_level := 0
var status := INVALID
var cost := 0.0
var missing_currency := 0.0
var unmet_conditions: Array[String] = []
var current_values: Dictionary = {}
var resulting_values: Dictionary = {}
var deltas: Dictionary = {}


func can_purchase() -> bool:
	return status == AFFORDABLE


func snapshot() -> Dictionary:
	return {
		"content_id": content_id,
		"family": family,
		"amount": amount,
		"current_level": current_level,
		"resulting_level": resulting_level,
		"status": status,
		"cost": cost,
		"missing_currency": missing_currency,
		"unmet_conditions": unmet_conditions.duplicate(),
		"current_values": current_values.duplicate(true),
		"resulting_values": resulting_values.duplicate(true),
		"deltas": deltas.duplicate(true),
	}
