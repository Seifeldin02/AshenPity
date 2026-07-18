extends SceneTree

const TEST_SCENE := preload("res://scenes/sideview/SideViewAnimationTest.tscn")
const ARTIFACT_DIR := "res://playtest_artifacts/sideview_animation_rebuild"
const EXPECTED_FRAMES := {
	&"idle": 4,
	&"run": 8,
	&"normal": 7,
	&"heavy": 8,
	&"parry": 6,
	&"skill": 8,
	&"hurt": 2,
	&"death": 6,
}
const EXPECTED_FPS := {
	&"idle": 14.0,
	&"run": 24.0,
	&"normal": 24.0,
	&"heavy": 24.0,
	&"parry": 24.0,
	&"skill": 28.0,
	&"hurt": 24.0,
	&"death": 24.0,
}

var _failures := 0
var _scene: Node
var _player: PlayerSideViewController
var _animation: PlayerAnimationController
var _body: AnimatedSprite2D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_scene = TEST_SCENE.instantiate()
	root.add_child(_scene)
	_player = _scene.get_node("SideViewPlayer")
	_animation = _player.get_node("AnimationController")
	_body = _player.get_node("CharacterVisual/Body")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ARTIFACT_DIR))
	await _wait_frames(5)

	_check_configuration()
	_check_separate_weapon_hierarchy()
	_check_review_overlay_is_hidden()
	await _check_locomotion_and_facing()
	await _check_action_buffering()
	await _review_every_animation()

	if _failures == 0:
		print("SIDEVIEW ANIMATION REBUILD: PASS")
	else:
		print("SIDEVIEW ANIMATION REBUILD: FAIL (%d)" % _failures)
	quit(_failures)


func _check_configuration() -> void:
	_expect(
		ProjectSettings.get_setting("physics/common/physics_ticks_per_second") == 120,
		"Physics remains configured for 120 ticks per second"
	)
	for animation: StringName in EXPECTED_FRAMES:
		_expect(
			_body.sprite_frames.get_frame_count(animation) == EXPECTED_FRAMES[animation],
			"%s uses %d unique source frames" % [animation, EXPECTED_FRAMES[animation]]
		)
		_expect(
			is_equal_approx(_body.sprite_frames.get_animation_speed(animation), EXPECTED_FPS[animation]),
			"%s plays at %.0f FPS" % [animation, EXPECTED_FPS[animation]]
		)


func _check_separate_weapon_hierarchy() -> void:
	var weapon := _player.get_node("CharacterVisual/WeaponSocket/WeaponPivot/WeaponVisual") as Sprite2D
	var blade_tip := _player.get_node("CharacterVisual/WeaponSocket/WeaponPivot/BladeTip") as Marker2D
	_expect(_body != weapon, "Character and starter sword are separate render nodes")
	_expect(weapon.texture != null, "Starter sword texture is loaded")
	_expect(blade_tip != null, "Blade tip is attached below the grip-centered weapon pivot")
	_expect(_player.has_node("AnimationPlayer"), "Secondary motion has a dedicated AnimationPlayer")


func _check_review_overlay_is_hidden() -> void:
	var panel := _scene.get_node("AnimationReview/ReviewPanel") as Control
	_expect(not panel.visible, "Animation review information is hidden during normal play")


func _check_locomotion_and_facing() -> void:
	var start_x := _player.global_position.x
	Input.action_press("move_right")
	await create_timer(0.24).timeout
	Input.action_release("move_right")
	_expect(_player.global_position.x > start_x + 20.0, "Frame-independent movement advances the CharacterBody2D")
	_expect(_body.animation == &"run", "Movement selects run without restarting action states")
	Input.action_press("move_left")
	await create_timer(0.10).timeout
	Input.action_release("move_left")
	_expect(_player.get_node("CharacterVisual").scale.x < 0.0, "Facing flips the complete body and weapon hierarchy")


func _check_action_buffering() -> void:
	await create_timer(0.20).timeout
	Input.action_press("light_attack")
	await _wait_physics_frames(2)
	Input.action_release("light_attack")
	_expect(_body.animation == &"normal", "Normal attack starts once")
	await create_timer(0.25).timeout
	Input.action_press("heavy_attack")
	await _wait_physics_frames(2)
	Input.action_release("heavy_attack")
	var state: PlayerActionState = _player.get_node("AnimationStateController")
	_expect(state.buffered_action() == &"heavy", "Late recovery input buffers the next action")
	await create_timer(0.12).timeout
	_expect(_body.animation == &"heavy", "Buffered heavy begins after normal recovery")
	await create_timer(0.58).timeout


func _review_every_animation() -> void:
	_player.set_animation_review_mode(true)
	for speed in [1.0, 0.25]:
		_animation.set_review_speed(speed)
		for animation: StringName in EXPECTED_FRAMES:
			_animation.play_review_animation(animation)
			await create_timer(0.12 / speed).timeout
			_expect(_body.animation == animation, "%s review plays at %.2fx" % [animation, speed])
			await _capture("%s_%s" % [animation, "normal" if speed == 1.0 else "quarter"])
	_player.set_animation_review_mode(false)


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [ARTIFACT_DIR, name]
	var error := image.save_png(ProjectSettings.globalize_path(path))
	_expect(error == OK, "Captured %s visual review frame" % name)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame


func _wait_physics_frames(count: int) -> void:
	for _index in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
	else:
		_failures += 1
		push_error("FAIL: " + message)
