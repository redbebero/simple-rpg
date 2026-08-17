extends Camera2D

const FOLLOW_SPEED_X := 3.0
const FOLLOW_SPEED_Y := 12.0
const FOLLOW_OFFSET := Vector2.ZERO

var target: Node2D


func _ready() -> void:
	target = get_parent().get_node("Player") as Node2D
	global_position = target.global_position + FOLLOW_OFFSET


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var destination := target.global_position + FOLLOW_OFFSET
	global_position.x = lerpf(global_position.x, destination.x, 1.0 - exp(-FOLLOW_SPEED_X * delta))
	global_position.y = lerpf(global_position.y, destination.y, 1.0 - exp(-FOLLOW_SPEED_Y * delta))
