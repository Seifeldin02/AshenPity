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
	_test_dodge_requires_stamina()
	_test_enemy_damage_is_applied()
	_test_player_invulnerability_prevents_damage()
	_test_enemy_state_transitions()
	_test_movement_input_normalization()
	_test_player_remains_inside_world_boundaries()
	_test_dodge_invulnerability_timing()
	_test_mouse_aim_world_position_calculation()
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


func _test_enemy_damage_is_applied() -> void:
	var enemy: Node = GuardianScene.instantiate()
	root.add_child(enemy)
	var start_health: float = enemy.get("health")
	enemy.call("take_damage", 20.0, Vector2.ZERO, 0.0)
	_assert_equal(enemy.get("health"), start_health - 20.0, "enemy damage reduces health")
	enemy.queue_free()


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
		var rect := Route.camera_rect_at(point, Vector2(1920, 1080), Vector2(1.08, 1.08))
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
