class_name WeaponVisual
extends Sprite2D

const WEAPON_TEXTURE := preload("res://assets/sprites/sideview/weapons/starter_longsword.png")

var _action: StringName = &"idle"
var _ghost: Sprite2D


func _ready() -> void:
	texture = WEAPON_TEXTURE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	position = Vector2(0, -91)
	_ghost = Sprite2D.new()
	_ghost.texture = WEAPON_TEXTURE
	_ghost.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_ghost.modulate = Color(1.0, 0.58, 0.26, 0.0)
	add_child(_ghost)


func _process(_delta: float) -> void:
	var active := _action in [&"normal", &"heavy", &"skill"]
	_ghost.modulate.a = 0.20 + sin(Time.get_ticks_msec() * 0.018) * 0.06 if active else 0.0


func set_action(action: StringName) -> void:
	_action = action
	if action == &"skill":
		modulate = Color(1.18, 0.82, 0.56, 1.0)
	elif action == &"parry":
		modulate = Color(1.22, 1.18, 1.05, 1.0)
	else:
		modulate = Color.WHITE
