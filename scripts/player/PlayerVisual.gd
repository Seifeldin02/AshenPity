extends Node2D

const SPRITE_PATHS := {
	"idle": "res://assets/sprites/upgrade/player_idle.png",
	"idle_2": "res://assets/sprites/upgrade/player_idle_2.png",
	"run_1": "res://assets/sprites/upgrade/player_run_1.png",
	"run_2": "res://assets/sprites/upgrade/player_run_2.png",
	"run_3": "res://assets/sprites/upgrade/player_run_3.png",
	"run_4": "res://assets/sprites/upgrade/player_run_4.png",
	"attack": "res://assets/sprites/upgrade/player_light_1.png",
	"light_1": "res://assets/sprites/upgrade/player_light_1.png",
	"light_2": "res://assets/sprites/upgrade/player_light_2.png",
	"light_3": "res://assets/sprites/upgrade/player_light_3.png",
	"heavy": "res://assets/sprites/upgrade/player_heavy.png",
	"collect": "res://assets/sprites/upgrade/player_collect.png",
	"dodge": "res://assets/sprites/upgrade/player_dodge.png",
	"parry": "res://assets/sprites/upgrade/player_parry.png",
	"heal": "res://assets/sprites/upgrade/player_heal.png",
	"hurt": "res://assets/sprites/upgrade/player_hurt.png",
	"dead": "res://assets/sprites/upgrade/player_death.png",
	"weapon": "res://assets/sprites/upgrade/player_weapon.png",
}

const BODY_SCALE := Vector2.ONE
const SPRITE_OFFSET := Vector2(0, -22)

var facing := Vector2.RIGHT
var state_name := "idle"
var flash := 0.0
var attack_alpha := 0.0
var attack_name := ""

var _time := 0.0
var _state_time := 0.0
var _sprites := {}

func _ready() -> void:
	for key in SPRITE_PATHS:
		_sprites[key] = _load_texture(str(SPRITE_PATHS[key]))


func _process(delta: float) -> void:
	_time += delta
	_state_time += delta
	flash = maxf(flash - delta * 7.5, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_attack_alpha: float, new_attack_name: String = "") -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	if state_name != new_state:
		_state_time = 0.0
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
	draw_colored_polygon(_ellipse(Vector2(0, 23), 28.0, 7.0), Color(0.02, 0.018, 0.022, 0.38))
	if state_name == "dodge":
		_draw_dodge_afterimages(flip, tint)
	if attack_alpha > 0.0:
		_draw_slash()
	if state_name == "parry":
		_draw_parry_guard()
	var body_rotation := _body_rotation(flip)
	var body_scale := _body_scale()
	draw_set_transform(Vector2(0, bob), body_rotation, Vector2(flip * body_scale.x, body_scale.y))
	_draw_texture_centered(frame, SPRITE_OFFSET, BODY_SCALE, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _select_frame() -> Texture2D:
	if state_name == "dead":
		return _sprites["dead"]
	if state_name == "hurt":
		return _sprites["hurt"]
	if state_name == "parry" or state_name == "parry_recovery":
		return _sprites["parry"]
	if state_name == "heal":
		return _sprites["heal"]
	if state_name == "dodge":
		return _sprites["dodge"]
	if state_name.begins_with("light") or state_name.begins_with("heavy") or state_name.begins_with("collect"):
		return _attack_frame()
	if state_name == "move":
		return _run_frame()
	return _sprites["idle"] if int(_time * 2.0) % 2 == 0 else _sprites["idle_2"]


func _run_frame() -> Texture2D:
	var frames := [_sprites["run_1"], _sprites["run_2"], _sprites["run_3"], _sprites["run_4"]]
	return frames[int(_state_time * 14.0) % frames.size()]


func _attack_frame() -> Texture2D:
	if state_name.begins_with("collect"):
		return _sprites["collect"]
	if attack_name == "heavy" or state_name.begins_with("heavy"):
		return _sprites["heavy"]
	if attack_name == "light_2" or state_name.begins_with("light_2"):
		return _sprites["light_2"]
	if attack_name == "light_3" or state_name.begins_with("light_3"):
		return _sprites["light_3"]
	return _sprites["light_1"]


func _bob_offset() -> float:
	if state_name == "move":
		return sin(_time * 14.0) * 0.7
	if state_name == "dodge":
		return -0.8
	if state_name.begins_with("collect"):
		return -1.0
	return sin(_time * 4.2) * 0.45


func _body_rotation(flip: float) -> float:
	if state_name == "move":
		return sin(_time * 14.0) * 0.018 * flip
	if state_name.ends_with("_windup"):
		return -0.055 * flip
	if state_name.ends_with("_active"):
		return 0.045 * flip
	if state_name.begins_with("collect"):
		return 0.060 * flip
	if state_name == "hurt":
		return sin(_time * 32.0) * 0.035
	return 0.0


func _body_scale() -> Vector2:
	if state_name == "move":
		return Vector2(1.0 + abs(sin(_time * 14.0)) * 0.010, 1.0 - abs(sin(_time * 14.0)) * 0.008)
	if state_name == "dodge":
		return Vector2(1.06, 0.94)
	if state_name.ends_with("_windup"):
		return Vector2(0.98, 1.02)
	if state_name.ends_with("_active"):
		return Vector2(1.04, 0.98)
	if state_name.begins_with("collect"):
		return Vector2(1.07, 0.97)
	return Vector2.ONE


func _draw_slash() -> void:
	var alpha := clampf(attack_alpha, 0.0, 1.0)
	var radius := 70.0
	var spread := 0.86
	var reach := 64.0
	var color := Color(1.0, 0.76, 0.34, 0.74 * alpha)
	var core := Color(1.0, 0.96, 0.74, 0.55 * alpha)
	if attack_name == "light_2":
		radius = 82.0
		spread = 0.98
	elif attack_name == "light_3":
		radius = 92.0
		spread = 1.12
		reach = 74.0
	elif attack_name == "heavy":
		radius = 106.0
		spread = 0.94
		reach = 84.0
		color = Color(1.0, 0.50, 0.20, 0.78 * alpha)
	elif attack_name == "collect":
		radius = 128.0
		spread = 0.58
		reach = 98.0
		color = Color(1.0, 0.34, 0.12, 0.84 * alpha)
	var center := facing * reach
	var angle := facing.angle()
	draw_colored_polygon(_crescent(center, radius + 12.0, radius * 0.58, angle - spread, angle + spread, 34), Color(0.07, 0.018, 0.006, 0.30 * alpha))
	draw_colored_polygon(_crescent(center, radius, radius * 0.72, angle - spread, angle + spread, 34), color)
	draw_colored_polygon(_crescent(center, radius * 0.84, radius * 0.70, angle - spread * 0.62, angle + spread * 0.62, 22), core)
	if attack_name == "heavy" or attack_name == "collect":
		_draw_blade_line(center, facing, radius, alpha)
	for i in 4:
		var a := lerpf(angle - spread, angle + spread, float(i) / 3.0)
		_draw_shard(center + Vector2.RIGHT.rotated(a) * (radius - 9.0), Vector2.RIGHT.rotated(a), alpha)


func _draw_parry_guard() -> void:
	var center := facing * 42.0
	var side := facing.orthogonal()
	var shield := PackedVector2Array([
		center + facing * 38.0,
		center + side * 34.0 + facing * 6.0,
		center + side * 18.0 - facing * 28.0,
		center - side * 18.0 - facing * 28.0,
		center - side * 34.0 + facing * 6.0,
	])
	draw_colored_polygon(shield, Color(0.95, 0.80, 0.42, 0.34))
	draw_colored_polygon(PackedVector2Array([shield[0], shield[1].lerp(shield[2], 0.35), center, shield[4].lerp(shield[3], 0.35)]), Color(0.96, 0.96, 0.82, 0.24))


func _draw_dodge_afterimages(flip: float, tint: Color) -> void:
	for i in 3:
		var offset := -facing * float(i + 1) * 22.0
		var alpha := 0.20 - float(i) * 0.045
		draw_set_transform(offset + Vector2(0, 3), 0.0, Vector2(flip, 1.0) * (1.0 - float(i) * 0.08))
		_draw_texture_centered(_sprites["dodge"], SPRITE_OFFSET, BODY_SCALE, Color(tint.r, tint.g, tint.b, alpha))
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


func _crescent(center: Vector2, outer_radius: float, inner_radius: float, start_angle: float, end_angle: float, steps: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		points.append(center + Vector2.RIGHT.rotated(lerpf(start_angle, end_angle, t)) * outer_radius)
	for i in range(steps, -1, -1):
		var t := float(i) / float(steps)
		points.append(center + Vector2.RIGHT.rotated(lerpf(start_angle, end_angle, t)) * inner_radius)
	return points


func _draw_shard(center: Vector2, dir: Vector2, alpha: float) -> void:
	var side := dir.orthogonal()
	draw_colored_polygon(PackedVector2Array([
		center + dir * 15.0,
		center - dir * 8.0 + side * 4.0,
		center - dir * 2.0,
		center - dir * 8.0 - side * 4.0,
	]), Color(1.0, 0.80, 0.45, 0.36 * alpha))


func _draw_blade_line(center: Vector2, dir: Vector2, radius: float, alpha: float) -> void:
	var side := dir.orthogonal()
	var start := center - dir * radius * 0.34
	var end := center + dir * radius * 0.92
	draw_colored_polygon(PackedVector2Array([
		start - side * 7.0,
		end - side * 2.0,
		end + dir * 16.0,
		end + side * 2.0,
		start + side * 7.0,
	]), Color(1.0, 0.90, 0.62, 0.34 * alpha))
