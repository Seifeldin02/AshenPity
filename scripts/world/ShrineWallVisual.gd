extends Node2D

@export var size := Vector2(100, 80)
@export_enum("wall", "broken_wall", "altar") var kind := "wall"

var _wall_texture: Texture2D
var _brick_texture: Texture2D
var _broken_wall_texture: Texture2D

func _ready() -> void:
	_wall_texture = _load_texture("res://assets/environment/sbs_dungeon/wall_brick_a.png")
	_brick_texture = _load_texture("res://assets/environment/sbs_dungeon/wall_stone_a.png")
	_broken_wall_texture = _load_texture("res://assets/environment/upgrade/broken_wall_chunk.png")


func _draw() -> void:
	match kind:
		"broken_wall":
			_draw_broken_wall()
		"altar":
			_draw_altar()
		_:
			_draw_wall()


func _draw_wall() -> void:
	var rect := Rect2(-size * 0.5, size)
	draw_rect(Rect2(rect.position + Vector2(8, 12), rect.size), Color(0.02, 0.016, 0.020, 0.34))
	draw_rect(rect, Color("#241f22"))
	_draw_texture_tiled(_wall_texture, rect.grow(-3.0), Color(0.54, 0.45, 0.42, 0.92))
	var inner := Rect2(Vector2(-size.x * 0.5 + 5.0, -size.y * 0.5 + 5.0), size - Vector2(10, 10))
	draw_rect(inner, Color(0.02, 0.018, 0.022, 0.36), false, 2.0)
	draw_rect(Rect2(Vector2(rect.position.x + 6.0, rect.position.y + 6.0), Vector2(rect.size.x - 12.0, 4.0)), Color(0.82, 0.66, 0.48, 0.10))
	draw_rect(Rect2(Vector2(rect.position.x + 4.0, rect.end.y - 10.0), Vector2(rect.size.x - 8.0, 7.0)), Color(0.02, 0.018, 0.022, 0.34))


func _draw_broken_wall() -> void:
	if _broken_wall_texture != null:
		var scale_value := Vector2(size.x / maxf(_broken_wall_texture.get_width(), 1.0), size.y / maxf(_broken_wall_texture.get_height(), 1.0))
		_draw_texture_centered(_broken_wall_texture, Vector2.ZERO, scale_value, Color(0.88, 0.84, 0.88, 1.0))
		return
	draw_colored_polygon(_ellipse(Vector2(0, 27), size.x * 0.52, 10.0), Color(0.02, 0.016, 0.02, 0.38))
	var left := Rect2(-size.x * 0.5, -size.y * 0.5, size.x * 0.43, size.y)
	var right := Rect2(size.x * 0.06, -size.y * 0.42, size.x * 0.43, size.y * 0.86)
	draw_rect(left, Color("#342d2e"))
	_draw_stone_chips(left, Color(0.10, 0.08, 0.08, 0.18))
	draw_rect(right, Color("#2b2629"))
	_draw_stone_chips(right, Color(0.10, 0.08, 0.08, 0.15))
	_draw_block_pattern(left, 46.0, 28.0, Color(0.05, 0.04, 0.04, 0.16))
	_draw_block_pattern(right, 46.0, 28.0, Color(0.05, 0.04, 0.04, 0.14))
	_draw_cracked_plate(Vector2(-size.x * 0.12, -size.y * 0.08), Vector2(12, size.y * 0.58), Color("#151319"))
	_draw_cracked_plate(Vector2(size.x * 0.28, -size.y * 0.05), Vector2(10, size.y * 0.42), Color("#4e4649"))


func _draw_altar() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, 44), size.x * 0.54, 14.0), Color(0.02, 0.016, 0.02, 0.45))
	var body := Rect2(Vector2(-size.x * 0.5, -size.y * 0.45), Vector2(size.x, size.y * 0.9))
	draw_rect(body, Color("#33292a"))
	_draw_texture_tiled(_brick_texture, body.grow(-2.0), Color(0.70, 0.57, 0.48, 0.82))
	draw_rect(Rect2(Vector2(-size.x * 0.38, -size.y * 0.62), Vector2(size.x * 0.76, size.y * 0.34)), Color("#5d4c42"))
	draw_rect(Rect2(Vector2(-size.x * 0.34, -size.y * 0.60), Vector2(size.x * 0.68, 4.0)), Color(0.86, 0.70, 0.48, 0.20))
	draw_rect(Rect2(Vector2(-size.x * 0.42, size.y * 0.24), Vector2(size.x * 0.84, 6.0)), Color(0.05, 0.035, 0.032, 0.55))


func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


func _draw_texture_centered(texture: Texture2D, offset: Vector2, scale_value: Vector2, tint: Color) -> void:
	var size_value := texture.get_size() * scale_value
	draw_texture_rect(texture, Rect2(offset - size_value * 0.5, size_value), false, tint)


func _draw_texture_tiled(texture: Texture2D, rect: Rect2, tint: Color) -> void:
	if texture == null:
		return
	draw_texture_rect(texture, rect, true, tint)


func _draw_block_pattern(rect: Rect2, block_width: float, row_height: float, color: Color) -> void:
	var y := rect.position.y + row_height
	var row := 0
	while y < rect.end.y - 4.0:
		draw_rect(Rect2(Vector2(rect.position.x + 4.0, y), Vector2(rect.size.x - 8.0, 2.0)), color)
		y += row_height
	while row * row_height < rect.size.y:
		var offset := 0.0 if row % 2 == 0 else block_width * 0.5
		var x := rect.position.x + offset + block_width
		var y0 := rect.position.y + float(row) * row_height + 4.0
		var y1 := minf(y0 + row_height - 8.0, rect.end.y - 4.0)
		while x < rect.end.x - 4.0:
			draw_rect(Rect2(Vector2(x - 1.0, y0), Vector2(2.0, y1 - y0)), color)
			x += block_width
		row += 1


func _draw_stone_chips(rect: Rect2, color: Color) -> void:
	var seed := int(abs(rect.position.x * 13.0 + rect.position.y * 7.0 + rect.size.x))
	for i in 7:
		var x := rect.position.x + 10.0 + fmod(float(seed + i * 37), maxf(rect.size.x - 22.0, 1.0))
		var y := rect.position.y + 9.0 + fmod(float(seed * 2 + i * 29), maxf(rect.size.y - 18.0, 1.0))
		var chip := Rect2(Vector2(x, y), Vector2(5.0 + float(i % 3) * 3.0, 3.0 + float((i + 1) % 2) * 3.0))
		draw_rect(chip, color)


func _draw_cracked_plate(center: Vector2, plate_size: Vector2, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(-plate_size.x * 0.45, -plate_size.y * 0.5),
		center + Vector2(plate_size.x * 0.45, -plate_size.y * 0.34),
		center + Vector2(plate_size.x * 0.28, plate_size.y * 0.5),
		center + Vector2(-plate_size.x * 0.35, plate_size.y * 0.34),
	])
	draw_colored_polygon(points, color)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
