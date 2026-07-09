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
	draw_rect(Rect2(rect.position + Vector2(8, 12), rect.size), Color(0.02, 0.016, 0.020, 0.34))
	draw_rect(rect, Color("#30282a"))
	_draw_wall_grain(rect, Color(0.16, 0.13, 0.12, 0.18))
	var inner := Rect2(Vector2(-size.x * 0.5 + 5.0, -size.y * 0.5 + 5.0), size - Vector2(10, 10))
	draw_rect(inner, Color(0.02, 0.018, 0.022, 0.42), false, 2.0)
	draw_line(Vector2(-size.x * 0.5, -size.y * 0.5 + 7.0), Vector2(size.x * 0.5, -size.y * 0.5 + 7.0), Color(0.72, 0.55, 0.40, 0.16), 3.0)
	draw_line(Vector2(-size.x * 0.5, size.y * 0.5 - 5.0), Vector2(size.x * 0.5, size.y * 0.5 - 5.0), Color(0.02, 0.018, 0.022, 0.34), 4.0)
	_draw_block_lines(rect, 72.0, 34.0, Color(0.08, 0.065, 0.065, 0.18))


func _draw_broken_wall() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 27), size.x * 0.52, 10.0), Color(0.02, 0.016, 0.02, 0.38))
	var left := Rect2(-size.x * 0.5, -size.y * 0.5, size.x * 0.43, size.y)
	var right := Rect2(size.x * 0.06, -size.y * 0.42, size.x * 0.43, size.y * 0.86)
	draw_rect(left, Color("#342d2e"))
	_draw_wall_grain(left, Color(0.16, 0.13, 0.12, 0.18))
	draw_rect(right, Color("#2b2629"))
	_draw_wall_grain(right, Color(0.16, 0.13, 0.12, 0.15))
	_draw_block_lines(left, 46.0, 28.0, Color(0.08, 0.065, 0.065, 0.20))
	_draw_block_lines(right, 46.0, 28.0, Color(0.08, 0.065, 0.065, 0.18))
	draw_line(Vector2(-size.x * 0.18, -size.y * 0.45), Vector2(-size.x * 0.02, size.y * 0.26), Color("#151319"), 4.0)
	draw_line(Vector2(size.x * 0.2, -size.y * 0.34), Vector2(size.x * 0.38, size.y * 0.16), Color("#4e4649"), 3.0)


func _draw_altar() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 44), size.x * 0.54, 14.0), Color(0.02, 0.016, 0.02, 0.45))
	draw_rect(Rect2(-size * 0.5, size), Color(0, 0, 0, 0))
	var body := Rect2(Vector2(-size.x * 0.5, -size.y * 0.45), Vector2(size.x, size.y * 0.9))
	draw_rect(body, Color("#46393a"))
	_draw_wall_grain(body, Color(0.18, 0.13, 0.11, 0.16))
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


func _draw_block_lines(rect: Rect2, block_width: float, row_height: float, color: Color) -> void:
	var y := rect.position.y + row_height
	var row := 0
	while y < rect.end.y - 4.0:
		draw_line(Vector2(rect.position.x + 4.0, y), Vector2(rect.end.x - 4.0, y), color, 1.0)
		y += row_height
	while row * row_height < rect.size.y:
		var offset := 0.0 if row % 2 == 0 else block_width * 0.5
		var x := rect.position.x + offset + block_width
		var y0 := rect.position.y + float(row) * row_height + 4.0
		var y1 := minf(y0 + row_height - 8.0, rect.end.y - 4.0)
		while x < rect.end.x - 4.0:
			draw_line(Vector2(x, y0), Vector2(x, y1), color, 1.0)
			x += block_width
		row += 1


func _draw_wall_grain(rect: Rect2, color: Color) -> void:
	var x := rect.position.x + 18.0
	while x < rect.end.x:
		draw_line(Vector2(x, rect.position.y + 8.0), Vector2(x - 16.0, rect.end.y - 8.0), color, 1.0)
		x += 92.0
	var y := rect.position.y + 17.0
	while y < rect.end.y:
		draw_line(Vector2(rect.position.x + 8.0, y), Vector2(rect.end.x - 8.0, y + 3.0), Color(color.r, color.g, color.b, color.a * 0.65), 1.0)
		y += 39.0


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
