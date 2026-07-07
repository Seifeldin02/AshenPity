extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal brand_changed(branded: bool, collect_ready: bool)
signal died

enum EnemyState { IDLE, PATROL, CHASE, WINDUP, ACTIVE, RECOVERY, STAGGER, DYING, DEAD }

const EnemyBrainUtil := preload("res://scripts/enemies/EnemyBrain.gd")
const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")
const ProjectileScript := preload("res://scripts/enemies/EnemyProjectile.gd")

@export_enum("guardian", "hound", "archer", "bell_bearer") var enemy_kind := "guardian"

@onready var visual: Node2D = %Visual
@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape: CollisionShape2D = %AttackShape
@onready var ash: CPUParticles2D = %Ash
@onready var collision_shape: CollisionShape2D = %BodyCollision

var player: Node2D
var health := GameBalance.ENEMY_MAX_HEALTH
var max_health := GameBalance.ENEMY_MAX_HEALTH
var facing := Vector2.LEFT
var state := EnemyState.PATROL
var state_name := "patrol"
var ash_branded := false
var collect_ready := false
var display_name := "Shrine Guardian"

var _config := {}
var _attack_direction := Vector2.LEFT
var _state_timer := 0.0
var _patrol_origin := Vector2.ZERO
var _patrol_target := Vector2.ZERO
var _stagger_meter := 0.0
var _brand_timer := 0.0
var _brand_hits := 0
var _hit_targets: Array[Node] = []
var _knockback := Vector2.ZERO
var _died_emitted := false
var _rng := RandomNumberGenerator.new()
var _elite_attack_flip := false

func _ready() -> void:
	add_to_group("enemies")
	_apply_config()
	_rng.seed = int(global_position.x * 31.0 + global_position.y * 17.0 + float(enemy_kind.hash())) & 0xffff
	_patrol_origin = global_position
	_choose_patrol_target()
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_body_entered)
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
	_update_brand(delta)
	_update_facing()
	_tick_state(delta)
	_update_attack_hitbox()
	_update_visual()
	move_and_slide()


func _apply_config() -> void:
	_config = GameBalance.ENEMY_CONFIGS.get(enemy_kind, GameBalance.ENEMY_CONFIGS["guardian"])
	display_name = str(_config["display_name"])
	max_health = float(_config["max_health"])
	health = max_health


func take_damage(damage: float, source_position: Vector2 = global_position, knockback_force: float = 180.0) -> bool:
	return take_combat_hit({"damage": damage, "stagger": 1.0, "knockback": knockback_force, "kind": "legacy"}, source_position)


func take_combat_hit(hit: Dictionary, source_position: Vector2 = global_position) -> bool:
	if state in [EnemyState.DYING, EnemyState.DEAD]:
		return false
	var damage := float(hit.get("damage", 0.0))
	var stagger := float(hit.get("stagger", 1.0))
	var knockback_force := float(hit.get("knockback", 180.0))
	var kind := str(hit.get("kind", "light"))
	health = maxf(health - damage, 0.0)
	health_changed.emit(health, max_health)
	_stagger_meter += stagger
	_knockback = (global_position - source_position).normalized() * knockback_force
	if ash_branded and kind.begins_with("light"):
		_brand_hits = CombatMathUtil.ash_brand_hit_progress(_brand_hits, GameBalance.ASH_BRAND_HITS_TO_COLLECT)
		collect_ready = CombatMathUtil.is_collect_ready(_brand_hits, GameBalance.ASH_BRAND_HITS_TO_COLLECT)
		brand_changed.emit(ash_branded, collect_ready)
	if visual.has_method("trigger_flash"):
		visual.trigger_flash()
	_play_audio("heavy_hit" if kind == "heavy" or kind == "collect" else "light_hit", -7.0)
	if health <= 0.0:
		_die()
	elif _stagger_meter >= float(_config["stagger_threshold"]):
		_stagger_meter = 0.0
		_play_audio("enemy_stagger", -6.0)
		_set_state(EnemyState.STAGGER, GameBalance.ENEMY_STAGGER_TIME + stagger * 0.04)
	return true


func apply_ash_brand(_source: Node) -> void:
	if state in [EnemyState.DYING, EnemyState.DEAD]:
		return
	ash_branded = true
	collect_ready = false
	_brand_hits = 0
	_brand_timer = GameBalance.ASH_BRAND_DURATION
	_play_audio("ash_brand", -5.0)
	brand_changed.emit(ash_branded, collect_ready)


func consume_ash_brand() -> void:
	ash_branded = false
	collect_ready = false
	_brand_hits = 0
	_brand_timer = 0.0
	brand_changed.emit(false, false)


func is_collect_ready() -> bool:
	return ash_branded and collect_ready


func _update_brand(delta: float) -> void:
	if not ash_branded:
		return
	_brand_timer -= delta
	if _brand_timer <= 0.0:
		consume_ash_brand()


func _tick_state(delta: float) -> void:
	_state_timer -= delta
	match state:
		EnemyState.IDLE, EnemyState.PATROL:
			_patrol(delta)
			if _has_player():
				var distance := global_position.distance_to(player.global_position)
				var next_state := EnemyBrainUtil.next_awareness_state(distance, float(_config["detect_range"]), float(_config["attack_range"]))
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
				if distance <= float(_config["attack_range"]):
					_begin_attack()
				elif distance > float(_config["detect_range"]) * 1.25:
					_set_state(EnemyState.PATROL, 0.0)
		EnemyState.WINDUP:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _state_timer <= 0.0:
				_hit_targets.clear()
				if str(_config["attack_style"]) == "ranged":
					_fire_projectile()
				else:
					attack_area.monitoring = true
				_set_state(EnemyState.ACTIVE, float(_config["active"]))
		EnemyState.ACTIVE:
			if enemy_kind == "hound":
				velocity = _attack_direction * 130.0
			else:
				velocity = Vector2.ZERO
			if attack_area.monitoring:
				_poll_attack_hits()
			if _state_timer <= 0.0:
				attack_area.monitoring = false
				_set_state(EnemyState.RECOVERY, float(_config["recovery"]))
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
	velocity = velocity.move_toward(to_target.normalized() * (float(_config["move_speed"]) * 0.38), 500.0 * delta)


func _chase(delta: float) -> void:
	var to_player := player.global_position - global_position
	var desired := to_player.normalized() * float(_config["move_speed"])
	if enemy_kind == "archer" and to_player.length() < 260.0:
		desired = -to_player.normalized() * float(_config["move_speed"])
	velocity = velocity.move_toward(desired, 760.0 * delta)


func _begin_attack() -> void:
	velocity = Vector2.ZERO
	if _has_player():
		_attack_direction = (player.global_position - global_position).normalized()
		facing = _attack_direction
	if enemy_kind == "bell_bearer":
		_elite_attack_flip = not _elite_attack_flip
	_set_state(EnemyState.WINDUP, float(_config["windup"]) + (0.18 if enemy_kind == "bell_bearer" and _elite_attack_flip else 0.0))


func _fire_projectile() -> void:
	var projectile := Area2D.new()
	projectile.name = "ReliquaryBolt"
	projectile.collision_layer = 0
	projectile.collision_mask = 2
	projectile.set_script(ProjectileScript)
	projectile.global_position = global_position + _attack_direction * 48.0
	projectile.set("direction", _attack_direction)
	projectile.set("damage", float(_config["attack_damage"]))
	projectile.set("knockback", float(_config["attack_knockback"]))
	projectile.set("source_enemy", self)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	projectile.add_child(shape)
	get_parent().add_child(projectile)


func _die() -> void:
	attack_area.set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)
	ash.emitting = true
	_play_audio("enemy_death", -7.0)
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
	var range := float(_config["attack_range"]) * (1.08 if enemy_kind == "bell_bearer" and _elite_attack_flip else 0.72)
	attack_area.position = attack_facing * range
	attack_area.rotation = attack_facing.angle()
	var rect := attack_shape.shape as RectangleShape2D
	if rect != null:
		if enemy_kind == "hound":
			rect.size = Vector2(72, 46)
		elif enemy_kind == "bell_bearer" and _elite_attack_flip:
			rect.size = Vector2(170, 84)
		else:
			rect.size = Vector2(104, 58)


func _poll_attack_hits() -> void:
	for body in attack_area.get_overlapping_bodies():
		_on_attack_body_entered(body)


func _on_attack_body_entered(body: Node) -> void:
	if state != EnemyState.ACTIVE or _hit_targets.has(body):
		return
	if body.has_method("try_perfect_dodge") and body.try_perfect_dodge(self, global_position):
		_hit_targets.append(body)
		return
	if body.has_method("take_damage"):
		_hit_targets.append(body)
		body.take_damage(float(_config["attack_damage"]), global_position, float(_config["attack_knockback"]))


func _update_visual() -> void:
	if visual.has_method("set_pose"):
		visual.set_pose(facing, state_name, health / max_health, enemy_kind, ash_branded, collect_ready)


func apply_performance_mode(lightweight: bool) -> void:
	ash.amount = 36 if lightweight else 72


func playtest_reset(position_value: Vector2, player_ref: Node2D) -> void:
	global_position = position_value
	velocity = Vector2.ZERO
	player = player_ref
	_apply_config()
	facing = Vector2.LEFT
	_attack_direction = Vector2.LEFT
	_state_timer = 0.0
	_stagger_meter = 0.0
	_hit_targets.clear()
	_knockback = Vector2.ZERO
	_died_emitted = false
	modulate = Color.WHITE
	attack_area.monitoring = false
	collision_shape.disabled = false
	ash.emitting = false
	consume_ash_brand()
	_patrol_origin = global_position
	_choose_patrol_target()
	_set_state(EnemyState.PATROL, 0.0)
	health_changed.emit(health, max_health)


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


func _play_audio(cue: String, volume_db: float) -> void:
	var audio := get_node_or_null("/root/CombatAudio")
	if audio != null and audio.has_method("play"):
		audio.play(cue, volume_db)
