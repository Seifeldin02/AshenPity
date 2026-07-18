class_name PlayerAnimationController
extends Node

const CHARACTER_ROOT := "res://assets/sprites/sideview/wanderer/"
const FRAME_COUNTS := {
	&"idle": 4,
	&"run": 8,
	&"normal": 7,
	&"heavy": 8,
	&"parry": 6,
	&"skill": 8,
	&"death": 6,
}
const FILE_PREFIX := {
	&"idle": "idle",
	&"run": "run",
	&"normal": "light",
	&"heavy": "heavy",
	&"parry": "parry",
	&"skill": "skill",
	&"death": "death",
}

@export var tuning: SideViewAnimationTuning
@export var visual_scale := 0.72

@onready var action_state: PlayerActionState = %AnimationStateController
@onready var character_visual: Node2D = %CharacterVisual
@onready var body: AnimatedSprite2D = %Body
@onready var weapon_socket: WeaponSocket = %WeaponSocket
@onready var weapon_visual: WeaponVisual = %WeaponVisual
@onready var blade_trail: WeaponBladeTrail = %BladeTrail
@onready var skill_impact: Sprite2D = %SkillImpact
@onready var secondary_animation: AnimationPlayer = %AnimationPlayer

var _review_mode := false
var _review_paused := false
var _review_speed := 1.0


func _ready() -> void:
	body.sprite_frames = _build_character_frames()
	weapon_socket.follow_speed = tuning.weapon_follow_speed
	action_state.state_changed.connect(_on_state_changed)
	character_visual.scale = Vector2(visual_scale, visual_scale)
	_install_secondary_animations()
	_on_state_changed(&"", PlayerActionState.IDLE)
	weapon_socket.target_pose(body.animation, body.frame, true)


func _process(_delta: float) -> void:
	weapon_socket.target_pose(body.animation, body.frame, _review_paused)
	blade_trail.set_action_frame(body.animation, body.frame)
	var show_impact := body.animation == PlayerActionState.SKILL and body.frame == 5
	skill_impact.visible = show_impact
	if show_impact:
		skill_impact.modulate.a = 0.7 + 0.3 * sin(body.frame_progress * PI)


func request_action(action: StringName) -> bool:
	if _review_mode:
		return false
	return action_state.request_action(
		action,
		_duration_for(action),
		tuning.input_buffer_window
	)


func set_locomotion(moving: bool) -> void:
	if not _review_mode:
		action_state.set_locomotion(moving)


func set_facing(direction: float) -> void:
	if is_zero_approx(direction):
		return
	character_visual.scale.x = visual_scale * signf(direction)


func is_action_locked() -> bool:
	return action_state.is_action_locked() or _review_mode


func movement_scale() -> float:
	match action_state.current:
		PlayerActionState.NORMAL:
			return tuning.normal_movement_scale
		PlayerActionState.HEAVY:
			return tuning.heavy_movement_scale
		PlayerActionState.PARRY:
			return tuning.parry_movement_scale
		PlayerActionState.SKILL:
			return tuning.skill_movement_scale
		PlayerActionState.HURT, PlayerActionState.DEATH:
			return 0.0
		_:
			return 1.0


func set_review_mode(enabled: bool) -> void:
	_review_mode = enabled
	_review_paused = false
	action_state.set_review_mode(enabled)
	if enabled:
		play_review_animation(&"idle")
	else:
		body.speed_scale = 1.0
		secondary_animation.speed_scale = 1.0


func play_review_animation(animation: StringName) -> void:
	if not _review_mode or not body.sprite_frames.has_animation(animation):
		return
	_review_paused = false
	body.speed_scale = _review_speed
	body.play(animation)
	weapon_visual.set_action(animation)
	_play_secondary(animation)
	secondary_animation.speed_scale = _review_speed


func toggle_review_pause() -> bool:
	if not _review_mode:
		return false
	_review_paused = not _review_paused
	if _review_paused:
		body.pause()
		secondary_animation.pause()
	else:
		body.play()
		secondary_animation.play()
	return _review_paused


func step_review_frame(direction: int) -> void:
	if not _review_mode or not _review_paused:
		return
	var count := body.sprite_frames.get_frame_count(body.animation)
	body.frame = posmod(body.frame + direction, count)
	body.frame_progress = 0.0
	weapon_socket.target_pose(body.animation, body.frame, true)


func set_review_speed(speed: float) -> void:
	_review_speed = clampf(speed, 0.25, 1.0)
	body.speed_scale = _review_speed
	secondary_animation.speed_scale = _review_speed


func set_weapon_debug_visible(enabled: bool) -> void:
	weapon_socket.set_debug_visible(enabled)


func current_animation() -> StringName:
	return body.animation


func current_frame() -> int:
	return body.frame


func current_animation_fps() -> float:
	return body.sprite_frames.get_animation_speed(body.animation)


func review_speed() -> float:
	return _review_speed


func review_paused() -> bool:
	return _review_paused


func current_state() -> StringName:
	return body.animation if _review_mode else action_state.current


func _on_state_changed(_previous: StringName, current: StringName) -> void:
	if _review_mode:
		return
	body.speed_scale = 1.0
	body.play(current)
	weapon_visual.set_action(current)
	_play_secondary(current)


func _build_character_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation: StringName in FRAME_COUNTS:
		frames.add_animation(animation)
		frames.set_animation_loop(animation, animation in [&"idle", &"run"])
		frames.set_animation_speed(animation, _fps_for(animation))
		var prefix: String = FILE_PREFIX[animation]
		var holds := _holds_for(animation)
		for frame_index in range(FRAME_COUNTS[animation]):
			var texture := load(CHARACTER_ROOT + "%s_%02d.png" % [prefix, frame_index])
			frames.add_frame(animation, texture, holds[frame_index])
	frames.add_animation(&"hurt")
	frames.set_animation_loop(&"hurt", false)
	frames.set_animation_speed(&"hurt", tuning.hurt_fps)
	frames.add_frame(&"hurt", load(CHARACTER_ROOT + "death_00.png"), tuning.hurt_frame_holds[0])
	frames.add_frame(&"hurt", load(CHARACTER_ROOT + "death_01.png"), tuning.hurt_frame_holds[1])
	return frames


func _fps_for(animation: StringName) -> float:
	match animation:
		&"idle":
			return tuning.idle_fps
		&"run":
			return tuning.run_fps
		&"normal":
			return tuning.normal_fps
		&"heavy":
			return tuning.heavy_fps
		&"parry":
			return tuning.parry_fps
		&"skill":
			return tuning.skill_fps
		&"death":
			return tuning.death_fps
		_:
			return tuning.hurt_fps


func _holds_for(animation: StringName) -> PackedFloat32Array:
	match animation:
		&"idle":
			return tuning.idle_frame_holds
		&"run":
			return tuning.run_frame_holds
		&"normal":
			return tuning.normal_frame_holds
		&"heavy":
			return tuning.heavy_frame_holds
		&"parry":
			return tuning.parry_frame_holds
		&"skill":
			return tuning.skill_frame_holds
		&"death":
			return tuning.death_frame_holds
		_:
			return tuning.hurt_frame_holds


func _duration_for(animation: StringName) -> float:
	var holds := _holds_for(animation)
	var total_frames := 0.0
	for hold in holds:
		total_frames += hold
	return total_frames / _fps_for(animation)


func _play_secondary(animation: StringName) -> void:
	if secondary_animation.has_animation(animation):
		secondary_animation.play(animation)


func _install_secondary_animations() -> void:
	if secondary_animation.has_animation_library(&""):
		secondary_animation.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	var definitions := {
		&"idle": [Vector2.ZERO, Vector2(0, -2), Vector2.ZERO],
		&"run": [Vector2.ZERO, Vector2(0, 3), Vector2(0, -3), Vector2.ZERO],
		&"normal": [Vector2.ZERO, Vector2(0, 2), Vector2(0, -3), Vector2.ZERO],
		&"heavy": [Vector2.ZERO, Vector2(0, -5), Vector2(0, 4), Vector2.ZERO],
		&"parry": [Vector2.ZERO, Vector2(0, -2), Vector2.ZERO],
		&"skill": [Vector2.ZERO, Vector2(0, 5), Vector2(0, -9), Vector2.ZERO],
		&"hurt": [Vector2.ZERO, Vector2(0, 4), Vector2.ZERO],
		&"death": [Vector2.ZERO, Vector2(0, 5), Vector2.ZERO],
	}
	for animation_name: StringName in definitions:
		var animation := Animation.new()
		animation.length = maxf(_duration_for(animation_name), 0.01)
		animation.loop_mode = Animation.LOOP_LINEAR if animation_name in [&"idle", &"run"] else Animation.LOOP_NONE
		var track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath("CharacterVisual:position"))
		animation.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)
		var offsets: Array = definitions[animation_name]
		for index in range(offsets.size()):
			var key_time := animation.length * index / maxf(offsets.size() - 1, 1)
			animation.track_insert_key(track, key_time, offsets[index])
		library.add_animation(animation_name, animation)
	secondary_animation.add_animation_library(&"", library)
