class_name ReactionComponent
extends Node

var burning := 0.0
var frightened := 0.0

func tick(delta: float) -> void:
	burning = maxf(0.0, burning - delta * 0.08)
	frightened = maxf(0.0, frightened - delta * 0.5)
