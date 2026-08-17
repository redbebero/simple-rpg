class_name PerceptionComponent
extends Node

@export var vision_range := 180.0
@export var hearing_range := 260.0
var last_event := ""
var last_position := Vector2.ZERO

func hear(position: Vector2, intensity: float, kind: String, owner_position: Vector2) -> bool:
	if owner_position.distance_to(position) <= hearing_range * intensity:
		last_event = kind
		last_position = position
		return true
	return false
