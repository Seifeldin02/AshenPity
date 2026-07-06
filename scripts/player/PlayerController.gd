extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal flask_changed(current: int, maximum: int)
signal state_changed(state: String)
signal hit_confirmed
signal died

enum PlayerState { IDLE, MOVE, ATTACK_WINDUP, ATTACK_ACTIVE, ATTACK_RECOVERY, DODGE, DODGE_RECOVERY, HEAL, HURT, DEAD }

const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")

@onready var visual: Node2D = %Visual
@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape: CollisionShape2D = %AttackShape
@onready var dust: CPUParticles2D = %Dust

var health := GameBalance.PLAYER_MAX_HEALTH
var stamina := GameBalance.PLAYER_MAX_STAMINA
var flask_charges := 2
var facing := Vector2.RIGHT
var state := PlayerState.IDLE
var state_name := "idle"
var invulnerable := false

var _state_timer := 0.0
var _regen_delay := 0.0
var _roll_direction := Vector2.RIGHT
var _attack_direction := Vector2.RIGHT
var _heal_pending := false
var _queued_attack := false
var _hit_targets: Array[Node] = []
var _knockback := Vector2.ZERO
var _dead_emitted := false

func _ready() -> void:
	add_to_group("player")
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_body_entered)
	_emit_all()


func _physics_process(delta: float) -> void:
	_update_aim()
	_update_stamina(delta)
	var move_input := _get_move_input()
	_tick_state(delta, move_input)
	_update_attack_hitbox()
	_update_visual()
	move_and_slide()


func take_damage(damage: float, source_position: Vector2 = global_position, knockback_force: float = 220.0) -> bool:
	if state == PlayerState.DEAD or invulnerable:
		return false
	if state == PlayerState.HEAL:
		_heal_pending = false
	var old_health := health
	health = CombatMathUtil.apply_damage(health, damage, false)
	health_changed.emit(health, GameBalance.PLAYER_MAX_HEALTH)
	if visual.has_method("trigger_flash"):
		visual.trigger_flash()
	_knockback = (global_position - source_position).normalized() * knockback_force
	if health <= 0.0:
		_set_state(PlayerState.DEAD, 999.0)
		if not _dead_emitted:
			_dead_emitted = true
			died.emit()
	else:
		_set_state(PlayerState.HURT, GameBalance.PLAYER_HURT_TIME)
	return health < old_health


func heal_to_full_for_test() -> void:
	health = GameBalance.PLAYER_MAX_HEALTH
	health_changed.emit(health, GameBalance.PLAYER_MAX_HEALTH)


func _tick_state(delta: float, move_input: Vector2) -> void:
	_state_timer -= delta
	match state:
		PlayerState.IDLE, PlayerState.MOVE:
			_handle_actions(move_input)
			if state == PlayerState.IDLE or state == PlayerState.MOVE:
				_apply_weighted_movement(move_input, delta)
				_set_state(PlayerState.MOVE if move_input.length() > 0.05 else PlayerState.IDLE, 0.0)
		PlayerState.ATTACK_WINDUP:
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				_hit_targets.clear()
				attack_area.monitoring = true
				_set_state(PlayerState.ATTACK_ACTIVE, GameBalance.PLAYER_ATTACK_ACTIVE_TIME)
		PlayerState.ATTACK_ACTIVE:
			velocity = velocity.move_toward(_attack_direction * 42.0, GameBalance.PLAYER_DECELERATION * delta)
			_poll_attack_hits()
			if _state_timer <= 0.0:
				attack_area.monitoring = false
				_set_state(PlayerState.ATTACK_RECOVERY, GameBalance.PLAYER_ATTACK_RECOVERY_TIME)
		PlayerState.ATTACK_RECOVERY:
			if _action_attack_pressed() and _state_timer <= GameBalance.PLAYER_ATTACK_BUFFER_WINDOW and CombatMathUtil.can_spend_stamina(stamina, GameBalance.PLAYER_ATTACK_COST):
				_queued_attack = true
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				if _queued_attack and CombatMathUtil.can_spend_stamina(stamina, GameBalance.PLAYER_ATTACK_COST):
					_queued_attack = false
					_start_attack()
				else:
					_queued_attack = false
					_set_state(PlayerState.IDLE, 0.0)
		PlayerState.DODGE:
			velocity = _roll_direction * GameBalance.PLAYER_DODGE_SPEED
			if _state_timer <= GameBalance.PLAYER_DODGE_TIME - GameBalance.PLAYER_DODGE_INVULN_TIME:
				invulnerable = false
			if _state_timer <= 0.0:
				invulnerable = false
				dust.emitting = false
				_set_state(PlayerState.DODGE_RECOVERY, GameBalance.PLAYER_DODGE_RECOVERY)
		PlayerState.DODGE_RECOVERY:
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				_set_state(PlayerState.IDLE, 0.0)
		PlayerState.HEAL:
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				if _heal_pending:
					health = minf(health + GameBalance.PLAYER_HEAL_AMOUNT, GameBalance.PLAYER_MAX_HEALTH)
					health_changed.emit(health, GameBalance.PLAYER_MAX_HEALTH)
				_heal_pending = false
				_set_state(PlayerState.IDLE, 0.0)
		PlayerState.HURT:
			velocity = _knockback
			_knockback = _knockback.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				_set_state(PlayerState.IDLE, 0.0)
		PlayerState.DEAD:
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)


func _handle_actions(move_input: Vector2) -> void:
	if _action_attack_pressed() and CombatMathUtil.can_spend_stamina(stamina, GameBalance.PLAYER_ATTACK_COST):
		_start_attack()
		return
	if (Input.is_action_just_pressed("dodge") or InputRouter.consume_dodge()) and CombatMathUtil.can_spend_stamina(stamina, GameBalance.PLAYER_DODGE_COST):
		stamina = CombatMathUtil.spend_stamina(stamina, GameBalance.PLAYER_DODGE_COST)
		_regen_delay = GameBalance.PLAYER_STAMINA_REGEN_DELAY
		stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
		_roll_direction = move_input.normalized() if move_input.length() > 0.05 else facing
		invulnerable = true
		dust.emitting = true
		dust.restart()
		_set_state(PlayerState.DODGE, GameBalance.PLAYER_DODGE_TIME)
		return
	if (Input.is_action_just_pressed("flask") or InputRouter.consume_flask()) and flask_charges > 0 and health < GameBalance.PLAYER_MAX_HEALTH:
		flask_charges -= 1
		flask_changed.emit(flask_charges, 2)
		_heal_pending = true
		_set_state(PlayerState.HEAL, GameBalance.PLAYER_HEAL_TIME)


func _action_attack_pressed() -> bool:
	return Input.is_action_just_pressed("light_attack") or InputRouter.consume_attack()


func _start_attack() -> void:
	stamina = CombatMathUtil.spend_stamina(stamina, GameBalance.PLAYER_ATTACK_COST)
	_regen_delay = GameBalance.PLAYER_STAMINA_REGEN_DELAY
	stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
	_attack_direction = facing
	_set_state(PlayerState.ATTACK_WINDUP, GameBalance.PLAYER_ATTACK_WINDUP_TIME)


func _get_move_input() -> Vector2:
	return InputRouter.get_move_vector()


func _update_aim() -> void:
	facing = InputRouter.get_aim_direction(global_position, get_global_mouse_position(), facing)


func _apply_weighted_movement(move_input: Vector2, delta: float) -> void:
	var target := move_input * GameBalance.PLAYER_MOVE_SPEED
	var rate := GameBalance.PLAYER_ACCELERATION if move_input.length() > 0.05 else GameBalance.PLAYER_DECELERATION
	velocity = velocity.move_toward(target, rate * delta)


func _update_stamina(delta: float) -> void:
	if _regen_delay > 0.0:
		_regen_delay -= delta
		return
	if stamina < GameBalance.PLAYER_MAX_STAMINA and state not in [PlayerState.ATTACK_WINDUP, PlayerState.ATTACK_ACTIVE, PlayerState.DODGE]:
		stamina = minf(stamina + GameBalance.PLAYER_STAMINA_REGEN * delta, GameBalance.PLAYER_MAX_STAMINA)
		stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)


func _update_attack_hitbox() -> void:
	var attack_facing := _attack_direction if state in [PlayerState.ATTACK_WINDUP, PlayerState.ATTACK_ACTIVE, PlayerState.ATTACK_RECOVERY] else facing
	attack_area.position = attack_facing * 58.0
	attack_area.rotation = attack_facing.angle()


func _poll_attack_hits() -> void:
	for body in attack_area.get_overlapping_bodies():
		_on_attack_body_entered(body)


func _on_attack_body_entered(body: Node) -> void:
	if state != PlayerState.ATTACK_ACTIVE or _hit_targets.has(body):
		return
	if body.has_method("take_damage"):
		_hit_targets.append(body)
		body.take_damage(GameBalance.PLAYER_ATTACK_DAMAGE, global_position, GameBalance.PLAYER_ATTACK_KNOCKBACK)
		hit_confirmed.emit()


func _update_visual() -> void:
	var alpha := 1.0 if state == PlayerState.ATTACK_ACTIVE else (0.42 if state == PlayerState.ATTACK_RECOVERY else 0.0)
	if visual.has_method("set_pose"):
		visual.set_pose(_attack_direction if alpha > 0.0 else facing, state_name, alpha)


func is_dodge_invulnerable() -> bool:
	return state == PlayerState.DODGE and invulnerable


func _set_state(new_state: PlayerState, duration: float) -> void:
	if state == new_state and duration == 0.0:
		return
	state = new_state
	_state_timer = duration
	state_name = _state_to_name(new_state)
	state_changed.emit(state_name)


func _state_to_name(value: PlayerState) -> String:
	match value:
		PlayerState.IDLE:
			return "idle"
		PlayerState.MOVE:
			return "move"
		PlayerState.ATTACK_WINDUP:
			return "attack_windup"
		PlayerState.ATTACK_ACTIVE:
			return "attack_active"
		PlayerState.ATTACK_RECOVERY:
			return "attack_recovery"
		PlayerState.DODGE, PlayerState.DODGE_RECOVERY:
			return "dodge"
		PlayerState.HEAL:
			return "heal"
		PlayerState.HURT:
			return "hurt"
		PlayerState.DEAD:
			return "dead"
	return "unknown"


func _emit_all() -> void:
	health_changed.emit(health, GameBalance.PLAYER_MAX_HEALTH)
	stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
	flask_changed.emit(flask_charges, 2)
	state_changed.emit(state_name)
