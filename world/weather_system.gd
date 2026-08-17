class_name WeatherSystem
extends RefCounted

func apply(state: WorldState, events: WorldEvents, weather: String, intensity: float) -> void:
	state.set_weather(weather, intensity)
	events.weather_changed.emit(weather, intensity)
	events.emit_state(state)
