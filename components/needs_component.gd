class_name NeedsComponent
extends Node

@export var hunger := 0.0
@export var fear := 0.0

func tick(delta: float) -> void:
	hunger = clampf(hunger + delta * 0.01, 0.0, 1.0)
