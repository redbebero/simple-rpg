class_name WorldEvents
extends RefCounted

signal time_changed(time_of_day: float, light_level: float)
signal weather_changed(weather: String, intensity: float)
signal sound_emitted(position: Vector2, intensity: float, kind: String)
signal entity_spotted(observer: Node, position: Vector2, kind: String)
signal fire_started(position: Vector2)
signal fire_weakened(position: Vector2, amount: float)
signal entity_damaged(target: Node, amount: float)
signal creature_fled(creature: Node, reason: String)
signal creature_died(creature: Node)
signal interaction_resolved(effect: String, position: Vector2)
signal world_state_changed(period: String, light_level: float, weather: String)

var recent: Array[String] = []

func record(name: String) -> void:
	recent.push_front(name)
	if recent.size() > 8:
		recent.pop_back()

func emit_state(state: WorldState) -> void:
	world_state_changed.emit(state.period(), state.light_level, state.weather)
