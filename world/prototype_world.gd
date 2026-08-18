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
	_spawn_creature("herbivore", Vector2(270, 430), ["ANIMAL", "ORGANIC"])
	_spawn_creature("herbivore", Vector2(340, 430), ["ANIMAL", "ORGANIC"])
	_spawn_creature("predator", Vector2(500, 430), ["PREDATOR", "ANIMAL"])
	_spawn_creature("shadow", Vector2(720, 430), ["SHADOW_SENSITIVE", "SHADOW", "ANIMAL"])
	_spawn_object(Vector2(410, 430), ["PLANT", "FLAMMABLE", "ORGANIC"])
	_spawn_object(Vector2(450, 430), ["PLANT", "FLAMMABLE", "ORGANIC"])
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
	_route_if_needed()
	queue_redraw()

func _route_if_needed() -> void:
	var player := context.get_parent().get_node_or_null("Player")
	if player == null: return
	if player.position.x > 980.0:
		context.router.change_map("boss_arena", Vector2(180.0, 430.0))
	elif player.position.x < 40.0:
		context.router.change_map("village", Vector2(900.0, 430.0))

func try_create_fire() -> void:
	if fire_cooldown > 0.0 or fire != null: return
	fire_cooldown = 0.5
	fire = _spawn_object(Vector2(390, 430), ["FIRE", "HEAT", "LIGHT"])
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
	draw_rect(Rect2(-400, 0, 2200, 640), Color("#101c31").lerp(Color("#080d19"), fade), true)
	draw_circle(Vector2(820, 92), 34.0, Color("#d9d1b1").lerp(Color("#8b86a0"), fade))
	draw_colored_polygon(PackedVector2Array([Vector2(-400, 320), Vector2(80, 175), Vector2(370, 310), Vector2(700, 160), Vector2(1120, 310), Vector2(1800, 210), Vector2(1800, 430), Vector2(-400, 430)]), Color("#172d3a"))
	draw_rect(Rect2(-400, 285, 2200, 145), Color("#1b3d31").lerp(Color("#142522"), fade), true)
	# Two depth layers of square-canopy trees create a readable forest silhouette.
	for x in range(20, 1100, 70):
		var tree_height := 70.0 + float(int(x / 7) % 3) * 18.0
		draw_rect(Rect2(x - 5, 390 - tree_height, 10, tree_height), Color("#10251f"), true)
		draw_rect(Rect2(x - 32, 350 - tree_height, 64, 48), Color("#214d3a"), true)
	for x in range(55, 1080, 115):
		draw_rect(Rect2(x - 4, 390 - 52, 8, 52), Color("#19352b"), true)
		draw_rect(Rect2(x - 24, 350 - 52, 48, 34), Color("#2f6944"), true)
	# A quiet pond gives the forest a landmark without introducing sprite art.
	draw_set_transform(Vector2(760, 365), 0.0, Vector2(1.0, 0.18))
	draw_circle(Vector2.ZERO, 150.0, Color("#245a6a").lerp(Color("#18333e"), fade))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for x in range(650, 880, 45):
		draw_line(Vector2(x, 365), Vector2(x + 24, 365), Color("#78c4c1"), 2.0)
	draw_line(Vector2(-400, 420), Vector2(1800, 420), Color("#536277"), 4.0)
	draw_rect(Rect2(-400, 424, 2200, 6), Color("#273447"), true)
	draw_rect(Rect2(-400, 430, 2200, 210), Color("#101827"), true)
	draw_rect(Rect2(-400, 525, 2200, 115), Color("#1a2737").lerp(Color("#0d1421"), fade), true)
	draw_line(Vector2(0, 525), Vector2(3200, 525), Color("#536277"), 3.0)
	for x in range(20, 1080, 120):
		draw_line(Vector2(x, 535), Vector2(x + 60, 535), Color("#405067"), 2.0)
		draw_line(Vector2(x + 30, 565), Vector2(x + 100, 565), Color("#293a50"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(32, 150), "FOREST · WILDERNESS", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#a3d17b"))
	draw_string(ThemeDB.fallback_font, Vector2(850, 400), "BOSS ARENA →", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffb08a"))
