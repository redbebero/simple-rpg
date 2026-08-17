class_name UtilityAI
extends RefCounted

static func choose(context: Dictionary) -> String:
	var scores := {
		"Idle": 0.1,
		"Wander": 0.2,
		"Feed": float(context.get("hunger", 0.0)),
		"Flee": float(context.get("danger", 0.0)) * float(context.get("fear", 1.0)),
		"Hunt": float(context.get("prey", 0.0)) * float(context.get("aggression", 1.0)),
		"SeekShelter": float(context.get("rain", 0.0)) + float(context.get("night", 0.0)) * float(context.get("shelter", 1.0)),
		"AvoidLight": float(context.get("light", 0.0)) * float(context.get("light_aversion", 0.0)),
		"Investigate": float(context.get("heard", 0.0))
	}
	var best := "Idle"
	for action in scores:
		if scores[action] > scores[best]: best = action
	return best
