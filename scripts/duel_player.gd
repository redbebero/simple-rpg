extends CharacterBody2D

const ROOM_RIGHT := 3100.0
const AttackData = preload("res://scripts/attack_data.gd")

const ACTION_TIMES := {
	"attack": Vector3(0.08, 0.09, 0.16),
	"parry": Vector3(0.04, 0.14, 0.12),
	"jump": Vector3(0.0, 0.04, 0.20),
	"evade": Vector3(0.0, 0.16, 0.10),
}

var hp := 3
var action := ""
var action_phase := "ready"
var action_time := 0.0
var facing := 1.0
var hurt_time := 0.0
var step_time := 0.0
var jump_height := 0.0
var jump_velocity := 0.0
var jump_cut_applied := false
var ground_y := 0.0
var pending_action := ""
var action_buffer_time := 0.0
var coyote_time := 0.0
var attack_data: AttackData
var world_tags: TagComponent
var world_health: HealthComponent
var world_movement: MovementComponent
var world_perception: PerceptionComponent
var world_reaction: ReactionComponent
var world_needs: NeedsComponent
var world_memory: MemoryComponent

const ACTION_BUFFER_WINDOW := 0.12
const COYOTE_WINDOW := 0.10


func _ready() -> void:
	ground_y = position.y
	attack_data = AttackData.new()
	attack_data.id = "slash"
	attack_data.visual_kind = "slash"
	world_tags = TagComponent.new()
	world_tags.tags = ["PLAYER", "ORGANIC", "SOLID"]
	add_child(world_tags)
	world_health = HealthComponent.new()
	world_health.maximum = 3.0
	add_child(world_health)
	world_movement = MovementComponent.new()
	add_child(world_movement)
	world_perception = PerceptionComponent.new()
	add_child(world_perception)
	world_reaction = ReactionComponent.new()
	add_child(world_reaction)
	world_needs = NeedsComponent.new()
	add_child(world_needs)
	world_memory = MemoryComponent.new()
	add_child(world_memory)


func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	var movement_scale := 1.0
	if action_phase == "active" and action == "attack":
		movement_scale = 0.45
	elif action_phase == "recovery":
		movement_scale = 0.75
	velocity.x = move_toward(velocity.x, axis * 260.0 * movement_scale, 1800.0 * delta)
	if axis != 0.0:
		facing = sign(axis)
	step_time = maxf(0.0, step_time - delta)
	advance_action(delta)
	if step_time > 0.0:
		velocity.x = facing * 520.0
	if jump_height > 0.0 or jump_velocity > 0.0:
		coyote_time = 0.0
		if jump_velocity > 0.0 and not Input.is_action_pressed("jump"):
			cut_jump()
		jump_velocity -= 900.0 * delta
		jump_height = maxf(0.0, jump_height + jump_velocity * delta)
		position.y = ground_y - jump_height
		if jump_height == 0.0:
			jump_velocity = 0.0
	else:
		coyote_time = minf(COYOTE_WINDOW, coyote_time + delta)
	move_and_slide()
	global_position.x = clamp(global_position.x, 180.0, ROOM_RIGHT)
	hurt_time = maxf(0.0, hurt_time - delta)
	_consume_buffered_action(delta)
	if Input.is_action_just_pressed("action"):
		queue_action("attack")
	elif Input.is_action_just_pressed("evade"):
		queue_action("evade")
	elif Input.is_action_just_pressed("parry"):
		queue_action("parry")
	elif Input.is_action_just_pressed("jump"):
		queue_action("jump")
	_update_visual()


func queue_action(kind: String) -> bool:
	if not ACTION_TIMES.has(kind):
		return false
	if action != "" and action_phase != "ready":
		return begin_action(kind)
	pending_action = kind
	action_buffer_time = ACTION_BUFFER_WINDOW
	return true


func _consume_buffered_action(delta: float) -> void:
	if pending_action == "":
		return
	action_buffer_time -= delta
	if action_buffer_time <= 0.0:
		pending_action = ""
		return
	if action != "" and action_phase != "ready":
		return
	if pending_action == "jump" and jump_height > 0.0:
		return
	var next_action := pending_action
	if begin_action(next_action):
		pending_action = ""
		action_buffer_time = 0.0


func begin_action(kind: String) -> bool:
	if kind == "jump" and jump_height > 0.0:
		return false
	if not ACTION_TIMES.has(kind):
		return false
	action = ""
	action_phase = "ready"
	action_time = 0.0
	step_time = 0.0
	action = kind
	action_phase = "active" if kind == "evade" else "anticipation"
	action_time = 0.0
	if kind == "evade":
		step_time = 0.16
	if kind == "jump":
		jump_velocity = 360.0
		jump_cut_applied = false
	return true


func cut_jump() -> void:
	if jump_velocity > 0.0 and not jump_cut_applied:
		jump_velocity *= 0.5
		jump_cut_applied = true


func advance_action(delta: float) -> void:
	if action == "" or action_phase == "ready":
		return
	action_time += delta
	var times: Vector3 = ACTION_TIMES[action]
	if action_phase == "anticipation" and action_time >= times.x:
		action_phase = "active"
		action_time = 0.0
	elif action_phase == "active" and action_time >= times.y:
		action_phase = "recovery"
		action_time = 0.0
	elif action_phase == "recovery" and action_time >= times.z:
		action_phase = "ready"
	action_time = minf(action_time, 0.25)


func action_can_hit() -> bool:
	return action == "attack" and action_phase == "active"


func action_can_parry() -> bool:
	return action == "parry"


func action_can_evade() -> bool:
	return (action == "evade" and step_time > 0.0) or (action == "jump" and jump_height > 0.0)


func action_progress() -> float:
	if action == "" or not ACTION_TIMES.has(action):
		return 0.0
	var times: Vector3 = ACTION_TIMES[action]
	var duration := times.x if action_phase == "anticipation" else times.y if action_phase == "active" else times.z
	return clampf(action_time / maxf(duration, 0.001), 0.0, 1.0)


func take_hit(damage: int = 1) -> void:
	hp -= damage
	hurt_time = 0.18


func clear_action() -> void:
	action = ""
	action_phase = "ready"
	action_time = 0.0
	step_time = 0.0
	pending_action = ""
	action_buffer_time = 0.0


func get_attack_data() -> AttackData:
	return attack_data


func get_facing() -> float:
	return facing


func can_be_hit(enemy_intent: String) -> bool:
	return hurt_time <= 0.0 and step_time <= 0.0 and not (action == "parry" and action_phase == "active")


func _update_visual() -> void:
	var rig := get_node_or_null("Visual")
	if rig:
		var color := Color("#f4f1de")
		if action == "parry":
			color = Color("#71c7ff") if action_phase == "active" else Color("#4d7798")
		elif action == "attack":
			color = Color("#ffd166") if action_phase == "active" else Color("#e5ad49")
		elif step_time > 0.0:
			color = Color("#b6f2d0")
		elif jump_height > 0.0:
			color = Color("#d7b8ff")
		if hurt_time > 0.0:
			color = Color("#ff5364")
		rig.body_color = color
		rig.queue_redraw()
	queue_redraw()


func _draw() -> void:
	if jump_height > 0.0:
		draw_line(Vector2(-14.0, 2.0), Vector2(14.0, 2.0), Color(0.05, 0.06, 0.1, 0.45), 4.0)
	if action == "attack":
		var progress := action_progress()
		var reach := 26.0 + 84.0 * progress
		var blade_color := Color("#fff1a8") if action_phase == "active" else Color("#c9913d")
		draw_line(Vector2(8.0 * facing, -14.0), Vector2(facing * reach, -18.0), blade_color, 6.0)
		if action_phase == "active":
			draw_circle(Vector2(facing * reach, -18.0), 5.0, Color("#ffffff"))
	if action == "parry":
		draw_arc(Vector2(8.0 * facing, -14.0), 22.0, -1.2 if facing > 0.0 else 1.9, 1.2 if facing > 0.0 else 4.3, 18, Color("#9edcff"), 5.0)
