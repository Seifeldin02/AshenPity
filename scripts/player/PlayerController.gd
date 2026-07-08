extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal flask_changed(current: int, maximum: int)
signal state_changed(state: String)
signal hit_confirmed(kind: String, position: Vector2)
signal perfect_dodge(enemy: Node)
signal ash_brand_changed(enemy: Node, collect_ready: bool)
signal died

enum PlayerState { IDLE, MOVE, ATTACK_WINDUP, ATTACK_ACTIVE, ATTACK_RECOVERY, DODGE, DODGE_RECOVERY, COLLECT_WINDUP, COLLECT_ACTIVE, COLLECT_RECOVERY, HEAL, HURT, DEAD }

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
var collect_ready := false
var branded_enemy: Node

var _state_timer := 0.0
var _state_duration := 0.0
var _elapsed_in_state := 0.0
var _regen_delay := 0.0
var _roll_direction := Vector2.RIGHT
var _attack_direction := Vector2.RIGHT
var _current_attack := {}
var _combo_index := 0
var _combo_timer := 0.0
var _queued_light := false
var _queued_heavy := false
var _heal_pending := false
var _hit_targets: Array[Node] = []
var _knockback := Vector2.ZERO
var _dead_emitted := false
var _perfect_dodge_used := false
var _collect_target: Node

func _ready() -> void:
	add_to_group("player")
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_body_entered)
	_emit_all()


func _physics_process(delta: float) -> void:
	_update_aim()
	_update_stamina(delta)
	_combo_timer = maxf(_combo_timer - delta, 0.0)
	var move_input := _get_move_input()
	_tick_state(delta, move_input)
	_update_attack_hitbox()
	_update_visual()
	_update_collect_status()
	move_and_slide()


func take_damage(damage: float, source_position: Vector2 = global_position, knockback_force: float = 220.0) -> bool:
	if state == PlayerState.DEAD or invulnerable:
		return false
	if state == PlayerState.HEAL:
		_heal_pending = false
	var old_health := health
	health = CombatMathUtil.apply_damage(health, damage, false)
	health_changed.emit(health, GameBalance.PLAYER_MAX_HEALTH)
	_play_audio("player_hurt", -7.0)
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


func try_perfect_dodge(enemy: Node, _attack_position: Vector2) -> bool:
	if state != PlayerState.DODGE or not invulnerable or _perfect_dodge_used:
		return false
	var elapsed := _state_duration - _state_timer
	if not CombatMathUtil.is_perfect_dodge(elapsed, GameBalance.PLAYER_PERFECT_DODGE_WINDOW, GameBalance.PLAYER_DODGE_TIME):
		return false
	_perfect_dodge_used = true
	branded_enemy = enemy
	stamina = minf(stamina + GameBalance.PLAYER_PERFECT_DODGE_STAMINA_RESTORE, GameBalance.PLAYER_MAX_STAMINA)
	stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
	if enemy.has_method("apply_ash_brand"):
		enemy.apply_ash_brand(self)
	collect_ready = enemy.get("collect_ready") if enemy != null else false
	InputRouter.set_collect_available(collect_ready)
	_play_audio("perfect_dodge", -5.0)
	perfect_dodge.emit(enemy)
	ash_brand_changed.emit(enemy, collect_ready)
	return true


func _tick_state(delta: float, move_input: Vector2) -> void:
	_state_timer -= delta
	_elapsed_in_state = maxf(_state_duration - _state_timer, 0.0)
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
				_set_state(PlayerState.ATTACK_ACTIVE, float(_current_attack["active"]))
		PlayerState.ATTACK_ACTIVE:
			velocity = velocity.move_toward(_attack_direction * float(_current_attack["lunge"]), GameBalance.PLAYER_DECELERATION * delta)
			_poll_attack_hits()
			if _state_timer <= 0.0:
				attack_area.monitoring = false
				_set_state(PlayerState.ATTACK_RECOVERY, float(_current_attack["recovery"]))
		PlayerState.ATTACK_RECOVERY:
			if _dodge_pressed() and _elapsed_in_state >= GameBalance.PLAYER_DODGE_CANCEL_AFTER and CombatMathUtil.can_spend_stamina(stamina, GameBalance.PLAYER_DODGE_COST):
				_start_dodge(move_input)
				return
			_capture_attack_buffer()
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				if _queued_light and _can_start_light():
					_queued_light = false
					_start_light_attack()
				elif _queued_heavy and _can_start_heavy():
					_queued_heavy = false
					_start_heavy_attack()
				else:
					_queued_light = false
					_queued_heavy = false
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
			if _state_timer <= GameBalance.PLAYER_DODGE_ATTACK_BUFFER_WINDOW:
				if _action_collect_pressed() and _can_start_collect():
					_start_collect()
					return
				if _action_attack_pressed() and _can_start_light():
					_start_light_attack()
					return
				if _action_heavy_pressed() and _can_start_heavy():
					_start_heavy_attack()
					return
			if _state_timer <= 0.0:
				_set_state(PlayerState.IDLE, 0.0)
		PlayerState.COLLECT_WINDUP:
			velocity = velocity.move_toward(Vector2.ZERO, GameBalance.PLAYER_DECELERATION * delta)
			if _state_timer <= 0.0:
				_hit_targets.clear()
				attack_area.monitoring = true
				_set_state(PlayerState.COLLECT_ACTIVE, float(GameBalance.COLLECT_ATTACK["active"]))
		PlayerState.COLLECT_ACTIVE:
			velocity = _attack_direction * float(GameBalance.COLLECT_ATTACK["lunge"])
			_poll_attack_hits()
			if _state_timer <= 0.0:
				attack_area.monitoring = false
				_set_state(PlayerState.COLLECT_RECOVERY, float(GameBalance.COLLECT_ATTACK["recovery"]))
		PlayerState.COLLECT_RECOVERY:
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
	if _action_collect_pressed() and _can_start_collect():
		_start_collect()
		return
	if _action_heavy_pressed() and _can_start_heavy():
		_start_heavy_attack()
		return
	if _action_attack_pressed() and _can_start_light():
		_start_light_attack()
		return
	if _dodge_pressed() and CombatMathUtil.can_spend_stamina(stamina, GameBalance.PLAYER_DODGE_COST):
		_start_dodge(move_input)
		return
	if (Input.is_action_just_pressed("flask") or InputRouter.consume_flask()) and flask_charges > 0 and health < GameBalance.PLAYER_MAX_HEALTH:
		flask_charges -= 1
		flask_changed.emit(flask_charges, 2)
		_heal_pending = true
		_play_audio("flask", -9.0)
		_set_state(PlayerState.HEAL, GameBalance.PLAYER_HEAL_TIME)


func _capture_attack_buffer() -> void:
	if CombatMathUtil.is_attack_buffer_allowed(_state_timer, GameBalance.PLAYER_ATTACK_BUFFER_WINDOW):
		if _action_collect_pressed() and _can_start_collect():
			_start_collect()
		elif _action_attack_pressed() and _can_start_light():
			_queued_light = true
		elif _action_heavy_pressed() and _can_start_heavy():
			_queued_heavy = true


func _action_attack_pressed() -> bool:
	return Input.is_action_just_pressed("light_attack") or InputRouter.consume_attack()


func _action_heavy_pressed() -> bool:
	return Input.is_action_just_pressed("heavy_attack") or InputRouter.consume_heavy()


func _action_collect_pressed() -> bool:
	return Input.is_action_just_pressed("collect") or InputRouter.consume_collect()


func _dodge_pressed() -> bool:
	return Input.is_action_just_pressed("dodge") or InputRouter.consume_dodge()


func _can_start_light() -> bool:
	var next := _next_combo_index()
	return CombatMathUtil.can_spend_stamina(stamina, float(GameBalance.LIGHT_COMBO[next]["stamina"]))


func _can_start_heavy() -> bool:
	return CombatMathUtil.can_spend_stamina(stamina, float(GameBalance.HEAVY_ATTACK["stamina"]))


func _can_start_collect() -> bool:
	_update_collect_status()
	return collect_ready and is_instance_valid(branded_enemy) and global_position.distance_to(branded_enemy.global_position) <= GameBalance.COLLECT_TARGET_RANGE and CombatMathUtil.can_spend_stamina(stamina, float(GameBalance.COLLECT_ATTACK["stamina"]))


func _next_combo_index() -> int:
	if _combo_timer <= 0.0:
		return 0
	return clampi(_combo_index, 0, GameBalance.LIGHT_COMBO.size() - 1)


func _start_light_attack() -> void:
	var index := _next_combo_index()
	_combo_index = (index + 1) % GameBalance.LIGHT_COMBO.size()
	_combo_timer = 0.72
	_start_attack(GameBalance.LIGHT_COMBO[index], "light")


func _start_heavy_attack() -> void:
	_combo_index = 0
	_combo_timer = 0.0
	_start_attack(GameBalance.HEAVY_ATTACK, "heavy")


func _start_dodge(move_input: Vector2) -> void:
	stamina = CombatMathUtil.spend_stamina(stamina, GameBalance.PLAYER_DODGE_COST)
	_regen_delay = GameBalance.PLAYER_STAMINA_REGEN_DELAY
	stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
	_roll_direction = move_input.normalized() if move_input.length() > 0.05 else facing
	invulnerable = true
	_perfect_dodge_used = false
	attack_area.monitoring = false
	dust.emitting = true
	dust.restart()
	_play_audio("dodge", -12.0)
	_set_state(PlayerState.DODGE, GameBalance.PLAYER_DODGE_TIME)


func _start_attack(attack_data: Dictionary, _kind: String) -> void:
	_current_attack = attack_data
	stamina = CombatMathUtil.spend_stamina(stamina, float(attack_data["stamina"]))
	_regen_delay = GameBalance.PLAYER_STAMINA_REGEN_DELAY
	stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
	_attack_direction = facing
	_play_audio("sword_whoosh", -10.0)
	_set_state(PlayerState.ATTACK_WINDUP, float(attack_data["windup"]))


func _start_collect() -> void:
	_collect_target = branded_enemy
	_current_attack = GameBalance.COLLECT_ATTACK
	stamina = CombatMathUtil.spend_stamina(stamina, float(GameBalance.COLLECT_ATTACK["stamina"]))
	_regen_delay = GameBalance.PLAYER_STAMINA_REGEN_DELAY
	stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)
	_attack_direction = (_collect_target.global_position - global_position).normalized() if is_instance_valid(_collect_target) else facing
	_play_audio("collect", -4.0)
	_set_state(PlayerState.COLLECT_WINDUP, float(GameBalance.COLLECT_ATTACK["windup"]))


func _get_move_input() -> Vector2:
	return InputRouter.get_move_vector()


func _update_aim() -> void:
	if state != PlayerState.COLLECT_ACTIVE:
		facing = InputRouter.get_aim_direction(global_position, get_global_mouse_position(), facing)


func _apply_weighted_movement(move_input: Vector2, delta: float) -> void:
	var target := move_input * GameBalance.PLAYER_MOVE_SPEED
	var rate := GameBalance.PLAYER_ACCELERATION if move_input.length() > 0.05 else GameBalance.PLAYER_DECELERATION
	velocity = velocity.move_toward(target, rate * delta)


func _update_stamina(delta: float) -> void:
	if _regen_delay > 0.0:
		_regen_delay -= delta
		return
	if stamina < GameBalance.PLAYER_MAX_STAMINA and state not in [PlayerState.ATTACK_WINDUP, PlayerState.ATTACK_ACTIVE, PlayerState.DODGE, PlayerState.COLLECT_ACTIVE]:
		stamina = CombatMathUtil.regenerate_stamina(stamina, GameBalance.PLAYER_MAX_STAMINA, GameBalance.PLAYER_STAMINA_REGEN, delta)
		stamina_changed.emit(stamina, GameBalance.PLAYER_MAX_STAMINA)


func _update_attack_hitbox() -> void:
	var active_attack := _current_attack if not _current_attack.is_empty() else GameBalance.LIGHT_COMBO[0]
	var attack_facing := _attack_direction if state in [PlayerState.ATTACK_WINDUP, PlayerState.ATTACK_ACTIVE, PlayerState.ATTACK_RECOVERY, PlayerState.COLLECT_WINDUP, PlayerState.COLLECT_ACTIVE, PlayerState.COLLECT_RECOVERY] else facing
	attack_area.position = attack_facing * float(active_attack.get("range", 58.0))
	attack_area.rotation = attack_facing.angle()
	var rect := attack_shape.shape as RectangleShape2D
	if rect != null:
		rect.size = Vector2(float(active_attack.get("width", 76.0)), float(active_attack.get("height", 48.0)))


func _poll_attack_hits() -> void:
	for body in attack_area.get_overlapping_bodies():
		_on_attack_body_entered(body)


func _on_attack_body_entered(body: Node) -> void:
	if state not in [PlayerState.ATTACK_ACTIVE, PlayerState.COLLECT_ACTIVE] or _hit_targets.has(body):
		return
	if body.has_method("take_combat_hit"):
		_hit_targets.append(body)
		var hit_kind := str(_current_attack.get("name", "light"))
		var hit := {
			"damage": float(_current_attack["damage"]),
			"stagger": float(_current_attack["stagger"]),
			"knockback": float(_current_attack["knockback"]),
			"kind": hit_kind,
			"direction": _attack_direction,
			"source": self
		}
		body.take_combat_hit(hit, global_position)
		if hit_kind == "collect" and body.has_method("consume_ash_brand"):
			body.consume_ash_brand()
			branded_enemy = null
			collect_ready = false
		hit_confirmed.emit(hit_kind, body.global_position)
	elif body.has_method("take_damage"):
		_hit_targets.append(body)
		body.take_damage(float(_current_attack["damage"]), global_position, float(_current_attack["knockback"]))
		hit_confirmed.emit(str(_current_attack.get("name", "light")), body.global_position)


func _update_visual() -> void:
	var alpha := 0.0
	if state in [PlayerState.ATTACK_ACTIVE, PlayerState.COLLECT_ACTIVE]:
		alpha = 1.0
	elif state in [PlayerState.ATTACK_RECOVERY, PlayerState.COLLECT_RECOVERY]:
		alpha = 0.42
	if visual.has_method("set_pose"):
		visual.set_pose(_attack_direction if alpha > 0.0 else facing, state_name, alpha, str(_current_attack.get("name", "")))


func _update_collect_status() -> void:
	var old_ready := collect_ready
	if is_instance_valid(branded_enemy) and branded_enemy.has_method("is_collect_ready"):
		collect_ready = branded_enemy.is_collect_ready()
	else:
		collect_ready = false
		if not is_instance_valid(branded_enemy):
			branded_enemy = null
	InputRouter.set_collect_available(collect_ready)
	if old_ready != collect_ready:
		ash_brand_changed.emit(branded_enemy, collect_ready)


func is_dodge_invulnerable() -> bool:
	return state == PlayerState.DODGE and invulnerable


func apply_performance_mode(lightweight: bool) -> void:
	dust.amount = 10 if lightweight else 18


func playtest_reset(position_value: Vector2, aim: Vector2) -> void:
	global_position = position_value
	velocity = Vector2.ZERO
	health = GameBalance.PLAYER_MAX_HEALTH
	stamina = GameBalance.PLAYER_MAX_STAMINA
	flask_charges = 2
	facing = aim.normalized() if aim.length() > 0.001 else Vector2.RIGHT
	invulnerable = false
	_heal_pending = false
	_queued_light = false
	_queued_heavy = false
	_dead_emitted = false
	_combo_index = 0
	_combo_timer = 0.0
	branded_enemy = null
	collect_ready = false
	InputRouter.set_collect_available(false)
	attack_area.monitoring = false
	dust.emitting = false
	_current_attack = GameBalance.LIGHT_COMBO[0]
	_set_state(PlayerState.IDLE, 0.0)
	_emit_all()


func _set_state(new_state: PlayerState, duration: float) -> void:
	if state == new_state and duration == 0.0:
		return
	state = new_state
	_state_timer = duration
	_state_duration = duration
	state_name = _state_to_name(new_state)
	state_changed.emit(state_name)


func _state_to_name(value: PlayerState) -> String:
	match value:
		PlayerState.IDLE:
			return "idle"
		PlayerState.MOVE:
			return "move"
		PlayerState.ATTACK_WINDUP:
			return "%s_windup" % str(_current_attack.get("name", "attack"))
		PlayerState.ATTACK_ACTIVE:
			return "%s_active" % str(_current_attack.get("name", "attack"))
		PlayerState.ATTACK_RECOVERY:
			return "%s_recovery" % str(_current_attack.get("name", "attack"))
		PlayerState.DODGE, PlayerState.DODGE_RECOVERY:
			return "dodge"
		PlayerState.COLLECT_WINDUP:
			return "collect_windup"
		PlayerState.COLLECT_ACTIVE:
			return "collect_active"
		PlayerState.COLLECT_RECOVERY:
			return "collect_recovery"
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
	ash_brand_changed.emit(branded_enemy, collect_ready)


func _play_audio(cue: String, volume_db: float) -> void:
	var audio := get_node_or_null("/root/CombatAudio")
	if audio != null and audio.has_method("play"):
		audio.play(cue, volume_db)
