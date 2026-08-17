extends SceneTree

const AttackData = preload("res://scripts/attack_data.gd")


func _init() -> void:
	var attack := AttackData.new()
	attack.startup = 0.10
	attack.active = 0.20
	attack.recovery = 0.30
	assert(attack.phase_at(0.05) == "startup")
	assert(attack.phase_at(0.15) == "active")
	assert(attack.phase_at(0.45) == "recovery")
	assert(attack.phase_at(0.61) == "done")
	assert(absf(attack.progress_at(0.15) - 0.25) < 0.001)
	print("attack_data_test: passed")
	quit()
