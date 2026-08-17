class_name DuelRules
extends RefCounted


static func enemy_intent(distance: float, player_action: String, exchange: int, parry_streak := 0, step_streak := 0, attack_streak := 0) -> String:
	if distance > 260.0:
		if exchange > 0 and exchange % 5 == 0:
			return "slam"
		if exchange > 0 and exchange % 4 == 0:
			return "leap"
		if exchange > 0 and exchange % 3 == 0:
			return "ground_wave"
		return "lunge"
	if parry_streak >= 2:
		return "feint"
	if step_streak >= 2:
		return "delayed_sweep"
	if player_action == "evade":
		return "sweep"
	if attack_streak >= 2:
		return "heavy_swing" if exchange % 3 == 0 else "strike"
	if distance >= 150.0 and exchange % 5 == 0:
		return "slam"
	if distance >= 150.0 and exchange % 4 == 0:
		return "leap"
	if distance < 105.0:
		return "sweep" if exchange % 3 == 0 else "strike"
	return "strike" if exchange % 2 == 0 else "lunge"


static func resolve(player_action: String, enemy_intent: String) -> String:
	if player_action == "parry" and enemy_intent in ["strike", "lunge", "sweep", "delayed_sweep", "leap", "slam", "heavy_swing", "ground_wave"]:
		return "parry"
	if player_action == "evade" and enemy_intent in ["lunge", "sweep", "delayed_sweep", "leap", "slam", "heavy_swing", "ground_wave"]:
		return "evade"
	if player_action == "jump" and enemy_intent in ["sweep", "delayed_sweep", "leap", "slam", "heavy_swing", "ground_wave"]:
		return "evade"
	if player_action == "attack" and enemy_intent == "recover":
		return "punish"
	if player_action == "attack":
		return "attack"
	return "hit"


static func attack_hits(distance: float, attacker_facing: float, target_direction: float, reach := 110.0) -> bool:
	return distance <= reach and attacker_facing * target_direction > 0.0


static func enemy_reach(intent: String) -> float:
	return {"ground_wave": 320.0, "lunge": 210.0, "sweep": 145.0, "delayed_sweep": 145.0, "leap": 170.0, "slam": 185.0, "heavy_swing": 155.0, "strike": 105.0, "feint": 105.0}.get(intent, 105.0)


static func telegraph_time(intent: String) -> float:
	return {"ground_wave": 0.88, "slam": 0.90, "leap": 0.78, "lunge": 0.68, "sweep": 0.68, "delayed_sweep": 0.82, "heavy_swing": 0.78, "strike": 0.58, "feint": 0.58}.get(intent, 0.58)


static func is_weak_point(state: String) -> bool:
	return state == "stagger"


static func route_enemy_hp(safe_route: bool) -> int:
	return 3 if safe_route else 4
