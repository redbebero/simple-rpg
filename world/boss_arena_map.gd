class_name BossArenaMap
extends Node2D

var context: WorldContext

func setup_world(world: WorldContext) -> void:
	context = world
	queue_redraw()

func _process(_delta: float) -> void:
	if context == null: return
	var player := context.get_parent().get_node_or_null("Player")
	if player != null and player.position.x < 40.0:
		context.router.change_map("forest", Vector2(900.0, 430.0))
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-400, 0, 2200, 640), Color("#090d1b"), true)
	draw_colored_polygon(PackedVector2Array([Vector2(-400, 280), Vector2(150, 110), Vector2(500, 250), Vector2(850, 90), Vector2(1400, 280), Vector2(1400, 640), Vector2(-400, 640)]), Color("#17152e"))
	draw_rect(Rect2(80, 170, 920, 360), Color("#2b1f32"), true)
	draw_rect(Rect2(80, 500, 920, 30), Color("#6b4b52"), true)
	draw_line(Vector2(80, 500), Vector2(1000, 500), Color("#e07b68"), 4.0)
	draw_line(Vector2(80, 170), Vector2(80, 500), Color("#a85661"), 6.0)
	draw_line(Vector2(1000, 170), Vector2(1000, 500), Color("#a85661"), 6.0)
	for x in [180, 900]:
		draw_rect(Rect2(x - 18, 220, 36, 280), Color("#453451"), true)
		draw_rect(Rect2(x - 26, 205, 52, 18), Color("#a15b69"), true)
	draw_arc(Vector2(540, 455), 170.0, PI, TAU, 48, Color("#d26f9b"), 3.0)
	draw_arc(Vector2(540, 455), 125.0, PI, TAU, 48, Color("#8f6bc4"), 2.0)
	for point in [Vector2(370, 455), Vector2(540, 285), Vector2(710, 455)]:
		draw_colored_polygon(PackedVector2Array([point + Vector2(0, -12), point + Vector2(12, 0), point + Vector2(0, 12), point + Vector2(-12, 0)]), Color("#e3a1c2"))
	draw_string(ThemeDB.fallback_font, Vector2(32, 110), "BOSS ARENA · COMBAT ROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ffb08a"))
	draw_string(ThemeDB.fallback_font, Vector2(100, 570), "← FOREST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#b7d98d"))
