extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal brand_changed(branded: bool, collect_ready: bool)
signal died

enum EnemyState { IDLE, PATROL, CHASE, WINDUP, ACTIVE, RECOVERY, STAGGER, DYING, DEAD }

const EnemyBrainUtil := preload("res://scripts/enemies/EnemyBrain.gd")
const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")
const ProjectileScript := preload("res://scripts/enemies/EnemyProjectile.gd")

@export_enum("guardian", "hound", "archer", "bell_bearer", "ashen_judicator") var enemy_kind := "guardian"

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
var _ai_time := 0.0
var _attack_pattern := "sweep"
var _boss_pattern_index := 0
var _special_fired := false

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
	_ai_time += delta
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
	var hit_direction: Vector2 = hit.get("direction", (global_position - source_position).normalized())
	var is_counter := state == EnemyState.WINDUP
	var is_rear_hit := hit_direction.length() > 0.01 and hit_direction.normalized().dot(facing.normalized()) > 0.52
	if is_counter:
		damage *= GameBalance.COUNTER_HIT_DAMAGE_MULTIPLIER
		stagger *= GameBalance.COUNTER_HIT_STAGGER_MULTIPLIER
	if is_rear_hit:
		damage *= GameBalance.REAR_HIT_DAMAGE_MULTIPLIER
		stagger += GameBalance.REAR_HIT_STAGGER_BONUS
	if state == EnemyState.RECOVERY:
		stagger += GameBalance.RECOVERY_PUNISH_STAGGER_BONUS
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
	if is_counter or is_rear_hit:
		_play_audio("armor_hit", -6.5)
	else:
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


func prime_parry_collect(_source: Node) -> void:
	if state in [EnemyState.DYING, EnemyState.DEAD]:
		return
	ash_branded = true
	collect_ready = true
	_brand_hits = GameBalance.ASH_BRAND_HITS_TO_COLLECT
	_brand_timer = GameBalance.ASH_BRAND_DURATION + GameBalance.PLAYER_PARRY_BRAND_DURATION_BONUS
	_play_audio("ash_brand", -3.5)
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
				_special_fired = false
				if str(_config["attack_style"]) == "ranged":
					_fire_projectile()
				elif str(_config["attack_style"]) == "boss" and _attack_pattern == "toll":
					_spawn_radial_projectiles(8, 360.0, 0.72)
				else:
					attack_area.monitoring = true
				_set_state(EnemyState.ACTIVE, float(_config["active"]))
		EnemyState.ACTIVE:
			if enemy_kind == "hound":
				velocity = _attack_direction * 130.0
			elif enemy_kind == "ashen_judicator" and _attack_pattern == "lunge":
				velocity = _attack_direction * 390.0
			elif enemy_kind == "ashen_judicator" and _attack_pattern == "slam":
				velocity = velocity.move_toward(Vector2.ZERO, 1600.0 * delta)
			else:
				velocity = Vector2.ZERO
			if attack_area.monitoring:
				_poll_attack_hits()
			if enemy_kind == "ashen_judicator" and _attack_pattern == "slam" and not _special_fired and _state_timer <= float(_config["active"]) * 0.45:
				_special_fired = true
				_spawn_radial_projectiles(6, 300.0, 0.55)
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
	elif enemy_kind == "ashen_judicator" and to_player.length() < 230.0:
		var boss_tangent := to_player.normalized().orthogonal() * sin(_ai_time * 2.6)
		desired = (to_player.normalized() * 0.22 + boss_tangent * 0.48).normalized() * float(_config["move_speed"]) * 0.72
	elif enemy_kind == "guardian" and to_player.length() < 260.0:
		var tangent := to_player.normalized().orthogonal() * sin(_ai_time * 4.8 + global_position.x * 0.01)
		desired = (to_player.normalized() + tangent * 0.28).normalized() * float(_config["move_speed"])
	elif enemy_kind == "hound" and to_player.length() < 190.0:
		var tangent_hound := to_player.normalized().orthogonal() * signf(sin(_ai_time * 8.0 + global_position.y * 0.02))
		desired = (to_player.normalized() * 0.85 + tangent_hound * 0.32).normalized() * float(_config["move_speed"])
	velocity = velocity.move_toward(desired, 760.0 * delta)


func _begin_attack() -> void:
	velocity = Vector2.ZERO
	if _has_player():
		_attack_direction = (player.global_position - global_position).normalized()
		facing = _attack_direction
	if enemy_kind == "bell_bearer":
		_elite_attack_flip = not _elite_attack_flip
	if enemy_kind == "ashen_judicator":
		var patterns := ["sweep", "lunge", "slam", "toll"]
		_attack_pattern = patterns[_boss_pattern_index % patterns.size()]
		_boss_pattern_index += 1
	else:
		_attack_pattern = "lunge" if enemy_kind == "hound" else "sweep"
	_special_fired = false
	var windup := float(_config["windup"]) + (0.18 if enemy_kind == "bell_bearer" and _elite_attack_flip else 0.0)
	if enemy_kind == "ashen_judicator":
		match _attack_pattern:
			"lunge":
				windup = 0.50
			"slam":
				windup = 0.78
			"toll":
				windup = 0.92
			_:
				windup = 0.62
	_set_state(EnemyState.WINDUP, windup)


func _fire_projectile() -> void:
	_spawn_projectile(_attack_direction, 430.0, 1.0)


func _spawn_projectile(direction_value: Vector2, speed_value: float, damage_scale: float) -> void:
	var projectile := Area2D.new()
	projectile.name = "ReliquaryBolt"
	projectile.collision_layer = 0
	projectile.collision_mask = 2
	projectile.set_script(ProjectileScript)
	projectile.global_position = global_position + direction_value.normalized() * 56.0
	projectile.set("direction", direction_value.normalized())
	projectile.set("speed", speed_value)
	projectile.set("damage", float(_config["attack_damage"]) * damage_scale)
	projectile.set("knockback", float(_config["attack_knockback"]))
	projectile.set("source_enemy", self)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	projectile.add_child(shape)
	get_parent().add_child(projectile)


func _spawn_radial_projectiles(count: int, speed_value: float, damage_scale: float) -> void:
	for i in count:
		var angle := _attack_direction.angle() + float(i) * TAU / float(count)
		_spawn_projectile(Vector2.RIGHT.rotated(angle), speed_value, damage_scale)


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
	if enemy_kind == "ashen_judicator":
		match _attack_pattern:
			"lunge":
				range = 150.0
			"slam":
				range = 70.0
			"toll":
				range = 0.0
			_:
				range = 118.0
	attack_area.position = attack_facing * range
	attack_area.rotation = attack_facing.angle()
	var rect := attack_shape.shape as RectangleShape2D
	if rect != null:
		if enemy_kind == "hound":
			rect.size = Vector2(72, 46)
		elif enemy_kind == "bell_bearer" and _elite_attack_flip:
			rect.size = Vector2(170, 84)
		elif enemy_kind == "ashen_judicator" and _attack_pattern == "slam":
			rect.size = Vector2(220, 148)
		elif enemy_kind == "ashen_judicator" and _attack_pattern == "lunge":
			rect.size = Vector2(126, 72)
		elif enemy_kind == "ashen_judicator":
			rect.size = Vector2(180, 92)
		else:
			rect.size = Vector2(104, 58)


func _poll_attack_hits() -> void:
	for body in attack_area.get_overlapping_bodies():
		_on_attack_body_entered(body)


func _on_attack_body_entered(body: Node) -> void:
	if state != EnemyState.ACTIVE or _hit_targets.has(body):
		return
	if body.has_method("try_parry") and body.try_parry(self, global_position):
		_hit_targets.append(body)
		return
	if body.has_method("try_perfect_dodge") and body.try_perfect_dodge(self, global_position):
		_hit_targets.append(body)
		return
	if body.has_method("take_damage"):
		_hit_targets.append(body)
		body.take_damage(float(_config["attack_damage"]), global_position, float(_config["attack_knockback"]))


func _update_visual() -> void:
	if visual.has_method("set_pose"):
		visual.set_pose(facing, state_name, health / max_health, enemy_kind, ash_branded, collect_ready, _attack_pattern)


func receive_parry(source: Node, hit_position: Vector2) -> void:
	if state in [EnemyState.DYING, EnemyState.DEAD]:
		return
	var stagger_scale := GameBalance.BOSS_PARRY_STAGGER_RESIST if enemy_kind == "ashen_judicator" else 1.0
	var hit := {
		"damage": float(GameBalance.PARRY_COUNTER["damage"]),
		"stagger": float(GameBalance.PARRY_COUNTER["stagger"]) * stagger_scale,
		"knockback": float(GameBalance.PARRY_COUNTER["knockback"]),
		"kind": "parry",
		"direction": (global_position - hit_position).normalized(),
		"source": source
	}
	take_combat_hit(hit, hit_position)
	if enemy_kind == "ashen_judicator":
		_set_state(EnemyState.STAGGER, 0.34)
	else:
		_set_state(EnemyState.STAGGER, 0.48)


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
	_ai_time = 0.0
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
