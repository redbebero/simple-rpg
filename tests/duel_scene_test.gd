extends SceneTree


func _init() -> void:
	var duel = load("res://scenes/game.tscn").instantiate()
	root.add_child(duel)
	await process_frame
	assert(duel.get_node("Camera2D").limit_right == 3200)
	assert(duel.get_node("Camera2D").limit_bottom == 2000)
	assert(duel.get_node("Camera2D").process_callback == Camera2D.CAMERA2D_PROCESS_PHYSICS)
	assert(not duel.get_node("Camera2D").position_smoothing_enabled)
	assert(duel.get_node("Camera2D").target == duel.player)
	assert(ProjectSettings.get_setting("physics/common/physics_interpolation") == true)
	duel.player.global_position.x = 4000.0
	duel.player._physics_process(0.016)
	assert(duel.player.global_position.x == 3100.0)
	duel.enemy.hp = 0
	await process_frame
	assert(duel.route_choice)
	duel._choose_route(false)
	assert(duel.enemy.hp == 4)
	duel.route_choice = true
	duel._choose_route(true)
	assert(duel.enemy.hp == 3)
	assert(duel.player.hp == 3)
	duel.player.position.x = 650.0
	duel.enemy.position.x = 760.0
	duel.enemy.intent = "strike"
	duel.player.begin_action("attack")
	duel._resolve_response()
	assert(duel.enemy.hp == 2)
	assert(duel.message == "STRIKE")
	duel._choose_route(true)
	duel.player.position.x = 660.0
	duel.enemy.position.x = 760.0
	duel.player.begin_action("attack")
	duel.player.action_phase = "active"
	duel._process(0.01)
	assert(duel.enemy.hp == 2)
	duel.enemy.reset(3)
	duel.enemy.intent = "strike"
	duel.player.begin_action("parry")
	duel.parry_armed = true
	duel._resolve_response()
	assert(duel.phase == "recover")
	assert(duel.enemy.state == "stagger")
	duel._choose_route(true)
	duel.player.position = Vector2(300.0, 430.0)
	duel.enemy.position = Vector2(400.0, 430.0)
	duel.enemy.intent = "strike"
	duel.enemy.set_state("commit")
	duel.phase = "telegraph"
	duel.timer = 0.01
	duel._process(0.02)
	assert(duel.player.hp == 2)
	print("duel_scene_test: passed")
	quit()
