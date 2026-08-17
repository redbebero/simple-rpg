class_name WorldState
extends RefCounted

signal changed

var time_of_day := 12.0
var weather := "clear"
var rain_intensity := 0.0
var temperature := 18.0
var light_level := 1.0
var region := "forest"
var region_values: Dictionary = {"wind": 0.15, "magic": 0.0}
var environment: Dictionary = {"wind": 0.15, "magic": 0.0}

func period() -> String:
	if time_of_day >= 6.0 and time_of_day < 18.0: return "day"
	if time_of_day >= 18.0 and time_of_day < 21.0: return "evening"
	return "night"

func set_time(hours: float) -> void:
	time_of_day = fmod(hours + 24.0, 24.0)
	_recalculate()

func set_weather(next_weather: String, intensity := 0.0) -> void:
	weather = next_weather
	rain_intensity = clampf(intensity, 0.0, 1.0)
	_recalculate()

func advance(hours: float) -> void:
	time_of_day = fmod(time_of_day + hours, 24.0)
	_recalculate()

func _recalculate() -> void:
	var daylight := maxf(0.0, sin((time_of_day - 6.0) / 12.0 * PI))
	light_level = clampf(0.08 + daylight * 0.92 - rain_intensity * 0.18, 0.03, 1.0)
	temperature = 12.0 + daylight * 14.0 - rain_intensity * 4.0
	changed.emit()
