class_name PrototypeWorld
extends Node2D

const CreatureScript = preload("res://entities/creature.gd")
const ObjectScript = preload("res://entities/world_object.gd")
const PerceptionScript = preload("res://ai/perception_system.gd")
var context: WorldContext
var perception: PerceptionSystem
var creatures: Array[WorldCreature] = []
var objects: Array[WorldObject] = []
var fire: WorldObject
var fire_cooldown := 0.0
var rain_timer := 0.0

func _ready() -> void:
	perception = PerceptionScript.new()
	_spawn_creature("herbivore", Vector2(270, 250), ["ANIMAL", "ORGANIC"])
	_spawn_creature("herbivore", Vector2(340, 250), ["ANIMAL", "ORGANIC"])
	_spawn_creature("predator", Vector2(500, 250), ["PREDATOR", "ANIMAL"])
	_spawn_creature("shadow", Vector2(720, 245), ["SHADOW_SENSITIVE", "SHADOW", "ANIMAL"])
	_spawn_creature("villager", Vector2(130, 250), ["NPC", "ORGANIC"])
	_spawn_object(Vector2(410, 280), ["PLANT", "FLAMMABLE", "ORGANIC"])
	_spawn_object(Vector2(450, 280), ["PLANT", "FLAMMABLE", "ORGANIC"])
	_spawn_object(Vector2(620, 280), ["WATER", "SOLID"])
	_spawn_object(Vector2(740, 275), ["CAVE", "DARK"])
	queue_redraw()

func _process(delta: float) -> void:
	if context != null and not context.simulation_lod.tick(delta): return
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	rain_timer += delta
	if rain_timer > 18.0 and context.state.weather == "clear": context.set_weather("rain", 0.85)
	if rain_timer > 28.0 and context.state.weather == "rain": context.set_weather("clear", 0.0)
	perception.observe(creatures)
	context.ecology.tick(creatures, context.state, delta)
	for creature in creatures: creature.tick(delta)
	if fire != null and context.state.weather == "rain":
		var rain_effects: Array = context.resolver.resolve(["RAIN"], fire.tags, context.state.rain_intensity)
		if "WEAKEN_FIRE" in rain_effects:
			fire.intensity = maxf(0.0, fire.intensity - delta * context.state.rain_intensity * 0.12)
		if fire.intensity <= 0.0: context.events.fire_weakened.emit(fire.global_position, 1.0)
	_apply_interactions()
	queue_redraw()

func try_create_fire() -> void:
	if fire_cooldown > 0.0 or fire != null: return
	fire_cooldown = 0.5
	fire = _spawn_object(Vector2(390, 275), ["FIRE", "HEAT", "LIGHT"])
	fire.intensity = 1.0
	context.events.record("fire started")
	context.events.fire_started.emit(fire.global_position)
	perception.emit_sound(context.events, fire.global_position, 1.0, "fire")
	perception.emit_visible(context.events, fire.global_position, 1.5, "fire")

func _apply_interactions() -> void:
	if fire == null or fire.intensity <= 0.0: return
	for object in objects:
		if object != fire:
			var effects: Array = context.resolver.resolve(["FIRE"], object.tags, fire.intensity)
			if "BURN" in effects:
				object.burn()
				context.events.interaction_resolved.emit("BURN", object.global_position)
	for creature in creatures:
		if creature.global_position.distance_to(fire.global_position) < 360.0:
			var light_effects: Array = context.resolver.resolve(["LIGHT"], creature.tags, fire.intensity)
			if "FLEE_LIGHT" in light_effects: creature.perceived_danger = 1.0
			elif creature.creature_kind != "villager": creature.perceived_danger = 0.7

func _spawn_creature(kind: String, at: Vector2, tags: Array[String]) -> WorldCreature:
	var creature := CreatureScript.new()
	creature.position = at
	var definition := load("res://data/creatures/%s.tres" % kind) as CreatureDefinition
	var configured_tags: Array[String] = definition.tags if definition != null else tags
	creature.setup(context, kind, configured_tags)
	if definition != null:
		creature.aggression = definition.aggression
		creature.fear = definition.fear
		creature.speed = definition.movement_speed
		creature.light_aversion = 1.0 - definition.preferred_light
		creature.movement_component.speed = creature.speed
	add_child(creature)
	creatures.append(creature)
	return creature

func _spawn_object(at: Vector2, tags: Array[String]) -> WorldObject:
	var object := ObjectScript.new()
	object.position = at
	object.tags = tags
	add_child(object)
	objects.append(object)
	return object

func debug_decisions() -> String:
	var result: Array[String] = []
	for creature in creatures:
		result.append("%s:%s" % [creature.creature_kind, creature.decision])
	return " ".join(result)

func _draw() -> void:
	var light := context.state.light_level if context != null else 1.0
	draw_rect(Rect2(0, 205, 1080, 125), Color("#1d3b2a").lerp(Color("#101827"), 1.0 - light), true)
	draw_rect(Rect2(80, 220, 170, 90), Color("#76533d"), true)
	draw_rect(Rect2(270, 215, 270, 105), Color("#244b2e"), true)
	draw_rect(Rect2(550, 215, 160, 105), Color("#235270"), true)
	draw_rect(Rect2(710, 210, 250, 110), Color("#161225"), true)
	draw_string(ThemeDB.fallback_font, Vector2(90, 238), "VILLAGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#e3c38b"))
	draw_string(ThemeDB.fallback_font, Vector2(300, 238), "FOREST", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#a3d17b"))
	draw_string(ThemeDB.fallback_font, Vector2(580, 238), "LAKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#8ed5ef"))
	draw_string(ThemeDB.fallback_font, Vector2(745, 238), "CAVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#bba3e5"))
