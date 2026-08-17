class_name WorldCreature
extends Node2D

@export var creature_kind := "herbivore"
@export var tags: Array[String] = []
@export var aggression := 0.2
@export var fear := 0.8
@export var light_aversion := 0.0
@export var speed := 24.0
var context: WorldContext
var decision := "Idle"
var perceived_danger := 0.0
var heard := 0.0
var memory := {}

func setup(world: WorldContext, kind: String, initial_tags: Array[String]) -> void:
	context = world
	creature_kind = kind
	tags = initial_tags
	var perception := PerceptionComponent.new()
	perception.name = "PerceptionComponent"
	add_child(perception)
	world.get_node("PrototypeWorld").perception.register(self)

func receive_sound(at: Vector2, intensity: float, kind: String) -> void:
	if global_position.distance_to(at) <= 260.0 * intensity:
		heard = intensity
		memory[kind] = at

func tick(delta: float) -> void:
	var light := context.state.light_level
	var night := 1.0 if light < 0.35 else 0.0
	var danger := perceived_danger
	decision = UtilityAI.choose({"hunger": 0.4 if creature_kind == "herbivore" else 0.0, "danger": danger, "fear": fear, "aggression": aggression, "prey": 0.5 if creature_kind == "predator" else 0.0, "rain": context.state.rain_intensity, "night": night, "shelter": 0.6, "light": light, "light_aversion": light_aversion, "heard": heard})
	if creature_kind == "shadow" and light < 0.35: position.x = move_toward(position.x, 720.0, speed * delta)
	if decision == "AvoidLight" or decision == "Flee":
		position.x = move_toward(position.x, position.x - 45.0, speed * delta)
		context.events.creature_fled.emit(self, decision)
		context.events.record(creature_kind + " fled")
	heard = maxf(0.0, heard - delta)
	perceived_danger = maxf(0.0, perceived_danger - delta * 0.12)
	queue_redraw()

func _draw() -> void:
	var color: Color = {"herbivore": Color("#9cdb8a"), "predator": Color("#d87968"), "shadow": Color("#9c82d8"), "villager": Color("#d9bb75")}.get(creature_kind, Color.WHITE)
	draw_circle(Vector2.ZERO, 12.0, color)
	draw_line(Vector2(-10, 9), Vector2(-13, 22), color, 4)
	draw_line(Vector2(10, 9), Vector2(13, 22), color, 4)
