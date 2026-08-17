class_name WorldContext
extends Node2D

const WorldStateScript = preload("res://core/world_state.gd")
const WorldEventsScript = preload("res://core/world_events.gd")
const ResolverScript = preload("res://interaction/interaction_resolver.gd")
const PrototypeWorldScript = preload("res://world/prototype_world.gd")

var state: WorldState
var events: WorldEvents
var resolver
var fixed_tick := 0.25
var tick_accumulator := 0.0
var debug_visible := false

func _ready() -> void:
	state = WorldStateScript.new()
	events = WorldEventsScript.new()
	resolver = ResolverScript.new()
	var prototype := PrototypeWorldScript.new()
	prototype.context = self
	prototype.name = "PrototypeWorld"
	add_child(prototype)

func _process(delta: float) -> void:
	tick_accumulator += delta
	while tick_accumulator >= fixed_tick:
		tick_accumulator -= fixed_tick
		state.advance(fixed_tick / 2.0)
		events.time_changed.emit(state.time_of_day, state.light_level)
		if state.time_of_day > 18.0 and state.time_of_day < 18.0 + fixed_tick / 12.0:
			events.record("evening")
			events.time_changed.emit(state.time_of_day, state.light_level)
		if state.time_of_day < fixed_tick / 12.0:
			events.record("daybreak")
			events.time_changed.emit(state.time_of_day, state.light_level)
	if Input.is_action_just_pressed("world_fire"):
		var world := get_node_or_null("PrototypeWorld")
		if world != null:
			world.try_create_fire()
	if Input.is_action_just_pressed("debug_toggle"):
		debug_visible = not debug_visible
	queue_redraw()

func set_weather(next_weather: String, intensity: float) -> void:
	state.set_weather(next_weather, intensity)
	events.record(next_weather)
	events.weather_changed.emit(next_weather, intensity)

func _draw() -> void:
	var tint := Color(0.08, 0.12, 0.18).lerp(Color(0.02, 0.03, 0.06), 1.0 - state.light_level)
	draw_rect(Rect2(0, 0, 1080, 330), tint, true)
	if debug_visible:
		var text := "WORLD  %02d:%02d  light %.2f  %s  temp %.1fC" % [int(state.time_of_day), int(fmod(state.time_of_day * 60.0, 60.0)), state.light_level, state.weather, state.temperature]
		text += "\nEVENTS  " + ", ".join(events.recent)
		draw_string(ThemeDB.fallback_font, Vector2(24, 24), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d7e7ff"))
