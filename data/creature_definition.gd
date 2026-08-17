class_name CreatureDefinition
extends Resource

@export var id := ""
@export var movement_speed := 24.0
@export var aggression := 0.2
@export var fear := 0.8
@export var preferred_light := 0.5
@export var tags: Array[String] = []
@export var behavior_weights: Dictionary = {}
@export var shelter_preference := 0.0
