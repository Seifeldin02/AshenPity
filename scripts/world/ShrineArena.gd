extends Node2D

const PLAYER_SCENE_PATH := "res://scenes/player/Player.tscn"
const GUARDIAN_SCENE_PATH := "res://scenes/enemies/ShrineGuardian.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/HUD.tscn"
const MOBILE_SCENE_PATH := "res://scenes/ui/MobileControls.tscn"
const PROP_SCRIPT := preload("res://scripts/world/ShrineProp.gd")
const WALL_VISUAL_SCRIPT := preload("res://scripts/world/ShrineWallVisual.gd")
const EFFECT_SCRIPT := preload("res://scripts/effects/CombatEffect.gd")
const TRIAL_SCRIPT := preload("res://scripts/trial/AshTrial.gd")
const LOOT_SHRINE_SCRIPT := preload("res://scripts/world/LootShrine.gd")
const Route := preload("res://scripts/world/ShrineRoute.gd")

@onready var actors_and_tall_props: Node2D = %ActorsAndTallProps
@onready var collision_root: Node2D = %Collision
@onready var camera: Camera2D = %ArenaCamera

var player: Node2D
var guardians: Array[Node] = []
var trial: Node
var _rng := RandomNumberGenerator.new()
var _debug_visible := false
var _debug_label: Label
var _hud: CanvasLayer
var _mobile_controls: CanvasLayer
var _screen_shake := 0.0
var _shake_offset := Vector2.ZERO
var _trial_started := false

func _ready() -> void:
	_rng.seed = 1312
	y_sort_enabled = false
	_enforce_render_layer_integrity()
	_build_collision()
	_build_world_props()
	_spawn_combatants()
	_spawn_loot_shrines()
	_spawn_ui()
	_configure_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		_debug_visible = not _debug_visible
		if is_instance_valid(_debug_label):
			_debug_label.visible = _debug_visible
	if event.is_action_pressed("toggle_performance_mode"):
		PerformanceStats.set_lightweight_mode(not PerformanceStats.lightweight_mode)
		_apply_performance_mode()
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
	camera.zoom = Route.CAMERA_ZOOM
	camera.position_smoothing_enabled = false
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
		camera.global_position = camera.global_position.lerp(target, minf(delta * 9.0, 1.0))


func snap_camera_to_player() -> void:
	if not is_instance_valid(player):
		return
	camera.global_position = Route.clamped_to_camera_limits(player.global_position)
	camera.reset_smoothing()


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


func _spawn_loot_shrines() -> void:
	for shrine_data in Route.LOOT_SHRINES:
		var shrine := Area2D.new()
		shrine.name = "LootShrine_%s" % str(shrine_data["id"])
		shrine.set_script(LOOT_SHRINE_SCRIPT)
		shrine.set("boon_id", str(shrine_data["id"]))
		shrine.position = shrine_data["pos"]
		shrine.collected.connect(_on_loot_collected)
		actors_and_tall_props.add_child(shrine)


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
	if player.has_signal("perfect_dodge"):
		player.perfect_dodge.connect(_on_perfect_dodge)
	if player.has_signal("died"):
		player.died.connect(_on_player_died)
	var guardian_scene: PackedScene = load(GUARDIAN_SCENE_PATH)
	trial = Node.new()
	trial.name = "AshTrial"
	trial.set_script(TRIAL_SCRIPT)
	add_child(trial)
	trial.configure(guardian_scene, actors_and_tall_props, player)
	trial.enemies_changed.connect(_on_trial_enemies_changed)
	trial.trial_completed.connect(_on_trial_completed)
	trial.wave_started.connect(_on_trial_wave_started)
	_apply_performance_mode()


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


func _on_hit_confirmed(kind: String = "light", hit_position: Vector2 = Vector2.ZERO) -> void:
	var shake := 0.24
	var stop := 0.035
	var effect := "spark"
	if kind == "light_ember":
		shake = 0.36
		stop = 0.046
		effect = "brand"
	if kind == "ash_burst":
		shake = 0.58
		stop = 0.055
		effect = "ash_burst"
	if kind == "heavy":
		shake = 0.42
		stop = 0.050
		effect = "heavy"
	elif kind == "parry":
		shake = 0.62
		stop = 0.070
		effect = "brand"
	elif kind == "collect":
		shake = 0.78
		stop = 0.075
		effect = "collect"
	_screen_shake = maxf(_screen_shake, shake)
	if hit_position != Vector2.ZERO:
		EFFECT_SCRIPT.spawn(actors_and_tall_props, hit_position, effect, player.get("facing") if is_instance_valid(player) else Vector2.RIGHT)
	get_tree().paused = true
	await get_tree().create_timer(stop, true, false, true).timeout
	get_tree().paused = false


func _on_perfect_dodge(enemy: Node) -> void:
	_screen_shake = maxf(_screen_shake, 0.32)
	if is_instance_valid(enemy):
		EFFECT_SCRIPT.spawn(actors_and_tall_props, enemy.global_position, "brand", Vector2.RIGHT, Color("#ff6a24"))


func _on_trial_enemies_changed(enemies: Array[Node]) -> void:
	guardians = enemies
	if is_instance_valid(_hud) and _hud.has_method("bind_enemies"):
		_hud.bind_enemies(guardians)
	_apply_performance_mode()


func _on_trial_wave_started(index: int, label: String) -> void:
	if index > 0 and is_instance_valid(player) and player.has_method("restore_flask_charge"):
		player.restore_flask_charge(1)
	if is_instance_valid(_hud) and _hud.has_method("show_wave"):
		var total: int = int(trial.wave_count()) if is_instance_valid(trial) and trial.has_method("wave_count") else index + 1
		_hud.show_wave("%s  %d/%d" % [label, index + 1, total])


func _on_loot_collected(_boon_id: String, display_name: String) -> void:
	if is_instance_valid(_hud) and _hud.has_method("show_pickup"):
		var data: Dictionary = GameBalance.BOON_DATA.get(_boon_id, {})
		_hud.show_pickup("BOON CLAIMED: %s\n%s" % [display_name, str(data.get("description", "Run-only combat boon claimed."))])
	EFFECT_SCRIPT.spawn(actors_and_tall_props, player.global_position if is_instance_valid(player) else Vector2.ZERO, "brand", Vector2.RIGHT, Color("#ff8f2a"))
	start_trial.call_deferred()


func start_trial() -> void:
	if _trial_started or not is_instance_valid(trial):
		return
	_trial_started = true
	trial.start()


func _on_trial_completed() -> void:
	if is_instance_valid(_hud) and _hud.has_method("show_trial_complete"):
		_hud.show_trial_complete()


func _on_player_died() -> void:
	if is_instance_valid(_hud) and _hud.has_method("show_death_prompt"):
		_hud.show_death_prompt()


func _apply_performance_mode() -> void:
	if is_instance_valid(player) and player.has_method("apply_performance_mode"):
		player.apply_performance_mode(PerformanceStats.lightweight_mode)
	for guardian in guardians:
		if is_instance_valid(guardian) and guardian.has_method("apply_performance_mode"):
			guardian.apply_performance_mode(PerformanceStats.lightweight_mode)


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
	var brand_state := "none"
	if is_instance_valid(player):
		var target = player.get("branded_enemy")
		if is_instance_valid(target):
			brand_state = "%s ready=%s" % [target.get("display_name"), str(player.get("collect_ready"))]
	var stats := PerformanceStats.snapshot(player.get("state_name") if is_instance_valid(player) else "none")
	_debug_label.text = "Build: %s\nFPS: %d\nRefresh: %.0f Hz\nAvg frame: %.2f ms\nP95 frame: %.2f ms\nPhysics: %d Hz\nPerf mode: %s\nPlayer HP: %.0f\nStamina: %.0f\nState: %s\nAsh Brand: %s\nCollect: %s\nAim: %s\nTouch: %s\nEnemy: %s\nEnemies: %d\nCamera: %s" % [
		BuildInfo.label(),
		Engine.get_frames_per_second(),
		stats["display_refresh_hz"],
		stats["avg_frame_ms"],
		stats["p95_frame_ms"],
		stats["physics_hz"],
		"light" if stats["lightweight_mode"] else "full",
		player.get("health") if is_instance_valid(player) else 0.0,
		player.get("stamina") if is_instance_valid(player) else 0.0,
		player.get("state_name") if is_instance_valid(player) else "none",
		brand_state,
		str(player.get("collect_ready")) if is_instance_valid(player) else "false",
		str(player.get("facing").round()) if is_instance_valid(player) else "none",
		str(InputRouter.touch_active),
		enemy_state,
		stats["active_enemies"],
		str(camera.global_position.round())
	]
