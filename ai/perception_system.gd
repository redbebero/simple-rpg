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
