extends SceneTree

const DuelEnemy = preload("res://scripts/duel_enemy.gd")
const DuelRules = preload("res://scripts/duel_rules.gd")


func _init() -> void:
	assert(DuelRules.enemy_intent(300.0, "none", 0) == "lunge")
	assert(DuelRules.enemy_intent(300.0, "none", 3) == "ground_wave")
	assert(DuelRules.enemy_reach("ground_wave") == 320.0)
	assert(DuelRules.enemy_intent(120.0, "none", 2) == "strike")
	assert(DuelRules.enemy_intent(80.0, "none", 3) == "sweep")
	assert(DuelRules.enemy_intent(180.0, "none", 4) == "leap")
	assert(DuelRules.enemy_reach("leap") == 170.0)
	assert(DuelRules.telegraph_time("leap") > DuelRules.telegraph_time("strike"))
	assert(DuelRules.enemy_reach("slam") == 185.0)
	assert(DuelRules.telegraph_time("slam") > DuelRules.telegraph_time("strike"))
	var enemy := DuelEnemy.new()
	enemy.position = Vector2(760.0, 430.0)
	enemy.set_intent("leap")
	var start_x := enemy.position.x
	enemy.set_state("commit")
	enemy.advance_motion(300.0, 0.1)
	assert(enemy.position.x < start_x)
	assert(enemy.position.y < 430.0)
	enemy.set_intent("slam")
	enemy.set_state("commit")
	enemy.advance_motion(300.0, 0.1)
	assert(enemy.position.y < 430.0)
	var airborne_y := enemy.position.y
	enemy.advance_motion(300.0, 0.6)
	assert(enemy.position.y >= airborne_y)
	enemy.position.x = 4000.0
	enemy.advance_motion(300.0, 0.0)
	assert(enemy.position.x == 3100.0)
	enemy.free()
	print("enemy_motion_test: passed")
	quit()
