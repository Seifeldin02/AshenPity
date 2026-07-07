extends Node2D

var facing := Vector2.LEFT
var state_name := "idle"
var health_ratio := 1.0
var enemy_kind := "guardian"
var ash_branded := false
var collect_ready := false
var flash := 0.0

var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	flash = maxf(flash - delta * 4.0, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_health_ratio: float, new_kind: String = "guardian", new_branded: bool = false, new_collect_ready: bool = false) -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	health_ratio = clampf(new_health_ratio, 0.0, 1.0)
	enemy_kind = new_kind
	ash_branded = new_branded
	collect_ready = new_collect_ready


func trigger_flash() -> void:
	flash = 1.0


func _draw() -> void:
	var flip := -1.0 if facing.x < -0.1 else 1.0
	var bob := sin(_time * 4.0) * 2.0
	var tint := Color.WHITE.lerp(Color(1.0, 0.28, 0.18), flash)
	if state_name == "stagger":
		bob += sin(_time * 38.0) * 2.0
	_draw_shadow()
	if ash_branded:
		_draw_brand()
	draw_set_transform(Vector2(0, bob), 0.0, Vector2(flip, 1.0))
	match enemy_kind:
		"hound":
			_draw_hound(tint)
		"archer":
			_draw_archer(tint)
		"bell_bearer":
			_draw_bell_bearer(tint)
		_:
			_draw_guardian(tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if state_name == "windup":
		_draw_telegraph()
	elif state_name == "active":
		_draw_swing()
	elif state_name == "dying":
		draw_circle(Vector2.ZERO, 66.0, Color(0.68, 0.58, 0.45, 0.18))


func _draw_shadow() -> void:
	var width := 44.0
	var y := 42.0
	if enemy_kind == "hound":
		width = 54.0
		y = 28.0
	elif enemy_kind == "bell_bearer":
		width = 64.0
		y = 50.0
	draw_colored_polygon(_ellipse(Vector2(0, y), width, 13.0), Color(0.02, 0.018, 0.02, 0.64))


func _draw_brand() -> void:
	var pulse := 0.55 + sin(_time * 9.0) * 0.16
	var ring_color := Color(1.0, 0.32, 0.12, 0.55 + pulse * 0.24)
	if collect_ready:
		ring_color = Color(1.0, 0.78, 0.32, 0.82)
	draw_arc(Vector2.ZERO, 56.0 + pulse * 8.0, 0.0, TAU, 42, ring_color, 5.0)
	for i in 6:
		var angle := _time * 1.8 + float(i) * TAU / 6.0
		draw_circle(Vector2.RIGHT.rotated(angle) * (46.0 + pulse * 8.0), 3.0, ring_color)


func _draw_guardian(tint: Color) -> void:
	_draw_armored_body(tint, 1.0)
	_draw_mask(tint, 1.0)
	_draw_staff_weapon(tint, 1.0)


func _draw_hound(tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-52, -4), Vector2(-30, -31), Vector2(22, -29), Vector2(58, -9),
		Vector2(48, 20), Vector2(5, 28), Vector2(-36, 20)
	]), Color("#2b2427").lerp(tint, 0.16))
	draw_colored_polygon(PackedVector2Array([Vector2(26, -29), Vector2(61, -43), Vector2(51, -10)]), Color("#48404a").lerp(tint, 0.15))
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -31), Vector2(-8, -52), Vector2(1, -29)]), Color("#6b5e55").lerp(tint, 0.15))
	draw_colored_polygon(PackedVector2Array([Vector2(8, -31), Vector2(19, -53), Vector2(27, -28)]), Color("#6b5e55").lerp(tint, 0.15))
	draw_line(Vector2(-35, 18), Vector2(-46, 43), Color("#111016"), 7.0)
	draw_line(Vector2(28, 19), Vector2(37, 42), Color("#111016"), 7.0)
	draw_line(Vector2(-3, -2), Vector2(46, -8), Color("#95503b").lerp(tint, 0.25), 5.0)
	draw_circle(Vector2(43, -16), 4.0, Color("#f4c16b").lerp(tint, 0.25))


func _draw_archer(tint: Color) -> void:
	_draw_armored_body(tint, 0.82)
	_draw_mask(tint, 0.84)
	draw_line(Vector2(-42, -24), Vector2(-44, 38), Color("#5e3b2f").lerp(tint, 0.12), 6.0)
	draw_arc(Vector2(-46, 8), 42.0, -1.25, 1.25, 24, Color("#8f745c").lerp(tint, 0.12), 5.0)
	draw_line(Vector2(-41, -21), Vector2(-38, 31), Color("#d8cdb6").lerp(tint, 0.18), 2.0)
	draw_line(Vector2(-18, -1), Vector2(37, -18), Color("#b8ac94").lerp(tint, 0.12), 4.0)


func _draw_bell_bearer(tint: Color) -> void:
	_draw_armored_body(tint, 1.28)
	_draw_mask(tint, 1.20)
	draw_colored_polygon(PackedVector2Array([Vector2(-28, -98), Vector2(28, -98), Vector2(36, -72), Vector2(0, -52), Vector2(-36, -72)]), Color("#675b47").lerp(tint, 0.13))
	draw_line(Vector2(42, -52), Vector2(70, 44), Color("#4c312b").lerp(tint, 0.12), 11.0)
	draw_circle(Vector2(73, 52), 20.0, Color("#7a6140").lerp(tint, 0.12))
	draw_arc(Vector2(73, 52), 15.0, 0.0, TAU, 24, Color("#2a2020"), 4.0)


func _draw_armored_body(tint: Color, scale_value: float) -> void:
	var s := scale_value
	draw_colored_polygon(PackedVector2Array([
		Vector2(-36, -38) * s, Vector2(-57, -6) * s, Vector2(-45, 25) * s, Vector2(-25, 6) * s
	]), Color("#28242c").lerp(tint, 0.10))
	draw_colored_polygon(PackedVector2Array([
		Vector2(35, -38) * s, Vector2(57, -5) * s, Vector2(43, 27) * s, Vector2(23, 7) * s
	]), Color("#3a3338").lerp(tint, 0.10))
	var armor := PackedVector2Array([
		Vector2(0, -66) * s, Vector2(36, -42) * s, Vector2(36, 21) * s,
		Vector2(18, 64) * s, Vector2(-17, 64) * s, Vector2(-36, 21) * s, Vector2(-37, -42) * s
	])
	draw_colored_polygon(armor, Color("#343139").lerp(tint, 0.22))
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -45) * s, Vector2(20, -45) * s, Vector2(26, -18) * s, Vector2(0, -2) * s, Vector2(-26, -18) * s]), Color("#56505a").lerp(tint, 0.15))
	draw_line(Vector2(-27, -30) * s, Vector2(27, 35) * s, Color("#8a806f").lerp(tint, 0.12), 5.0 * s)
	draw_line(Vector2(24, -32) * s, Vector2(-17, 40) * s, Color("#17141a"), 5.0 * s)
	draw_rect(Rect2(Vector2(-28, 65) * s, Vector2(15, 27) * s), Color("#17151c"))
	draw_rect(Rect2(Vector2(13, 65) * s, Vector2(15, 27) * s), Color("#17151c"))


func _draw_mask(tint: Color, scale_value: float) -> void:
	var s := scale_value
	var mask := PackedVector2Array([
		Vector2(-18, -76) * s, Vector2(0, -84) * s, Vector2(19, -76) * s, Vector2(29, -50) * s,
		Vector2(16, -23) * s, Vector2(0, -16) * s, Vector2(-16, -23) * s, Vector2(-29, -50) * s
	])
	draw_colored_polygon(mask, Color("#c5bdac").lerp(tint, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-28, -61) * s, Vector2(-43, -76) * s, Vector2(-31, -50) * s]), Color("#9d9181").lerp(tint, 0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(28, -61) * s, Vector2(44, -76) * s, Vector2(31, -50) * s]), Color("#9d9181").lerp(tint, 0.12))
	draw_line(Vector2(-12, -57) * s, Vector2(-3, -54) * s, Color("#111016"), 3.0 * s)
	draw_line(Vector2(12, -57) * s, Vector2(3, -54) * s, Color("#111016"), 3.0 * s)
	draw_line(Vector2(0, -78) * s, Vector2(0, -19) * s, Color("#766e65"), 2.0 * s)


func _draw_staff_weapon(tint: Color, scale_value: float) -> void:
	var s := scale_value
	var raised := -26.0 if state_name == "windup" else 0.0
	draw_line(Vector2(-45, -33 + raised) * s, Vector2(47, 39 + raised) * s, Color("#5e3b2f").lerp(tint, 0.12), 9.0 * s)
	draw_line(Vector2(30, 25 + raised) * s, Vector2(70, 50 + raised) * s, Color("#b8ac94").lerp(tint, 0.14), 8.0 * s)
	draw_line(Vector2(32, 20 + raised) * s, Vector2(71, 45 + raised) * s, Color("#4f4a48"), 3.0 * s)


func _draw_telegraph() -> void:
	var dir_angle := facing.angle()
	var radius := 98.0 if enemy_kind != "bell_bearer" else 140.0
	draw_arc(Vector2.ZERO, radius, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.90, 0.22, 0.13, 0.46), 7.0)
	draw_arc(Vector2.ZERO, radius + 8.0, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.95, 0.62, 0.25, 0.22), 3.0)


func _draw_swing() -> void:
	var dir_angle := facing.angle()
	var radius := 112.0 if enemy_kind != "bell_bearer" else 152.0
	draw_arc(Vector2.ZERO, radius, dir_angle - 0.92, dir_angle + 0.82, 34, Color(1.0, 0.62, 0.28, 0.55), 11.0)
	draw_arc(Vector2.ZERO, radius - 18.0, dir_angle - 0.60, dir_angle + 0.72, 24, Color(0.63, 0.08, 0.05, 0.36), 5.0)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
