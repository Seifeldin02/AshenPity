extends Node2D

var facing := Vector2.RIGHT
var state_name := "idle"
var flash := 0.0
var attack_alpha := 0.0
var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	flash = maxf(flash - delta * 5.0, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_attack_alpha: float) -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	attack_alpha = new_attack_alpha


func trigger_flash() -> void:
	flash = 1.0


func _draw() -> void:
	var breathe := sin(_time * 5.0) * 2.0
	var walk_bob := 0.0
	if state_name == "move":
		walk_bob = sin(_time * 12.0) * 4.0
	elif state_name == "dodge":
		walk_bob = -8.0
	var flip := -1.0 if facing.x < -0.12 else 1.0
	var tint := Color.WHITE.lerp(Color(1.0, 0.35, 0.25), flash)
	draw_colored_polygon(_ellipse(Vector2(0, 31), 27.0, 9.0), Color(0.02, 0.018, 0.022, 0.50))
	draw_set_transform(Vector2(0, walk_bob), 0.0, Vector2(flip, 1.0))
	_draw_cloak(tint, breathe)
	_draw_mask(tint, breathe)
	_draw_sword(tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if attack_alpha > 0.0:
		_draw_slash()


func _draw_cloak(tint: Color, breathe: float) -> void:
	var cloak := PackedVector2Array([
		Vector2(0, -46 + breathe), Vector2(31, -24), Vector2(26, 24),
		Vector2(10, 45), Vector2(-8, 46), Vector2(-28, 25), Vector2(-31, -23)
	])
	draw_colored_polygon(cloak, Color("#191821").lerp(tint, 0.18))
	draw_polyline(PackedVector2Array([Vector2(-26, -19), Vector2(0, -46 + breathe), Vector2(28, -18)]), Color("#55505b").lerp(tint, 0.20), 5.0)
	draw_line(Vector2(-7, -19), Vector2(-14, 36), Color("#0d0c12"), 5.0)
	draw_line(Vector2(10, -20), Vector2(16, 34), Color("#302b35"), 4.0)
	draw_circle(Vector2(-12, -4), 4.0, Color("#352c35").lerp(tint, 0.18))
	draw_circle(Vector2(13, -4), 4.0, Color("#352c35").lerp(tint, 0.18))


func _draw_mask(tint: Color, breathe: float) -> void:
	var mask := PackedVector2Array([
		Vector2(-12, -32 + breathe), Vector2(12, -32 + breathe),
		Vector2(16, -14), Vector2(6, 0), Vector2(-6, 0), Vector2(-16, -14)
	])
	draw_colored_polygon(mask, Color("#d7d1c1").lerp(tint, 0.35))
	draw_line(Vector2(-7, -20), Vector2(-1, -18), Color("#141217"), 2.0)
	draw_line(Vector2(7, -20), Vector2(1, -18), Color("#141217"), 2.0)
	draw_line(Vector2(0, -31), Vector2(0, -2), Color("#8a8177").lerp(tint, 0.20), 2.0)


func _draw_sword(tint: Color) -> void:
	var raised := -12.0 if state_name == "attack_windup" else 0.0
	var side := 30.0
	draw_line(Vector2(side - 8, -12 + raised), Vector2(side + 36, -34 + raised), Color("#c8bda6").lerp(tint, 0.25), 6.0)
	draw_line(Vector2(side - 9, -13 + raised), Vector2(side + 19, -27 + raised), Color("#f1e7d0").lerp(tint, 0.18), 2.0)
	draw_line(Vector2(side - 18, -6 + raised), Vector2(side - 3, -18 + raised), Color("#7c4b36"), 5.0)


func _draw_slash() -> void:
	var alpha := clampf(attack_alpha, 0.0, 1.0)
	var dir_angle := facing.angle()
	draw_arc(Vector2.ZERO, 69.0, dir_angle - 0.74, dir_angle + 0.74, 28, Color(0.95, 0.82, 0.55, 0.62 * alpha), 10.0)
	draw_arc(Vector2.ZERO, 83.0, dir_angle - 0.50, dir_angle + 0.62, 24, Color(0.95, 0.33, 0.16, 0.28 * alpha), 5.0)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
