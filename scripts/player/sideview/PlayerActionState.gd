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
var _locomotion_requested := false
var _buffered_state: StringName = &""
var _buffered_duration := 0.0
var _review_mode := false


func _physics_process(delta: float) -> void:
	if _review_mode:
		return
	if _remaining <= 0.0:
		return
	_remaining = maxf(0.0, _remaining - delta)
	if is_zero_approx(_remaining) and current != DEATH:
		if not _buffered_state.is_empty():
			var next_state := _buffered_state
			var next_duration := _buffered_duration
			_clear_buffer()
			_begin_action(next_state, next_duration)
		else:
			_set_state(RUN if _locomotion_requested else IDLE)


func request_action(next_state: StringName, duration: float, buffer_window: float) -> bool:
	if is_action_locked():
		if current != DEATH and _remaining <= buffer_window:
			_buffered_state = next_state
			_buffered_duration = maxf(duration, 0.01)
			return true
		return false
	_begin_action(next_state, duration)
	return true


func set_locomotion(moving: bool) -> void:
	_locomotion_requested = moving
	if is_action_locked():
		return
	_set_state(RUN if moving else IDLE)


func is_action_locked() -> bool:
	return current not in [IDLE, RUN]


func remaining_time() -> float:
	return _remaining


func buffered_action() -> StringName:
	return _buffered_state


func set_review_mode(enabled: bool) -> void:
	_review_mode = enabled
	_remaining = 0.0
	_clear_buffer()
	if not enabled:
		_set_state(RUN if _locomotion_requested else IDLE)


func _begin_action(next_state: StringName, duration: float) -> void:
	_remaining = maxf(duration, 0.01)
	_set_state(next_state)


func _clear_buffer() -> void:
	_buffered_state = &""
	_buffered_duration = 0.0


func _set_state(next_state: StringName) -> void:
	if current == next_state:
		return
	var previous := current
	current = next_state
	state_changed.emit(previous, current)
