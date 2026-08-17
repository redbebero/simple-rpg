class_name MemoryComponent
extends Node

var observations: Dictionary = {}

func remember(kind: String, position: Vector2) -> void:
	observations[kind] = {"position": position, "age": 0.0}

func tick(delta: float) -> void:
	for key in observations:
		observations[key].age += delta
		if observations[key].age > 8.0: observations.erase(key)
