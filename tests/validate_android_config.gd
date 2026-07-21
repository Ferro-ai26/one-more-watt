extends SceneTree

const PRESET := "preset.0"
const OPTIONS := "preset.0.options"
const G01_PRESET := "preset.1"
const G01_OPTIONS := "preset.1.options"
const PACKAGE_ID := "com.ferroai.onemorewatt"

var _failures: Array[String] = []
var _checks := 0


func _init() -> void:
	var config := ConfigFile.new()
	var error := config.load("res://export_presets.cfg")
	_check_equal("export preset loads", error, OK)
	if error != OK:
		_finish()
		return

	_check_equal("normal and G01 debug presets", config.get_sections().size(), 4)
	_check_equal("preset name", config.get_value(PRESET, "name"), "Android Debug")
	_check_equal("preset platform", config.get_value(PRESET, "platform"), "Android")
	_check_equal("preset is runnable", config.get_value(PRESET, "runnable"), true)
	_check_equal("debug export path", config.get_value(PRESET, "export_path"), "build/android/one_more_watt_phase10_debug.apk")
	_check_equal("prebuilt template export", config.get_value(OPTIONS, "gradle_build/use_gradle_build"), false)
	_check_equal("permanent package identifier", config.get_value(OPTIONS, "package/unique_name"), PACKAGE_ID)
	_check_equal("package display name", config.get_value(OPTIONS, "package/name"), "ONE MORE WATT")
	_check_equal("version code", config.get_value(OPTIONS, "version/code"), 10)
	_check_equal("version name", config.get_value(OPTIONS, "version/name"), ProjectSettings.get_setting("application/config/version"))
	_check_equal("arm64 included", config.get_value(OPTIONS, "architectures/arm64-v8a"), true)
	_check_equal("x86_64 included", config.get_value(OPTIONS, "architectures/x86_64"), true)
	_check_equal("32-bit ARM excluded", config.get_value(OPTIONS, "architectures/armeabi-v7a"), false)
	_check_equal("32-bit x86 excluded", config.get_value(OPTIONS, "architectures/x86"), false)
	_check_equal("Internet permission excluded", config.get_value(OPTIONS, "permissions/internet"), false)
	_check_equal("network-state permission excluded", config.get_value(OPTIONS, "permissions/access_network_state"), false)
	_check_equal("haptic vibration permission included", config.get_value(OPTIONS, "permissions/vibrate"), true)
	_check_equal("debug keystore path not committed", config.get_value(OPTIONS, "keystore/debug", ""), "")
	_check_equal("debug keystore user not committed", config.get_value(OPTIONS, "keystore/debug_user", ""), "")
	_check_equal("debug keystore password not committed", config.get_value(OPTIONS, "keystore/debug_password", ""), "")
	_check_equal("release keystore absent", config.get_value(OPTIONS, "keystore/release", ""), "")
	_check_true("tests excluded from APK", "tests/*" in str(config.get_value(PRESET, "exclude_filter")))
	_check_true("tools excluded from APK", "tools/*" in str(config.get_value(PRESET, "exclude_filter")))
	_check_equal("G01 preset name", config.get_value(G01_PRESET, "name"), "Android G01 Debug")
	_check_equal("G01 preset is not the normal runnable preset", config.get_value(G01_PRESET, "runnable"), false)
	_check_equal("G01 feature is explicit", config.get_value(G01_PRESET, "custom_features"), "g01_playtest")
	_check_equal("G01 export path", config.get_value(G01_PRESET, "export_path"), "build/android/one_more_watt_g01_debug.apk")
	_check_equal("G01 package identifier", config.get_value(G01_OPTIONS, "package/unique_name"), PACKAGE_ID)
	_check_equal("G01 version code", config.get_value(G01_OPTIONS, "version/code"), 10)
	_check_equal("G01 version name", config.get_value(G01_OPTIONS, "version/name"), ProjectSettings.get_setting("application/config/version"))
	_check_equal("G01 arm64 included", config.get_value(G01_OPTIONS, "architectures/arm64-v8a"), true)
	_check_equal("G01 x86_64 included", config.get_value(G01_OPTIONS, "architectures/x86_64"), true)
	_check_equal("G01 Internet permission excluded", config.get_value(G01_OPTIONS, "permissions/internet"), false)
	_check_equal("G01 network-state permission excluded", config.get_value(G01_OPTIONS, "permissions/access_network_state"), false)
	_check_true("G01 tests excluded from APK", "tests/*" in str(config.get_value(G01_PRESET, "exclude_filter")))
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("ANDROID EXPORT CONFIG VALIDATION PASSED: %d checks" % _checks)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ANDROID EXPORT CONFIG VALIDATION FAILED: %s" % failure)
	quit(1)


func _check_equal(label: String, actual: Variant, expected: Variant) -> void:
	_checks += 1
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [label, expected, actual])


func _check_true(label: String, value: bool) -> void:
	_checks += 1
	if not value:
		_failures.append(label)
