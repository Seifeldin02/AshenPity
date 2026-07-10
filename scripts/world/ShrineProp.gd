extends Node2D

@export var kind := "pillar"

var _textures := {}

func _ready() -> void:
	_textures = {
		"pillar": _load_texture("res://assets/environment/upgrade/broken_pillar.png"),
		"torch": _load_texture("res://assets/environment/upgrade/torch_brazier.png"),
	}


func _draw() -> void:
	if kind == "torch":
		_draw_torch()
	else:
		_draw_pillar()


func _draw_pillar() -> void:
	var texture: Texture2D = _textures.get("pillar")
	if texture != null:
		_draw_texture_centered(texture, Vector2(0, 42), Vector2(0.72, 0.72), Color(0.92, 0.90, 0.96, 1.0))


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
