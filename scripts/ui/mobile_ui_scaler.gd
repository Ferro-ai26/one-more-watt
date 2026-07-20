class_name MobileUIScaler
extends RefCounted

## Converts Godot's resolution-based canvas scaling into Android density-aware
## scaling. The layout uses logical pixels as density-independent pixels, while
## retaining the smallest portrait layout when a display cannot provide both.

const BASE_SIZE := Vector2(720.0, 1280.0)
const MINIMUM_LOGICAL_SIZE := Vector2(320.0, 568.0)
const BASE_DPI := 160.0
const MINIMUM_DENSITY := 0.75
const MAXIMUM_DENSITY := 4.0


static func calculate_content_scale_factor(
	physical_size: Vector2i,
	dpi: int,
	base_size: Vector2 = BASE_SIZE,
	minimum_logical_size: Vector2 = MINIMUM_LOGICAL_SIZE
) -> float:
	if physical_size.x <= 0 or physical_size.y <= 0 or dpi <= 0:
		return 1.0
	if base_size.x <= 0.0 or base_size.y <= 0.0:
		return 1.0
	if minimum_logical_size.x <= 0.0 or minimum_logical_size.y <= 0.0:
		return 1.0

	var physical := Vector2(physical_size)
	var base_fit_scale := minf(physical.x / base_size.x, physical.y / base_size.y)
	if base_fit_scale <= 0.0:
		return 1.0

	var density := clampf(float(dpi) / BASE_DPI, MINIMUM_DENSITY, MAXIMUM_DENSITY)
	var largest_scale_that_fits := minf(
		physical.x / minimum_logical_size.x,
		physical.y / minimum_logical_size.y
	)
	var output_scale := minf(density, largest_scale_that_fits)
	return maxf(output_scale / base_fit_scale, 0.1)


static func effective_logical_size(
	physical_size: Vector2i,
	content_scale_factor: float,
	base_size: Vector2 = BASE_SIZE
) -> Vector2:
	if physical_size.x <= 0 or physical_size.y <= 0 or content_scale_factor <= 0.0:
		return Vector2.ZERO
	var physical := Vector2(physical_size)
	var base_fit_scale := minf(physical.x / base_size.x, physical.y / base_size.y)
	var output_scale := base_fit_scale * content_scale_factor
	return physical / output_scale if output_scale > 0.0 else Vector2.ZERO


static func apply_to_window(window: Window) -> Dictionary:
	var diagnostics := {
		"applied": false,
		"physical_size": window.size,
		"dpi": 0,
		"content_scale_factor": window.content_scale_factor,
		"effective_logical_size": Vector2(window.size),
	}
	if not OS.has_feature("mobile"):
		return diagnostics

	var dpi := DisplayServer.screen_get_dpi(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	var factor := calculate_content_scale_factor(window.size, dpi)
	window.content_scale_factor = factor
	diagnostics["applied"] = true
	diagnostics["dpi"] = dpi
	diagnostics["content_scale_factor"] = factor
	diagnostics["effective_logical_size"] = effective_logical_size(window.size, factor)
	return diagnostics
