extends SceneTree

const DuelPlayer = preload("res://scripts/duel_player.gd")


func _init() -> void:
	var player := DuelPlayer.new()
	assert(player.queue_action("attack"))
	assert(player.pending_action == "attack")
	player.free()
	print("action_buffer_test: passed")
	quit()
