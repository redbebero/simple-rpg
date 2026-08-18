extends SceneTree

const ContextScript = preload("res://core/world_context.gd")
const StateScript = preload("res://core/world_state.gd")
const ResolverScript = preload("res://interaction/interaction_resolver.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var state: WorldState = StateScript.new()
	state.time_of_day = 0.0
	state._recalculate()
	assert(state.light_level < 0.2)
	assert(state.period() == "night")
	state.set_time(12.0)
	assert(state.period() == "day")
	assert(state.light_level > 0.9)
	var resolver: InteractionResolver = ResolverScript.new()
	assert("BURN" in resolver.resolve(["FIRE"], ["FLAMMABLE"]))
	assert("WEAKEN_FIRE" in resolver.resolve(["RAIN"], ["FIRE"]))
	assert("FLEE_LIGHT" in resolver.resolve(["LIGHT"], ["SHADOW_SENSITIVE"]))
	assert("SEEK_SHELTER" in resolver.resolve(["COLD"], ["HEAT_SENSITIVE"]))
	assert("AMPLIFY" in resolver.resolve(["MAGIC"], ["MAGIC_CONDUCTOR"]))
	var context: WorldContext = ContextScript.new()
	root.add_child(context)
	await process_frame
	assert(context.router.change_map("forest"))
	await process_frame
	var prototype = context.router.active_map()
	context.state.set_time(0.0)
	var shadow = prototype.creatures[3]
	var shadow_start_x: float = shadow.position.x
	prototype._process(1.0)
	assert(shadow.position.x < shadow_start_x)
	var predator = prototype.creatures[2]
	assert(predator.memory.has("herbivore"))
	prototype.try_create_fire()
	assert(prototype.fire != null)
	assert("fire started" in context.events.recent)
	prototype._apply_interactions()
	assert(prototype.objects[0].burning)
	prototype._process(1.0)
	prototype._process(1.0)
	assert(prototype.creatures[0].decision == "Flee")
	assert(shadow.perceived_danger > 0.0)
	var before: float = prototype.fire.intensity
	context.set_weather("rain", 1.0)
	assert("rain" in context.events.recent)
	assert(context.state.temperature < 26.0)
	prototype._process(1.0)
	assert(prototype.fire.intensity < before)
	print("systemic_world_test: PASS")
	quit()
