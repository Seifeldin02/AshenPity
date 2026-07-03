extends Node2D

const PLAYER_SCENE_PATH := "res://scenes/player/Player.tscn"
const GUARDIAN_SCENE_PATH := "res://scenes/enemies/ShrineGuardian.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/HUD.tscn"
const MOBILE_SCENE_PATH := "res://scenes/ui/MobileControls.tscn"
const PROP_SCRIPT := preload("res://scripts/world/ShrineProp.gd")

@onready var prop_sort: Node2D = %PropSort
@onready var actor_sort: Node2D = %ActorSort
@onready var camera: Camera2D = %ArenaCamera

var player: Node2D
var guardians: Array[Node] = []
var _cracks: Array[PackedVector2Array] = []
var _ash: Array[Vector2] = []
var _rng := RandomNumberGenerator.new()
var _debug_visible := false
var _debug_label: Label
var _hud: CanvasLayer
var _mobile_controls: CanvasLayer
var _screen_shake := 0.0
var _shake_offset := Vector2.ZERO

func _ready() -> void:
	_rng.seed = 1312
	y_sort_enabled = true
	_build_collision()
	_build_floor_marks()
	_build_props()
	_spawn_combatants()
	_spawn_ui()
	camera.position = Vector2.ZERO
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		_debug_visible = not _debug_visible
		if is_instance_valid(_debug_label):
			_debug_label.visible = _debug_visible
	if event.is_action_pressed("pause") or InputRouter.consume_pause():
		_toggle_pause()


func _process(delta: float) -> void:
	if _screen_shake > 0.0:
		_screen_shake = maxf(_screen_shake - delta, 0.0)
		_shake_offset = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * 9.0 * _screen_shake
	else:
		_shake_offset = Vector2.ZERO
	camera.offset = _shake_offset
	if is_instance_valid(player):
		camera.global_position = camera.global_position.lerp(player.global_position, minf(delta * 4.0, 1.0))
	if _debug_visible and is_instance_valid(_debug_label):
		_update_debug_text()


func _draw() -> void:
	var half := GameBalance.ARENA_HALF_SIZE
	draw_rect(Rect2(-half - Vector2(140, 110), half * 2.0 + Vector2(280, 220)), Color("#111018"))
	for y in range(-384, 385, 96):
		for x in range(-768, 769, 96):
			var shade := 0.12 + (0.025 if ((x / 96 + y / 96) % 2 == 0) else 0.0)
			draw_rect(Rect2(x, y, 96, 96), Color(shade, shade * 0.95, shade * 0.90, 1.0))
			draw_rect(Rect2(x + 2, y + 2, 92, 92), Color(0.02, 0.018, 0.021, 0.16), false, 2.0)
	for crack in _cracks:
		draw_polyline(crack, Color(0.025, 0.022, 0.025, 0.72), 3.0)
		draw_polyline(crack, Color(0.46, 0.42, 0.36, 0.10), 1.0)
	for point in _ash:
		draw_circle(point, _rng.randf_range(1.0, 2.3), Color(0.78, 0.72, 0.64, 0.14))
	_draw_walls()
	_draw_light_pool(Vector2(-615, -210), 210.0)
	_draw_light_pool(Vector2(620, -214), 210.0)
	_draw_light_pool(Vector2(-610, 238), 180.0)
	_draw_light_pool(Vector2(615, 238), 180.0)


func _draw_walls() -> void:
	var half := GameBalance.ARENA_HALF_SIZE
	var wall_color := Color("#242129")
	var wall_lit := Color("#39333a")
	draw_rect(Rect2(-half.x - 86.0, -half.y - 86.0, half.x * 2.0 + 172.0, 98.0), wall_color)
	draw_rect(Rect2(-half.x - 86.0, half.y - 12.0, half.x * 2.0 + 172.0, 98.0), wall_color)
	draw_rect(Rect2(-half.x - 86.0, -half.y - 86.0, 98.0, half.y * 2.0 + 172.0), wall_color)
	draw_rect(Rect2(half.x - 12.0, -half.y - 86.0, 98.0, half.y * 2.0 + 172.0), wall_color)
	draw_line(Vector2(-half.x - 60, -half.y - 10), Vector2(half.x + 60, -half.y - 10), wall_lit, 6.0)
	draw_line(Vector2(-half.x - 60, half.y + 8), Vector2(half.x + 60, half.y + 8), Color(0.03, 0.025, 0.026, 0.9), 8.0)
	for i in 13:
		var x := -half.x + i * 126.0
		draw_rect(Rect2(x, -half.y - 68.0, 58.0, 70.0), Color("#302c34"))
		draw_rect(Rect2(x + 7.0, half.y + 2.0, 58.0, 60.0), Color("#1b1920"))


func _draw_light_pool(center: Vector2, radius: float) -> void:
	for i in 7:
		var t := float(i) / 7.0
		draw_circle(center, radius * (1.0 - t * 0.12), Color(0.98, 0.48, 0.18, 0.025 * (1.0 - t)))


func _build_floor_marks() -> void:
	for i in 34:
		var origin := Vector2(_rng.randf_range(-690.0, 690.0), _rng.randf_range(-320.0, 320.0))
		var crack := PackedVector2Array()
		crack.append(origin)
		var direction := Vector2.RIGHT.rotated(_rng.randf_range(-PI, PI))
		for s in range(1, _rng.randi_range(3, 6)):
			crack.append(origin + direction * float(s) * _rng.randf_range(16.0, 34.0) + Vector2(_rng.randf_range(-9, 9), _rng.randf_range(-9, 9)))
		_cracks.append(crack)
	for i in 220:
		_ash.append(Vector2(_rng.randf_range(-760.0, 760.0), _rng.randf_range(-390.0, 390.0)))


func _build_collision() -> void:
	var half := GameBalance.ARENA_HALF_SIZE
	_add_box_collision("NorthWall", Vector2(0, -half.y - 58.0), Vector2(half.x * 2.0 + 180.0, 110.0))
	_add_box_collision("SouthWall", Vector2(0, half.y + 58.0), Vector2(half.x * 2.0 + 180.0, 110.0))
	_add_box_collision("WestWall", Vector2(-half.x - 58.0, 0), Vector2(110.0, half.y * 2.0 + 180.0))
	_add_box_collision("EastWall", Vector2(half.x + 58.0, 0), Vector2(110.0, half.y * 2.0 + 180.0))
	for item in [
		["PillarCollisionA", Vector2(-385, -120), Vector2(64, 88)],
		["PillarCollisionB", Vector2(350, -90), Vector2(64, 88)],
		["PillarCollisionC", Vector2(-290, 210), Vector2(64, 88)],
		["PillarCollisionD", Vector2(315, 225), Vector2(64, 88)]
	]:
		_add_box_collision(item[0], item[1], item[2])


func _add_box_collision(node_name: String, position_value: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = position_value
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)


func _build_props() -> void:
	for pos in [Vector2(-385, -120), Vector2(350, -90), Vector2(-290, 210), Vector2(315, 225)]:
		var pillar := Node2D.new()
		pillar.set_script(PROP_SCRIPT)
		pillar.set("kind", "pillar")
		pillar.position = pos + Vector2(0, -44)
		prop_sort.add_child(pillar)
	for pos in [Vector2(-615, -210), Vector2(620, -214), Vector2(-610, 238), Vector2(615, 238)]:
		var torch := Node2D.new()
		torch.set_script(PROP_SCRIPT)
		torch.set("kind", "torch")
		torch.position = pos
		torch.scale = Vector2(0.82, 0.82)
		prop_sort.add_child(torch)


func _spawn_combatants() -> void:
	if not ResourceLoader.exists(PLAYER_SCENE_PATH) or not ResourceLoader.exists(GUARDIAN_SCENE_PATH):
		return
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH)
	player = player_scene.instantiate()
	player.position = Vector2(-420, 80)
	actor_sort.add_child(player)
	if player.has_signal("hit_confirmed"):
		player.hit_confirmed.connect(_on_hit_confirmed)
	if player.has_signal("died"):
		player.died.connect(_on_player_died)
	var guardian_scene: PackedScene = load(GUARDIAN_SCENE_PATH)
	for pos in [Vector2(180, -145), Vector2(420, 80), Vector2(160, 225)]:
		var guardian: Node = guardian_scene.instantiate()
		guardian.position = pos
		guardian.set("player_path", guardian.get_path_to(player))
		actor_sort.add_child(guardian)
		guardians.append(guardian)
		if guardian.has_signal("died"):
			guardian.died.connect(_on_guardian_died.bind(guardian))


func _spawn_ui() -> void:
	if ResourceLoader.exists(HUD_SCENE_PATH):
		var hud_scene: PackedScene = load(HUD_SCENE_PATH)
		_hud = hud_scene.instantiate()
		add_child(_hud)
		if is_instance_valid(player) and _hud.has_method("bind"):
			_hud.bind(player, guardians)
	if ResourceLoader.exists(MOBILE_SCENE_PATH):
		var mobile_scene: PackedScene = load(MOBILE_SCENE_PATH)
		_mobile_controls = mobile_scene.instantiate()
		add_child(_mobile_controls)
	_debug_label = Label.new()
	_debug_label.visible = false
	_debug_label.position = Vector2(24, 140)
	_debug_label.add_theme_font_size_override("font_size", 18)
	if is_instance_valid(_hud):
		_hud.add_child(_debug_label)
	else:
		add_child(_debug_label)


func _on_hit_confirmed() -> void:
	_screen_shake = 0.35
	get_tree().paused = true
	await get_tree().create_timer(0.045, true, false, true).timeout
	get_tree().paused = false


func _on_guardian_died(guardian: Node) -> void:
	guardians.erase(guardian)
	if guardians.is_empty():
		await get_tree().create_timer(1.0).timeout
		SceneFlow.victory()


func _on_player_died() -> void:
	if is_instance_valid(_hud) and _hud.has_method("show_death_prompt"):
		_hud.show_death_prompt()


func _toggle_pause() -> void:
	if not is_instance_valid(_hud):
		return
	get_tree().paused = not get_tree().paused
	if _hud.has_method("set_pause_visible"):
		_hud.set_pause_visible(get_tree().paused)


func _update_debug_text() -> void:
	var enemy_state := "none"
	if not guardians.is_empty() and is_instance_valid(guardians[0]):
		enemy_state = str(guardians[0].get("state_name"))
	_debug_label.text = "FPS: %d\nPlayer HP: %.0f\nStamina: %.0f\nState: %s\nAim: %s\nTouch: %s\nEnemy: %s\nGuardians: %d" % [
		Engine.get_frames_per_second(),
		player.get("health") if is_instance_valid(player) else 0.0,
		player.get("stamina") if is_instance_valid(player) else 0.0,
		player.get("state_name") if is_instance_valid(player) else "none",
		str(player.get("facing").round()) if is_instance_valid(player) else "none",
		str(InputRouter.touch_active),
		enemy_state,
		guardians.size()
	]
