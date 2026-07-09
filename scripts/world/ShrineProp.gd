extends Node2D

@export var kind := "pillar"

var _textures := {}

func _ready() -> void:
	_textures = {
		"pillar": _load_texture("res://assets/environment/sbs_dungeon/wall_stone_a.png"),
		"torch": _load_texture("res://assets/environment/simple_souls/brazier.png"),
	}


func _draw() -> void:
	if kind == "torch":
		_draw_torch()
	else:
		_draw_pillar()


func _draw_pillar() -> void:
	draw_colored_polygon(_ellipse_points(Vector2(0, 112), 38.0, 13.0), Color(0.02, 0.016, 0.02, 0.42))
	var shaft := PackedVector2Array([
		Vector2(-23, -10), Vector2(22, -10), Vector2(18, 98), Vector2(0, 108), Vector2(-20, 98)
	])
	draw_colored_polygon(shaft, Color("#4a494d"))
	draw_colored_polygon(PackedVector2Array([Vector2(-15, -4), Vector2(6, -4), Vector2(0, 102), Vector2(-18, 94)]), Color("#5e5c61"))
	draw_colored_polygon(PackedVector2Array([Vector2(6, -4), Vector2(22, -10), Vector2(18, 98), Vector2(0, 102)]), Color("#38373d"))
	draw_rect(Rect2(-36, -25, 72, 18), Color("#34323a"))
	draw_rect(Rect2(-31, 92, 62, 18), Color("#2e2c33"))
	draw_rect(Rect2(-25, -10, 50, 110), Color("#151319"), false, 2.0)
	draw_line(Vector2(-11, 6), Vector2(-17, 88), Color(0.86, 0.82, 0.72, 0.15), 3.0)
	draw_line(Vector2(14, 6), Vector2(9, 92), Color(0.02, 0.018, 0.022, 0.42), 4.0)
	draw_polyline(PackedVector2Array([Vector2(-16, 36), Vector2(2, 22), Vector2(-4, 54), Vector2(16, 73)]), Color("#242229"), 4.0)


func _draw_torch() -> void:
	var texture: Texture2D = _textures.get("torch")
	if texture != null:
		_draw_texture_centered(texture, Vector2.ZERO, Vector2(0.92, 0.92), Color.WHITE)
		return


func _draw_texture_centered(texture: Texture2D, offset: Vector2, scale_value: Vector2, tint: Color) -> void:
	var size := texture.get_size() * scale_value
	draw_texture_rect(texture, Rect2(offset - size * 0.5, size), false, tint)


func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


func _ellipse_points(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
