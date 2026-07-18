class_name WeaponVisual
extends Sprite2D

const WEAPON_TEXTURE := preload("res://assets/sprites/sideview/weapons/starter_longsword.png")

func _ready() -> void:
	texture = WEAPON_TEXTURE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	# The image center is above the leather grip, so this places the grip on WeaponPivot.
	position = Vector2(0, -64)


func set_action(action: StringName) -> void:
	if action == &"skill":
		modulate = Color(1.18, 0.82, 0.56, 1.0)
	elif action == &"parry":
		modulate = Color(1.22, 1.18, 1.05, 1.0)
	else:
		modulate = Color.WHITE
