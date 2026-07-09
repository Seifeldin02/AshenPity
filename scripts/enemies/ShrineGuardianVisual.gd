extends Node2D

const SPRITE_PATHS := {
	"guardian": {
		"idle": "res://assets/sprites/ashen_runtime/melee_idle.png",
		"run_1": "res://assets/sprites/ashen_runtime/melee_run_1.png",
		"run_2": "res://assets/sprites/ashen_runtime/melee_run_2.png",
		"attack": "res://assets/sprites/ashen_runtime/melee_attack.png",
		"hurt": "res://assets/sprites/ashen_runtime/melee_hurt.png",
		"death": "res://assets/sprites/ashen_runtime/melee_death.png",
	},
	"hound": {
		"idle": "res://assets/sprites/ashen_runtime/hound_idle.png",
		"run_1": "res://assets/sprites/ashen_runtime/hound_run_1.png",
		"run_2": "res://assets/sprites/ashen_runtime/hound_run_2.png",
		"attack": "res://assets/sprites/ashen_runtime/hound_attack.png",
		"hurt": "res://assets/sprites/ashen_runtime/hound_hurt.png",
		"death": "res://assets/sprites/ashen_runtime/hound_death.png",
	},
	"archer": {
		"idle": "res://assets/sprites/ashen_runtime/archer_idle.png",
		"run_1": "res://assets/sprites/ashen_runtime/archer_run_1.png",
		"run_2": "res://assets/sprites/ashen_runtime/archer_run_2.png",
		"attack": "res://assets/sprites/ashen_runtime/archer_attack.png",
		"hurt": "res://assets/sprites/ashen_runtime/archer_hurt.png",
		"death": "res://assets/sprites/ashen_runtime/archer_death.png",
	},
	"bell_bearer": {
		"idle": "res://assets/sprites/ashen_runtime/elite_idle.png",
		"run_1": "res://assets/sprites/ashen_runtime/elite_run_1.png",
		"run_2": "res://assets/sprites/ashen_runtime/elite_run_2.png",
		"attack": "res://assets/sprites/ashen_runtime/elite_attack.png",
		"hurt": "res://assets/sprites/ashen_runtime/elite_hurt.png",
		"death": "res://assets/sprites/ashen_runtime/elite_death.png",
	},
	"ashen_judicator": {
		"idle": "res://assets/sprites/ashen_runtime/judicator_idle.png",
		"run_1": "res://assets/sprites/ashen_runtime/judicator_run_1.png",
		"run_2": "res://assets/sprites/ashen_runtime/judicator_run_2.png",
		"attack": "res://assets/sprites/ashen_runtime/judicator_attack.png",
		"hurt": "res://assets/sprites/ashen_runtime/judicator_hurt.png",
		"death": "res://assets/sprites/ashen_runtime/judicator_death.png",
	},
}

const EFFECT_PATHS := {
	"spark": "res://assets/effects/upgrade/spark.png",
	"flame": "res://assets/effects/upgrade/flame.png",
	"smoke": "res://assets/effects/upgrade/smoke.png",
}

var facing := Vector2.LEFT
var state_name := "idle"
var health_ratio := 1.0
var enemy_kind := "guardian"
var ash_branded := false
var collect_ready := false
var flash := 0.0
var attack_pattern := "sweep"

var _time := 0.0
var _sprites := {}
var _effects := {}

func _ready() -> void:
	for kind in SPRITE_PATHS:
		_sprites[kind] = {}
		var set: Dictionary = SPRITE_PATHS[kind]
		for key in set:
			_sprites[kind][key] = _load_texture(str(set[key]))
	for key in EFFECT_PATHS:
		_effects[key] = _load_texture(str(EFFECT_PATHS[key]))


func _process(delta: float) -> void:
	_time += delta
	flash = maxf(flash - delta * 7.0, 0.0)
	queue_redraw()


func set_pose(new_facing: Vector2, new_state: String, new_health_ratio: float, new_kind: String = "guardian", new_branded: bool = false, new_collect_ready: bool = false, new_attack_pattern: String = "sweep") -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	health_ratio = clampf(new_health_ratio, 0.0, 1.0)
	enemy_kind = new_kind
	ash_branded = new_branded
	collect_ready = new_collect_ready
	attack_pattern = new_attack_pattern


func trigger_flash() -> void:
	flash = 1.0


func _draw() -> void:
	var sprite := _select_frame()
	var flip := -1.0 if facing.x < -0.1 else 1.0
	var bob := _bob_offset()
	var tint := Color.WHITE.lerp(Color(1.0, 0.30, 0.20), flash)
	_draw_shadow()
	if ash_branded:
		_draw_brand()
	if state_name == "windup":
		_draw_telegraph()
	var scale_value := _sprite_scale() * _body_scale()
	draw_set_transform(Vector2(0, bob), _body_rotation(flip), Vector2(flip * scale_value.x, scale_value.y))
	_draw_texture_centered(sprite, Vector2(0, -18), Vector2.ONE, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if state_name == "active":
		_draw_swing()
	elif state_name == "stagger":
		_draw_stagger_flash()
	elif state_name == "dying":
		_draw_death_smoke()


func _select_frame() -> Texture2D:
	var set: Dictionary = _sprites.get(enemy_kind, _sprites.get("guardian", {}))
	if set.is_empty():
		return null
	if state_name == "dying" or state_name == "dead":
		return set["death"]
	if state_name == "stagger":
		return set["hurt"]
	if state_name == "windup" or state_name == "active":
		return set["attack"]
	if state_name == "chase" or state_name == "patrol":
		return set["run_1"] if int(_time * 9.0) % 2 == 0 else set["run_2"]
	return set["idle"]


func _sprite_scale() -> Vector2:
	if enemy_kind == "hound":
		return Vector2(0.58, 0.58)
	if enemy_kind == "bell_bearer":
		return Vector2(0.66, 0.66)
	if enemy_kind == "ashen_judicator":
		return Vector2(0.76, 0.76)
	return Vector2(0.60, 0.60)


func _bob_offset() -> float:
	if state_name == "chase" or state_name == "patrol":
		var pace := 18.0 if enemy_kind == "hound" else 12.0
		return sin(_time * pace) * (3.0 if enemy_kind != "bell_bearer" else 2.0)
	if state_name == "stagger":
		return sin(_time * 40.0) * 3.0
	if state_name == "windup":
		return -3.0
	return sin(_time * 4.0) * 1.5


func _body_rotation(flip: float) -> float:
	if state_name == "chase" or state_name == "patrol":
		var pace := 18.0 if enemy_kind == "hound" else 12.0
		return sin(_time * pace) * (0.040 if enemy_kind == "hound" else 0.024) * flip
	if state_name == "windup":
		return -0.10 * flip
	if state_name == "active":
		return 0.12 * flip
	if state_name == "stagger":
		return sin(_time * 42.0) * 0.09
	return 0.0


func _body_scale() -> Vector2:
	if state_name == "chase" or state_name == "patrol":
		var stride: float = abs(sin(_time * (18.0 if enemy_kind == "hound" else 12.0)))
		return Vector2(1.0 + stride * 0.025, 1.0 - stride * 0.020)
	if state_name == "windup":
		return Vector2(0.96, 1.06)
	if state_name == "active":
		return Vector2(1.08, 0.95)
	if state_name == "stagger":
		return Vector2(1.05, 0.96)
	return Vector2.ONE


func _draw_shadow() -> void:
	var width := 44.0
	var y := 37.0
	if enemy_kind == "hound":
		width = 52.0
		y = 32.0
	elif enemy_kind == "bell_bearer":
		width = 60.0
		y = 42.0
	elif enemy_kind == "ashen_judicator":
		width = 76.0
		y = 46.0
	draw_colored_polygon(_ellipse(Vector2(0, y), width, 11.0), Color(0.02, 0.018, 0.02, 0.66))


func _draw_brand() -> void:
	var pulse := 0.55 + sin(_time * 9.0) * 0.16
	var ring_color := Color(1.0, 0.32, 0.12, 0.60 + pulse * 0.20)
	if collect_ready:
		ring_color = Color(1.0, 0.78, 0.30, 0.86)
	draw_arc(Vector2.ZERO, 54.0 + pulse * 8.0, 0.0, TAU, 48, ring_color, 5.0)
	for i in 6:
		var angle := _time * 1.8 + float(i) * TAU / 6.0
		_draw_texture(_effects.get("smoke"), Vector2.RIGHT.rotated(angle) * (43.0 + pulse * 7.0), Vector2(0.34, 0.34), ring_color, 0.0)


func _draw_telegraph() -> void:
	var dir_angle := facing.angle()
	if enemy_kind == "ashen_judicator":
		match attack_pattern:
			"lunge":
				var end := facing * 210.0
				draw_line(Vector2.ZERO, end, Color(1.0, 0.22, 0.12, 0.48), 18.0)
				draw_line(Vector2.ZERO, end, Color(1.0, 0.72, 0.30, 0.28), 7.0)
			"slam":
				draw_arc(Vector2.ZERO, 128.0, 0.0, TAU, 52, Color(1.0, 0.24, 0.12, 0.48), 8.0)
				draw_arc(Vector2.ZERO, 82.0, 0.0, TAU, 44, Color(1.0, 0.68, 0.24, 0.22), 4.0)
			"toll":
				for i in 3:
					draw_arc(Vector2.ZERO, 78.0 + float(i) * 34.0, 0.0, TAU, 54, Color(0.96, 0.66, 0.24, 0.20 + float(i) * 0.06), 5.0)
			_:
				draw_arc(Vector2.ZERO, 142.0, dir_angle - 0.88, dir_angle + 0.88, 34, Color(0.92, 0.20, 0.12, 0.50), 8.0)
		return
	var radius := 92.0 if enemy_kind != "bell_bearer" else 132.0
	if attack_pattern == "fan":
		for offset in [-0.22, 0.0, 0.22]:
			draw_line(Vector2.ZERO, facing.rotated(offset) * 500.0, Color(0.92, 0.20, 0.12, 0.36), 7.0)
		return
	if attack_pattern == "shield_bash":
		draw_arc(Vector2.ZERO, 82.0, dir_angle - 0.45, dir_angle + 0.45, 24, Color(0.92, 0.20, 0.12, 0.50), 11.0)
		draw_line(facing.rotated(-PI * 0.5) * 44.0 + facing * 55.0, facing.rotated(PI * 0.5) * 44.0 + facing * 55.0, Color(0.95, 0.70, 0.25, 0.25), 6.0)
		return
	if attack_pattern == "thrust" or attack_pattern == "shot" or attack_pattern == "pounce" or attack_pattern == "snap":
		var reach := 142.0 if attack_pattern != "shot" else 520.0
		if attack_pattern == "snap":
			reach = 80.0
		var width := 9.0 if attack_pattern != "pounce" else 16.0
		draw_line(Vector2.ZERO, facing * reach, Color(0.92, 0.20, 0.12, 0.46), width)
		draw_line(Vector2.ZERO, facing * reach, Color(0.95, 0.70, 0.25, 0.24), maxf(width * 0.38, 3.0))
		return
	if attack_pattern == "bell_slam":
		draw_arc(Vector2.ZERO, 118.0, 0.0, TAU, 52, Color(0.92, 0.20, 0.12, 0.48), 8.0)
		draw_arc(Vector2.ZERO, 72.0, 0.0, TAU, 44, Color(0.95, 0.70, 0.25, 0.24), 4.0)
		return
	draw_arc(Vector2.ZERO, radius, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.92, 0.20, 0.12, 0.50), 7.0)
	draw_arc(Vector2.ZERO, radius + 8.0, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.95, 0.70, 0.25, 0.25), 3.0)


func _draw_swing() -> void:
	var radius := 92.0 if enemy_kind != "bell_bearer" else 126.0
	var reach := 68.0 if enemy_kind != "bell_bearer" else 98.0
	var spread := 0.72 if enemy_kind != "bell_bearer" else 0.92
	if attack_pattern == "fan":
		for offset in [-0.22, 0.0, 0.22]:
			draw_line(Vector2.ZERO, facing.rotated(offset) * 170.0, Color(1.0, 0.68, 0.24, 0.34), 4.0)
		return
	if attack_pattern == "shield_bash":
		draw_arc(Vector2.ZERO, 86.0, facing.angle() - 0.48, facing.angle() + 0.48, 28, Color(1.0, 0.45, 0.18, 0.48), 13.0)
		return
	if attack_pattern == "thrust" or attack_pattern == "pounce" or attack_pattern == "snap":
		var thrust_reach := 126.0 if attack_pattern == "thrust" else 102.0
		if attack_pattern == "snap":
			thrust_reach = 78.0
		var line_width := 10.0 if attack_pattern == "thrust" else 18.0
		draw_line(facing * 18.0, facing * thrust_reach, Color(0.05, 0.025, 0.018, 0.36), line_width + 6.0)
		draw_line(facing * 22.0, facing * thrust_reach, Color(1.0, 0.44, 0.16, 0.54), line_width)
		draw_line(facing * 42.0, facing * (thrust_reach - 12.0), Color(1.0, 0.78, 0.34, 0.30), maxf(line_width * 0.35, 3.0))
		return
	if attack_pattern == "shot":
		draw_line(Vector2.ZERO, facing * 160.0, Color(1.0, 0.68, 0.24, 0.40), 5.0)
		return
	if attack_pattern == "bell_slam":
		draw_arc(Vector2.ZERO, 130.0, 0.0, TAU, 58, Color(1.0, 0.40, 0.16, 0.44), 13.0)
		draw_arc(Vector2.ZERO, 82.0, 0.0, TAU, 44, Color(0.22, 0.08, 0.05, 0.42), 8.0)
		return
	if enemy_kind == "ashen_judicator":
		if attack_pattern == "slam":
			draw_arc(Vector2.ZERO, 132.0, 0.0, TAU, 60, Color(1.0, 0.40, 0.16, 0.46), 14.0)
			draw_arc(Vector2.ZERO, 88.0, 0.0, TAU, 54, Color(0.22, 0.08, 0.05, 0.52), 8.0)
			return
		if attack_pattern == "lunge":
			reach = 105.0
			radius = 90.0
			spread = 0.42
		elif attack_pattern == "toll":
			draw_arc(Vector2.ZERO, 142.0, 0.0, TAU, 60, Color(0.95, 0.70, 0.22, 0.34), 8.0)
			return
		else:
			reach = 92.0
			radius = 118.0
			spread = 0.96
	var center := facing * reach
	var angle := facing.angle()
	draw_arc(center, radius, angle - spread, angle + spread, 30, Color(0.05, 0.025, 0.018, 0.34), 13.0)
	draw_arc(center, radius, angle - spread, angle + spread, 30, Color(1.0, 0.42, 0.18, 0.54), 7.0)
	draw_arc(center, radius - 11.0, angle - spread * 0.66, angle + spread * 0.66, 22, Color(1.0, 0.72, 0.28, 0.30), 3.0)


func _draw_stagger_flash() -> void:
	for i in 3:
		var angle := _time * 5.0 + float(i) * TAU / 3.0
		_draw_texture(_effects.get("spark"), Vector2.RIGHT.rotated(angle) * 42.0, Vector2(0.42, 0.42), Color(1.0, 0.76, 0.36, 0.75), angle)


func _draw_death_smoke() -> void:
	for i in 5:
		var angle := float(i) * TAU / 5.0 + _time
		_draw_texture(_effects.get("smoke"), Vector2.RIGHT.rotated(angle) * (18.0 + float(i) * 8.0), Vector2(0.52, 0.52), Color(0.64, 0.56, 0.48, 0.42), angle)


func _draw_texture_centered(texture: Texture2D, offset: Vector2, scale_value: Vector2, tint: Color) -> void:
	if texture == null:
		return
	var size := texture.get_size() * scale_value
	draw_texture_rect(texture, Rect2(offset - size * 0.5, size), false, tint)


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


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
