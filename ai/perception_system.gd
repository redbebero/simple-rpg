class_name PerceptionSystem
extends RefCounted

var observers: Array[Node] = []

func register(observer: Node) -> void:
	if observer not in observers: observers.append(observer)

func emit_sound(events: WorldEvents, position: Vector2, intensity: float, kind: String) -> void:
	events.sound_emitted.emit(position, intensity, kind)
	for observer in observers:
		if is_instance_valid(observer) and observer.has_method("receive_sound"):
			observer.receive_sound(position, intensity, kind)

func emit_visible(events: WorldEvents, position: Vector2, intensity: float, kind: String) -> void:
	events.entity_spotted.emit(null, position, kind)
	for observer in observers:
		if is_instance_valid(observer) and observer.has_method("receive_visible"):
			observer.receive_visible(position, intensity, kind)

func observe(creatures: Array) -> void:
	for observer in creatures:
		if not is_instance_valid(observer): continue
		for target in creatures:
			if observer == target or not is_instance_valid(target): continue
			if observer.global_position.distance_to(target.global_position) <= 220.0 and observer.has_method("receive_visible"):
				observer.receive_visible(target.global_position, 1.0, str(target.creature_kind))
