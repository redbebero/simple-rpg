extends CharacterBody2D

const ROOM_RIGHT := 3100.0
const AttackData = preload("res://scripts/attack_data.gd")

var hp := 3
var intent := "strike"
var state := "idle"
var motion_facing := -1.0
var motion_time := 0.0
var ground_y := 430.0
var vertical_velocity := 0.0
var knockback_velocity := 0.0
var attack_data: AttackData


func set_intent(next_intent: String) -> void:
	intent = next_intent
	attack_data = AttackData.for_kind(intent)
	state = "telegraph"
	motion_time = 0.0
	_refresh_color()


func set_state(next_state: String) -> void:
	state = next_state
	motion_time = 0.0
	if next_state != "commit":
		vertical_velocity = 0.0
	_refresh_color()


func take_hit(damage: int = 1, knockback: float = 220.0) -> void:
	hp -= damage
	knockback_velocity = -motion_facing * knockback
	motion_time = 0.0


func reset(new_hp: int) -> void:
	hp = new_hp
	set_state("idle")


func get_attack_data() -> AttackData:
	if attack_data == null:
		attack_data = AttackData.for_kind(intent)
	return attack_data


func advance_motion(target_x: float, delta: float) -> void:
	motion_time += delta
	var direction := signf(target_x - global_position.x)
	if direction != 0.0:
		motion_facing = direction
	if state == "telegraph":
		global_position.x = move_toward(global_position.x, target_x - motion_facing * 130.0, 110.0 * delta)
	elif state == "commit":
		var speed: float = float({"ground_wave": 0.0, "lunge": 560.0, "sweep": 220.0, "delayed_sweep": 150.0, "leap": 360.0, "slam": 250.0, "heavy_swing": 115.0, "strike": 90.0, "feint": 65.0}.get(intent, 90.0))
		global_position.x += motion_facing * speed * delta
		if intent in ["leap", "slam"]:
			if motion_time <= delta * 1.5 and vertical_velocity == 0.0:
				vertical_velocity = -460.0 if intent == "leap" else -390.0
			vertical_velocity += 980.0 * delta
			global_position.y += vertical_velocity * delta
			if global_position.y >= ground_y:
				global_position.y = ground_y
				vertical_velocity = 0.0
	elif state == "recover":
		global_position.x = move_toward(global_position.x, target_x - motion_facing * 150.0, 90.0 * delta)
		global_position.y = move_toward(global_position.y, ground_y, 260.0 * delta)
	elif state == "stagger":
		global_position.x += knockback_velocity * delta
		knockback_velocity = move_toward(knockback_velocity, 0.0, 900.0 * delta)
	global_position.x = clamp(global_position.x, 150.0, ROOM_RIGHT)
	queue_redraw()


func _refresh_color() -> void:
	var rig := get_node_or_null("Visual")
	if rig == null:
		return
	rig.body_color = {"telegraph": Color("#f0bd3f"), "commit": Color("#e74c55"), "recover": Color("#6ad1a0"), "stagger": Color("#ffffff")}.get(state, Color("#c94c59"))
	rig.queue_redraw()


func _draw() -> void:
	if state == "telegraph":
		var tell_color := Color(1.0, 0.75, 0.25, 0.75)
		if intent in ["sweep", "delayed_sweep"]:
			draw_arc(Vector2(0.0, -14.0), 112.0, -1.4, 1.4, 24, tell_color, 6.0)
		elif intent in ["leap", "slam"]:
			draw_arc(Vector2(0.0, -70.0), 44.0, 0.0, TAU, 24, tell_color, 5.0)
			if intent == "slam":
				draw_line(Vector2(-58.0, 0.0), Vector2(58.0, 0.0), tell_color, 6.0)
		elif intent == "ground_wave":
			draw_line(Vector2(0.0, 0.0), Vector2(motion_facing * 220.0, 0.0), tell_color, 8.0)
		else:
			draw_line(Vector2(0.0, -14.0), Vector2(motion_facing * 70.0, -14.0), tell_color, 6.0)
	elif state == "commit":
		var reach: float = float({"lunge": 125.0, "sweep": 105.0, "delayed_sweep": 115.0, "leap": 120.0, "slam": 135.0, "heavy_swing": 120.0, "strike": 65.0, "feint": 50.0}.get(intent, 65.0))
		if intent == "ground_wave":
			draw_line(Vector2(0.0, 2.0), Vector2(motion_facing * 260.0, 2.0), Color("#ff7b72"), 12.0)
		elif intent in ["sweep", "delayed_sweep"]:
			draw_arc(Vector2(0.0, -14.0), reach, -1.4, 1.4, 24, Color("#ff7b72"), 8.0)
		elif intent in ["leap", "slam"]:
			draw_arc(Vector2(motion_facing * 55.0, -60.0), reach * 0.55, 0.0, PI, 18, Color("#ff7b72"), 8.0)
		else:
			draw_line(Vector2(0.0, -14.0), Vector2(motion_facing * reach, -20.0), Color("#ff7b72"), 8.0)


func get_facing() -> float:
	return motion_facing
