extends Node2D

@export var kind := "pillar"

func _draw() -> void:
	if kind == "torch":
		_draw_torch()
	else:
		_draw_pillar()


func _draw_pillar() -> void:
	draw_colored_polygon(_ellipse_points(Vector2(0, 156), 43.0, 13.0), Color(0.03, 0.025, 0.03, 0.55))
	var outer := PackedVector2Array([
		Vector2(-25, -12), Vector2(-12, -26), Vector2(18, -26), Vector2(31, -12),
		Vector2(24, 103), Vector2(0, 114), Vector2(-26, 103)
	])
	draw_colored_polygon(outer, Color("#4b4a50"))
	var face := PackedVector2Array([
		Vector2(-16, -7), Vector2(17, -7), Vector2(12, 96),
		Vector2(-4, 105), Vector2(-20, 96)
	])
	draw_colored_polygon(face, Color("#64626b"))
	draw_rect(Rect2(-36, -13, 72, 15), Color("#38363d"))
	draw_line(Vector2(-9, 8), Vector2(-18, 95), Color(0.82, 0.78, 0.70, 0.18), 3.0)
	draw_line(Vector2(14, 10), Vector2(7, 97), Color(0.02, 0.018, 0.023, 0.45), 4.0)
	draw_polyline(PackedVector2Array([Vector2(-18, 35), Vector2(2, 21), Vector2(-5, 52), Vector2(18, 71)]), Color("#2d2b31"), 5.0)


func _draw_torch() -> void:
	draw_colored_polygon(_ellipse_points(Vector2(0, 65), 31.0, 8.0), Color(0.03, 0.025, 0.03, 0.55))
	draw_circle(Vector2.ZERO, 56.0, Color(0.95, 0.42, 0.15, 0.10))
	draw_colored_polygon(PackedVector2Array([Vector2(-18, 7), Vector2(18, 7), Vector2(10, 60), Vector2(-10, 60)]), Color("#363238"))
	draw_rect(Rect2(-26, -4, 52, 18), Color("#61544a"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -50), Vector2(14, -19), Vector2(2, 4), Vector2(-10, -19)]), Color("#e2a24d"))
	draw_colored_polygon(PackedVector2Array([Vector2(-12, -30), Vector2(2, -12), Vector2(-5, 5), Vector2(-17, -13)]), Color("#b94f2d"))
	draw_colored_polygon(PackedVector2Array([Vector2(9, -28), Vector2(18, -12), Vector2(7, 5), Vector2(2, -12)]), Color("#ffd283"))


func _ellipse_points(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
