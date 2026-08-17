class_name EcologySystem
extends RefCounted

func tick(creatures: Array, state: WorldState, delta: float) -> void:
	for creature in creatures:
		if is_instance_valid(creature) and creature.has_method("apply_world_pressure"):
			creature.apply_world_pressure(state, delta)
