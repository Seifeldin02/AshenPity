extends Node2D

const SPRITE_PATHS := {
	"idle": "res://assets/sprites/kenney/player_idle.png",
	"run_1": "res://assets/sprites/kenney/player_run_1.png",
	"run_2": "res://assets/sprites/kenney/player_run_2.png",
	"attack": "res://assets/sprites/kenney/player_attack.png",
	"dodge": "res://assets/sprites/kenney/player_dodge.png",
	"hurt": "res://assets/sprites/kenney/player_hurt.png",
	"dead": "res://assets/sprites/kenney/player_death.png",
	"weapon": "res://assets/sprites/kenney/player_weapon.png",
}

const SLASH_PATHS := [
	"res://assets/effects/kenney/slash_01.png",
	"res://assets/effects/kenney/slash_02.png",
	"res://assets/effects/kenney/slash_03.png",
	"res://assets/effects/kenney/slash_04.png",
]

var facing := Vector2.RIGHT
var state_name := "idle"
var flash := 0.0
var attack_alpha := 0.0
var attack_name := ""

var _time := 0.0
var _sprites := {}
var _slashes: Array[Texture2D] = []

func _ready() -> void:
	for key in SPRITE_PATHS:
		_sprites[key] = _load_texture(str(SPRITE_PATHS[key]))
	for path in SLASH_PATHS:
		_slashes.append(_load_texture(path))


func _process(delta: float) -> void:
	_time += delta
	flash = maxf(flash - delta * 7.5, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_attack_alpha: float, new_attack_name: String = "") -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	attack_alpha = new_attack_alpha
	attack_name = new_attack_name


func trigger_flash() -> void:
	flash = 1.0


func _draw() -> void:
	var frame := _select_frame()
	var bob := _bob_offset()
	var flip := -1.0 if facing.x < -0.12 else 1.0
	var tint := Color.WHITE.lerp(Color(1.0, 0.34, 0.24), flash)
	draw_colored_polygon(_ellipse(Vector2(0, 35), 35.0, 11.0), Color(0.02, 0.018, 0.022, 0.62))
	if state_name == "dodge":
		_draw_dodge_afterimages(flip, tint)
	if attack_alpha > 0.0:
		_draw_slash()
	draw_set_transform(Vector2(0, bob), 0.0, Vector2(flip, 1.0))
	_draw_texture_centered(frame, Vector2.ZERO, Vector2(1.12, 1.12), tint)
	if state_name == "idle" or state_name == "move":
		_draw_texture_centered(_sprites["weapon"], Vector2(22, -8), Vector2(0.62, 0.62), Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _select_frame() -> Texture2D:
	if state_name == "dead":
		return _sprites["dead"]
	if state_name == "hurt":
		return _sprites["hurt"]
	if state_name == "dodge":
		return _sprites["dodge"]
	if state_name.begins_with("light") or state_name.begins_with("heavy") or state_name.begins_with("collect"):
		return _sprites["attack"]
	if state_name == "move":
		return _sprites["run_1"] if int(_time * 10.0) % 2 == 0 else _sprites["run_2"]
	return _sprites["idle"]


func _bob_offset() -> float:
	if state_name == "move":
		return sin(_time * 16.0) * 3.0
	if state_name == "dodge":
		return -5.0
	if state_name.begins_with("collect"):
		return -4.0
	return sin(_time * 5.0) * 1.5


func _draw_slash() -> void:
	if _slashes.is_empty():
		return
	var alpha := clampf(attack_alpha, 0.0, 1.0)
	var texture := _slashes[0]
	var scale := Vector2(1.55, 1.0)
	if attack_name == "light_2":
		texture = _slashes[1]
	elif attack_name == "light_3":
		texture = _slashes[2]
		scale = Vector2(1.85, 1.10)
	elif attack_name == "heavy":
		texture = _slashes[3]
		scale = Vector2(2.1, 1.25)
	elif attack_name == "collect":
		texture = _slashes[3]
		scale = Vector2(2.45, 1.40)
	draw_set_transform(facing * (70.0 if attack_name != "collect" else 88.0), facing.angle(), scale)
	_draw_texture_centered(texture, Vector2.ZERO, Vector2.ONE, Color(1.0, 0.82, 0.48, 0.78 * alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_dodge_afterimages(flip: float, tint: Color) -> void:
	for i in 3:
		var offset := -facing * float(i + 1) * 22.0
		var alpha := 0.20 - float(i) * 0.045
		draw_set_transform(offset + Vector2(0, 3), 0.0, Vector2(flip, 1.0) * (1.0 - float(i) * 0.08))
		_draw_texture_centered(_sprites["dodge"], Vector2.ZERO, Vector2(1.0, 1.0), Color(tint.r, tint.g, tint.b, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_texture_centered(texture: Texture2D, offset: Vector2, scale_value: Vector2, tint: Color) -> void:
	if texture == null:
		return
	var size := texture.get_size() * scale_value
	draw_texture_rect(texture, Rect2(offset - size * 0.5, size), false, tint)


func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
		image.fill(Color(1.0, 0.0, 1.0, 1.0))
	return ImageTexture.create_from_image(image)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
