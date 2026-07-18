extends SceneTree

const TEST_SCENE := preload("res://scenes/sideview/SideViewAnimationTest.tscn")
const ARTIFACT_DIR := "res://playtest_artifacts/sideview_foundation"

var _failures := 0
var _scene: Node
var _player: PlayerSideViewController


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_scene = TEST_SCENE.instantiate()
	root.add_child(_scene)
	_player = _scene.get_node("SideViewPlayer")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ARTIFACT_DIR))
	await _wait_frames(5)

	_check_animation_rates()
	_check_separate_weapon()
	await _capture("idle")

	var start_x := _player.global_position.x
	Input.action_press("move_right")
	await create_timer(0.28).timeout
	Input.action_release("move_right")
	_expect(_player.global_position.x > start_x + 20.0, "A/D movement advances the CharacterBody2D")
	await _capture("run")

	await _trigger_and_capture("light_attack", "normal", 0.12)
	await create_timer(0.35).timeout
	await _trigger_and_capture("heavy_attack", "heavy", 0.20)
	await create_timer(0.55).timeout
	await _trigger_and_capture("parry", "parry", 0.10)
	await create_timer(0.32).timeout
	await _trigger_and_capture("ash_burst", "skill", 0.15)
	await create_timer(0.24).timeout

	Input.action_press("move_left")
	await create_timer(0.10).timeout
	Input.action_release("move_left")
	_expect(_player.get_node("VisualRoot").scale.x < 0.0, "Left movement flips character and weapon root")

	if _failures == 0:
		print("SIDEVIEW FOUNDATION: PASS")
	else:
		print("SIDEVIEW FOUNDATION: FAIL (%d)" % _failures)
	quit(_failures)


func _check_animation_rates() -> void:
	var body: AnimatedSprite2D = _player.get_node("VisualRoot/Body")
	for animation in body.sprite_frames.get_animation_names():
		var fps := body.sprite_frames.get_animation_speed(animation)
		_expect(fps >= 12.0, "%s animation runs at %.2f FPS" % [animation, fps])
	_expect(is_equal_approx(body.sprite_frames.get_animation_speed(&"skill"), 24.0), "Skill animation runs at 24 FPS")


func _check_separate_weapon() -> void:
	var body: AnimatedSprite2D = _player.get_node("VisualRoot/Body")
	var weapon: Sprite2D = _player.get_node("VisualRoot/WeaponSocket/WeaponVisual")
	_expect(body != weapon, "Character and weapon are separate render nodes")
	_expect(weapon.texture != null, "Starter longsword texture is loaded")


func _trigger_and_capture(action: StringName, expected_animation: StringName, delay: float) -> void:
	Input.action_press(action)
	await physics_frame
	Input.action_release(action)
	await create_timer(delay).timeout
	var body: AnimatedSprite2D = _player.get_node("VisualRoot/Body")
	_expect(body.animation == expected_animation, "%s input plays %s animation" % [action, expected_animation])
	await _capture(expected_animation)


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [ARTIFACT_DIR, name]
	var error := image.save_png(ProjectSettings.globalize_path(path))
	_expect(error == OK, "Captured %s visual frame" % name)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
	else:
		_failures += 1
		push_error("FAIL: " + message)
