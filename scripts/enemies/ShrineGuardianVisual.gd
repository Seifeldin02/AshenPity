extends Node2D

var facing := Vector2.LEFT
var state_name := "idle"
var health_ratio := 1.0
var flash := 0.0
var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	flash = maxf(flash - delta * 4.0, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_health_ratio: float) -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	health_ratio = clampf(new_health_ratio, 0.0, 1.0)


func trigger_flash() -> void:
	flash = 1.0


func _draw() -> void:
	var flip := -1.0 if facing.x < -0.1 else 1.0
	var bob := sin(_time * 4.0) * 2.0
	var tint := Color.WHITE.lerp(Color(1.0, 0.28, 0.18), flash)
	draw_colored_polygon(_ellipse(Vector2(0, 38), 35.0, 11.0), Color(0.02, 0.018, 0.02, 0.58))
	draw_set_transform(Vector2(0, bob), 0.0, Vector2(flip, 1.0))
	_draw_body(tint)
	_draw_head(tint)
	_draw_weapon(tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if state_name == "windup":
		_draw_telegraph()
	elif state_name == "active":
		_draw_swing()
	elif state_name == "dying":
		draw_circle(Vector2.ZERO, 60.0, Color(0.68, 0.58, 0.45, 0.18))


func _draw_body(tint: Color) -> void:
	var armor := PackedVector2Array([
		Vector2(0, -58), Vector2(31, -34), Vector2(28, 22),
		Vector2(12, 57), Vector2(-13, 57), Vector2(-30, 22), Vector2(-31, -34)
	])
	draw_colored_polygon(armor, Color("#343139").lerp(tint, 0.22))
	draw_line(Vector2(-22, -26), Vector2(22, 30), Color("#787065").lerp(tint, 0.12), 4.0)
	draw_line(Vector2(20, -27), Vector2(-15, 34), Color("#1b1920"), 5.0)
	draw_circle(Vector2(-12, 4), 7.0, Color("#554436").lerp(tint, 0.12))
	draw_circle(Vector2(14, 3), 7.0, Color("#554436").lerp(tint, 0.12))
	draw_rect(Rect2(-24, 60, 14, 23), Color("#211f25"))
	draw_rect(Rect2(10, 60, 14, 23), Color("#211f25"))


func _draw_head(tint: Color) -> void:
	var mask := PackedVector2Array([
		Vector2(-16, -67), Vector2(15, -69), Vector2(25, -47),
		Vector2(11, -24), Vector2(-8, -22), Vector2(-23, -45)
	])
	draw_colored_polygon(mask, Color("#c5bdac").lerp(tint, 0.25))
	draw_line(Vector2(-10, -52), Vector2(-2, -50), Color("#111016"), 3.0)
	draw_line(Vector2(11, -53), Vector2(3, -50), Color("#111016"), 3.0)
	draw_polyline(PackedVector2Array([Vector2(-18, -62), Vector2(-5, -72), Vector2(9, -66)]), Color("#6c645c"), 3.0)


func _draw_weapon(tint: Color) -> void:
	var raised := -26.0 if state_name == "windup" else 0.0
	draw_line(Vector2(-37, -25 + raised), Vector2(44, 34 + raised), Color("#5e3b2f").lerp(tint, 0.12), 8.0)
	draw_line(Vector2(30, 22 + raised), Vector2(62, 40 + raised), Color("#b8ac94").lerp(tint, 0.14), 7.0)
	draw_line(Vector2(32, 18 + raised), Vector2(63, 36 + raised), Color("#4f4a48"), 3.0)


func _draw_telegraph() -> void:
	var dir_angle := facing.angle()
	draw_arc(Vector2.ZERO, 98.0, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.90, 0.22, 0.13, 0.46), 7.0)
	draw_arc(Vector2.ZERO, 106.0, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.95, 0.62, 0.25, 0.22), 3.0)


func _draw_swing() -> void:
	var dir_angle := facing.angle()
	draw_arc(Vector2.ZERO, 112.0, dir_angle - 0.92, dir_angle + 0.82, 34, Color(1.0, 0.62, 0.28, 0.55), 11.0)
	draw_arc(Vector2.ZERO, 94.0, dir_angle - 0.60, dir_angle + 0.72, 24, Color(0.63, 0.08, 0.05, 0.36), 5.0)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
