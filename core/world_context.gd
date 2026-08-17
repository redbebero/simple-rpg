class_name WorldContext
extends Node2D

const WorldStateScript = preload("res://core/world_state.gd")
const WorldEventsScript = preload("res://core/world_events.gd")
const ResolverScript = preload("res://interaction/interaction_resolver.gd")
const PrototypeWorldScript = preload("res://world/prototype_world.gd")
const TimeSystemScript = preload("res://world/time_system.gd")
const WeatherSystemScript = preload("res://world/weather_system.gd")
const EcologySystemScript = preload("res://world/ecology_system.gd")
const SimulationLODScript = preload("res://world/simulation_lod.gd")

var state: WorldState
var events: WorldEvents
var resolver
var time_system: TimeSystem
var weather_system: WeatherSystem
var ecology: EcologySystem
var simulation_lod: SimulationLOD
var fixed_tick := 0.25
var tick_accumulator := 0.0
var debug_visible := false

func _ready() -> void:
	state = WorldStateScript.new()
	events = WorldEventsScript.new()
	resolver = ResolverScript.new()
	time_system = TimeSystemScript.new()
	weather_system = WeatherSystemScript.new()
	ecology = EcologySystemScript.new()
	simulation_lod = SimulationLODScript.new()
	var prototype := PrototypeWorldScript.new()
	prototype.context = self
	prototype.name = "PrototypeWorld"
	add_child(prototype)

func _process(delta: float) -> void:
	tick_accumulator += delta
	while tick_accumulator >= fixed_tick:
		tick_accumulator -= fixed_tick
		time_system.tick(state, events, fixed_tick / 2.0)
		if state.time_of_day > 18.0 and state.time_of_day < 18.0 + fixed_tick / 2.0:
			events.record("evening")
			events.time_changed.emit(state.time_of_day, state.light_level)
		if state.time_of_day < fixed_tick / 2.0:
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
	weather_system.apply(state, events, next_weather, intensity)
	events.record(next_weather)

func _draw() -> void:
	var tint := Color(0.08, 0.12, 0.18).lerp(Color(0.02, 0.03, 0.06), 1.0 - state.light_level)
	draw_rect(Rect2(0, 0, 1080, 330), tint, true)
	if debug_visible:
		var text := "WORLD  %02d:%02d  light %.2f  %s  temp %.1fC" % [int(state.time_of_day), int(fmod(state.time_of_day * 60.0, 60.0)), state.light_level, state.weather, state.temperature]
		text += "\nEVENTS  " + ", ".join(events.recent)
		var world := get_node_or_null("PrototypeWorld")
		if world != null: text += "\nDECISIONS " + world.debug_decisions()
		draw_string(ThemeDB.fallback_font, Vector2(24, 24), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d7e7ff"))
