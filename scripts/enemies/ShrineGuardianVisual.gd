extends Node2D

const SPRITE_PATHS := {
	"guardian": {
		"idle": "res://assets/sprites/kenney/melee_idle.png",
		"run_1": "res://assets/sprites/kenney/melee_run_1.png",
		"run_2": "res://assets/sprites/kenney/melee_run_2.png",
		"attack": "res://assets/sprites/kenney/melee_attack.png",
		"hurt": "res://assets/sprites/kenney/melee_hurt.png",
		"death": "res://assets/sprites/kenney/melee_death.png",
	},
	"hound": {
		"idle": "res://assets/sprites/kenney/hound_idle.png",
		"run_1": "res://assets/sprites/kenney/hound_run_1.png",
		"run_2": "res://assets/sprites/kenney/hound_run_2.png",
		"attack": "res://assets/sprites/kenney/hound_attack.png",
		"hurt": "res://assets/sprites/kenney/hound_hurt.png",
		"death": "res://assets/sprites/kenney/hound_death.png",
	},
	"archer": {
		"idle": "res://assets/sprites/kenney/archer_idle.png",
		"run_1": "res://assets/sprites/kenney/archer_run_1.png",
		"run_2": "res://assets/sprites/kenney/archer_run_2.png",
		"attack": "res://assets/sprites/kenney/archer_attack.png",
		"hurt": "res://assets/sprites/kenney/archer_hurt.png",
		"death": "res://assets/sprites/kenney/archer_death.png",
	},
	"bell_bearer": {
		"idle": "res://assets/sprites/kenney/elite_idle.png",
		"run_1": "res://assets/sprites/kenney/elite_run_1.png",
		"run_2": "res://assets/sprites/kenney/elite_run_2.png",
		"attack": "res://assets/sprites/kenney/elite_attack.png",
		"hurt": "res://assets/sprites/kenney/elite_hurt.png",
		"death": "res://assets/sprites/kenney/elite_death.png",
	},
}

const EFFECT_PATHS := {
	"slash": "res://assets/effects/kenney/slash_03.png",
	"star": "res://assets/effects/kenney/star_06.png",
	"smoke": "res://assets/effects/kenney/smoke_08.png",
}

var facing := Vector2.LEFT
var state_name := "idle"
var health_ratio := 1.0
var enemy_kind := "guardian"
var ash_branded := false
var collect_ready := false
var flash := 0.0

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


func set_pose(new_facing: Vector2, new_state: String, new_health_ratio: float, new_kind: String = "guardian", new_branded: bool = false, new_collect_ready: bool = false) -> void:
	if new_facing.length() > 0.01:
		facing = new_facing.normalized()
	state_name = new_state
	health_ratio = clampf(new_health_ratio, 0.0, 1.0)
	enemy_kind = new_kind
	ash_branded = new_branded
	collect_ready = new_collect_ready


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
	draw_set_transform(Vector2(0, bob), 0.0, Vector2(flip, 1.0))
	_draw_texture_centered(sprite, Vector2.ZERO, _sprite_scale(), tint)
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
		return Vector2(1.08, 1.08)
	if enemy_kind == "bell_bearer":
		return Vector2(1.22, 1.22)
	return Vector2(1.10, 1.10)


func _bob_offset() -> float:
	if state_name == "chase" or state_name == "patrol":
		return sin(_time * 13.0) * (3.0 if enemy_kind != "bell_bearer" else 2.0)
	if state_name == "stagger":
		return sin(_time * 40.0) * 3.0
	if state_name == "windup":
		return -3.0
	return sin(_time * 4.0) * 1.5


func _draw_shadow() -> void:
	var width := 44.0
	var y := 37.0
	if enemy_kind == "hound":
		width = 52.0
		y = 32.0
	elif enemy_kind == "bell_bearer":
		width = 60.0
		y = 42.0
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
	var radius := 92.0 if enemy_kind != "bell_bearer" else 132.0
	draw_arc(Vector2.ZERO, radius, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.92, 0.20, 0.12, 0.50), 7.0)
	draw_arc(Vector2.ZERO, radius + 8.0, dir_angle - 0.72, dir_angle + 0.72, 30, Color(0.95, 0.70, 0.25, 0.25), 3.0)


func _draw_swing() -> void:
	var scale := Vector2(1.65, 1.0) if enemy_kind != "bell_bearer" else Vector2(2.25, 1.25)
	draw_set_transform(facing * (78.0 if enemy_kind != "bell_bearer" else 108.0), facing.angle(), scale)
	_draw_texture_centered(_effects.get("slash"), Vector2.ZERO, Vector2.ONE, Color(1.0, 0.54, 0.25, 0.62))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_stagger_flash() -> void:
	for i in 3:
		var angle := _time * 5.0 + float(i) * TAU / 3.0
		_draw_texture(_effects.get("star"), Vector2.RIGHT.rotated(angle) * 42.0, Vector2(0.42, 0.42), Color(1.0, 0.76, 0.36, 0.75), angle)


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
