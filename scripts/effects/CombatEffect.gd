extends Node2D

var kind := "spark"
var direction := Vector2.RIGHT
var lifetime := 0.22
var color := Color("#f0b15e")

var _age := 0.0

static func spawn(parent: Node, position_value: Vector2, effect_kind: String, facing: Vector2 = Vector2.RIGHT, tint: Color = Color("#f0b15e")) -> Node2D:
	var effect := Node2D.new()
	effect.set_script(load("res://scripts/effects/CombatEffect.gd"))
	effect.global_position = position_value
	effect.set("kind", effect_kind)
	effect.set("direction", facing.normalized() if facing.length() > 0.001 else Vector2.RIGHT)
	effect.set("color", tint)
	parent.add_child(effect)
	return effect


func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var t := clampf(_age / lifetime, 0.0, 1.0)
	var alpha := 1.0 - t
	match kind:
		"spark":
			_draw_sparks(alpha)
		"heavy":
			_draw_burst(alpha, 70.0, Color(1.0, 0.45, 0.18, alpha * 0.65))
		"collect":
			_draw_cross_cut(alpha)
		"brand":
			_draw_burst(alpha, 48.0, Color(1.0, 0.38, 0.16, alpha * 0.55))
		"perfect":
			_draw_ring(alpha, 58.0, Color(0.90, 0.84, 0.60, alpha * 0.72))
		"death":
			_draw_burst(alpha, 92.0, Color(0.60, 0.50, 0.40, alpha * 0.48))
		_:
			_draw_sparks(alpha)


func _draw_sparks(alpha: float) -> void:
	for i in 7:
		var angle := direction.angle() + lerpf(-1.0, 1.0, float(i) / 6.0)
		var length := 18.0 + float(i % 3) * 10.0
		var start := Vector2.RIGHT.rotated(angle) * 10.0
		var end := Vector2.RIGHT.rotated(angle) * length
		draw_line(start, end, _with_alpha(color, alpha * 0.72), 3.0)


func _draw_burst(alpha: float, radius: float, tint: Color) -> void:
	draw_circle(Vector2.ZERO, radius * (1.0 - alpha * 0.45), tint)
	_draw_ring(alpha, radius, tint.lightened(0.35))


func _draw_ring(alpha: float, radius: float, tint: Color) -> void:
	draw_arc(Vector2.ZERO, radius * (1.0 + (1.0 - alpha) * 0.45), 0.0, TAU, 42, _with_alpha(tint, alpha), 5.0)


func _draw_cross_cut(alpha: float) -> void:
	var angle := direction.angle()
	for offset in [-0.28, 0.28]:
		var dir := Vector2.RIGHT.rotated(angle + offset)
		draw_line(-dir * 74.0, dir * 74.0, Color(1.0, 0.78, 0.42, alpha * 0.88), 9.0)
		draw_line(-dir * 42.0, dir * 92.0, Color(0.95, 0.24, 0.12, alpha * 0.52), 4.0)


func _with_alpha(source: Color, alpha: float) -> Color:
	return Color(source.r, source.g, source.b, alpha)
