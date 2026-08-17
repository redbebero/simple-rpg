class_name InteractionResolver
extends RefCounted

var rules: Array[InteractionRule] = []

func _init() -> void:
	for pair in [["FIRE", "FLAMMABLE", "BURN"], ["WATER", "FIRE", "WEAKEN_FIRE"], ["LIGHT", "SHADOW_SENSITIVE", "FLEE_LIGHT"], ["RAIN", "FIRE", "WEAKEN_FIRE"], ["COLD", "HEAT_SENSITIVE", "SEEK_SHELTER"], ["MAGIC", "MAGIC_CONDUCTOR", "AMPLIFY"]]:
		var rule := InteractionRule.new()
		rule.source_tag = pair[0]
		rule.target_tag = pair[1]
		rule.effect = pair[2]
		rules.append(rule)

func resolve(source: Array, target: Array, intensity := 1.0) -> Array:
	var effects: Array = []
	for rule in rules:
		if rule.source_tag in source and rule.target_tag in target:
			effects.append(rule.effect)
	return effects
