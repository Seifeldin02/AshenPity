class_name PlayerActionState
extends Node

signal state_changed(previous: StringName, current: StringName)

const IDLE := &"idle"
const RUN := &"run"
const NORMAL := &"normal"
const HEAVY := &"heavy"
const PARRY := &"parry"
const SKILL := &"skill"
const HURT := &"hurt"
const DEATH := &"death"

var current: StringName = IDLE
var _remaining := 0.0


func _physics_process(delta: float) -> void:
	if _remaining <= 0.0:
		return
	_remaining = maxf(0.0, _remaining - delta)
	if is_zero_approx(_remaining) and current != DEATH:
		_set_state(IDLE)


func request_action(next_state: StringName, duration: float) -> bool:
	if is_action_locked():
		return false
	_remaining = maxf(duration, 0.01)
	_set_state(next_state)
	return true


func set_locomotion(moving: bool) -> void:
	if is_action_locked():
		return
	_set_state(RUN if moving else IDLE)


func is_action_locked() -> bool:
	return current not in [IDLE, RUN]


func _set_state(next_state: StringName) -> void:
	if current == next_state:
		return
	var previous := current
	current = next_state
	state_changed.emit(previous, current)
