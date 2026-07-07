extends SceneTree

const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")
const EnemyBrainUtil := preload("res://scripts/enemies/EnemyBrain.gd")
const Route := preload("res://scripts/world/ShrineRoute.gd")
const GuardianScene := preload("res://scenes/enemies/ShrineGuardian.tscn")

var _failures := 0

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("Running Ashen Pity gameplay logic tests...")
	_test_stamina_cannot_go_below_zero()
	_test_stamina_regeneration()
	_test_120hz_physics_configuration()
	_test_dodge_requires_stamina()
	_test_enemy_damage_is_applied()
	_test_player_invulnerability_prevents_damage()
	_test_enemy_state_transitions()
	_test_movement_input_normalization()
	_test_player_remains_inside_world_boundaries()
	_test_dodge_invulnerability_timing()
	_test_mouse_aim_world_position_calculation()
	_test_frame_rate_independent_velocity()
	_test_attack_buffering_window()
	_test_ash_brand_collect_progress()
	_test_enemy_configs_exist()
	if _failures == 0:
		print("All gameplay logic tests passed.")
		quit(0)
	else:
		push_error("%d gameplay logic test(s) failed." % _failures)
		quit(1)


func _test_stamina_cannot_go_below_zero() -> void:
	_assert_equal(CombatMathUtil.spend_stamina(18.0, 18.0), 0.0, "stamina reaches zero exactly")
	_assert_equal(CombatMathUtil.spend_stamina(12.0, 18.0), 12.0, "failed spend does not go below zero")


func _test_dodge_requires_stamina() -> void:
	_assert_false(CombatMathUtil.can_spend_stamina(20.0, GameBalance.PLAYER_DODGE_COST), "dodge is blocked below cost")
	_assert_true(CombatMathUtil.can_spend_stamina(GameBalance.PLAYER_DODGE_COST, GameBalance.PLAYER_DODGE_COST), "dodge is allowed at exact cost")


func _test_stamina_regeneration() -> void:
	_assert_equal(CombatMathUtil.regenerate_stamina(90.0, 100.0, 20.0, 1.0), 100.0, "stamina regeneration clamps to max")
	_assert_equal(CombatMathUtil.regenerate_stamina(20.0, 100.0, 10.0, 0.5), 25.0, "stamina regeneration uses delta")


func _test_120hz_physics_configuration() -> void:
	_assert_equal(int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second")), 120, "project physics ticks are 120 Hz")


func _test_enemy_damage_is_applied() -> void:
	var enemy: Node = GuardianScene.instantiate()
	root.add_child(enemy)
	var start_health: float = enemy.get("health")
	enemy.call("take_damage", 20.0, Vector2.ZERO, 0.0)
	_assert_equal(enemy.get("health"), start_health - 20.0, "enemy damage reduces health")
	enemy.free()


func _test_player_invulnerability_prevents_damage() -> void:
	var start_health := 72.0
	var result := CombatMathUtil.apply_damage(start_health, 20.0, true)
	_assert_equal(result, start_health, "dodge-frame invulnerability prevents damage")


func _test_enemy_state_transitions() -> void:
	_assert_equal(EnemyBrainUtil.next_awareness_state(90.0, 620.0, 104.0), EnemyBrainUtil.State.WINDUP, "enemy attacks inside range")
	_assert_equal(EnemyBrainUtil.next_awareness_state(240.0, 620.0, 104.0), EnemyBrainUtil.State.CHASE, "enemy chases inside detection")
	_assert_equal(EnemyBrainUtil.next_awareness_state(900.0, 620.0, 104.0), EnemyBrainUtil.State.PATROL, "enemy patrols outside detection")


func _test_movement_input_normalization() -> void:
	var diagonal := CombatMathUtil.normalized_input(Vector2(1.0, 1.0))
	_assert_true(diagonal.length() <= 1.001, "diagonal movement is normalized")
	_assert_equal(CombatMathUtil.normalized_input(Vector2(0.4, 0.0)), Vector2(0.4, 0.0), "partial input is preserved")


func _test_player_remains_inside_world_boundaries() -> void:
	_assert_true(Route.is_inside_route(Route.PLAYER_START), "player start is inside shrine route")
	for point in Route.TEST_VISIBILITY_POINTS:
		_assert_true(Route.is_inside_route(point), "visibility test point is inside route: %s" % str(point))
		var rect := Route.camera_rect_at(point, Vector2(1920, 1080), Route.CAMERA_ZOOM)
		_assert_true(rect.has_point(point), "camera covers route test point: %s" % str(point))
	_assert_false(Route.is_inside_route(Vector2(-900, -620)), "outer void is outside route")


func _test_dodge_invulnerability_timing() -> void:
	_assert_true(CombatMathUtil.is_dodge_invulnerable_at(0.0, GameBalance.PLAYER_DODGE_TIME), "dodge is invulnerable at start")
	_assert_true(CombatMathUtil.is_dodge_invulnerable_at(GameBalance.PLAYER_DODGE_TIME * 0.5, GameBalance.PLAYER_DODGE_TIME), "dodge is invulnerable during roll")
	_assert_false(CombatMathUtil.is_dodge_invulnerable_at(GameBalance.PLAYER_DODGE_TIME + 0.01, GameBalance.PLAYER_DODGE_TIME), "dodge invulnerability ends after roll")


func _test_mouse_aim_world_position_calculation() -> void:
	var direction := CombatMathUtil.aim_direction_from_world(Vector2(10, 10), Vector2(10, -90))
	_assert_true(direction.distance_to(Vector2.UP) < 0.001, "world-space mouse aim points up")
	var fallback := CombatMathUtil.aim_direction_from_world(Vector2(4, 4), Vector2(4, 4), Vector2.LEFT)
	_assert_true(fallback.distance_to(Vector2.LEFT) < 0.001, "zero-length aim uses fallback")


func _test_frame_rate_independent_velocity() -> void:
	var start := Vector2.ZERO
	var target := Vector2(1000, 0)
	var once_60 := CombatMathUtil.velocity_toward(start, target, 600.0, 1.0 / 60.0)
	var twice_120 := CombatMathUtil.velocity_toward(start, target, 600.0, 1.0 / 120.0)
	twice_120 = CombatMathUtil.velocity_toward(twice_120, target, 600.0, 1.0 / 120.0)
	_assert_true(once_60.distance_to(twice_120) < 0.001, "velocity integration is equivalent at 60 and 120 Hz")


func _test_attack_buffering_window() -> void:
	_assert_true(CombatMathUtil.is_attack_buffer_allowed(GameBalance.PLAYER_ATTACK_BUFFER_WINDOW * 0.5, GameBalance.PLAYER_ATTACK_BUFFER_WINDOW), "attack buffering accepts late recovery input")
	_assert_false(CombatMathUtil.is_attack_buffer_allowed(GameBalance.PLAYER_ATTACK_BUFFER_WINDOW + 0.02, GameBalance.PLAYER_ATTACK_BUFFER_WINDOW), "attack buffering rejects early recovery input")


func _test_ash_brand_collect_progress() -> void:
	_assert_true(CombatMathUtil.is_perfect_dodge(0.04, GameBalance.PLAYER_PERFECT_DODGE_WINDOW, GameBalance.PLAYER_DODGE_TIME), "early dodge overlap is a perfect dodge")
	_assert_false(CombatMathUtil.is_perfect_dodge(GameBalance.PLAYER_PERFECT_DODGE_WINDOW + 0.02, GameBalance.PLAYER_PERFECT_DODGE_WINDOW, GameBalance.PLAYER_DODGE_TIME), "late dodge overlap is not a perfect dodge")
	var hits := 0
	hits = CombatMathUtil.ash_brand_hit_progress(hits, GameBalance.ASH_BRAND_HITS_TO_COLLECT)
	_assert_false(CombatMathUtil.is_collect_ready(hits, GameBalance.ASH_BRAND_HITS_TO_COLLECT), "one branded hit is not enough for collect")
	hits = CombatMathUtil.ash_brand_hit_progress(hits, GameBalance.ASH_BRAND_HITS_TO_COLLECT)
	_assert_true(CombatMathUtil.is_collect_ready(hits, GameBalance.ASH_BRAND_HITS_TO_COLLECT), "required branded hits unlock collect")


func _test_enemy_configs_exist() -> void:
	for key in ["guardian", "hound", "archer", "bell_bearer"]:
		_assert_true(GameBalance.ENEMY_CONFIGS.has(key), "enemy config exists: %s" % key)
		_assert_true(float(GameBalance.ENEMY_CONFIGS[key]["max_health"]) > 0.0, "enemy config has health: %s" % key)


func _assert_true(value: bool, label: String) -> void:
	if not value:
		_fail(label)


func _assert_false(value: bool, label: String) -> void:
	if value:
		_fail(label)


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s: expected %s, got %s" % [label, str(expected), str(actual)])


func _fail(label: String) -> void:
	_failures += 1
	push_error("FAIL: %s" % label)
