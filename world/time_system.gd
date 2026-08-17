class_name TimeSystem
extends RefCounted

func tick(state: WorldState, events: WorldEvents, hours: float) -> void:
	state.advance(hours)
	events.time_changed.emit(state.time_of_day, state.light_level)
