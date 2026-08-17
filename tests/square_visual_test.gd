extends SceneTree

const ProceduralRig = preload("res://scripts/procedural_rig_2d.gd")


func _init() -> void:
	for style in ["knight", "enemy"]:
		var rig := ProceduralRig.new()
		rig.set_style(style)
		rig.update_pose(Vector2.ZERO, -1.0, true, "heavy_strike", 0.1, "active")
		assert(rig.get_visual_shape() == Rect2(-12.0, -24.0, 24.0, 24.0))
		assert(rig.get_visual_motion_state() == "static")
		rig.free()
	print("square_visual_test: passed")
	quit()
