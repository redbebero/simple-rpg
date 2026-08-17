class_name UtilityAction
extends Resource

@export var id := "Idle"
@export var base_score := 0.0
@export var weight_key := ""

func score(context: Dictionary) -> float:
	return base_score + float(context.get(weight_key, 0.0))
