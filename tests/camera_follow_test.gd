extends SceneTree


func _init() -> void:
	var duel = load("res://scenes/game.tscn").instantiate()
	root.add_child(duel)
	await process_frame
	var camera: Camera2D = duel.get_node("Camera2D")
	var start := camera.global_position
	duel.player.global_position += Vector2(240.0, 240.0)
	camera._physics_process(0.016)
	assert(camera.global_position.x > start.x)
	assert(camera.global_position.y > start.y)
	assert(camera.global_position.x - start.x < camera.global_position.y - start.y)
	assert(camera.global_position.x < duel.player.global_position.x)
	assert(camera.global_position.y < duel.player.global_position.y)
	print("camera_follow_test: passed")
	quit()
