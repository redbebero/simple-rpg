class_name AttackData
extends Resource

@export var id := "slash"
@export var startup := 0.08
@export var active := 0.09
@export var recovery := 0.16
@export var reach := 110.0
@export var thickness := 34.0
@export var vertical_offset := -14.0
@export var damage := 1
@export var knockback := 220.0
@export var visual_kind := "slash"
@export var collision_mask := 1


func phase_at(elapsed: float) -> String:
	if elapsed < startup:
		return "startup"
	if elapsed < startup + active:
		return "active"
	if elapsed < total_time():
		return "recovery"
	return "done"


func progress_at(elapsed: float) -> float:
	return clampf(elapsed / maxf(total_time(), 0.001), 0.0, 1.0)


func total_time() -> float:
	return startup + active + recovery


static func for_kind(kind: String) -> AttackData:
	var attack: AttackData = new()
	attack.id = kind
	attack.visual_kind = kind
	match kind:
		"sweep":
			attack.startup = 0.12
			attack.active = 0.12
			attack.recovery = 0.24
			attack.reach = 145.0
			attack.thickness = 48.0
			attack.vertical_offset = -12.0
			attack.knockback = 180.0
		"lunge":
			attack.startup = 0.18
			attack.active = 0.10
			attack.recovery = 0.28
			attack.reach = 185.0
			attack.thickness = 38.0
			attack.knockback = 260.0
		"ground_wave":
			attack.startup = 0.22
			attack.active = 0.12
			attack.recovery = 0.34
			attack.reach = 320.0
			attack.thickness = 24.0
			attack.vertical_offset = 8.0
			attack.knockback = 140.0
		"slam":
			attack.startup = 0.24
			attack.active = 0.16
			attack.recovery = 0.38
			attack.reach = 185.0
			attack.thickness = 64.0
			attack.vertical_offset = -24.0
			attack.knockback = 340.0
		"heavy_swing":
			attack.startup = 0.20
			attack.active = 0.14
			attack.recovery = 0.32
			attack.reach = 155.0
			attack.thickness = 54.0
			attack.knockback = 300.0
		"feint":
			attack.startup = 0.10
			attack.active = 0.08
			attack.recovery = 0.20
			attack.reach = 105.0
			attack.thickness = 30.0
			attack.damage = 0
			attack.visual_kind = "thrust"
	return attack
