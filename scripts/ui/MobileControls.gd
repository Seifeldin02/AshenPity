extends CanvasLayer

@onready var root: Control = %Root
@onready var move_knob: Control = %MoveKnob
@onready var aim_ring: Control = %AimRing
@onready var aim_knob: Control = %AimKnob
@onready var collect_button: Button = %CollectButton

var _move_touch := -1
var _aim_touch := -1
var _move_center := Vector2.ZERO
var _aim_center := Vector2.ZERO
const STICK_RADIUS := 86.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = InputRouter.mobile_controls_visible
	InputRouter.mobile_visibility_changed.connect(_on_mobile_visibility_changed)
	get_viewport().size_changed.connect(_update_centers)
	_update_centers.call_deferred()


func _process(_delta: float) -> void:
	collect_button.visible = InputRouter.collect_available


func _unhandled_input(event: InputEvent) -> void:
	if not root.visible:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if event.position.x < get_viewport().get_visible_rect().size.x * 0.42 and _move_touch == -1:
			_move_touch = event.index
			_update_move(event.position)
		elif event.position.x > get_viewport().get_visible_rect().size.x * 0.52 and _aim_touch == -1:
			_aim_touch = event.index
			_update_aim(event.position)
	else:
		if event.index == _move_touch:
			_move_touch = -1
			InputRouter.touch_move_vector = Vector2.ZERO
			move_knob.position = Vector2.ZERO
		if event.index == _aim_touch:
			_aim_touch = -1
			InputRouter.touch_aim_vector = Vector2.ZERO
			aim_knob.position = Vector2.ZERO
		InputRouter.touch_active = _move_touch != -1 or _aim_touch != -1


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == _move_touch:
		_update_move(event.position)
	elif event.index == _aim_touch:
		_update_aim(event.position)


func _update_move(position: Vector2) -> void:
	var vector := (position - _move_center).limit_length(STICK_RADIUS)
	InputRouter.touch_move_vector = vector / STICK_RADIUS
	move_knob.position = vector
	InputRouter.touch_active = true


func _update_aim(position: Vector2) -> void:
	var vector := (position - _aim_center).limit_length(STICK_RADIUS)
	InputRouter.touch_aim_vector = (vector / STICK_RADIUS).normalized() if vector.length() > 8.0 else Vector2.ZERO
	aim_knob.position = vector
	InputRouter.touch_active = true


func _update_centers() -> void:
	var size := get_viewport().get_visible_rect().size
	_move_center = Vector2(160, size.y - 165)
	_aim_center = Vector2(size.x - 280, size.y - 165)
	aim_ring.global_position = _aim_center


func _on_mobile_visibility_changed(value: bool) -> void:
	root.visible = value


func _on_attack_pressed() -> void:
	InputRouter.press_attack()


func _on_heavy_pressed() -> void:
	InputRouter.press_heavy()


func _on_collect_pressed() -> void:
	InputRouter.press_collect()


func _on_ash_burst_pressed() -> void:
	InputRouter.press_ash_burst()


func _on_parry_pressed() -> void:
	InputRouter.press_parry()


func _on_dodge_pressed() -> void:
	InputRouter.press_dodge()


func _on_flask_pressed() -> void:
	InputRouter.press_flask()


func _on_pause_pressed() -> void:
	InputRouter.press_pause()
