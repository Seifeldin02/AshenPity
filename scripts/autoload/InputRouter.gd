extends Node

signal mobile_visibility_changed(visible: bool)

const CombatMathUtil := preload("res://scripts/combat/CombatMath.gd")

var touch_move_vector := Vector2.ZERO
var touch_aim_vector := Vector2.ZERO
var touch_active := false
var mobile_controls_visible := false
var simulation_enabled := false
var simulated_move_vector := Vector2.ZERO
var simulated_aim_vector := Vector2.ZERO

var _attack_pressed := false
var _dodge_pressed := false
var _flask_pressed := false
var _pause_pressed := false

func _ready() -> void:
	mobile_controls_visible = DisplayServer.is_touchscreen_available()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mobile"):
		set_mobile_controls_visible(not mobile_controls_visible)


func set_mobile_controls_visible(value: bool) -> void:
	if mobile_controls_visible == value:
		return
	mobile_controls_visible = value
	mobile_visibility_changed.emit(value)


func begin_simulation() -> void:
	simulation_enabled = true
	simulated_move_vector = Vector2.ZERO
	simulated_aim_vector = Vector2.ZERO
	touch_move_vector = Vector2.ZERO
	touch_aim_vector = Vector2.ZERO
	touch_active = false


func end_simulation() -> void:
	simulation_enabled = false
	simulated_move_vector = Vector2.ZERO
	simulated_aim_vector = Vector2.ZERO
	_attack_pressed = false
	_dodge_pressed = false
	_flask_pressed = false
	_pause_pressed = false


func set_simulated_input(move_vector: Vector2, aim_vector: Vector2) -> void:
	simulated_move_vector = CombatMathUtil.normalized_input(move_vector)
	simulated_aim_vector = aim_vector.normalized() if aim_vector.length() > 0.001 else Vector2.ZERO


func get_move_vector() -> Vector2:
	var keyboard := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var mixed := keyboard + touch_move_vector
	if simulation_enabled:
		mixed += simulated_move_vector
	return CombatMathUtil.normalized_input(mixed)


func get_aim_direction(actor_position: Vector2, mouse_world_position: Vector2, fallback: Vector2) -> Vector2:
	if simulation_enabled and simulated_aim_vector.length() > 0.001:
		return simulated_aim_vector.normalized()
	if touch_aim_vector.length() >= 0.12:
		return touch_aim_vector.normalized()
	return CombatMathUtil.aim_direction_from_world(actor_position, mouse_world_position, fallback)


func press_attack() -> void:
	_attack_pressed = true


func press_dodge() -> void:
	_dodge_pressed = true


func press_flask() -> void:
	_flask_pressed = true


func press_pause() -> void:
	_pause_pressed = true


func consume_attack() -> bool:
	return _consume("_attack_pressed")


func consume_dodge() -> bool:
	return _consume("_dodge_pressed")


func consume_flask() -> bool:
	return _consume("_flask_pressed")


func consume_pause() -> bool:
	return _consume("_pause_pressed")


func _consume(property_name: StringName) -> bool:
	var value: bool = get(property_name)
	if value:
		set(property_name, false)
	return value
