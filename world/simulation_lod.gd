class_name SimulationLOD
extends RefCounted

@export var near_interval := 0.25
@export var distant_interval := 2.0
var elapsed := 0.0

func tick(delta: float) -> bool:
	elapsed += delta
	if elapsed < near_interval: return false
	elapsed = 0.0
	return true
