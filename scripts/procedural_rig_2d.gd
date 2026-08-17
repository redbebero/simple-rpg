class_name ProceduralRig2D
extends Node2D

@export var body_color := Color("#5279a8")

const VISUAL_SHAPE := Rect2(-12.0, -24.0, 24.0, 24.0)
const OUTLINE_COLOR := Color("#0a0d16")


func set_style(style: String) -> void:
	body_color = Color("#c94c59") if style == "enemy" else Color("#5279a8")
	queue_redraw()


func update_pose(_velocity: Vector2, _facing: float, _grounded: bool, _action: String, _delta: float, _phase: String = "none", _progress: float = -1.0, _motion: Resource = null, _attack_progress: float = -1.0) -> void:
	pass


func get_visual_shape() -> Rect2:
	return VISUAL_SHAPE


func get_visual_motion_state() -> String:
	return "static"


func _draw() -> void:
	draw_rect(VISUAL_SHAPE, OUTLINE_COLOR)
	draw_rect(Rect2(-10.0, -22.0, 20.0, 20.0), body_color)
