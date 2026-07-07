extends Control

@onready var _start_button: Button = %StartButton
@onready var _build_label: Label = %BuildLabel

func _ready() -> void:
	_start_button.grab_focus()
	_build_label.text = BuildInfo.label()


func _draw() -> void:
	var rect := get_viewport_rect()
	draw_rect(rect, Color("#121018"))
	for i in 18:
		var t := float(i) / 18.0
		var y := rect.size.y * t
		draw_line(Vector2(0, y), Vector2(rect.size.x, y + 90.0), Color(0.18, 0.15, 0.16, 0.18), 3.0)
	draw_circle(rect.size * Vector2(0.5, 0.56), 240.0, Color(0.50, 0.23, 0.12, 0.08))


func _on_start_button_pressed() -> void:
	SceneFlow.start_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
