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
var tag_component: TagComponent
var health_component: HealthComponent
var movement_component: MovementComponent
var reaction_component: ReactionComponent
var needs_component: NeedsComponent
var memory_component: MemoryComponent

func setup(world: WorldContext, kind: String, initial_tags: Array[String]) -> void:
	context = world
	creature_kind = kind
	tags = initial_tags
	tag_component = TagComponent.new()
	tag_component.tags = initial_tags
	add_child(tag_component)
	health_component = HealthComponent.new()
	health_component.maximum = 3.0
	add_child(health_component)
	movement_component = MovementComponent.new()
	movement_component.speed = speed
	add_child(movement_component)
	reaction_component = ReactionComponent.new()
	add_child(reaction_component)
	needs_component = NeedsComponent.new()
	add_child(needs_component)
	memory_component = MemoryComponent.new()
	add_child(memory_component)
	var perception := PerceptionComponent.new()
	perception.name = "PerceptionComponent"
	add_child(perception)
	world.get_node("PrototypeWorld").perception.register(self)

func receive_sound(at: Vector2, intensity: float, kind: String) -> void:
	if global_position.distance_to(at) <= 260.0 * intensity:
		heard = intensity
		memory[kind] = at
		if memory_component != null: memory_component.remember(kind, at)
		if kind == "predator" and creature_kind == "herbivore": perceived_danger = 1.0

func receive_visible(at: Vector2, intensity: float, kind: String) -> void:
	if global_position.distance_to(at) <= 220.0 * intensity:
		memory[kind] = at
		if kind == "fire" and "SHADOW_SENSITIVE" in tags: perceived_danger = intensity

func apply_world_pressure(state: WorldState, delta: float) -> void:
	if needs_component != null: needs_component.tick(delta)
	if reaction_component != null: reaction_component.tick(delta)
	if memory_component != null: memory_component.tick(delta)
	if creature_kind == "shadow" and state.period() == "night":
		perceived_danger = maxf(0.0, perceived_danger - delta * 0.03)

func tick(delta: float) -> void:
	var light := context.state.light_level
	var night := 1.0 if context.state.period() == "night" else 0.0
	var danger := perceived_danger
	decision = UtilityAI.choose({"hunger": 0.4 if creature_kind == "herbivore" else 0.0, "danger": danger, "fear": fear, "aggression": aggression, "prey": 1.0 if memory.has("herbivore") else 0.0, "rain": context.state.rain_intensity, "night": night, "shelter": 0.6, "light": light, "light_aversion": light_aversion, "heard": heard})
	if creature_kind == "shadow":
		var shelter_target := 740.0 if context.state.period() != "night" else 620.0
		position.x = move_toward(position.x, shelter_target, speed * delta)
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
