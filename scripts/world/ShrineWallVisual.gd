extends Node2D

@export var size := Vector2(100, 80)
@export_enum("wall", "broken_wall", "altar") var kind := "wall"

var _wall_texture: Texture2D
var _brick_texture: Texture2D
var _broken_wall_texture: Texture2D

func _ready() -> void:
	_wall_texture = _load_texture("res://assets/environment/sbs_dungeon/wall_brick_a.png")
	_brick_texture = _load_texture("res://assets/environment/sbs_dungeon/wall_stone_a.png")
	_broken_wall_texture = _load_texture("res://assets/environment/sbs_dungeon/wall_brick_b.png")


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
	draw_rect(Rect2(-size * 0.5 + Vector2(10, 12), size), Color(0.02, 0.016, 0.020, 0.48))
	draw_rect(rect, Color("#27232a"))
	if _wall_texture != null:
		draw_texture_rect(_wall_texture, rect, true, Color(0.56, 0.50, 0.49, 0.92))
	else:
		draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y * 0.5), size), Color("#302b33"))
	draw_rect(Rect2(Vector2(-size.x * 0.5 + 8.0, -size.y * 0.5 + 7.0), size - Vector2(16, 14)), Color("#18161c"), false, 3.0)
	draw_line(Vector2(-size.x * 0.5, -size.y * 0.5 + 9.0), Vector2(size.x * 0.5, -size.y * 0.5 + 9.0), Color(0.68, 0.58, 0.44, 0.18), 3.0)
	draw_line(Vector2(-size.x * 0.5, size.y * 0.5 - 7.0), Vector2(size.x * 0.5, size.y * 0.5 - 7.0), Color(0.02, 0.018, 0.022, 0.38), 4.0)
	for i in int(size.x / 96.0) + 1:
		var x := -size.x * 0.5 + 18.0 + float(i) * 92.0
		draw_line(Vector2(x, -size.y * 0.46), Vector2(x - 18.0, size.y * 0.35), Color(0.08, 0.07, 0.08, 0.20), 2.0)


func _draw_broken_wall() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 27), size.x * 0.52, 10.0), Color(0.02, 0.016, 0.02, 0.38))
	var left := Rect2(-size.x * 0.5, -size.y * 0.5, size.x * 0.43, size.y)
	var right := Rect2(size.x * 0.06, -size.y * 0.42, size.x * 0.43, size.y * 0.86)
	if _broken_wall_texture != null:
		draw_texture_rect(_broken_wall_texture, left, true, Color(0.52, 0.48, 0.46, 0.90))
		draw_texture_rect(_broken_wall_texture, right, true, Color(0.44, 0.40, 0.41, 0.90))
	else:
		draw_rect(left, Color("#343039"))
		draw_rect(right, Color("#29252d"))
	draw_line(Vector2(-size.x * 0.18, -size.y * 0.45), Vector2(-size.x * 0.02, size.y * 0.26), Color("#151319"), 4.0)
	draw_line(Vector2(size.x * 0.2, -size.y * 0.34), Vector2(size.x * 0.38, size.y * 0.16), Color("#4e4649"), 3.0)


func _draw_altar() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 44), size.x * 0.54, 14.0), Color(0.02, 0.016, 0.02, 0.45))
	draw_rect(Rect2(-size * 0.5, size), Color(0, 0, 0, 0))
	var body := Rect2(Vector2(-size.x * 0.5, -size.y * 0.45), Vector2(size.x, size.y * 0.9))
	if _brick_texture != null:
		draw_texture_rect(_brick_texture, body, true, Color(0.72, 0.58, 0.52, 0.92))
	else:
		draw_rect(body, Color("#46393a"))
	draw_rect(Rect2(Vector2(-size.x * 0.38, -size.y * 0.62), Vector2(size.x * 0.76, size.y * 0.34)), Color("#67544a"))
	draw_line(Vector2(-size.x * 0.38, -size.y * 0.60), Vector2(size.x * 0.38, -size.y * 0.60), Color(0.86, 0.70, 0.48, 0.28), 3.0)
	draw_line(Vector2(-24, -size.y * 0.60), Vector2(18, size.y * 0.34), Color("#17141a"), 5.0)


func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


func _draw_texture_centered(texture: Texture2D, offset: Vector2, scale_value: Vector2, tint: Color) -> void:
	var size_value := texture.get_size() * scale_value
	draw_texture_rect(texture, Rect2(offset - size_value * 0.5, size_value), false, tint)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
