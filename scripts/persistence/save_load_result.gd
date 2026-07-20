class_name SaveLoadResult
extends RefCounted

var ok := false
var status := "no_save"
var source := ""
var recovered := false
var migrated := false
var sequence := 0
var envelope: Dictionary = {}
var diagnostics: PackedStringArray = []
var preserved_corrupt_path := ""

