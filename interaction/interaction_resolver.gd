class_name InteractionResolver
extends RefCounted

var rules: Array[InteractionRule] = []

func _init() -> void:
	for path in ["res://data/interactions/fire_burn.tres", "res://data/interactions/water_fire.tres", "res://data/interactions/light_shadow.tres", "res://data/interactions/rain_fire.tres", "res://data/interactions/cold_heat.tres", "res://data/interactions/magic_conductor.tres"]:
		var rule := load(path) as InteractionRule
		if rule != null: rules.append(rule)

func resolve(source: Array, target: Array, intensity := 1.0) -> Array:
	var effects: Array = []
	for rule in rules:
		if rule.source_tag in source and rule.target_tag in target:
			effects.append(rule.effect)
	return effects
