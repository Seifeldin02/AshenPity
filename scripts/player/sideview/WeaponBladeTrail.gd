class_name WeaponBladeTrail
extends Line2D

@export var blade_tip_path: NodePath

@onready var blade_tip: Marker2D = get_node(blade_tip_path)

var _samples: Array[Vector2] = []
var _ages: Array[float] = []
var _active := false
var _lifetime := 0.12


func _ready() -> void:
	antialiased = true
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	var trail_gradient := Gradient.new()
	trail_gradient.colors = PackedColorArray([
		Color(0.35, 0.12, 0.06, 0.0),
		Color(1.0, 0.34, 0.10, 0.45),
		Color(1.0, 0.88, 0.62, 0.95),
	])
	trail_gradient.offsets = PackedFloat32Array([0.0, 0.66, 1.0])
	gradient = trail_gradient


func _process(delta: float) -> void:
	for index in range(_ages.size() - 1, -1, -1):
		_ages[index] += delta
		if _ages[index] >= _lifetime:
			_ages.remove_at(index)
			_samples.remove_at(index)
	if _active:
		var sample := to_local(blade_tip.global_position)
		if _samples.is_empty() or _samples.back().distance_to(sample) >= 3.0:
			_samples.append(sample)
			_ages.append(0.0)
	while _samples.size() > 14:
		_samples.pop_front()
		_ages.pop_front()
	points = PackedVector2Array(_samples)


func set_action_frame(animation: StringName, frame: int) -> void:
	match animation:
		&"normal":
			_set_active(frame >= 2 and frame <= 5, 12.0, 0.10)
		&"heavy":
			_set_active(frame >= 3 and frame <= 6, 18.0, 0.14)
		&"parry":
			_set_active(frame >= 2 and frame <= 4, 9.0, 0.08)
		&"skill":
			_set_active(frame >= 1 and frame <= 6, 24.0, 0.18)
		_:
			_set_active(false, 12.0, 0.10)


func _set_active(enabled: bool, trail_width: float, lifetime: float) -> void:
	_active = enabled
	width = trail_width
	_lifetime = lifetime
