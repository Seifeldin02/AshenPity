extends Node2D

const TEXTURE_PATHS := {
	"spark": "res://assets/effects/upgrade/spark.png",
	"flame": "res://assets/effects/upgrade/flame.png",
	"smoke": "res://assets/effects/upgrade/smoke.png",
	"blood": "res://assets/effects/upgrade/blood.png",
}

var kind := "spark"
var direction := Vector2.RIGHT
var lifetime := 0.22
var color := Color("#f0b15e")

var _age := 0.0
var _textures := {}

static func spawn(parent: Node, position_value: Vector2, effect_kind: String, facing: Vector2 = Vector2.RIGHT, tint: Color = Color("#f0b15e")) -> Node2D:
	var effect := Node2D.new()
	effect.set_script(load("res://scripts/effects/CombatEffect.gd"))
	effect.global_position = position_value
	effect.set("kind", effect_kind)
	effect.set("direction", facing.normalized() if facing.length() > 0.001 else Vector2.RIGHT)
	effect.set("color", tint)
	parent.add_child(effect)
	return effect


func _ready() -> void:
	for key in TEXTURE_PATHS:
		_textures[key] = _load_texture(str(TEXTURE_PATHS[key]))
	match kind:
		"heavy":
			lifetime = 0.28
		"collect":
			lifetime = 0.34
		"death":
			lifetime = 0.55
		"brand", "perfect":
			lifetime = 0.32
		_:
			lifetime = 0.20


func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var t := clampf(_age / lifetime, 0.0, 1.0)
	var alpha := 1.0 - t
	match kind:
		"spark":
			_draw_spark(alpha)
		"heavy":
			_draw_impact(alpha, 1.25)
		"collect":
			_draw_collect(alpha)
		"brand":
			_draw_ring(alpha, _textures.get("flame"), 1.2, Color(1.0, 0.36, 0.12, alpha * 0.78))
		"perfect":
			_draw_ring(alpha, _textures.get("spark"), 0.9, Color(1.0, 0.86, 0.44, alpha * 0.82))
		"death":
			_draw_death(alpha)
		_:
			_draw_spark(alpha)


func _draw_spark(alpha: float) -> void:
	for i in 5:
		var angle := direction.angle() + lerpf(-0.85, 0.85, float(i) / 4.0)
		var pos := Vector2.RIGHT.rotated(angle) * (15.0 + float(i % 2) * 11.0)
		_draw_texture(_textures.get("spark"), pos, Vector2(0.46, 0.46), _with_alpha(color, alpha * 0.82), angle)


func _draw_impact(alpha: float, scale_value: float) -> void:
	_draw_texture(_textures.get("blood"), Vector2.ZERO, Vector2(scale_value, scale_value), Color(1.0, 0.58, 0.34, alpha * 0.58), _age * 9.0)
	_draw_texture(_textures.get("spark"), direction * 32.0, Vector2(0.72, 0.72), Color(1.0, 0.76, 0.36, alpha * 0.76), direction.angle())
	draw_colored_polygon(_burst(42.0 + (1.0 - alpha) * 24.0, 12), Color(1.0, 0.70, 0.34, alpha * 0.25))


func _draw_collect(alpha: float) -> void:
	var angle := direction.angle()
	for offset in [-0.34, 0.34]:
		var cut_dir := Vector2.RIGHT.rotated(angle + offset)
		_draw_blade_cut(cut_dir, 88.0, 18.0, Color(0.10, 0.03, 0.01, alpha * 0.30))
		_draw_blade_cut(cut_dir, 76.0, 8.0, Color(1.0, 0.52, 0.16, alpha * 0.78))
		_draw_blade_cut(cut_dir, 58.0, 4.0, Color(1.0, 0.92, 0.64, alpha * 0.45))
	draw_colored_polygon(_burst(74.0 + (1.0 - alpha) * 28.0, 16), Color(1.0, 0.26, 0.08, alpha * 0.28))
	_draw_texture(_textures.get("flame"), Vector2.ZERO, Vector2(1.15, 1.15), Color(1.0, 0.35, 0.12, alpha * 0.46), _age * 8.0)


func _draw_ring(alpha: float, texture: Texture2D, scale_value: float, tint: Color) -> void:
	_draw_texture(texture, Vector2.ZERO, Vector2(scale_value + (1.0 - alpha) * 0.45, scale_value + (1.0 - alpha) * 0.45), tint, _age * 5.0)
	draw_colored_polygon(_burst(58.0 + (1.0 - alpha) * 24.0, 14), Color(tint.r, tint.g, tint.b, tint.a * 0.24))


func _draw_death(alpha: float) -> void:
	for i in 7:
		var angle := float(i) * TAU / 7.0 + _age * 1.8
		var pos := Vector2.RIGHT.rotated(angle) * (18.0 + float(i % 3) * 18.0)
		_draw_texture(_textures.get("smoke"), pos, Vector2(0.70, 0.70), Color(0.58, 0.50, 0.42, alpha * 0.55), angle)


func _draw_texture(texture: Texture2D, center: Vector2, scale_value: Vector2, tint: Color, rotation_value: float = 0.0) -> void:
	if texture == null:
		return
	var size := texture.get_size() * scale_value
	draw_set_transform(center, rotation_value, Vector2.ONE)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
		image.fill(Color(1.0, 0.0, 1.0, 1.0))
	return ImageTexture.create_from_image(image)


func _with_alpha(source: Color, alpha: float) -> Color:
	return Color(source.r, source.g, source.b, alpha)


func _draw_blade_cut(dir: Vector2, length: float, width: float, tint: Color) -> void:
	var side := dir.orthogonal()
	draw_colored_polygon(PackedVector2Array([
		-dir * length + side * width * 0.35,
		dir * length + side * width,
		dir * (length + width * 0.45),
		dir * length - side * width,
		-dir * length - side * width * 0.35,
	]), tint)


func _burst(radius: float, points_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in points_count:
		var angle := TAU * float(i) / float(points_count) + _age * 0.8
		var wobble := 0.58 if i % 2 == 0 else 1.0
		points.append(Vector2.RIGHT.rotated(angle) * radius * wobble)
	return points
