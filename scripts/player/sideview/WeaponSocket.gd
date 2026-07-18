class_name WeaponSocket
extends Node2D

# Each Vector3 is socket x, socket y, and sword rotation in degrees for one body frame.
const POSES := {
	&"idle": [Vector3(38, -168, -145), Vector3(39, -170, -143), Vector3(40, -168, -145), Vector3(38, -166, -147)],
	&"run": [Vector3(48, -164, -145), Vector3(52, -170, -140), Vector3(58, -168, -138), Vector3(52, -162, -145), Vector3(46, -160, -150), Vector3(46, -164, -147)],
	&"normal": [Vector3(38, -168, -145), Vector3(-22, -210, -70), Vector3(-12, -215, -20), Vector3(190, -225, 90), Vector3(174, -218, 135), Vector3(38, -168, -145)],
	&"heavy": [Vector3(38, -168, -145), Vector3(-34, -220, -52), Vector3(-26, -296, 0), Vector3(56, -162, 82), Vector3(24, -116, 154), Vector3(166, -205, 132), Vector3(38, -168, -145)],
	&"parry": [Vector3(38, -168, -145), Vector3(16, -258, 24), Vector3(28, -224, 46), Vector3(108, -208, 72), Vector3(18, -255, 26)],
	&"skill": [Vector3(38, -168, -145), Vector3(-30, -210, -82), Vector3(-10, -220, -30), Vector3(178, -228, 90), Vector3(170, -214, 136), Vector3(32, -104, 178), Vector3(46, -170, -145), Vector3(38, -168, -145)],
	&"hurt": [Vector3(38, -168, -145), Vector3(22, -150, -130), Vector3(38, -168, -145)],
	&"death": [Vector3(38, -168, -145), Vector3(16, -132, -124), Vector3(-18, -92, -100), Vector3(-56, -42, -74), Vector3(-72, -28, -62), Vector3(-80, -20, -58)],
}


func apply_pose(animation: StringName, frame: int) -> void:
	var poses: Array = POSES.get(animation, POSES[&"idle"])
	var pose: Vector3 = poses[mini(frame, poses.size() - 1)]
	position = Vector2(pose.x, pose.y)
	rotation = deg_to_rad(pose.z)
	z_index = 0 if animation in [&"idle", &"run"] else 3
	visible = animation != &"death" or frame < 3
