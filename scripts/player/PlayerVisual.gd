extends Node2D

const SPRITE_PATHS := {
	"idle": "res://assets/sprites/upgrade/player_idle.png",
	"run_1": "res://assets/sprites/upgrade/player_run_1.png",
	"run_2": "res://assets/sprites/upgrade/player_run_2.png",
	"attack": "res://assets/sprites/upgrade/player_attack.png",
	"dodge": "res://assets/sprites/upgrade/player_dodge.png",
	"hurt": "res://assets/sprites/upgrade/player_hurt.png",
	"dead": "res://assets/sprites/upgrade/player_death.png",
	"weapon": "res://assets/sprites/upgrade/player_weapon.png",
}

var facing := Vector2.RIGHT
var state_name := "idle"
var flash := 0.0
var attack_alpha := 0.0
var attack_name := ""

var _time := 0.0
var _sprites := {}

func _ready() -> void:
	for key in SPRITE_PATHS:
		_sprites[key] = _load_texture(str(SPRITE_PATHS[key]))


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
	if state_name == "parry":
		_draw_parry_guard()
	var body_rotation := _body_rotation(flip)
	var body_scale := _body_scale()
	draw_set_transform(Vector2(0, bob), body_rotation, Vector2(flip * body_scale.x, body_scale.y))
	_draw_texture_centered(frame, Vector2.ZERO, Vector2.ONE, tint)
	if state_name == "idle" or state_name == "move":
		_draw_texture_centered(_sprites["weapon"], Vector2(28, -10), Vector2(0.58, 0.58), Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _select_frame() -> Texture2D:
	if state_name == "dead":
		return _sprites["dead"]
	if state_name == "hurt":
		return _sprites["hurt"]
	if state_name == "parry" or state_name == "parry_recovery":
		return _sprites["attack"]
	if state_name == "dodge":
		return _sprites["dodge"]
	if state_name.begins_with("light") or state_name.begins_with("heavy") or state_name.begins_with("collect"):
		return _sprites["attack"]
	if state_name == "move":
		return _sprites["run_1"] if int(_time * 10.0) % 2 == 0 else _sprites["run_2"]
	return _sprites["idle"]


func _bob_offset() -> float:
	if state_name == "move":
		return sin(_time * 18.0) * 3.2
	if state_name == "dodge":
		return -5.0
	if state_name.begins_with("collect"):
		return -4.0
	return sin(_time * 5.0) * 1.5


func _body_rotation(flip: float) -> float:
	if state_name == "move":
		return sin(_time * 18.0) * 0.035 * flip
	if state_name.ends_with("_windup"):
		return -0.10 * flip
	if state_name.ends_with("_active"):
		return 0.08 * flip
	if state_name.begins_with("collect"):
		return 0.11 * flip
	if state_name == "hurt":
		return sin(_time * 46.0) * 0.06
	return 0.0


func _body_scale() -> Vector2:
	if state_name == "move":
		return Vector2(1.0 + abs(sin(_time * 18.0)) * 0.025, 1.0 - abs(sin(_time * 18.0)) * 0.018)
	if state_name == "dodge":
		return Vector2(1.12, 0.88)
	if state_name.ends_with("_windup"):
		return Vector2(0.96, 1.05)
	if state_name.ends_with("_active"):
		return Vector2(1.08, 0.96)
	if state_name.begins_with("collect"):
		return Vector2(1.13, 0.94)
	return Vector2.ONE


func _draw_slash() -> void:
	var alpha := clampf(attack_alpha, 0.0, 1.0)
	var radius := 70.0
	var width := 8.0
	var spread := 0.86
	var reach := 64.0
	var color := Color(1.0, 0.76, 0.34, 0.74 * alpha)
	var core := Color(1.0, 0.96, 0.74, 0.55 * alpha)
	if attack_name == "light_2":
		radius = 82.0
		spread = 0.98
	elif attack_name == "light_3":
		radius = 92.0
		width = 9.0
		spread = 1.12
		reach = 74.0
	elif attack_name == "heavy":
		radius = 106.0
		width = 12.0
		spread = 0.94
		reach = 84.0
		color = Color(1.0, 0.50, 0.20, 0.78 * alpha)
	elif attack_name == "collect":
		radius = 128.0
		width = 13.0
		spread = 0.58
		reach = 98.0
		color = Color(1.0, 0.34, 0.12, 0.84 * alpha)
	var center := facing * reach
	var angle := facing.angle()
	draw_arc(center, radius, angle - spread, angle + spread, 34, Color(0.12, 0.08, 0.04, 0.20 * alpha), width + 6.0)
	draw_arc(center, radius, angle - spread, angle + spread, 34, color, width)
	draw_arc(center, radius - 13.0, angle - spread * 0.72, angle + spread * 0.72, 24, core, maxf(width - 4.0, 2.0))
	for i in 4:
		var t := float(i) / 3.0
		var a := lerpf(angle - spread, angle + spread, t)
		var p := center + Vector2.RIGHT.rotated(a) * (radius - 8.0)
		draw_line(p - facing * 13.0, p + facing * 16.0, Color(1.0, 0.80, 0.45, 0.36 * alpha), 2.0)


func _draw_parry_guard() -> void:
	var center := facing * 42.0
	var angle := facing.angle()
	draw_arc(center, 52.0, angle - 0.72, angle + 0.72, 24, Color(0.95, 0.80, 0.42, 0.62), 5.0)
	draw_arc(center, 36.0, angle - 0.52, angle + 0.52, 18, Color(0.96, 0.96, 0.82, 0.34), 3.0)


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
