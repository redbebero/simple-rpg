class_name SceneRouter
extends Node

var context: WorldContext
var map_root: Node2D
var current_map_id := ""
var current_map: Node2D

const MAPS := {
	"village": "res://scenes/village.tscn",
	"forest": "res://scenes/forest.tscn",
	"boss_arena": "res://scenes/boss_arena.tscn",
}

func setup(world: WorldContext, root: Node2D) -> void:
	context = world
	map_root = root

func change_map(map_id: String, spawn_position := Vector2.ZERO) -> bool:
	if not MAPS.has(map_id) or map_root == null:
		return false
	if current_map != null:
		current_map.queue_free()
	current_map = load(MAPS[map_id]).instantiate()
	current_map.name = map_id.capitalize()
	if "context" in current_map:
		current_map.context = context
	map_root.add_child(current_map)
	current_map_id = map_id
	if current_map.has_method("setup_world"):
		current_map.setup_world(context)
	if spawn_position != Vector2.ZERO:
		var player := context.get_parent().get_node_or_null("Player")
		if player != null:
			player.position = spawn_position
	var duel_enemy := context.get_parent().get_node_or_null("Enemy")
	if duel_enemy != null:
		var boss_active := map_id == "boss_arena"
		duel_enemy.visible = boss_active
		duel_enemy.collision_layer = 1 if boss_active else 0
		duel_enemy.collision_mask = 1 if boss_active else 0
		if boss_active: duel_enemy.position = Vector2(760.0, 430.0)
	var combat_controller := context.get_parent()
	if combat_controller != null:
		combat_controller.set_process(map_id == "boss_arena")
		combat_controller.call_deferred("set_process", map_id == "boss_arena")
	return true

func active_map() -> Node2D:
	return current_map
