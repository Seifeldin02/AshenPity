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
	var texture: Texture2D = _textures.get("pillar")
	draw_colored_polygon(_ellipse_points(Vector2(0, 112), 38.0, 13.0), Color(0.02, 0.016, 0.02, 0.42))
	if texture != null:
		var shaft := Rect2(-25, -14, 50, 118)
		var cap_top := Rect2(-38, -26, 76, 18)
		var cap_bottom := Rect2(-34, 96, 68, 20)
		draw_texture_rect(texture, shaft, true, Color(0.58, 0.56, 0.54, 0.94))
		draw_texture_rect(texture, cap_top, true, Color(0.70, 0.67, 0.63, 0.96))
		draw_texture_rect(texture, cap_bottom, true, Color(0.45, 0.43, 0.43, 0.94))
		draw_rect(shaft, Color("#151319"), false, 2.0)
		draw_line(Vector2(-18, 4), Vector2(-20, 88), Color(0.88, 0.84, 0.76, 0.12), 3.0)
		draw_line(Vector2(17, 0), Vector2(14, 94), Color(0.02, 0.018, 0.022, 0.38), 4.0)
		return
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
