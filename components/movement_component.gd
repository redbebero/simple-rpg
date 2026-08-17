class_name MovementComponent
extends Node

@export var speed := 30.0
var desired_velocity := Vector2.ZERO

func tick(actor: Node2D, delta: float) -> void:
	actor.position += desired_velocity.limit_length(speed) * delta
