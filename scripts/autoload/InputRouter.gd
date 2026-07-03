extends Node

signal mobile_visibility_changed(visible: bool)

var touch_move_vector := Vector2.ZERO
var touch_aim_vector := Vector2.ZERO
var touch_active := false
var mobile_controls_visible := false

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
