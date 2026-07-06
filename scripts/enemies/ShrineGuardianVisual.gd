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
	draw_colored_polygon(_ellipse(Vector2(0, 42), 44.0, 13.0), Color(0.02, 0.018, 0.02, 0.64))
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
	draw_colored_polygon(PackedVector2Array([
		Vector2(-36, -38), Vector2(-57, -6), Vector2(-45, 25), Vector2(-25, 6)
	]), Color("#28242c").lerp(tint, 0.10))
	draw_colored_polygon(PackedVector2Array([
		Vector2(35, -38), Vector2(57, -5), Vector2(43, 27), Vector2(23, 7)
	]), Color("#3a3338").lerp(tint, 0.10))
	var armor := PackedVector2Array([
		Vector2(0, -66), Vector2(36, -42), Vector2(36, 21),
		Vector2(18, 64), Vector2(-17, 64), Vector2(-36, 21), Vector2(-37, -42)
	])
	draw_colored_polygon(armor, Color("#343139").lerp(tint, 0.22))
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -45), Vector2(20, -45), Vector2(26, -18), Vector2(0, -2), Vector2(-26, -18)]), Color("#56505a").lerp(tint, 0.15))
	draw_colored_polygon(PackedVector2Array([Vector2(-27, -15), Vector2(0, -1), Vector2(-3, 55), Vector2(-22, 46)]), Color("#27252d").lerp(tint, 0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(27, -15), Vector2(0, -1), Vector2(4, 55), Vector2(23, 46)]), Color("#4a4448").lerp(tint, 0.12))
	draw_line(Vector2(-27, -30), Vector2(27, 35), Color("#8a806f").lerp(tint, 0.12), 5.0)
	draw_line(Vector2(24, -32), Vector2(-17, 40), Color("#17141a"), 5.0)
	draw_circle(Vector2(-14, 6), 8.0, Color("#6d5641").lerp(tint, 0.12))
	draw_circle(Vector2(15, 5), 8.0, Color("#6d5641").lerp(tint, 0.12))
	draw_rect(Rect2(-28, 65, 15, 27), Color("#17151c"))
	draw_rect(Rect2(13, 65, 15, 27), Color("#17151c"))
	draw_line(Vector2(-29, 91), Vector2(-8, 91), Color("#09080d"), 4.0)
	draw_line(Vector2(8, 91), Vector2(31, 91), Color("#09080d"), 4.0)


func _draw_head(tint: Color) -> void:
	var mask := PackedVector2Array([
		Vector2(-18, -76), Vector2(0, -84), Vector2(19, -76), Vector2(29, -50),
		Vector2(16, -23), Vector2(0, -16), Vector2(-16, -23), Vector2(-29, -50)
	])
	draw_colored_polygon(mask, Color("#c5bdac").lerp(tint, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-28, -61), Vector2(-43, -76), Vector2(-31, -50)]), Color("#9d9181").lerp(tint, 0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(28, -61), Vector2(44, -76), Vector2(31, -50)]), Color("#9d9181").lerp(tint, 0.12))
	draw_line(Vector2(-12, -57), Vector2(-3, -54), Color("#111016"), 3.0)
	draw_line(Vector2(12, -57), Vector2(3, -54), Color("#111016"), 3.0)
	draw_line(Vector2(0, -78), Vector2(0, -19), Color("#766e65"), 2.0)
	draw_polyline(PackedVector2Array([Vector2(-21, -70), Vector2(-7, -80), Vector2(10, -73)]), Color("#6c645c"), 3.0)


func _draw_weapon(tint: Color) -> void:
	var raised := -26.0 if state_name == "windup" else 0.0
	draw_line(Vector2(-45, -33 + raised), Vector2(47, 39 + raised), Color("#5e3b2f").lerp(tint, 0.12), 9.0)
	draw_line(Vector2(30, 25 + raised), Vector2(70, 50 + raised), Color("#b8ac94").lerp(tint, 0.14), 8.0)
	draw_line(Vector2(32, 20 + raised), Vector2(71, 45 + raised), Color("#4f4a48"), 3.0)
	draw_line(Vector2(-50, -36 + raised), Vector2(-31, -21 + raised), Color("#34262a"), 6.0)


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
