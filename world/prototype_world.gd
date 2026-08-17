class_name PrototypeWorld
extends Node2D

const CreatureScript = preload("res://entities/creature.gd")
const ObjectScript = preload("res://entities/world_object.gd")
const NpcScript = preload("res://entities/npc.gd")
var context: WorldContext
var perception: PerceptionSystem
var creatures: Array[WorldCreature] = []
var objects: Array[WorldObject] = []
var fire: WorldObject
var fire_cooldown := 0.0
var rain_timer := 0.0

func _ready() -> void:
	perception = context.perception
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
	var creature: WorldCreature = NpcScript.new() if kind == "villager" else CreatureScript.new()
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
	var definition_id := "fire" if "FIRE" in tags else "plant" if "PLANT" in tags else ""
	var definition := load("res://data/objects/%s.tres" % definition_id) as ObjectDefinition if definition_id != "" else null
	object.setup(definition, tags)
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
	var fade := 1.0 - light
	draw_rect(Rect2(0, 120, 3200, 310), Color("#20354a").lerp(Color("#0e1828"), fade), true)
	# Four regions share one continuous ground line instead of floating cards.
	draw_rect(Rect2(0, 285, 260, 145), Color("#76533d").lerp(Color("#2c2630"), fade), true)
	draw_rect(Rect2(260, 270, 290, 160), Color("#244b2e").lerp(Color("#172529"), fade), true)
	draw_rect(Rect2(550, 300, 170, 130), Color("#235270").lerp(Color("#17263a"), fade), true)
	draw_rect(Rect2(720, 250, 360, 180), Color("#161225").lerp(Color("#0b0b16"), fade), true)
	for x in range(285, 540, 42):
		var tree_height := 38.0 + float(int(x / 7) % 3) * 12.0
		draw_line(Vector2(x, 390), Vector2(x, 390 - tree_height), Color("#152b24"), 7.0)
		draw_circle(Vector2(x, 380 - tree_height), 18.0, Color("#326b42"))
	for x in range(570, 710, 28):
		draw_line(Vector2(x, 330 + sin(float(x)) * 4.0), Vector2(x + 18, 330 + sin(float(x)) * 4.0), Color(0.45, 0.78, 0.9, 0.55), 2.0)
	draw_arc(Vector2(895, 405), 170, PI, TAU, 32, Color("#2d2545"), 28.0)
	draw_line(Vector2(0, 420), Vector2(1080, 420), Color("#536277"), 4.0)
	draw_rect(Rect2(0, 424, 1080, 6), Color("#273447"), true)
	# The combat lane is also world space: it now has ground, depth marks, and silhouettes.
	draw_rect(Rect2(0, 430, 3200, 210), Color("#101827"), true)
	draw_rect(Rect2(0, 525, 3200, 115), Color("#1a2737").lerp(Color("#0d1421"), fade), true)
	draw_line(Vector2(0, 525), Vector2(3200, 525), Color("#536277"), 3.0)
	for x in range(20, 3200, 120):
		draw_line(Vector2(x, 535), Vector2(x + 60, 535), Color("#405067"), 2.0)
		draw_line(Vector2(x + 30, 565), Vector2(x + 100, 565), Color("#293a50"), 2.0)
	for offset: int in [1080, 2160]:
		draw_rect(Rect2(offset, 285, 260, 145), Color("#76533d").lerp(Color("#2c2630"), fade), true)
		draw_rect(Rect2(offset + 260, 270, 290, 160), Color("#244b2e").lerp(Color("#172529"), fade), true)
		draw_rect(Rect2(offset + 550, 300, 170, 130), Color("#235270").lerp(Color("#17263a"), fade), true)
		draw_rect(Rect2(offset + 720, 250, 360, 180), Color("#161225").lerp(Color("#0b0b16"), fade), true)
		draw_string(ThemeDB.fallback_font, Vector2(offset + 24, 150), "VILLAGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#e3c38b"))
		draw_string(ThemeDB.fallback_font, Vector2(offset + 285, 150), "FOREST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a3d17b"))
		draw_string(ThemeDB.fallback_font, Vector2(offset + 575, 150), "LAKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8ed5ef"))
		draw_string(ThemeDB.fallback_font, Vector2(offset + 755, 150), "CAVE SHELTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#bba3e5"))
	draw_string(ThemeDB.fallback_font, Vector2(24, 150), "VILLAGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#e3c38b"))
	draw_string(ThemeDB.fallback_font, Vector2(285, 150), "FOREST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a3d17b"))
	draw_string(ThemeDB.fallback_font, Vector2(575, 150), "LAKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8ed5ef"))
	draw_string(ThemeDB.fallback_font, Vector2(755, 150), "CAVE SHELTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#bba3e5"))
