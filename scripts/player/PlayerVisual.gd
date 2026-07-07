extends Node2D

var facing := Vector2.RIGHT
var state_name := "idle"
var flash := 0.0
var attack_alpha := 0.0
var attack_name := ""
var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	flash = maxf(flash - delta * 5.0, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_attack_alpha: float, new_attack_name: String = "") -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	attack_alpha = new_attack_alpha
	attack_name = new_attack_name


func trigger_flash() -> void:
	flash = 1.0


func _draw() -> void:
	var breathe := sin(_time * 5.0) * 2.0
	var walk_bob := 0.0
	if state_name == "move":
		walk_bob = sin(_time * 14.0) * 3.0
	elif state_name == "dodge":
		walk_bob = -8.0
	elif state_name == "collect_active":
		walk_bob = -5.0
	var flip := -1.0 if facing.x < -0.12 else 1.0
	var tint := Color.WHITE.lerp(Color(1.0, 0.35, 0.25), flash)
	draw_colored_polygon(_ellipse(Vector2(0, 34), 34.0, 11.0), Color(0.02, 0.018, 0.022, 0.58))
	if state_name == "dodge":
		_draw_dodge_trail()
	draw_set_transform(Vector2(0, walk_bob), 0.0, Vector2(flip, 1.0))
	_draw_cloak(tint, breathe)
	_draw_mask(tint, breathe)
	_draw_sword(tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if attack_alpha > 0.0:
		_draw_slash()


func _draw_cloak(tint: Color, breathe: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-27, -16), Vector2(-48, 11), Vector2(-32, 31), Vector2(-15, 8)
	]), Color("#111018").lerp(tint, 0.10))
	draw_colored_polygon(PackedVector2Array([
		Vector2(25, -16), Vector2(43, 12), Vector2(31, 30), Vector2(14, 7)
	]), Color("#211c29").lerp(tint, 0.10))
	var cloak := PackedVector2Array([
		Vector2(0, -53 + breathe), Vector2(34, -31), Vector2(33, 20),
		Vector2(18, 51), Vector2(2, 61), Vector2(-16, 51), Vector2(-34, 21), Vector2(-35, -30)
	])
	draw_colored_polygon(cloak, Color("#191821").lerp(tint, 0.18))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-3, -49 + breathe), Vector2(23, -27), Vector2(19, 43), Vector2(4, 56), Vector2(0, 3)
	]), Color("#2b2633").lerp(tint, 0.12))
	draw_polyline(PackedVector2Array([Vector2(-29, -23), Vector2(0, -53 + breathe), Vector2(31, -22)]), Color("#6b6470").lerp(tint, 0.20), 5.0)
	draw_line(Vector2(-7, -22), Vector2(-16, 43), Color("#0d0c12"), 5.0)
	draw_line(Vector2(10, -22), Vector2(18, 41), Color("#3b3341"), 4.0)
	draw_line(Vector2(-22, 48), Vector2(18, 50), Color("#0a0910"), 4.0)
	draw_circle(Vector2(-14, -5), 4.5, Color("#463847").lerp(tint, 0.18))
	draw_circle(Vector2(14, -5), 4.5, Color("#463847").lerp(tint, 0.18))


func _draw_mask(tint: Color, breathe: float) -> void:
	var mask := PackedVector2Array([
		Vector2(-15, -38 + breathe), Vector2(0, -44 + breathe), Vector2(15, -38 + breathe),
		Vector2(19, -17), Vector2(8, 5), Vector2(0, 10), Vector2(-8, 5), Vector2(-19, -17)
	])
	draw_colored_polygon(mask, Color("#ddd7c7").lerp(tint, 0.35))
	draw_line(Vector2(-9, -23), Vector2(-2, -21), Color("#141217"), 2.5)
	draw_line(Vector2(9, -23), Vector2(2, -21), Color("#141217"), 2.5)
	draw_line(Vector2(0, -39), Vector2(0, 6), Color("#948a7c").lerp(tint, 0.20), 2.0)
	draw_line(Vector2(-11, -11), Vector2(11, -10), Color(0.95, 0.85, 0.66, 0.30), 1.5)


func _draw_sword(tint: Color) -> void:
	var raised := -15.0 if state_name.ends_with("_windup") else 0.0
	var side := 30.0
	draw_line(Vector2(side - 17, -2 + raised), Vector2(side - 2, -16 + raised), Color("#4f3740"), 8.0)
	draw_line(Vector2(side - 3, -18 + raised), Vector2(side + 47, -43 + raised), Color("#d8cdb6").lerp(tint, 0.25), 7.0)
	draw_line(Vector2(side - 1, -19 + raised), Vector2(side + 28, -34 + raised), Color("#fff1d5").lerp(tint, 0.18), 2.0)
	draw_line(Vector2(side - 20, 0 + raised), Vector2(side - 1, -18 + raised), Color("#8b563c"), 5.0)


func _draw_slash() -> void:
	var alpha := clampf(attack_alpha, 0.0, 1.0)
	var dir_angle := facing.angle()
	if attack_name == "collect":
		draw_arc(Vector2.ZERO, 96.0, dir_angle - 0.90, dir_angle + 0.90, 34, Color(1.0, 0.78, 0.38, 0.86 * alpha), 14.0)
		draw_arc(Vector2.ZERO, 122.0, dir_angle - 0.62, dir_angle + 0.72, 30, Color(0.98, 0.22, 0.12, 0.46 * alpha), 6.0)
		draw_line(-facing.rotated(0.24) * 70.0, facing.rotated(0.24) * 92.0, Color(0.95, 0.86, 0.58, 0.68 * alpha), 8.0)
	elif attack_name == "heavy":
		draw_arc(Vector2.ZERO, 92.0, dir_angle - 0.88, dir_angle + 0.88, 32, Color(1.0, 0.68, 0.32, 0.75 * alpha), 14.0)
		draw_arc(Vector2.ZERO, 112.0, dir_angle - 0.48, dir_angle + 0.66, 28, Color(0.95, 0.18, 0.10, 0.34 * alpha), 6.0)
	else:
		var radius := 78.0 if attack_name != "light_3" else 96.0
		draw_arc(Vector2.ZERO, radius, dir_angle - 0.74, dir_angle + 0.74, 30, Color(0.98, 0.86, 0.58, 0.66 * alpha), 11.0)
		draw_arc(Vector2.ZERO, radius + 17.0, dir_angle - 0.50, dir_angle + 0.62, 26, Color(0.95, 0.33, 0.16, 0.32 * alpha), 5.0)


func _draw_dodge_trail() -> void:
	for i in 3:
		var offset := -facing * float(i + 1) * 18.0
		var alpha := 0.14 - float(i) * 0.035
		draw_colored_polygon(_ellipse(offset + Vector2(0, 4), 25.0 - float(i) * 3.0, 35.0 - float(i) * 3.0), Color(0.60, 0.55, 0.50, alpha))


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
