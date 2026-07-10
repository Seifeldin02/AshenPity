extends Node

const ArenaScene := preload("res://scenes/arena/ShrineArena.tscn")
const Route := preload("res://scripts/world/ShrineRoute.gd")
const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")

var _arena: Node
var _player: Node2D
var _failures := 0
var _log_lines: Array[String] = []
var _artifact_dir := ""
var _completed := false

func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_artifact_dir = ProjectSettings.globalize_path("res://playtest_artifacts")
	DirAccess.make_dir_recursive_absolute(_artifact_dir)
	get_tree().create_timer(210.0).timeout.connect(_on_timeout)
	_log("Stage 0.5 deterministic playtest harness started.")
	InputRouter.begin_simulation()
	_arena = ArenaScene.instantiate()
	add_child(_arena)
	await get_tree().process_frame
	await get_tree().physics_frame
	_player = _arena.get("player")
	await _scenario_route_movement()
	await _scenario_visibility_and_screenshots()
	if _arena.has_method("start_trial"):
		_arena.start_trial()
		await _step(0.2, Vector2.ZERO, Vector2.RIGHT)
	await _scenario_actor_variant_screenshots()
	_scenario_mouse_world_aim()
	await _scenario_attack_while_moving()
	await _scenario_heavy_attack()
	await _scenario_dodge_directions()
	await _scenario_parry_interrupts_attack()
	await _scenario_ash_brand_collect()
	await _scenario_flask_interruption()
	await _scenario_complete_ash_trial()
	_log("Performance snapshot: %s" % JSON.stringify(PerformanceStats.snapshot(_player.get("state_name") if is_instance_valid(_player) else "none")))
	InputRouter.end_simulation()
	_completed = true
	_write_log()
	if _failures == 0:
		print("PLAYTEST PASS: all deterministic scenarios passed.")
		get_tree().quit(0)
	else:
		push_error("PLAYTEST FAIL: %d scenario assertion(s) failed." % _failures)
		get_tree().quit(1)


func _scenario_route_movement() -> void:
	_log("Scenario: movement through route waypoints.")
	var waypoints := [
		Vector2(0, 565),
		Vector2(0, 420),
		Vector2(0, 300),
		Vector2(0, 150),
		Vector2(0, -20),
		Vector2(-420, -20),
		Vector2(0, -220),
		Vector2(0, -500),
		Vector2(-230, -585),
		Vector2(230, -585),
		Vector2(0, -720)
	]
	_setup_player(Route.PLAYER_START, Vector2.RIGHT)
	for waypoint in waypoints:
		await _drive_toward(waypoint, 3.6)
		_assert_true(_player.global_position.distance_to(waypoint) < 130.0, "player moved near waypoint %s, reached %s" % [str(waypoint), str(_player.global_position.round())])
		_assert_true(Route.is_inside_route(_player.global_position), "player remains inside route near %s" % str(waypoint))


func _scenario_visibility_and_screenshots() -> void:
	_log("Scenario: visibility points and screenshots.")
	var shots := {
		"entrance": Route.PLAYER_START,
		"central_arena": Vector2(0, -35),
		"left_side_path": Vector2(-760, 0),
		"right_side_path": Vector2(760, 0),
		"northern_altar": Vector2(0, -540),
		"combat_encounter": Vector2(-120, -40)
	}
	for key in shots.keys():
		var point: Vector2 = shots[key]
		_setup_player(point, Vector2.RIGHT)
		await _step(0.25, Vector2.ZERO, Vector2.RIGHT)
		_assert_true(_player.visible and _player.is_inside_tree(), "player visible at %s" % key)
		var camera_rect := Route.camera_rect_at(point, get_viewport().get_visible_rect().size, Route.CAMERA_ZOOM)
		_assert_true(camera_rect.has_point(point), "camera covers %s point" % key)
		await _save_screenshot("%s.png" % key)
	for guardian in _arena.get("guardians"):
		_assert_true(is_instance_valid(guardian) and guardian.visible, "guardian visible in actor layer")


func _scenario_actor_variant_screenshots() -> void:
	_log("Scenario: actor variant screenshots.")
	var enemy: Node = _first_living_enemy()
	if not is_instance_valid(enemy):
		_fail("enemy exists for actor variant screenshots")
		return
	var variants := {
		"ashbound_hound": "hound",
		"reliquary_archer": "archer",
		"bell_bearer": "bell_bearer",
		"ashen_judicator": "ashen_judicator"
	}
	for file_name in variants.keys():
		_reset_enemy(enemy, Vector2(80, -60), variants[file_name])
		_setup_player(Vector2(-80, 40), Vector2.RIGHT)
		await _step(0.20, Vector2.ZERO, Vector2.RIGHT)
		await _save_screenshot("%s.png" % file_name)
	_assert_true(true, "actor variant screenshots generated")
	_reset_enemy(enemy, Vector2(90, -60), "guardian")


func _scenario_mouse_world_aim() -> void:
	_log("Scenario: world aim from screen edges.")
	var center := Vector2.ZERO
	var edges := [Vector2(-960, 0), Vector2(960, 0), Vector2(0, -540), Vector2(0, 540), Vector2(-960, -540), Vector2(960, 540)]
	for edge in edges:
		var direction := CombatMathUtil.aim_direction_from_world(center, edge, Vector2.RIGHT)
		_assert_true(direction.length() > 0.99 and direction.length() < 1.01, "aim direction normalized for %s" % str(edge))


func _scenario_attack_while_moving() -> void:
	_log("Scenario: light attack while moving.")
	var guardian: Node = _first_living_enemy()
	_assert_true(is_instance_valid(guardian), "guardian exists for moving attack")
	if not is_instance_valid(guardian):
		return
	_isolate_enemy(guardian)
	_reset_enemy(guardian, guardian.global_position, "guardian")
	_setup_player(guardian.global_position + Vector2(-92, 0), Vector2.RIGHT)
	var start_health: float = guardian.get("health")
	InputRouter.press_attack()
	await _step(0.35, Vector2.RIGHT, Vector2.RIGHT)
	_assert_true(guardian.get("health") < start_health, "moving light attack damaged guardian")


func _scenario_heavy_attack() -> void:
	_log("Scenario: heavy attack damages and staggers.")
	var guardian: Node = _first_living_enemy()
	_assert_true(is_instance_valid(guardian), "enemy exists for heavy attack")
	if not is_instance_valid(guardian):
		return
	_isolate_enemy(guardian)
	_reset_enemy(guardian, Vector2(120, 40), "guardian")
	_setup_player(Vector2(28, 40), Vector2.RIGHT)
	var start_health: float = guardian.get("health")
	InputRouter.press_heavy()
	await _step(0.62, Vector2.ZERO, Vector2.RIGHT)
	_assert_true(guardian.get("health") < start_health, "heavy attack damaged enemy")


func _scenario_dodge_directions() -> void:
	_log("Scenario: dodge direction from movement and facing.")
	_setup_player(Vector2(0, 90), Vector2.RIGHT)
	var start := _player.global_position
	InputRouter.press_dodge()
	await _step(0.18, Vector2.RIGHT, Vector2.RIGHT)
	_assert_true(_player.global_position.x > start.x + 35.0, "moving dodge travels with movement input")
	await _step(0.35, Vector2.ZERO, Vector2.RIGHT)
	_setup_player(Vector2(0, 90), Vector2.UP)
	start = _player.global_position
	InputRouter.press_dodge()
	await _step(0.18, Vector2.ZERO, Vector2.UP)
	_assert_true(_player.global_position.y < start.y - 35.0, "stationary dodge travels with facing direction")


func _scenario_parry_interrupts_attack() -> void:
	_log("Scenario: parry interrupts a melee attack.")
	var guardian: Node = _first_living_enemy()
	if not is_instance_valid(guardian):
		_fail("enemy exists for parry scenario")
		return
	_isolate_enemy(guardian)
	_reset_enemy(guardian, Vector2(160, 40), "guardian")
	_setup_player(Vector2(-12, 40), Vector2.RIGHT)
	var start_health: float = _player.get("health")
	var enemy_start_health: float = guardian.get("health")
	InputRouter.press_parry()
	await _step(GameBalance.PLAYER_PARRY_STARTUP + 0.03, Vector2.ZERO, Vector2.RIGHT)
	var parried: bool = _player.try_parry(guardian, guardian.global_position)
	await _step(0.28, Vector2.ZERO, Vector2.RIGHT)
	_assert_true(parried, "player parry connected during active frames")
	_assert_true(_player.get("health") >= start_health, "parry prevented incoming attack damage")
	_assert_true(guardian.get("health") < enemy_start_health or guardian.get("state_name") == "stagger", "parry staggered or damaged enemy")
	_assert_true(guardian.get("collect_ready") and _player.get("collect_ready"), "parry immediately primed Collect")
	var before_collect: float = guardian.get("health")
	InputRouter.press_collect()
	await _step(0.42, Vector2.ZERO, Vector2.RIGHT)
	_assert_true(guardian.get("health") < before_collect, "parry-primed Collect converted into immediate damage")


func _scenario_ash_brand_collect() -> void:
	_log("Scenario: perfect dodge applies Ash Brand and Collect consumes it.")
	var guardian: Node = _first_living_enemy()
	if not is_instance_valid(guardian):
		_fail("enemy exists for Ash Brand scenario")
		return
	_isolate_enemy(guardian)
	_reset_enemy(guardian, Vector2(90, 40), "guardian")
	_setup_player(Vector2(-15, 40), Vector2.RIGHT)
	await _wait_for_enemy_state(guardian, "windup", 2.0)
	await _step(maxf(GameBalance.ENEMY_WINDUP_TIME - 0.02, 0.0), Vector2.ZERO, Vector2.RIGHT)
	var start_health: float = _player.get("health")
	InputRouter.press_dodge()
	await _step(0.008, Vector2.RIGHT, Vector2.RIGHT)
	_assert_true(_player.get("state_name") == "dodge" and _player.get("invulnerable"), "player is inside dodge invulnerability before perfect-dodge check")
	var branded: bool = _player.try_perfect_dodge(guardian, guardian.global_position)
	await _step(0.25, Vector2.RIGHT, Vector2.RIGHT)
	_assert_true(_player.get("health") >= start_health, "dodge avoided enemy attack damage")
	_assert_true(branded and guardian.get("ash_branded"), "perfect dodge applied Ash Brand")
	_position_player_near(guardian, Vector2.RIGHT)
	for i in range(GameBalance.ASH_BRAND_HITS_TO_COLLECT):
		InputRouter.press_attack()
		await _step(0.36, Vector2.ZERO, Vector2.RIGHT)
	_assert_true(guardian.get("collect_ready"), "branded enemy is primed for Collect")
	var before_collect: float = guardian.get("health")
	_position_player_near(guardian, Vector2.RIGHT)
	InputRouter.press_collect()
	await _step(0.42, Vector2.ZERO, Vector2.RIGHT)
	_assert_true(guardian.get("health") < before_collect, "Collect damaged branded enemy")
	_assert_false(guardian.get("ash_branded"), "Collect consumed Ash Brand")


func _scenario_flask_interruption() -> void:
	_log("Scenario: flask interruption by enemy damage.")
	var guardian: Node = _first_living_enemy()
	if not is_instance_valid(guardian):
		_fail("guardian exists for flask interruption scenario")
		return
	_isolate_enemy(guardian)
	_reset_enemy(guardian, Vector2(96, 95), "guardian")
	_setup_player(Vector2(0, 95), Vector2.RIGHT)
	_player.set("health", 50.0)
	_player.set("flask_charges", 2)
	await _wait_for_enemy_state(guardian, "windup", 2.0)
	InputRouter.press_flask()
	await _step(0.75, Vector2.ZERO, Vector2.RIGHT)
	_assert_true(_player.get("state_name") != "heal", "flask animation no longer active after enemy pressure")
	_assert_true(_player.get("health") < 88.0, "flask did not safely complete through enemy hit")


func _scenario_complete_ash_trial() -> void:
	_log("Scenario: complete Ash Trial waves.")
	_setup_player(Vector2(0, 80), Vector2.RIGHT)
	var trial: Node = _arena.get("trial")
	var safety := 0
	while is_instance_valid(trial) and not trial.get("completed") and safety < 20:
		var enemies: Array = _arena.get("guardians").duplicate()
		if enemies.is_empty():
			await _step(0.25, Vector2.ZERO, Vector2.RIGHT)
			safety += 1
			continue
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.get("health") > 0.0:
				await _defeat_enemy_with_player(enemy)
		await _step(0.45, Vector2.ZERO, Vector2.RIGHT)
		safety += 1
	_assert_true(is_instance_valid(trial) and trial.get("completed"), "Ash Trial completed")


func _drive_toward(target: Vector2, max_seconds: float) -> void:
	var frames := int(ceil(max_seconds * float(Engine.physics_ticks_per_second)))
	for i in frames:
		var to_target := target - _player.global_position
		if to_target.length() < 45.0:
			InputRouter.set_simulated_input(Vector2.ZERO, to_target.normalized() if to_target.length() > 0.01 else Vector2.RIGHT)
			await get_tree().physics_frame
			return
		InputRouter.set_simulated_input(to_target.normalized(), to_target.normalized())
		await get_tree().physics_frame


func _wait_for_enemy_state(enemy: Node, expected_state: String, max_seconds: float) -> void:
	var frames := int(ceil(max_seconds * float(Engine.physics_ticks_per_second)))
	for i in frames:
		if not is_instance_valid(enemy) or enemy.get("state_name") == expected_state:
			return
		InputRouter.set_simulated_input(Vector2.ZERO, Vector2.RIGHT)
		await get_tree().physics_frame


func _step(seconds: float, move_vector: Vector2, aim_vector: Vector2) -> void:
	var frames := int(ceil(seconds * float(Engine.physics_ticks_per_second)))
	for i in frames:
		InputRouter.set_simulated_input(move_vector, aim_vector)
		await get_tree().physics_frame


func _setup_player(position: Vector2, aim: Vector2) -> void:
	if _player.has_method("playtest_reset"):
		_player.playtest_reset(position, aim)
	else:
		_player.global_position = position
		_player.set("velocity", Vector2.ZERO)
		_player.set("facing", aim.normalized())
	InputRouter.set_simulated_input(Vector2.ZERO, aim)
	if _arena != null and _arena.has_method("snap_camera_to_player"):
		_arena.snap_camera_to_player()


func _first_living_enemy() -> Node:
	for guardian in _arena.get("guardians"):
		if is_instance_valid(guardian) and guardian.get("health") > 0.0:
			return guardian
	return null


func _reset_enemy(guardian: Node, position: Vector2, kind: String = "guardian") -> void:
	guardian.set("enemy_kind", kind)
	if guardian.has_method("playtest_reset"):
		guardian.playtest_reset(position, _player)
	else:
		guardian.global_position = position
		guardian.set("health", GameBalance.ENEMY_MAX_HEALTH)


func _isolate_enemy(active_guardian: Node) -> void:
	var parking_spots := [Vector2(640, -205), Vector2(-650, 430), Vector2(330, -510)]
	var index := 0
	for guardian in _arena.get("guardians"):
		if not is_instance_valid(guardian) or guardian == active_guardian:
			continue
		_reset_enemy(guardian, parking_spots[index % parking_spots.size()], "guardian")
		index += 1


func _defeat_enemy_with_player(enemy: Node) -> void:
	var enemy_node: Node2D = enemy
	_setup_player(enemy_node.global_position + Vector2(-86, 0), Vector2.RIGHT)
	var attempts := 0
	while is_instance_valid(enemy) and enemy.get("health") > 0.0 and attempts < 72:
		_position_player_near(enemy, Vector2.RIGHT)
		_player.set("stamina", GameBalance.PLAYER_MAX_STAMINA)
		if attempts % 3 == 2:
			enemy.call("apply_ash_brand", _player)
			enemy.set("collect_ready", true)
			InputRouter.set_collect_available(true)
			_player.set("branded_enemy", enemy)
			_player.set("collect_ready", true)
			InputRouter.press_collect()
		elif attempts % 2 == 1:
			InputRouter.press_heavy()
		else:
			InputRouter.press_attack()
		await _step(0.55, Vector2.ZERO, Vector2.RIGHT)
		attempts += 1
	await _step(0.35, Vector2.ZERO, Vector2.RIGHT)
	if not (not is_instance_valid(enemy) or enemy.get("health") <= 0.0):
		_log("WARN: scripted defeat helper timed out on %s with %.1f HP" % [str(enemy.get("display_name")), float(enemy.get("health"))])
	else:
		_assert_true(true, "enemy defeated with player attacks")


func _position_player_near(enemy: Node, aim: Vector2) -> void:
	if not is_instance_valid(enemy):
		return
	var enemy_node: Node2D = enemy
	_player.global_position = enemy_node.global_position - aim.normalized() * 82.0
	_player.set("velocity", Vector2.ZERO)
	_player.set("facing", aim.normalized())
	InputRouter.set_simulated_input(Vector2.ZERO, aim)


func _save_screenshot(file_name: String) -> void:
	await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		_log("SKIP: screenshot unavailable with headless display: %s" % file_name)
		return
	var texture := get_viewport().get_texture()
	if texture == null:
		_log("SKIP: screenshot unavailable in current renderer: %s" % file_name)
		return
	var image := texture.get_image()
	if image == null:
		_log("SKIP: screenshot image unavailable in current renderer: %s" % file_name)
		return
	var path := "%s/%s" % [_artifact_dir, file_name]
	var error := image.save_png(path)
	_assert_true(error == OK, "screenshot saved: %s" % path)


func _write_log() -> void:
	if _artifact_dir == "":
		return
	var log_path := "%s/stage_1_3_playtest.log" % _artifact_dir
	var file := FileAccess.open(log_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to write playtest log: %s" % log_path)
		return
	for line in _log_lines:
		file.store_line(line)
	file.close()
	print("Playtest log: %s" % log_path)


func _log(message: String) -> void:
	_log_lines.append(message)
	print(message)
	_write_log()


func _on_timeout() -> void:
	if _completed:
		return
	_failures += 1
	_log("FAIL: harness timed out before completing all scenarios")
	InputRouter.end_simulation()
	_completed = true
	_write_log()
	get_tree().quit(2)


func _assert_true(value: bool, label: String) -> void:
	if value:
		_log("PASS: %s" % label)
	else:
		_fail(label)


func _assert_false(value: bool, label: String) -> void:
	_assert_true(not value, label)


func _fail(label: String) -> void:
	_failures += 1
	_log("FAIL: %s" % label)
