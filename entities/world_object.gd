class_name WorldObject
extends Node2D

@export var tags: Array[String] = []
var burning := false
var intensity := 0.0
var tag_component: TagComponent
var reaction_component: ReactionComponent

func setup(definition: ObjectDefinition, fallback_tags: Array[String]) -> void:
	tags = definition.tags if definition != null else fallback_tags

func _ready() -> void:
	tag_component = TagComponent.new()
	tag_component.tags = tags
	add_child(tag_component)
	reaction_component = ReactionComponent.new()
	add_child(reaction_component)

func has_tag(tag: String) -> bool: return tag in tags

func burn() -> void:
	if not burning:
		burning = true
		intensity = 1.0

func _process(delta: float) -> void:
	if burning: intensity = maxf(0.0, intensity - delta * 0.03)
	if reaction_component != null: reaction_component.tick(delta)
	queue_redraw()

func _draw() -> void:
	if has_tag("PLANT"):
		draw_line(Vector2.ZERO, Vector2(0, -28), Color("#64b678") if not burning else Color("#d16a3d"), 5)
		draw_circle(Vector2(0, -28), 11, Color("#86d27d") if not burning else Color("#ff9a46"))
	if has_tag("FIRE"):
		draw_circle(Vector2.ZERO, 18 + intensity * 7, Color(1, 0.35, 0.08, 0.18))
		draw_circle(Vector2.ZERO, 7 + intensity * 4, Color("#ffcf62"))
