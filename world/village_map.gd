class_name VillageMap
extends Node2D

var context: WorldContext
var villager: WorldNpc

func setup_world(world: WorldContext) -> void:
	context = world
	villager = WorldNpc.new()
	villager.setup(context, "villager", ["NPC", "ORGANIC"])
	villager.position = Vector2(260.0, 430.0)
	add_child(villager)
	queue_redraw()

func _process(delta: float) -> void:
	if context == null: return
	villager.apply_world_pressure(context.state, delta)
	villager.tick(delta)
	var player := context.get_parent().get_node_or_null("Player")
	if player != null and player.position.x > 980.0:
		context.router.change_map("forest", Vector2(80.0, 430.0))
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-400, 0, 2200, 640), Color("#111b33"), true)
	draw_circle(Vector2(820, 115), 42.0, Color("#f3ddb0"))
	draw_circle(Vector2(805, 105), 42.0, Color("#111b33"))
	draw_colored_polygon(PackedVector2Array([Vector2(-400, 330), Vector2(160, 210), Vector2(420, 320), Vector2(700, 190), Vector2(1100, 320), Vector2(1800, 230), Vector2(1800, 430), Vector2(-400, 430)]), Color("#1b3150"))
	draw_rect(Rect2(-400, 285, 2200, 145), Color("#5c463d"), true)
	draw_rect(Rect2(-400, 360, 2200, 70), Color("#705244"), true)
	# Simple square village house with a warm window glow.
	draw_rect(Rect2(80, 215, 180, 145), Color("#9a624a"), true)
	draw_colored_polygon(PackedVector2Array([Vector2(58, 215), Vector2(170, 145), Vector2(282, 215)]), Color("#4c3040"))
	draw_rect(Rect2(125, 260, 42, 100), Color("#4b3030"), true)
	draw_rect(Rect2(195, 250, 34, 30), Color("#f7c96b"), true)
	draw_rect(Rect2(200, 255, 24, 20), Color("#ffe7a0"), true)
	# Road, fence, and small square lanterns define the safe route.
	draw_line(Vector2(-400, 420), Vector2(1800, 420), Color("#d7b275"), 4.0)
	for x in range(300, 780, 80):
		draw_line(Vector2(x, 375), Vector2(x, 420), Color("#b4875a"), 5.0)
		draw_line(Vector2(x + 40, 375), Vector2(x + 40, 420), Color("#b4875a"), 5.0)
		draw_line(Vector2(x, 385), Vector2(x + 40, 385), Color("#d0a16a"), 3.0)
	for x in [330, 730, 960]:
		draw_rect(Rect2(x - 5, 315, 10, 45), Color("#30243a"), true)
		draw_rect(Rect2(x - 10, 306, 20, 16), Color("#f4bc63"), true)
	draw_string(ThemeDB.fallback_font, Vector2(32, 150), "VILLAGE · SAFE AREA", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f0d39a"))
	draw_string(ThemeDB.fallback_font, Vector2(840, 400), "FOREST →", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#b7d98d"))
