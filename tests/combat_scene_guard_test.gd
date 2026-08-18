extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.get_node("WorldContext").router.current_map_id == "village")
	assert(not game.is_processing())
	assert(game.get_node("Enemy").collision_layer == 0)
	assert(game.get_node("Enemy").collision_mask == 0)
	game.get_node("WorldContext").router.change_map("forest")
	await process_frame
	assert(not game.is_processing())
	assert(game.get_node("Enemy").collision_layer == 0)
	game.get_node("WorldContext").router.change_map("boss_arena")
	await process_frame
	assert(game.is_processing())
	assert(game.get_node("Enemy").collision_layer == 1)
	print("combat_scene_guard_test: passed")
	quit()
