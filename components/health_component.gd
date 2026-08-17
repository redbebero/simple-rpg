class_name HealthComponent
extends Node

@export var maximum := 1.0
var value := 1.0

func _ready() -> void:
	value = maximum

func damage(amount: float) -> void:
	value = maxf(0.0, value - amount)
