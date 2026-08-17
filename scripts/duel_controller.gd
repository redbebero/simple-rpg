extends Node2D

const DuelRules = preload("res://scripts/duel_rules.gd")
const CombatQuery = preload("res://scripts/combat_query.gd")
const AttackData = preload("res://scripts/attack_data.gd")

@onready var player = $Player
@onready var enemy = $Enemy
@onready var status: Label = $HUD/Status

var phase := "telegraph"
var timer := 0.0
var exchange := 0
var message := ""
var parry_streak := 0
var step_streak := 0
var attack_streak := 0
var route_choice := false
var impact_time := 0.0
var impact_position := Vector2.ZERO
var parry_armed := false
var commit_shown := false
var player_attack_resolved := false
var enemy_attack_contact := false
var enemy_attack_resolved := false
var ambient_time := 0.0

const COMMIT_LEAD := 0.12
const RECOVERY_GAP := 0.78


func _ready() -> void:
	_create_torch_lights()
	_begin_telegraph()
	queue_redraw()


func _process(delta: float) -> void:
	ambient_time += delta
	impact_time = maxf(0.0, impact_time - delta)
	if player.hp <= 0:
		status.text = "YOU FALL\nPress F5 to try again"
		return
	if route_choice:
		status.text = "VICTORY\n1 Safe camp (+health)   2 Unknown path (+danger)"
		if Input.is_action_just_pressed("route_safe"):
			_choose_route(true)
		elif Input.is_action_just_pressed("route_unknown"):
			_choose_route(false)
		return
	if enemy.hp <= 0:
		route_choice = true
		return
	timer -= delta
	enemy.advance_motion(player.global_position.x, delta)
	if phase == "telegraph" and enemy.state == "commit" and not enemy_attack_resolved:
		if enemy.get_attack_data().phase_at(enemy.motion_time) == "active":
			_resolve_enemy_attack_spatial()
	if phase == "telegraph":
		if player.action_can_hit() and not player_attack_resolved:
			player_attack_resolved = true
			_resolve_player_attack()
			player.clear_action()
			status.text = "%s\nEnemy %d   You %d\nA/D move   J strike   K step   L parry   Space jump" % [message, enemy.hp, player.hp]
			queue_redraw()
			return
		if player.action == "parry" and timer > COMMIT_LEAD:
			parry_armed = true
		if timer <= COMMIT_LEAD and not commit_shown:
			enemy.set_state("commit")
			message = "%s!" % enemy.intent.to_upper()
			commit_shown = true
	if phase == "recover" and player.action_can_hit():
		var player_attack: AttackData = player.get_attack_data()
		var hits := CombatQuery.find_hits(player, player_attack, player.facing)
		if DuelRules.is_weak_point(enemy.state) and enemy in hits:
			enemy.take_hit(player_attack.damage, player_attack.knockback)
			enemy.set_state("stagger")
			message = "WEAK POINT HIT"
			_show_impact(enemy.global_position, 0.18)
		else:
			message = "NO OPENING — parry first" if not DuelRules.is_weak_point(enemy.state) else "MISS — close the distance"
		player.clear_action()
		timer = RECOVERY_GAP
		phase = "stagger"
	elif timer <= 0.0:
		if phase == "telegraph":
			_resolve_response()
		elif phase == "recover" or phase == "stagger":
			_begin_telegraph()
	status.text = "%s\nEnemy %d   You %d\nA/D move   J strike   K step   L parry   Space jump" % [message, enemy.hp, player.hp]
	queue_redraw()


func _begin_telegraph() -> void:
	phase = "telegraph"
	parry_armed = false
	commit_shown = false
	player_attack_resolved = false
	enemy_attack_contact = false
	enemy_attack_resolved = false
	var distance := absf(enemy.global_position.x - player.global_position.x)
	enemy.set_intent(DuelRules.enemy_intent(distance, player.action, exchange, parry_streak, step_streak, attack_streak))
	timer = DuelRules.telegraph_time(enemy.intent)
	message = "%s" % enemy.intent.to_upper()
	exchange += 1


func _resolve_response() -> void:
	if not enemy_attack_resolved:
		_resolve_enemy_attack_spatial()
	var chosen_action: String = player.action
	_record_action(chosen_action)
	var result := DuelRules.resolve(chosen_action, enemy.intent)
	if chosen_action == "parry" and not parry_armed:
		result = "hit"
		message = "PARRY AFTER COMMIT"
	if chosen_action in ["evade", "jump"] and not player.action_can_evade():
		result = "hit"
		message = "TOO EARLY"
	player.clear_action()
	if chosen_action == "attack":
		_resolve_player_attack()
		return
	if result == "parry" or result == "evade":
		enemy.set_state("stagger")
		phase = "recover"
		timer = 0.65
		message = "OPENING — J STRIKE"
		return
	if result == "hit":
		if enemy_attack_contact and player.can_be_hit(enemy.intent):
			var enemy_attack: AttackData = enemy.get_attack_data()
			player.take_hit(enemy_attack.damage)
			message = message if message in ["PARRY LATE", "TOO EARLY"] else "HIT — read the next tell"
			_show_impact(player.global_position, 0.14)
		else:
			message = "MISS — you were out of range"
	else:
		message = result.to_upper()
	enemy.set_state("recover")
	phase = "recover"
	timer = RECOVERY_GAP


func _resolve_player_attack() -> void:
	var hits := CombatQuery.find_hits(player, player.get_attack_data(), player.facing)
	if enemy in hits:
		var attack: AttackData = player.get_attack_data()
		enemy.take_hit(attack.damage, attack.knockback)
		enemy.set_state("stagger")
		message = "STRIKE"
		_show_impact(enemy.global_position, 0.18)
	else:
		message = "MISS — move into sword range"
	enemy.set_state("recover")
	phase = "recover"
	timer = RECOVERY_GAP


func _resolve_enemy_attack_spatial() -> void:
	enemy_attack_resolved = true
	var hits := CombatQuery.find_hits(enemy, enemy.get_attack_data(), enemy.get_facing())
	enemy_attack_contact = player in hits


func _record_action(chosen_action: String) -> void:
	parry_streak = parry_streak + 1 if chosen_action == "parry" else 0
	step_streak = step_streak + 1 if chosen_action in ["evade", "jump"] else 0
	attack_streak = attack_streak + 1 if chosen_action == "attack" else 0


func _show_impact(at: Vector2, duration: float) -> void:
	impact_position = at
	impact_time = duration


func _create_torch_lights() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(1.0, 0.62, 0.18, 0.85), Color(1.0, 0.32, 0.05, 0.0)])
	var glow := GradientTexture2D.new()
	glow.gradient = gradient
	glow.width = 128
	glow.height = 128
	glow.fill_from = Vector2(0.5, 0.5)
	glow.fill_to = Vector2(1.0, 0.5)
	for x in range(120, 3200, 240):
		var light := PointLight2D.new()
		light.position = Vector2(x, 170.0)
		light.texture = glow
		light.energy = 1.35
		light.texture_scale = 2.8
		light.color = Color("#ffc36b")
		add_child(light)


func _choose_route(safe_route: bool) -> void:
	route_choice = false
	player.hp = 3 if safe_route else player.hp
	player.hurt_time = 0.0
	enemy.reset(DuelRules.route_enemy_hp(safe_route))
	player.position = Vector2(300.0, 430.0)
	player.clear_action()
	parry_streak = 0
	step_streak = 0
	attack_streak = 0
	exchange = 0 if safe_route else 1
	_begin_telegraph()
	message = "SAFE CAMP" if safe_route else "UNKNOWN PATH"


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 3200.0, 1000.0), Color("#111827"), true)
	draw_rect(Rect2(0.0, 250.0, 3200.0, 180.0), Color("#182235"), true)
	for x in range(120, 3200, 240):
		var pulse := 0.82 + 0.18 * sin(ambient_time * 2.0 + float(x) * 0.03)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 20.0, 180.0), Vector2(x + 20.0, 180.0),
			Vector2(x + 110.0, 430.0), Vector2(x - 110.0, 430.0)
		]), Color(1.0, 0.62, 0.25, 0.035 * pulse))
		draw_line(Vector2(x, 30), Vector2(x, 430), Color(0.15, 0.19, 0.27, 0.5), 2.0)
		draw_rect(Rect2(x - 26.0, 350.0, 52.0, 80.0), Color("#27344a"), true)
		draw_rect(Rect2(x - 32.0, 344.0, 64.0, 8.0), Color("#3b4b65"), true)
		draw_circle(Vector2(x, 170.0), 10.0 * pulse, Color("#ffd27a"))
		draw_circle(Vector2(x, 170.0), 22.0 * pulse, Color(0.84, 0.61, 0.27, 0.12))
	draw_line(Vector2(0.0, 405.0), Vector2(3200.0, 405.0), Color("#24324a"), 3.0)
	draw_rect(Rect2(0.0, 430.0, 3200.0, 4.0), Color("#354258"), true)
	for x in range(0, 3200, 160):
		draw_line(Vector2(x, 438.0), Vector2(x + 80.0, 438.0), Color("#4a5a73"), 2.0)
	if player.action == "attack":
		var player_attack: AttackData = player.get_attack_data()
		draw_line(player.position + Vector2(0.0, player_attack.vertical_offset), player.position + Vector2(player.facing * player_attack.reach, player_attack.vertical_offset), Color("#ffd166"), 5.0)
	if phase == "telegraph":
		var toward_player := signf(player.position.x - enemy.position.x)
		var range_color := Color("#f0bd3f") if enemy.state == "telegraph" else Color("#f06b63")
		var enemy_attack: AttackData = enemy.get_attack_data()
		draw_line(enemy.position + Vector2(0.0, enemy_attack.vertical_offset), enemy.position + Vector2(toward_player * enemy_attack.reach, enemy_attack.vertical_offset), range_color, 4.0)
	if impact_time > 0.0:
		var strength := clampf(impact_time / 0.18, 0.0, 1.0)
		draw_circle(impact_position, 34.0 + (1.0 - strength) * 34.0, Color(1.0, 0.82, 0.3, strength * 0.35))
		for angle in range(0, 360, 45):
			var direction := Vector2.from_angle(deg_to_rad(float(angle)))
			draw_line(impact_position + direction * 20.0, impact_position + direction * (45.0 + (1.0 - strength) * 25.0), Color(1.0, 0.92, 0.58, strength), 4.0)
