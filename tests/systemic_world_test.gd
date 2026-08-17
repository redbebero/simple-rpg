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
	var resolver: InteractionResolver = ResolverScript.new()
	assert("BURN" in resolver.resolve(["FIRE"], ["FLAMMABLE"]))
	assert("WEAKEN_FIRE" in resolver.resolve(["RAIN"], ["FIRE"]))
	var context: WorldContext = ContextScript.new()
	root.add_child(context)
	await process_frame
	var prototype = context.get_node("PrototypeWorld")
	prototype.try_create_fire()
	assert(prototype.fire != null)
	prototype._apply_interactions()
	assert(prototype.objects[0].burning)
	var before: float = prototype.fire.intensity
	context.set_weather("rain", 1.0)
	prototype._process(1.0)
	assert(prototype.fire.intensity < before)
	print("systemic_world_test: PASS")
	quit()
