class_name AnimationReviewController
extends CanvasLayer

const REVIEW_KEYS := {
	KEY_1: &"idle",
	KEY_2: &"run",
	KEY_3: &"normal",
	KEY_4: &"heavy",
	KEY_5: &"parry",
	KEY_6: &"skill",
}

@export var player_path: NodePath

@onready var player: PlayerSideViewController = get_node(player_path)
@onready var animation_controller: PlayerAnimationController = player.get_node("AnimationController")
@onready var panel: Control = %ReviewPanel
@onready var readout: Label = %ReviewReadout

var _active := false
var _weapon_debug := false


func _ready() -> void:
	panel.visible = false


func _process(_delta: float) -> void:
	if not _active:
		return
	readout.text = (
		"ANIMATION LAB\n"
		+ "Animation  %s\n" % animation_controller.current_animation()
		+ "Frame      %d\n" % animation_controller.current_frame()
		+ "Source FPS %.0f\n" % animation_controller.current_animation_fps()
		+ "Playback   %.2fx%s\n" % [
			animation_controller.review_speed(),
			"  PAUSED" if animation_controller.review_paused() else "",
		]
		+ "State      %s\n\n" % animation_controller.current_state()
		+ "1 Idle   2 Run   3 Normal   4 Heavy   5 Parry   6 Cross-Cut\n"
		+ "7 0.25x   8 0.5x   9 1x   P Pause   Left/Right Step   V Socket"
	)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F2:
		_set_active(not _active)
		get_viewport().set_input_as_handled()
		return
	if not _active:
		return
	if REVIEW_KEYS.has(event.keycode):
		animation_controller.play_review_animation(REVIEW_KEYS[event.keycode])
	elif event.keycode == KEY_P:
		animation_controller.toggle_review_pause()
	elif event.keycode == KEY_LEFT:
		animation_controller.step_review_frame(-1)
	elif event.keycode == KEY_RIGHT:
		animation_controller.step_review_frame(1)
	elif event.keycode == KEY_7:
		animation_controller.set_review_speed(0.25)
	elif event.keycode == KEY_8:
		animation_controller.set_review_speed(0.5)
	elif event.keycode == KEY_9:
		animation_controller.set_review_speed(1.0)
	elif event.keycode == KEY_V:
		_weapon_debug = not _weapon_debug
		animation_controller.set_weapon_debug_visible(_weapon_debug)
	else:
		return
	get_viewport().set_input_as_handled()


func _set_active(enabled: bool) -> void:
	_active = enabled
	panel.visible = enabled
	player.set_animation_review_mode(enabled)
	if not enabled:
		_weapon_debug = false
		animation_controller.set_weapon_debug_visible(false)
