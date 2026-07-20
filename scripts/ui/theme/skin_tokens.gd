class_name SkinTokens
extends RefCounted

## Authoritative semantic tokens for the Phase 12 skin sample.
## Migrated UI may reference these names, but must not duplicate their literals.

const COLOR_ENVIRONMENT_DEEP := Color("111718")
const COLOR_GRAPHITE := Color("252b2c")
const COLOR_GRAPHITE_RAISED := Color("343b3b")
const COLOR_AGED_METAL := Color("6f6b60")
const COLOR_IVORY := Color("f2e8d2")
const COLOR_IVORY_DIM := Color("c8bfae")
const COLOR_INK := Color("202829")
const COLOR_WATT := Color("24b8c7")
const COLOR_WATT_REBOOT := Color("58e5ec")
const COLOR_GENERATION := Color("e5a91b")
const COLOR_TRANSMISSION := Color("5d4bb3")
const COLOR_RESERVE := Color("23745f")
const COLOR_SUCCESS := Color("3f846c")
const COLOR_WARNING := Color("d9822b")
const COLOR_CRITICAL := Color("a93640")
const COLOR_DISABLED := Color("686f6c")
const COLOR_FOCUS := COLOR_WATT_REBOOT
const COLOR_SHADOW := Color("090d0e")
const COLOR_MODAL_SCRIM := Color("090d0eeb")
const COLOR_MODULATE_NEUTRAL := Color("ffffff")
const COLOR_ERA_01_BACKGROUND := Color("2e302d")
const COLOR_ERA_01_WALL := Color("6f684f")
const COLOR_ERA_01_DESK := Color("5b4938")
const COLOR_ERA_02_BACKGROUND := Color("202626")
const COLOR_ERA_02_WALL := Color("4b5047")
const COLOR_ERA_02_DESK := Color("4e4337")

const TYPE_DISPLAY := 28
const TYPE_WATT := 26
const TYPE_HEADING := 20
const TYPE_REQUEST := 19
const TYPE_BODY := 17
const TYPE_NUMERIC := 18
const TYPE_NAVIGATION := 14
const TYPE_CAPTION := 13
const TYPE_BUTTON := 16

const SPACE_1 := 4
const SPACE_2 := 8
const SPACE_3 := 12
const SPACE_4 := 16
const SPACE_5 := 24

const RADIUS_SMALL := 3
const RADIUS_MEDIUM := 6
const RADIUS_LARGE := 10
const BORDER_HAIRLINE := 1
const BORDER_FOCUS := 2
const ICON_SMALL := 16
const ICON_MEDIUM := 24
const ICON_LARGE := 32
const TOUCH_MINIMUM := 48

const MOTION_TAP := 0.08
const MOTION_RESPONSE := 0.18
const MOTION_REVEAL := 0.45
const MOTION_PULLBACK := 1.20
const REDUCED_MOTION_FADE := 0.12

const COMPONENT_STATES := [
	"default", "focused", "selected", "pressed", "disabled", "locked",
	"affordable", "unaffordable", "warning", "limiting", "loading", "progress",
]


static func panel(surface: Color, border: Color, radius: int = RADIUS_MEDIUM, margin: int = SPACE_2, border_width: int = BORDER_HAIRLINE) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = surface
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin
	style.content_margin_top = margin
	style.content_margin_right = margin
	style.content_margin_bottom = margin
	return style


static func component_style(state: String, surface: Color = COLOR_GRAPHITE) -> StyleBoxFlat:
	match state:
		"focused", "selected":
			return panel(surface, COLOR_FOCUS, RADIUS_MEDIUM, SPACE_3, BORDER_FOCUS)
		"pressed":
			return panel(COLOR_INK, COLOR_WATT, RADIUS_SMALL, SPACE_3, BORDER_FOCUS)
		"disabled":
			return panel(COLOR_INK, COLOR_DISABLED, RADIUS_MEDIUM, SPACE_3)
		"locked":
			return panel(COLOR_INK, COLOR_DISABLED, RADIUS_SMALL, SPACE_3)
		"affordable":
			return panel(surface, COLOR_SUCCESS, RADIUS_MEDIUM, SPACE_3, BORDER_FOCUS)
		"unaffordable":
			return panel(surface, COLOR_WARNING, RADIUS_MEDIUM, SPACE_3)
		"warning", "limiting":
			return panel(surface, COLOR_WARNING, RADIUS_MEDIUM, SPACE_3, BORDER_FOCUS)
		"critical":
			return panel(surface, COLOR_CRITICAL, RADIUS_MEDIUM, SPACE_3, BORDER_FOCUS)
		"loading", "progress":
			return panel(surface, COLOR_WATT, RADIUS_MEDIUM, SPACE_3, BORDER_FOCUS)
		_:
			return panel(surface, COLOR_AGED_METAL, RADIUS_MEDIUM, SPACE_3)


static func state_color(state: String) -> Color:
	match state:
		"focused", "selected", "loading", "progress": return COLOR_FOCUS
		"affordable", "success": return COLOR_SUCCESS
		"warning", "limiting", "unaffordable": return COLOR_WARNING
		"critical": return COLOR_CRITICAL
		"disabled", "locked": return COLOR_DISABLED
		_: return COLOR_IVORY
