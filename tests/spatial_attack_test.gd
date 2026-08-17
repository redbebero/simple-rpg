extends SceneTree

const AttackData = preload("res://scripts/attack_data.gd")
const CombatQuery = preload("res://scripts/combat_query.gd")


func _init() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var attacker := CharacterBody2D.new()
	attacker.position = Vector2(100.0, 100.0)
	arena.add_child(attacker)
	_add_shape(attacker, Vector2(16.0, 16.0))
	var target := CharacterBody2D.new()
	target.position = Vector2(150.0, 100.0)
	arena.add_child(target)
	_add_shape(target, Vector2(16.0, 16.0))
	var far_target := CharacterBody2D.new()
	far_target.position = Vector2(400.0, 100.0)
	arena.add_child(far_target)
	_add_shape(far_target, Vector2(16.0, 16.0))
	await process_frame

	var attack := AttackData.new()
	attack.reach = 90.0
	attack.thickness = 32.0
	var hits: Array[Node2D] = CombatQuery.find_hits(attacker, attack, 1.0)
	assert(target in hits)
	assert(attacker not in hits)
	assert(far_target not in hits)
	print("spatial_attack_test: passed")
	quit()


func _add_shape(body: CollisionObject2D, size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
