extends SceneTree

const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")
const EnemyBrainUtil := preload("res://scripts/enemies/EnemyBrain.gd")
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
