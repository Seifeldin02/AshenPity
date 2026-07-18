class_name PlayerAnimationController
extends Node

const CHARACTER_ROOT := "res://assets/sprites/sideview/wanderer/"
const EFFECT_ROOT := "res://assets/effects/sideview/ash_crosscut/"
const FRAME_COUNTS := {
	&"idle": 4,
	&"run": 6,
	&"normal": 6,
	&"heavy": 7,
	&"parry": 5,
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

@onready var action_state: PlayerActionState = %ActionState
@onready var visual_root: Node2D = %VisualRoot
@onready var body: AnimatedSprite2D = %Body
@onready var weapon_socket: WeaponSocket = %WeaponSocket
@onready var weapon_visual: WeaponVisual = %WeaponVisual
@onready var skill_effect: AnimatedSprite2D = %SkillEffect


func _ready() -> void:
	body.sprite_frames = _build_character_frames()
	skill_effect.sprite_frames = _build_effect_frames()
	action_state.state_changed.connect(_on_state_changed)
	visual_root.scale = Vector2(visual_scale, visual_scale)
	_on_state_changed(&"", PlayerActionState.IDLE)


func _process(_delta: float) -> void:
	weapon_socket.apply_pose(body.animation, body.frame)


func request_action(action: StringName) -> bool:
	var duration := _duration_for(action)
	return action_state.request_action(action, duration)


func set_locomotion(moving: bool) -> void:
	action_state.set_locomotion(moving)


func set_facing(direction: float) -> void:
	if is_zero_approx(direction):
		return
	visual_root.scale.x = visual_scale * signf(direction)


func is_action_locked() -> bool:
	return action_state.is_action_locked()


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


func _on_state_changed(_previous: StringName, current: StringName) -> void:
	body.play(current)
	weapon_visual.set_action(current)
	if current == PlayerActionState.SKILL:
		skill_effect.visible = true
		skill_effect.play(&"ash_crosscut")
	else:
		skill_effect.stop()
		skill_effect.visible = false


func _build_character_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation: StringName in FRAME_COUNTS:
		frames.add_animation(animation)
		frames.set_animation_loop(animation, animation in [&"idle", &"run"])
		frames.set_animation_speed(animation, _fps_for(animation))
		var prefix: String = FILE_PREFIX[animation]
		for frame_index in range(FRAME_COUNTS[animation]):
			frames.add_frame(animation, load(CHARACTER_ROOT + "%s_%02d.png" % [prefix, frame_index]))
	frames.add_animation(&"hurt")
	frames.set_animation_loop(&"hurt", false)
	frames.set_animation_speed(&"hurt", 12.0)
	frames.add_frame(&"hurt", load(CHARACTER_ROOT + "death_00.png"))
	frames.add_frame(&"hurt", load(CHARACTER_ROOT + "death_01.png"))
	frames.add_frame(&"hurt", load(CHARACTER_ROOT + "death_00.png"))
	return frames


func _build_effect_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"ash_crosscut")
	frames.set_animation_loop(&"ash_crosscut", false)
	frames.set_animation_speed(&"ash_crosscut", 24.0)
	for frame_index in range(6):
		frames.add_frame(&"ash_crosscut", load(EFFECT_ROOT + "ash_crosscut_%02d.png" % frame_index))
	return frames


func _fps_for(animation: StringName) -> float:
	match animation:
		&"idle":
			return tuning.idle_fps
		&"run":
			return tuning.run_fps
		&"normal":
			return maxf(12.0, FRAME_COUNTS[animation] / tuning.normal_attack_duration)
		&"heavy":
			return maxf(12.0, FRAME_COUNTS[animation] / tuning.heavy_attack_duration)
		&"parry":
			return maxf(12.0, FRAME_COUNTS[animation] / tuning.parry_duration)
		&"skill":
			return 24.0
		&"death":
			return maxf(12.0, FRAME_COUNTS[animation] / tuning.death_duration)
		_:
			return 12.0


func _duration_for(action: StringName) -> float:
	match action:
		PlayerActionState.NORMAL:
			return tuning.normal_attack_duration
		PlayerActionState.HEAVY:
			return tuning.heavy_attack_duration
		PlayerActionState.PARRY:
			return tuning.parry_duration
		PlayerActionState.SKILL:
			return tuning.skill_duration
		PlayerActionState.HURT:
			return tuning.hurt_duration
		PlayerActionState.DEATH:
			return tuning.death_duration
		_:
			return 0.01
