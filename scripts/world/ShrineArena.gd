extends Node2D

const PLAYER_SCENE_PATH := "res://scenes/player/Player.tscn"
const GUARDIAN_SCENE_PATH := "res://scenes/enemies/ShrineGuardian.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/HUD.tscn"
const MOBILE_SCENE_PATH := "res://scenes/ui/MobileControls.tscn"
const PROP_SCRIPT := preload("res://scripts/world/ShrineProp.gd")
const WALL_VISUAL_SCRIPT := preload("res://scripts/world/ShrineWallVisual.gd")
const Route := preload("res://scripts/world/ShrineRoute.gd")

@onready var actors_and_tall_props: Node2D = %ActorsAndTallProps
@onready var collision_root: Node2D = %Collision
@onready var camera: Camera2D = %ArenaCamera

var player: Node2D
var guardians: Array[Node] = []
var _rng := RandomNumberGenerator.new()
var _debug_visible := false
var _debug_label: Label
var _hud: CanvasLayer
var _mobile_controls: CanvasLayer
var _screen_shake := 0.0
var _shake_offset := Vector2.ZERO

func _ready() -> void:
	_rng.seed = 1312
	y_sort_enabled = false
	_enforce_render_layer_integrity()
	_build_collision()
	_build_world_props()
	_spawn_combatants()
	_spawn_ui()
	_configure_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		_debug_visible = not _debug_visible
		if is_instance_valid(_debug_label):
			_debug_label.visible = _debug_visible
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _process(delta: float) -> void:
	if InputRouter.consume_pause():
		_toggle_pause()
	_update_camera(delta)
	if _debug_visible and is_instance_valid(_debug_label):
		_update_debug_text()


func _configure_camera() -> void:
	camera.limit_left = Route.CAMERA_LIMIT_LEFT
	camera.limit_top = Route.CAMERA_LIMIT_TOP
	camera.limit_right = Route.CAMERA_LIMIT_RIGHT
	camera.limit_bottom = Route.CAMERA_LIMIT_BOTTOM
	camera.zoom = Vector2(1.10, 1.10)
	camera.global_position = Route.clamped_to_camera_limits(player.global_position if is_instance_valid(player) else Vector2.ZERO)
	camera.reset_smoothing()


func _enforce_render_layer_integrity() -> void:
	var ground: Node2D = %Ground
	var decals: Node2D = %GroundDecals
	var shadows: Node2D = %Shadows
	var foreground: Node2D = %ForegroundCanopy
	ground.y_sort_enabled = false
	decals.y_sort_enabled = false
	shadows.y_sort_enabled = false
	foreground.y_sort_enabled = false
	actors_and_tall_props.y_sort_enabled = true
	ground.z_index = 0
	decals.z_index = 1
	shadows.z_index = 2
	actors_and_tall_props.z_index = 10
	foreground.z_index = 20


func _update_camera(delta: float) -> void:
	if _screen_shake > 0.0:
		_screen_shake = maxf(_screen_shake - delta * 2.2, 0.0)
		_shake_offset = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * 7.0 * _screen_shake
	else:
		_shake_offset = Vector2.ZERO
	camera.offset = _shake_offset
	if is_instance_valid(player):
		var target := Route.clamped_to_camera_limits(player.global_position)
		camera.global_position = camera.global_position.lerp(target, minf(delta * 5.0, 1.0))


func _build_collision() -> void:
	for wall in Route.WALLS:
		_add_box_collision(wall[0], wall[1], wall[2])
	for obstacle in Route.OBSTACLES:
		_add_box_collision(obstacle[0], obstacle[1], obstacle[2])


func _add_box_collision(node_name: String, position_value: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = position_value
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	collision_root.add_child(body)


func _build_world_props() -> void:
	for wall in Route.WALLS:
		var visual := Node2D.new()
		visual.name = "%sVisual" % wall[0]
		visual.set_script(WALL_VISUAL_SCRIPT)
		visual.set("size", wall[2])
		visual.set("kind", "wall")
		visual.position = wall[1]
		actors_and_tall_props.add_child(visual)
	for obstacle in Route.OBSTACLES:
		_add_obstacle_visual(obstacle)
	for pos in Route.TORCHES:
		var torch := Node2D.new()
		torch.name = "Torch"
		torch.set_script(PROP_SCRIPT)
		torch.set("kind", "torch")
		torch.position = pos
		torch.scale = Vector2(0.84, 0.84)
		actors_and_tall_props.add_child(torch)


func _add_obstacle_visual(obstacle: Array) -> void:
	var name_value: String = obstacle[0]
	var pos: Vector2 = obstacle[1]
	var size: Vector2 = obstacle[2]
	var kind: String = obstacle[3]
	var visual := Node2D.new()
	visual.name = "%sVisual" % name_value
	if kind == "pillar":
		visual.set_script(PROP_SCRIPT)
		visual.set("kind", "pillar")
		visual.position = pos + Vector2(0, -44)
	else:
		visual.set_script(WALL_VISUAL_SCRIPT)
		visual.set("size", size)
		visual.set("kind", kind)
		visual.position = pos
	actors_and_tall_props.add_child(visual)


func _spawn_combatants() -> void:
	if not ResourceLoader.exists(PLAYER_SCENE_PATH) or not ResourceLoader.exists(GUARDIAN_SCENE_PATH):
		return
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH)
	player = player_scene.instantiate()
	player.position = Route.PLAYER_START
	actors_and_tall_props.add_child(player)
	if player.has_signal("hit_confirmed"):
		player.hit_confirmed.connect(_on_hit_confirmed)
	if player.has_signal("died"):
		player.died.connect(_on_player_died)
	var guardian_scene: PackedScene = load(GUARDIAN_SCENE_PATH)
	for pos in Route.GUARDIAN_SPAWNS:
		var guardian: Node = guardian_scene.instantiate()
		guardian.position = pos
		actors_and_tall_props.add_child(guardian)
		guardian.set("player", player)
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
	_screen_shake = 0.24
	get_tree().paused = true
	await get_tree().create_timer(0.035, true, false, true).timeout
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
	_debug_label.text = "FPS: %d\nPlayer HP: %.0f\nStamina: %.0f\nState: %s\nAim: %s\nTouch: %s\nEnemy: %s\nGuardians: %d\nCamera: %s" % [
		Engine.get_frames_per_second(),
		player.get("health") if is_instance_valid(player) else 0.0,
		player.get("stamina") if is_instance_valid(player) else 0.0,
		player.get("state_name") if is_instance_valid(player) else "none",
		str(player.get("facing").round()) if is_instance_valid(player) else "none",
		str(InputRouter.touch_active),
		enemy_state,
		guardians.size(),
		str(camera.global_position.round())
	]
