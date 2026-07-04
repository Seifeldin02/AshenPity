extends Node2D

@export var size := Vector2(100, 80)
@export_enum("wall", "broken_wall", "altar") var kind := "wall"

func _draw() -> void:
	match kind:
		"broken_wall":
			_draw_broken_wall()
		"altar":
			_draw_altar()
		_:
			_draw_wall()


func _draw_wall() -> void:
	draw_rect(Rect2(-size * 0.5, size), Color(0, 0, 0, 0))
	var rect := Rect2(-size * 0.5, size)
	draw_rect(Rect2(-size * 0.5, size), Color("#2a252c"))
	draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y * 0.5), size), Color("#302b33"))
	draw_rect(Rect2(Vector2(-size.x * 0.5 + 8.0, -size.y * 0.5 + 7.0), size - Vector2(16, 14)), Color("#242129"), false, 3.0)
	draw_line(Vector2(-size.x * 0.5, -size.y * 0.5 + 9.0), Vector2(size.x * 0.5, -size.y * 0.5 + 9.0), Color(0.58, 0.50, 0.42, 0.22), 3.0)
	for i in int(size.x / 96.0) + 1:
		var x := -size.x * 0.5 + 18.0 + float(i) * 92.0
		draw_line(Vector2(x, -size.y * 0.46), Vector2(x - 18.0, size.y * 0.35), Color(0.08, 0.07, 0.08, 0.32), 3.0)


func _draw_broken_wall() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 27), size.x * 0.52, 10.0), Color(0.02, 0.016, 0.02, 0.38))
	var left := Rect2(-size.x * 0.5, -size.y * 0.5, size.x * 0.43, size.y)
	var right := Rect2(size.x * 0.06, -size.y * 0.42, size.x * 0.43, size.y * 0.86)
	draw_rect(left, Color("#343039"))
	draw_rect(right, Color("#29252d"))
	draw_line(Vector2(-size.x * 0.18, -size.y * 0.45), Vector2(-size.x * 0.02, size.y * 0.26), Color("#151319"), 4.0)
	draw_line(Vector2(size.x * 0.2, -size.y * 0.34), Vector2(size.x * 0.38, size.y * 0.16), Color("#4e4649"), 3.0)


func _draw_altar() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 44), size.x * 0.54, 14.0), Color(0.02, 0.016, 0.02, 0.45))
	draw_rect(Rect2(-size * 0.5, size), Color(0, 0, 0, 0))
	draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y * 0.45), Vector2(size.x, size.y * 0.9)), Color("#46393a"))
	draw_rect(Rect2(Vector2(-size.x * 0.38, -size.y * 0.62), Vector2(size.x * 0.76, size.y * 0.34)), Color("#67544a"))
	draw_line(Vector2(-size.x * 0.38, -size.y * 0.60), Vector2(size.x * 0.38, -size.y * 0.60), Color(0.86, 0.70, 0.48, 0.28), 3.0)
	draw_line(Vector2(-24, -size.y * 0.60), Vector2(18, size.y * 0.34), Color("#17141a"), 5.0)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
