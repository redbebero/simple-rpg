class_name CombatQuery
extends RefCounted


static func find_hits(attacker: CollisionObject2D, attack: AttackData, facing: float) -> Array[Node2D]:
	var hits: Array[Node2D] = []
	if attacker == null or attack == null or attacker.get_world_2d() == null:
		return hits
	attacker.force_update_transform()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(attack.reach, attack.thickness)
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, attacker.global_position + Vector2(facing * attack.reach * 0.5, attack.vertical_offset))
	params.collision_mask = attack.collision_mask
	params.exclude = [attacker.get_rid()]
	for result in attacker.get_world_2d().direct_space_state.intersect_shape(params, 32):
		var body := result.get("collider") as Node2D
		if body != null and body not in hits:
			hits.append(body)
	return hits
