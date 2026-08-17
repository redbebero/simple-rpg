class_name TagComponent
extends Node

@export var tags: Array[String] = []

func has(tag: String) -> bool:
	return tag in tags

func add(tag: String) -> void:
	if not has(tag): tags.append(tag)
