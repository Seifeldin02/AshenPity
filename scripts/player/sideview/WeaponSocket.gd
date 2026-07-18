class_name WeaponSocket
extends Node2D

# Each Vector4 is grip x, grip y, sword angle, and draw depth for one body frame.
const POSES := {
	&"idle": [Vector4(38, -168, -145, 0), Vector4(39, -170, -143, 0), Vector4(40, -168, -145, 0), Vector4(38, -166, -147, 0)],
	&"run": [Vector4(46, -166, -148, 0), Vector4(48, -160, -144, 0), Vector4(54, -170, -138, 0), Vector4(58, -176, -134, 0), Vector4(46, -166, -148, 0), Vector4(48, -160, -144, 0), Vector4(54, -170, -138, 0), Vector4(58, -176, -134, 0)],
	&"normal": [Vector4(38, -168, -145, 0), Vector4(30, -166, -108, 3), Vector4(70, -176, -48, 3), Vector4(104, -181, 28, 3), Vector4(108, -163, 88, 3), Vector4(82, -154, 132, 3), Vector4(38, -168, -145, 0)],
	&"heavy": [Vector4(38, -168, -145, 0), Vector4(-18, -218, -72, 3), Vector4(-12, -236, -36, 3), Vector4(34, -226, 12, 3), Vector4(76, -186, 58, 3), Vector4(102, -116, 108, 3), Vector4(72, -128, 148, 3), Vector4(38, -168, -145, 0)],
	&"parry": [Vector4(38, -168, -145, 0), Vector4(28, -190, -12, 3), Vector4(40, -214, 18, 3), Vector4(92, -198, 72, 3), Vector4(62, -188, 34, 3), Vector4(32, -184, -8, 3)],
	&"skill": [Vector4(30, -184, -104, 3), Vector4(48, -178, -48, 3), Vector4(112, -178, 42, 3), Vector4(94, -148, 126, 3), Vector4(52, -220, 154, 3), Vector4(112, -188, 52, 3), Vector4(68, -138, -132, 3), Vector4(38, -168, -145, 0)],
	&"hurt": [Vector4(38, -168, -145, 0), Vector4(18, -148, -126, 0)],
	&"death": [Vector4(38, -168, -145, 0), Vector4(16, -132, -124, 0), Vector4(-18, -92, -100, 0), Vector4(-56, -42, -74, 0), Vector4(-72, -28, -62, 0), Vector4(-80, -20, -58, 0)],
}

@export var follow_speed := 36.0
var weapon_pivot: Node2D

var _target_position := Vector2.ZERO
var _target_rotation := 0.0
var _target_depth := 0
var _debug_visible := false


func _ready() -> void:
	weapon_pivot = get_node("WeaponPivot")
	queue_redraw()


func _process(delta: float) -> void:
	var weight := 1.0 - exp(-follow_speed * delta)
	position = position.lerp(_target_position, weight)
	weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, _target_rotation, weight)
	z_index = _target_depth


func target_pose(animation: StringName, frame: int, immediate := false) -> void:
	if weapon_pivot == null:
		weapon_pivot = get_node("WeaponPivot")
	var poses: Array = POSES.get(animation, POSES[&"idle"])
	var pose: Vector4 = poses[mini(frame, poses.size() - 1)]
	_target_position = Vector2(pose.x, pose.y)
	_target_rotation = deg_to_rad(pose.z)
	_target_depth = int(pose.w)
	visible = animation != &"death" or frame < 3
	if immediate:
		position = _target_position
		weapon_pivot.rotation = _target_rotation
		z_index = _target_depth


func set_debug_visible(enabled: bool) -> void:
	_debug_visible = enabled
	queue_redraw()


func _draw() -> void:
	if not _debug_visible:
		return
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.55, 0.18, 0.9), false, 2.0)
	draw_line(Vector2(-12, 0), Vector2(12, 0), Color(1.0, 0.8, 0.35), 2.0)
	draw_line(Vector2(0, -12), Vector2(0, 12), Color(1.0, 0.8, 0.35), 2.0)
