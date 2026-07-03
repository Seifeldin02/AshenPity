extends Control

@onready var _return_button: Button = %ReturnButton

func _ready() -> void:
	_return_button.grab_focus()


func _draw() -> void:
	var rect := get_viewport_rect()
	draw_rect(rect, Color("#121018"))
	draw_circle(rect.size * Vector2(0.5, 0.48), 260.0, Color(0.76, 0.49, 0.22, 0.10))
	for i in 9:
		var angle := TAU * float(i) / 9.0
		var center := rect.size * 0.5 + Vector2.RIGHT.rotated(angle) * 160.0
		draw_circle(center, 9.0, Color(0.85, 0.67, 0.42, 0.22))


func _on_return_button_pressed() -> void:
	SceneFlow.go_to_title()
