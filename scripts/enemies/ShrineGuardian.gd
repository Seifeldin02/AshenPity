extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal died

enum EnemyState { IDLE, PATROL, CHASE, WINDUP, ACTIVE, RECOVERY, STAGGER, DYING, DEAD }

const EnemyBrainUtil := preload("res://scripts/enemies/EnemyBrain.gd")

@onready var visual: Node2D = %Visual
@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape: CollisionShape2D = %AttackShape
@onready var ash: CPUParticles2D = %Ash
@onready var collision_shape: CollisionShape2D = %BodyCollision

var player: Node2D
var health := GameBalance.ENEMY_MAX_HEALTH
var facing := Vector2.LEFT
var state := EnemyState.PATROL
var state_name := "patrol"
var _attack_direction := Vector2.LEFT

var _state_timer := 0.0
var _patrol_origin := Vector2.ZERO
var _patrol_target := Vector2.ZERO
var _stagger_hits := 0
var _hit_targets: Array[Node] = []
var _knockback := Vector2.ZERO
var _died_emitted := false
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("enemies")
	_rng.seed = int(global_position.x * 31.0 + global_position.y * 17.0) & 0xffff
	_patrol_origin = global_position
	_choose_patrol_target()
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_body_entered)
	health_changed.emit(health, GameBalance.ENEMY_MAX_HEALTH)


func _physics_process(delta: float) -> void:
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
	_update_facing()
	_tick_state(delta)
	_update_attack_hitbox()
	_update_visual()
	move_and_slide()


func take_damage(damage: float, source_position: Vector2 = global_position, knockback_force: float = 180.0) -> bool:
	if state in [EnemyState.DYING, EnemyState.DEAD]:
		return false
	health = maxf(health - damage, 0.0)
	health_changed.emit(health, GameBalance.ENEMY_MAX_HEALTH)
	_stagger_hits += 1
	_knockback = (global_position - source_position).normalized() * knockback_force
	if visual.has_method("trigger_flash"):
		visual.trigger_flash()
	if health <= 0.0:
		_die()
	elif _stagger_hits >= GameBalance.ENEMY_STAGGER_HITS:
		_stagger_hits = 0
		_set_state(EnemyState.STAGGER, GameBalance.ENEMY_STAGGER_TIME)
	return true


func _tick_state(delta: float) -> void:
	_state_timer -= delta
	match state:
		EnemyState.IDLE, EnemyState.PATROL:
			_patrol(delta)
			if _has_player():
				var distance := global_position.distance_to(player.global_position)
				var next_state := EnemyBrainUtil.next_awareness_state(distance, GameBalance.ENEMY_DETECT_RANGE, GameBalance.ENEMY_ATTACK_RANGE)
				if next_state == EnemyBrainUtil.State.CHASE:
					_set_state(EnemyState.CHASE, 0.0)
				elif next_state == EnemyBrainUtil.State.WINDUP:
					_begin_attack()
		EnemyState.CHASE:
			_chase(delta)
			if not _has_player():
				_set_state(EnemyState.PATROL, 0.0)
			else:
				var distance := global_position.distance_to(player.global_position)
				if distance <= GameBalance.ENEMY_ATTACK_RANGE:
					_begin_attack()
				elif distance > GameBalance.ENEMY_DETECT_RANGE * 1.25:
					_set_state(EnemyState.PATROL, 0.0)
		EnemyState.WINDUP:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _state_timer <= 0.0:
				_hit_targets.clear()
				attack_area.monitoring = true
				_set_state(EnemyState.ACTIVE, GameBalance.ENEMY_ACTIVE_TIME)
		EnemyState.ACTIVE:
			velocity = Vector2.ZERO
			_poll_attack_hits()
			if _state_timer <= 0.0:
				attack_area.monitoring = false
				_set_state(EnemyState.RECOVERY, GameBalance.ENEMY_RECOVERY_TIME)
		EnemyState.RECOVERY:
			velocity = velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
			if _state_timer <= 0.0:
				_set_state(EnemyState.CHASE if _has_player() else EnemyState.PATROL, 0.0)
		EnemyState.STAGGER:
			velocity = _knockback
			_knockback = _knockback.move_toward(Vector2.ZERO, 1400.0 * delta)
			if _state_timer <= 0.0:
				_set_state(EnemyState.CHASE if _has_player() else EnemyState.PATROL, 0.0)
		EnemyState.DYING:
			velocity = velocity.move_toward(Vector2.ZERO, 1400.0 * delta)
			modulate.a = maxf(modulate.a - delta * 1.8, 0.0)
			if _state_timer <= 0.0:
				_set_state(EnemyState.DEAD, 0.0)
				queue_free()
		EnemyState.DEAD:
			velocity = Vector2.ZERO


func _patrol(delta: float) -> void:
	var to_target := _patrol_target - global_position
	if to_target.length() < 18.0:
		_choose_patrol_target()
	velocity = velocity.move_toward(to_target.normalized() * (GameBalance.ENEMY_MOVE_SPEED * 0.38), 500.0 * delta)


func _chase(delta: float) -> void:
	var to_player := player.global_position - global_position
	var desired := to_player.normalized() * GameBalance.ENEMY_MOVE_SPEED
	velocity = velocity.move_toward(desired, 680.0 * delta)


func _begin_attack() -> void:
	velocity = Vector2.ZERO
	if _has_player():
		_attack_direction = (player.global_position - global_position).normalized()
		facing = _attack_direction
	_set_state(EnemyState.WINDUP, GameBalance.ENEMY_WINDUP_TIME)


func _die() -> void:
	attack_area.set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)
	ash.emitting = true
	_set_state(EnemyState.DYING, 0.9)
	if not _died_emitted:
		_died_emitted = true
		died.emit()


func _choose_patrol_target() -> void:
	_patrol_target = _patrol_origin + Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU)) * _rng.randf_range(28.0, GameBalance.ENEMY_PATROL_RADIUS)


func _has_player() -> bool:
	return is_instance_valid(player) and player.has_method("take_damage")


func _update_facing() -> void:
	if state in [EnemyState.WINDUP, EnemyState.ACTIVE, EnemyState.RECOVERY]:
		facing = _attack_direction
	elif _has_player() and state == EnemyState.CHASE:
		var to_player := player.global_position - global_position
		if to_player.length() > 0.1:
			facing = to_player.normalized()
	elif velocity.length() > 6.0:
		facing = velocity.normalized()


func _update_attack_hitbox() -> void:
	var attack_facing := _attack_direction if state in [EnemyState.WINDUP, EnemyState.ACTIVE, EnemyState.RECOVERY] else facing
	attack_area.position = attack_facing * 72.0
	attack_area.rotation = attack_facing.angle()


func _poll_attack_hits() -> void:
	for body in attack_area.get_overlapping_bodies():
		_on_attack_body_entered(body)


func _on_attack_body_entered(body: Node) -> void:
	if state != EnemyState.ACTIVE or _hit_targets.has(body):
		return
	if body.has_method("take_damage"):
		_hit_targets.append(body)
		body.take_damage(GameBalance.ENEMY_ATTACK_DAMAGE, global_position, GameBalance.ENEMY_ATTACK_KNOCKBACK)


func _update_visual() -> void:
	if visual.has_method("set_pose"):
		visual.set_pose(facing, state_name, health / GameBalance.ENEMY_MAX_HEALTH)


func apply_performance_mode(lightweight: bool) -> void:
	ash.amount = 36 if lightweight else 72


func _set_state(new_state: EnemyState, duration: float) -> void:
	state = new_state
	_state_timer = duration
	state_name = _state_to_name(new_state)


func _state_to_name(value: EnemyState) -> String:
	match value:
		EnemyState.IDLE:
			return "idle"
		EnemyState.PATROL:
			return "patrol"
		EnemyState.CHASE:
			return "chase"
		EnemyState.WINDUP:
			return "windup"
		EnemyState.ACTIVE:
			return "active"
		EnemyState.RECOVERY:
			return "recovery"
		EnemyState.STAGGER:
			return "stagger"
		EnemyState.DYING:
			return "dying"
		EnemyState.DEAD:
			return "dead"
	return "unknown"
