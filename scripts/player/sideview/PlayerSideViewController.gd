class_name PlayerSideViewController
extends CharacterBody2D

@export var tuning: SideViewAnimationTuning

@onready var animation_controller: PlayerAnimationController = %AnimationController

var _review_mode := false


func _physics_process(delta: float) -> void:
	if _review_mode:
		velocity = Vector2.ZERO
		return
	_handle_actions()
	var input_axis := _movement_axis()
	if not animation_controller.is_action_locked() and not is_zero_approx(input_axis):
		animation_controller.set_facing(input_axis)
	var target_speed := input_axis * tuning.movement_speed * animation_controller.movement_scale()
	var rate := tuning.acceleration if not is_zero_approx(target_speed) else tuning.deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)
	velocity.y = 0.0
	move_and_slide()
	global_position.x = clampf(global_position.x, tuning.world_min_x, tuning.world_max_x)
	animation_controller.set_locomotion(absf(velocity.x) > 8.0)


func set_animation_review_mode(enabled: bool) -> void:
	_review_mode = enabled
	velocity = Vector2.ZERO
	animation_controller.set_review_mode(enabled)


func _handle_actions() -> void:
	if Input.is_action_just_pressed("ash_burst"):
		animation_controller.request_action(PlayerActionState.SKILL)
	elif Input.is_action_just_pressed("parry"):
		animation_controller.request_action(PlayerActionState.PARRY)
	elif Input.is_action_just_pressed("heavy_attack"):
		animation_controller.request_action(PlayerActionState.HEAVY)
	elif Input.is_action_just_pressed("light_attack"):
		animation_controller.request_action(PlayerActionState.NORMAL)


func _movement_axis() -> float:
	var axis := Input.get_axis("move_left", "move_right")
	if Input.is_key_pressed(KEY_LEFT):
		axis -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		axis += 1.0
	return clampf(axis, -1.0, 1.0)
