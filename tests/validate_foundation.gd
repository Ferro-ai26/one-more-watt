extends SceneTree

const EXPECTED_DIRECTORIES := [
	"res://assets/audio",
	"res://assets/fonts",
	"res://assets/icons",
	"res://assets/illustrations",
	"res://assets/shaders",
	"res://assets/themes",
	"res://data/achievements",
	"res://data/balance",
	"res://data/dialogue",
	"res://data/eras",
	"res://data/incidents",
	"res://data/infrastructure",
	"res://data/localization",
	"res://data/requests",
	"res://data/upgrades",
	"res://scenes/app",
	"res://scenes/components",
	"res://scenes/debug",
	"res://scenes/screens",
	"res://scenes/watt",
	"res://scenes/world",
	"res://scripts/content",
	"res://scripts/core",
	"res://scripts/persistence",
	"res://scripts/simulation",
	"res://scripts/ui",
	"res://scripts/utilities",
	"res://tests/fixtures",
	"res://tests/integration",
	"res://tests/unit",
	"res://tools",
]

var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	_check_equal("project name", ProjectSettings.get_setting("application/config/name"), "ONE MORE WATT")
	_check_equal("project version", ProjectSettings.get_setting("application/config/version"), "0.10.0-dev")
	_check_equal("build identifier", ProjectSettings.get_setting("application/config/build_commit"), "phase10-dev")
	_check_equal("application icon path", ProjectSettings.get_setting("application/config/icon"), "res://assets/icons/app_icon.svg")
	_check_equal("Android back is app-controlled", ProjectSettings.get_setting("application/config/quit_on_go_back"), false)
	_check_equal("main scene", ProjectSettings.get_setting("application/run/main_scene"), "res://scenes/app/Main.tscn")
	_check_equal("viewport width", ProjectSettings.get_setting("display/window/size/viewport_width"), 720)
	_check_equal("viewport height", ProjectSettings.get_setting("display/window/size/viewport_height"), 1280)
	_check_equal("stretch mode", ProjectSettings.get_setting("display/window/stretch/mode"), "canvas_items")
	_check_equal("stretch aspect", ProjectSettings.get_setting("display/window/stretch/aspect"), "expand")
	_check_equal("portrait orientation", ProjectSettings.get_setting("display/window/handheld/orientation"), 1)
	_check_equal("renderer", ProjectSettings.get_setting("rendering/renderer/rendering_method"), "gl_compatibility")

	_check_true("Godot 4.6.2 runtime", str(Engine.get_version_info().get("string", "")).begins_with("4.6.2"))
	_check_true("app_back input action", InputMap.has_action("app_back"))
	_check_true("app_confirm input action", InputMap.has_action("app_confirm"))
	_check_true("app_toggle_debug input action", InputMap.has_action("app_toggle_debug"))

	for directory in EXPECTED_DIRECTORIES:
		_check_true("directory %s" % directory, DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)))

	_check_resource("res://scenes/app/Main.tscn", "PackedScene")
	_check_resource("res://assets/icons/app_icon.svg", "Texture2D")
	_check_resource("res://assets/themes/base_theme.tres", "Theme")
	_check_resource("res://default_bus_layout.tres", "AudioBusLayout")

	for bus_name in [&"Master", &"Music", &"SFX", &"UI"]:
		_check_true("audio bus %s" % bus_name, AudioServer.get_bus_index(bus_name) >= 0)

	if _failures.is_empty():
		print("FOUNDATION VALIDATION PASSED: %d checks" % _checks)
		quit(0)
		return

	for failure in _failures:
		printerr("FOUNDATION VALIDATION FAILED: %s" % failure)
	printerr("FOUNDATION VALIDATION FAILED: %d of %d checks" % [_failures.size(), _checks])
	quit(1)


func _check_resource(path: String, expected_class: String) -> void:
	var resource := load(path)
	_check_true("resource %s loads as %s" % [path, expected_class], resource != null and resource.is_class(expected_class))


func _check_equal(label: String, actual: Variant, expected: Variant) -> void:
	_checks += 1
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [label, expected, actual])


func _check_true(label: String, value: bool) -> void:
	_checks += 1
	if not value:
		_failures.append(label)
