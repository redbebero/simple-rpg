extends SceneTree

const ContextScript = preload("res://core/world_context.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var context: WorldContext = ContextScript.new()
	root.add_child(context)
	await process_frame
	var router: SceneRouter = context.router
	assert(router.current_map_id == "village")
	assert(router.active_map().villager.position.y == 430.0)
	assert(router.change_map("forest"))
	await process_frame
	assert(router.current_map_id == "forest")
	assert(router.active_map().has_method("try_create_fire"))
	for creature in router.active_map().creatures: assert(creature.position.y == 430.0)
	for object in router.active_map().objects: assert(object.position.y == 430.0)
	assert(router.change_map("boss_arena"))
	await process_frame
	assert(router.current_map_id == "boss_arena")
	assert(router.active_map().get_node_or_null("BossEnemy") != null)
	print("scene_router_test: passed")
	quit()
